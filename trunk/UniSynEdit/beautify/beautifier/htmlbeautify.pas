{

 Style HTML
---------------

  Delphi port by Mihail Slobodyanuk, <slobodyanukma@gmail.com>
  Written by Nochum Sossonko, (nsossonko@hotmail.com)

  Based on code initially developed by: Einar Lielmanis, <elfz@laacz.lv>
    http://jsbeautifier.org

  You are free to use this in any way you want, in case you find this useful or working for you.

  Usage:
    style_html(html_source);
    style_html(html_source, indent_size, indent_character, max_char);

}
unit htmlbeautify;

interface

function html_beautify(html_source: string;
  indent_size: integer = 4;
  indent_character: char = ' ';
  max_char: integer = 80;
  doHTML: Boolean = True;
  doJavaScript: Boolean = True;
  doCSS: Boolean = True
  ): string;

implementation
uses functions, classes, SysUtils, StrUtils, jsbeautify, cssbeautify;

type
  TToken = record
    ttype: string;
    value: string;
  end;

  TTags = class(TStringList)
  private
    function GetiValue(const Name: string): integer;
    procedure SetiValue(const Name: string; Value: integer);
    property Ivalues[const Name: string]: integer read GetIvalue write
    SetIvalue;
    procedure Delete(key: string); reintroduce; overload;
  end;

  Thtml_beautify = class
    input, lowerinput: string;
    indent_level, line_char_count: integer;
    parser_pos: Integer; //Parser position
    current_mode, tag_type, last_token, last_text, token_type,
      token_text, indent_string: string;
    whitespace, single_token, extra_liners: TStringArray;
    output: TStringList;
    tags: TTags;

    opt: record
      indent_size: integer;
      indent_character: char;
      max_char: Integer;
      doHTML: Boolean;
      doJavaScript: Boolean;
      doCSS: Boolean;
    end;

    function getBeauty: string;
    function get_content: TToken;
    function get_script: TToken;
    function get_style: TToken;
    procedure record_tag(tag: string);
    procedure retrieve_tag(tag: string);
    function get_tag: TToken;
    function get_unformatted(delimiter: string; orig_tag: string = ''): string;
    function get_token: TToken;
    procedure print_newline(ignore: Boolean; arr: TStringList);
    procedure print_token(text: string);
    procedure indent;
    procedure unindent;
    constructor Create(Ahtml_source: string;
      Aindent_size: integer;
      Aindent_character: char;
      Amax_char: integer;
      AdoHTML: Boolean;
      AdoJavaScript: Boolean;
      AdoCSS: Boolean);
    destructor Destroy; override;
  end;

function html_beautify(html_source: string;
  indent_size: integer = 4;
  indent_character: char = ' ';
  max_char: integer = 80;
  doHTML: Boolean = True;
  doJavaScript: Boolean = True;
  doCSS: Boolean = True
  ): string;
var
  shtml: Thtml_beautify;
begin
  shtml := Thtml_beautify.Create(html_source, indent_size, indent_character,
    max_char, doHTML, doJavaScript, doCSS);
  result := shtml.getBeauty;
  shtml.Free;
end;

constructor Thtml_beautify.Create(Ahtml_source: string;
  Aindent_size: integer;
  Aindent_character: char;
  Amax_char: integer;
  AdoHTML: Boolean;
  AdoJavaScript: Boolean;
  AdoCSS: Boolean);
var
  i: Integer;
begin
  input := Ahtml_source;
  lowerinput := lowercase(Ahtml_source);
  opt.indent_size := Aindent_size;
  opt.indent_character := Aindent_character;
  opt.max_char := Amax_char;
  opt.doHTML := AdoHTML;
  opt.doJavaScript := AdoJavaScript;
  opt.doCSS := AdoCSS;
  parser_pos := 0;
  current_mode := 'CONTENT'; //reflects the current Parser mode: TAG/CONTENT
  tags := TTags.Create;
  tags.values['parent'] := 'parent1';
  //An object to hold tags, their position, and their parent-tags, initiated with default values
  tags.ivalues['parentcount'] := 1;
  tags.values['parent1'] := '';
  output := TStringList.Create();
  whitespace := split(#10#13#9' ');
  single_token :=
    split('br,input,link,meta,!doctype,basefont,base,area,hr,wbr,param,img,isindex,?xml,embed', ','); //all the single tags for HTML
  extra_liners := split('head,body,/html', ',');
  //for tags that need a line of whitespace before them
  indent_level := 0;
  line_char_count := 0; //count to see if max_char was exceeded

  for i := 0 to opt.indent_size - 1 do
  begin
    indent_string := indent_string + opt.indent_character;
  end;
end;

destructor Thtml_beautify.Destroy;
begin
  Output.free;
  tags.free;
end;

function Thtml_beautify.getBeauty: string;
  procedure onlyScriptAndStyle;
  var
    scriptPos, stylePos, closeTagPos, openTagPos: Integer;
    tag: string;
    content: string;
  begin
    parser_pos := 1;
    scriptPos := -1;
    stylePos := -1;

    while parser_pos <= Length(input)  do
    begin
      if scriptPos <> MAXINT then
        scriptPos := posex('<script', lowerinput, parser_pos);
      if stylePos <> MAXINT then
        stylePos := posex('<style', lowerinput, parser_pos);
      if scriptPos = 0 then
        scriptPos := MAXINT;
      if stylePos = 0 then
        stylePos := MAXINT;
      if (scriptPos <> MAXINT) or (stylePos <> MAXINT) then
      begin
        if scriptPos < stylePos then
        begin
          tag := 'script';
          openTagPos := scriptPos;
        end
        else
        begin
          tag := 'style';
          openTagPos := stylePos;
        end;
        while (input[openTagPos]<>'>') and (openTagPos<=Length(input)) do
          Inc(openTagPos);
        closeTagPos := posex('</' + tag + '>', lowerinput, openTagPos);
        if closeTagPos=0 then closeTagPos:=Length(input);
        content := Copy(input, openTagPos, closeTagPos - openTagPos);
        Output.Add(Copy(input, parser_pos, openTagPos - parser_pos));
        if scriptPos < stylePos then
          Output.Add(js_beautify(content, opt.indent_size, opt.indent_character))
        else
          output.add(css_beautify(content, opt.indent_size, opt.indent_character));
        parser_pos := closeTagPos;
        while (input[parser_pos]<>'>') and (parser_pos<=Length(input)) do
          Inc(parser_pos);
      end
      else
      begin
        Output.Add(Copy(input, parser_pos, Length(input)));
        Break;
      end;
    end;

  end;

var
  t: TToken;
begin
  if opt.doHTML then
    while (true) do
    begin
      t := get_token();
      token_text := t.value;
      token_type := t.ttype;

      if (token_type = 'TK_EOF') then
      begin
        break;
      end;

      if (token_type = 'TK_TAG_START') or (token_type = 'TK_TAG_SCRIPT') or
        (token_type = 'TK_TAG_STYLE') then
      begin
        print_newline(false, output);
        print_token(token_text);
        indent();
        current_mode := 'CONTENT';
      end
      else if (token_type = 'TK_TAG_END') then
      begin
        print_newline(true, output);
        print_token(token_text);
        current_mode := 'CONTENT';
      end
      else if (token_type = 'TK_TAG_SINGLE') then
      begin
        print_newline(false, output);
        print_token(token_text);
        current_mode := 'CONTENT';
      end
      else if (token_type = 'TK_CONTENT') then
      begin
        if (token_text <> '') then
        begin
          print_newline(false, output);
          print_token(token_text);
        end;
        current_mode := 'TAG';
      end;
      last_token := token_type;
      last_text := token_text;
    end
  else
    onlyScriptAndStyle;
  result := join(output);
end;

//function to capture regular content between tags

function Thtml_beautify.get_content: TToken;
var
  input_char: string;
  space: Boolean;
  content: TStringList;
  i: Integer;
label
  _exit;
begin
  content := TStringList.Create;
  space := false; //if a space is needed
  while (input[parser_pos + 1] <> '<') do
  begin
    if (parser_pos >= Length(input)) then
    begin
      if content.count > 0 then
        result.value := join(content)
      else
        result.ttype := 'TK_EOF';
      goto _exit;
    end;

    input_char := input[parser_pos + 1];
    inc(parser_pos);
    inc(line_char_count);

    if (in_array(input_char, whitespace)) then
    begin
      if (content.count > 0) then
      begin
        space := true;
      end;
      dec(line_char_count);
      continue; //don't want to insert unnecessary space
    end
    else if (space) then
    begin
      if (line_char_count >= opt.max_char) then
      begin //insert a line when the max_char is reached
        content.add(#10);
        for i := 0 to indent_level - 1 do
        begin
          content.add(indent_string);
        end;
        line_char_count := 0;
      end
      else
      begin
        content.add(' ');
        inc(line_char_count);
      end;
      space := false;
    end;
    content.add(input_char); //letter at-a-time (or string) inserted to an array
  end;
  if content.count > 0 then
    result.value := join(content)
  else
    result.value := '';
  _exit:
  content.free;
end;

function Thtml_beautify.get_script: TToken;
var
  input_char: string;
  content: TStringList;
  end_script: Integer;
label
  _exit;
begin //get the full content of a script to pass to js_beautify
  input_char := '';
  content := TStringList.Create;
  end_script := posex('</script>', lowerinput, parser_pos + 1);
  if end_script < 0 then
    end_script := Length(input);
  while (parser_pos < (end_script - 1)) do
  begin //get everything in between the script tags
    if (parser_pos >= Length(input)) then
    begin
      if content.Count > 0 then
        result.value := join(content)
      else
        Result.ttype := 'TK_EOF';
      goto _exit;
    end;

    input_char := input[parser_pos + 1];
    Inc(parser_pos);

    content.add(input_char);
  end;
  result.value := '';
  if content.Count > 0 then
    Result.value := join(content);
  //we might not have any content at all
  _exit:
  content.free;
end;

function Thtml_beautify.get_style: TToken;
var
  input_char: string;
  content: TStringList;
  end_script: Integer;
label
  _exit;
begin //get the full content of a style to pass to css beautify
  input_char := '';
  content := TStringList.Create;
  end_script := posex('</style>', lowerinput, parser_pos + 1);
  if end_script < 0 then
    end_script := Length(input);
  while (parser_pos < (end_script - 1)) do
  begin //get everything in between the style tags
    if (parser_pos >= Length(input)) then
    begin
      if content.Count > 0 then
        result.value := join(content)
      else
        Result.ttype := 'TK_EOF';
      goto _exit;
    end;

    input_char := input[parser_pos + 1];
    Inc(parser_pos);

    content.add(input_char);
  end;
  result.value := '';
  if content.Count > 0 then
    Result.value := join(content);
  //we might not have any content at all
  _exit:
  content.free;
end;

//function to record a tag and its parent in this.tags Object

procedure Thtml_beautify.record_tag(tag: string);
begin
  if (tags.values[tag + 'count']) <> '' then
  begin //check for the existence of this tag type
    tags.ivalues[tag + 'count'] := tags.ivalues[tag + 'count'] + 1;
    tags.ivalues[tag + tags.values[tag + 'count']] := indent_level;
    //and record the present indent level
  end
  else
  begin //otherwise initialize this tag type
    tags.values[tag + 'count'] := '1';
    tags.ivalues[tag + tags.values[tag + 'count']] := indent_level;
    //and record the present indent level
  end;
  tags.values[tag + tags.values[tag + 'count'] + 'parent'] :=
    tags.values['parent'];
  //set the parent (i.e. in the case of a div this.tags.div1parent)
  tags.values['parent'] := tag + tags.values[tag + 'count'];
  //and make this the current parent (i.e. in the case of a div 'div1')
end;

//function to retrieve the opening tag to the corresponding closer

procedure Thtml_beautify.retrieve_tag(tag: string);
var
  temp_parent: string;
begin
  if (tags.values[tag + 'count'] <> '') then
  begin //if the openener is not in the Object we ignore it
    temp_parent := tags.values['parent']; //check to see if it's a closable tag.
    while (temp_parent <> '') do
    begin //till we reach '' (the initial value);
      if (tag + tags.values[tag + 'count'] = temp_parent) then
      begin //if this is it use it
        break;
      end;
      temp_parent := tags.values[temp_parent + 'parent'];
      //otherwise keep on climbing up the DOM Tree
    end;
    if (temp_parent <> '') then
    begin //if we caught something
      indent_level := tags.ivalues[tag + tags.values[tag + 'count']];
      //set the indent_level accordingly
      tags.values['parent'] := tags.values[temp_parent + 'parent'];
      //and set the current parent
    end;
    tags.delete(tag + tags.values[tag + 'count'] + 'parent');
    //delete the closed tags parent reference...
    tags.delete(tag + tags.values[tag + 'count']); //...and the tag itself
    if (tags.ivalues[tag + 'count'] = 1) then
    begin
      tags.delete(tag + 'count');
    end
    else
    begin
      tags.ivalues[tag + 'count'] := tags.ivalues[tag + 'count'] - 1;
    end;
  end;
end;
//function to get a full tag and parse its type

function Thtml_beautify.get_tag: TToken;
var
  input_char: string;
  content: TStringList;
  space: Boolean;
  tag_complete: string;
  tag_index: integer;
  tag_check, comment: string;
  isPhp:Boolean;
label
  _exit;
begin
  content := TStringList.Create;
  space := false;
  isPhp := False;
  repeat
    if (parser_pos >= Length(input)) then
    begin
      if content.count > 0 then
        result.value := join(content)
      else
        result.ttype := 'TK_EOF';
      goto _exit;
    end;

    input_char := input[parser_pos + 1];
    inc(parser_pos);
    inc(line_char_count);
    if isPhp or ((content.count = 2) and (join(content)='<?')) then
    begin
      isPhp:=true;
      content.add(input_char);
      continue;
    end;

    if in_array(input_char, whitespace) then
    begin //don't want to insert unnecessary space
      if (content.count>1) then
      begin
        space := true;
        dec(line_char_count);
      end;
      continue;
    end;

    if (input_char = '''') or (input_char = '"') then
    begin
      if (content.count < 2) or (content.strings[1] = '') or (content.strings[1]
        <> '!') then
      begin //if we're in a comment strings don't get treated specially
        input_char := input_char + get_unformatted(input_char);
        space := true;
      end;
    end;

    if (input_char = '=') then
    begin //no space before =
      space := false;
    end;

    if (content.count > 0) and (content.strings[content.count - 1] <> '=') and
      (input_char <> '>') and space then
    begin //no space after = or before >
      if (line_char_count >= opt.max_char) then
      begin
        print_newline(false, content);
        line_char_count := 0;
      end
      else
      begin
        content.add(' ');
        inc(line_char_count);
      end;
    end;
    space := false;
    content.add(input_char); //inserts character at-a-time (or string)
  until input_char = '>';

  tag_complete := join(content);
  if (pos(' ', tag_complete) > 0) then
  begin //if there's whitespace, thats where the tag name ends
    tag_index := pos(' ', tag_complete);
  end
  else
  begin //otherwise go with the tag ending
    tag_index := pos('>', tag_complete);
  end;
  tag_check := lowercase(Copy(tag_complete, 2, tag_index - 2));
  if (Copy(tag_complete, length(tag_complete) - 1, 1) = '/') or
    in_array(tag_check, single_token) then
  begin //if this tag name is a single tag type (either in the list or has a closing /)
    tag_type := 'SINGLE';
  end
  else if (tag_check = 'script') then
  begin //for later script handling
    record_tag(tag_check);
    tag_type := 'SCRIPT';
  end
  else if (tag_check = 'style') then
  begin //for later style handling
    record_tag(tag_check);
    tag_type := 'STYLE';
  end
  else if (tag_check = 'a') then
  begin // do not reformat the <a> links
    comment := get_unformatted('</a>', tag_complete);
    //...delegate to get_unformatted function
    content.add(comment);
    tag_type := 'SINGLE';
  end
  else if (tag_check[1] = '!') then
  begin //peek for <!-- comment
    if (pos('[if', tag_check) > 0) then
    begin //peek for <!--[if conditional comment
      if (pos('!IE', tag_complete) > 0) then
      begin //this type needs a closing --> so...
        comment := get_unformatted('-->', tag_complete);
        //...delegate to get_unformatted
        content.add(comment);
      end;
      tag_type := 'START';
    end
    else if (pos('[endif', tag_check) > 0) then
    begin //peek for <!--[endif end conditional comment
      tag_type := 'END';
      unindent();
    end
    else if (pos('[cdata[', tag_check) > 0) then
    begin //if it's a <[cdata[ comment...
      comment := get_unformatted(']]>', tag_complete);
      //...delegate to get_unformatted function
      content.add(comment);
      tag_type := 'SINGLE'; //<![CDATA[ comments are treated like single tags
    end
    else
    begin
      comment := get_unformatted('-->', tag_complete);
      content.add(comment);
      tag_type := 'SINGLE';
    end;
  end
  else
  begin
    if (tag_check[1] = '/') then
    begin //this tag is a double tag so check for tag-ending
      retrieve_tag(Copy(tag_check, 2, Length(tag_check)));
      //remove it and all ancestors
      tag_type := 'END';
    end
    else
    begin //otherwise it's a start-tag
      record_tag(tag_check); //push it on the tag stack
      tag_type := 'START';
    end;
    if (in_array(tag_check, extra_liners)) then
    begin //check if this double needs an extra line
      print_newline(true, output);
    end;
  end;
  result.value := join(content); //returns fully formatted tag
  _exit:
  content.free;
end;

//function to return unformatted content in its entirety

function Thtml_beautify.get_unformatted(delimiter: string; orig_tag: string = ''):
  string;
var
  input_char: Char;
  content: string;
  space: Boolean;
  i: Integer;
begin

  if (orig_tag <> '') and (pos(delimiter, orig_tag) > 0) then
  begin
    result := '';
    Exit;
  end;
  space := true;
  repeat

    if (parser_pos >= Length(input)) then
    begin
      result := content;
      exit;
    end;

    input_char := input[parser_pos + 1];
    inc(parser_pos);

    if (in_array(input_char, whitespace)) then
    begin
      if (not space) then
      begin
        dec(line_char_count);
        continue;
      end;
      if (input_char = #10) or (input_char = #13) then
      begin
        content := content + #10;
        for i := 0 to indent_level - 1 do
        begin
          content := content + indent_string;
        end;
        space := false; //...and make sure other indentation is erased
        line_char_count := 0;
        continue;
      end;
    end;
    content := content + input_char;
    inc(line_char_count);
    space := true;
  until pos(delimiter, content) > 0;
  result := content;
end;

//initial handler for token-retrieval

function Thtml_beautify.get_token: TToken;
var
  token, temp_token: TToken;
begin
  if (last_token = 'TK_TAG_SCRIPT') then
  begin //check if we need to format javascript
    temp_token := get_script();
    if (temp_token.ttype <> '') then
    begin
      result := temp_token;
      Exit;
    end;
    if opt.doJavaScript then
      result.value := js_beautify(temp_token.value, opt.indent_size, opt.indent_character,
        True, 0, indent_level) //call the JS Beautifier
    else
      result.value := temp_token.value; //leave unformatted
    result.ttype := 'TK_CONTENT';
    Exit;
  end;
  if (last_token = 'TK_TAG_STYLE') then
  begin //check if we need to format css
    temp_token := get_style();
    if (temp_token.ttype <> '') then
    begin
      result := temp_token;
      Exit;
    end;
    if opt.doCSS then
      result.value :=css_beautify(temp_token.value, opt.indent_size, opt.indent_character, indent_level)
    else
      result.value := temp_token.value; //leave unformatted
    result.ttype := 'TK_CONTENT';
    Exit;
  end;
  if (current_mode = 'CONTENT') then
  begin
    token := get_content();
    if (token.ttype <> '') then
    begin
      result := token;
      Exit;
    end
    else
    begin
      result.value := token.value;
      result.ttype := 'TK_CONTENT';
      Exit;
    end;
  end;

  if (current_mode = 'TAG') then
  begin
    token := get_tag();
    if (token.ttype <> '') then
    begin
      result := token;
      Exit;
    end
    else
    begin
      result.ttype := 'TK_TAG_' + tag_type;
      result.value := token.value;
    end;
  end;
end;

procedure Thtml_beautify.print_newline(ignore: Boolean; arr: TStringList);
var
  i: Integer;
begin
  line_char_count := 0;
  if (arr.count = 0) then
  begin
    exit;
  end;
  if (not ignore) then
  begin //we might want the extra line
    while (in_array(arr.strings[arr.count - 1], whitespace)) do
    begin
      arr.delete(arr.count - 1);
    end;
  end;
  arr.add(#10);
  for i := 0 to indent_level - 1 do
  begin
    arr.add(indent_string);
  end;
end;

procedure Thtml_beautify.print_token(text: string);
begin
  output.add(text);
end;

procedure Thtml_beautify.indent;
begin
  inc(indent_level);
end;

procedure Thtml_beautify.unindent;
begin
  if (indent_level > 0) then
  begin
    dec(indent_level);
  end;
end;

procedure TTags.Delete(key: string);
var
  i: Integer;
begin
  i := IndexOfName(key);
  if i >= 0 then
    Delete(i);
end;

function TTags.GetiValue(const Name: string): integer;
begin
  result := strtoint(values[name]);
end;

procedure TTags.SetiValue(const Name: string; Value: integer);
begin
  values[name] := inttostr(value);
end;

end.

