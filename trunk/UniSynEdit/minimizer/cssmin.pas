unit cssmin;
{
cssmin.pas - 2010-05-05
Author: Mihail Slobodyanuk (slobodyanukma@ukr.net, slobodyanukma@gmail.com)
}
interface
uses Classes;

{
 level 1 - class and comment per line
 level 2 - all by one line
}
function css_min(css_source_text: string;
      level: Integer=1;
      remove_last_semicolons: Boolean = true;
      remove_comments: Boolean = true):string;

implementation
uses SysUtils, StrUtils, functions;

type
  TToken = record
    value:string;
    ttype:string;
  end;

  Tcss_min = class
    input, token_text, token_type, last_type, indent_string: string;
    output: TStringList;
    whitespace, wordchar: TStringArray;
    parser_pos: integer;
    just_added_newline, do_block_just_closed: Boolean;
    css_source_text: string;
    opt:record
      level: Integer;
      remove_last_semicolons: Boolean;
      remove_comments: Boolean
    end;
    input_length: Integer;
    in_html_comment:Boolean;
    function get_next_token: TToken;
    procedure print_single_space;
    procedure print_token;
    procedure trim_output(eat_newlines:Boolean = false);
    procedure print_newline(ignore_repeated: Boolean = false);
  public
    constructor Create(css_source_text: string;
      level: Integer;
      remove_last_semicolons: Boolean;
      remove_comments: Boolean);
    destructor Destroy; override;
    function getMin: string;
  end;

constructor Tcss_min.Create(css_source_text: string;
      level: Integer;
      remove_last_semicolons: Boolean;
      remove_comments: Boolean);
begin
  Self.css_source_text := css_source_text;
  opt.level := level;
  opt.remove_last_semicolons := remove_last_semicolons;
  opt.remove_comments := remove_comments;
  output := TStringList.Create();
  whitespace := split(#13#10#9' ');
  wordchar := split('/abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_!@#$%^&*()=.-+');
  in_html_comment:=False;
end;

destructor Tcss_min.Destroy;
begin
  Output.free;
end;

function Tcss_min.getMin(): string;
var
  t: TToken;
  i: Integer;
  lines: TStringArray;
label
  next_token;

begin
  just_added_newline := false;

  // cache the source's length.
  input_length := length(css_source_text);
  //----------------------------------
  indent_string := '';

  input := css_source_text;
  last_type := 'TK_END_BLOCK'; // last token type
  parser_pos := 0;
  while true do
  begin
    t := get_next_token;
    token_text := t.value;
    token_type := t.ttype;
    if token_type = 'TK_EOF' then
    begin
      break;
    end
    else if token_type = 'TK_WORD' then
    begin
      if (last_type='TK_END_BLOCK') then
        begin
        print_newline;
        end
      else if (last_type='TK_WORD') then
        begin
        print_single_space;
        end
      else if (last_type='TK_BLOCK_COMMENT') then
        begin
        print_newline();
        end;
      print_token();
    end
    else if (token_type = 'TK_COLON') then
    begin
      print_token();
    end
    else if (token_type = 'TK_COMMA') then
    begin
      print_token();
    end
    else if token_type = 'TK_START_BLOCK' then
    begin
      print_token();
    end
    else if token_type = 'TK_END_BLOCK' then
    begin
    //Remove last ";"
    if opt.remove_last_semicolons and (last_type='TK_SEMICOLON') then
        output.Delete(output.Count - 1);
      print_token();
    end
    else if token_type = 'TK_SEMICOLON' then
    begin
      print_token();
    end
    else if token_type = 'TK_BLOCK_COMMENT' then
    begin
      if not opt.remove_comments then
      begin
      lines := split(StringReplace(token_text, #13#10, #10, [rfReplaceAll]), #10);
      print_newline();
      output.add(Trim(lines[0]));
      for i := 1 to high(lines) do
      begin
        output.add(' ');
        output.add(Trim(lines[i]));
      end;
      end
      else
            //do not change last_type
      Continue;
    end
    else if token_type = 'TK_INLINE_COMMENT' then
    begin
      if not opt.remove_comments then
      begin
      print_token();
      end;
      //do not change last_type
      Continue;
    end
    else if token_type = 'TK_UNKNOWN' then
    begin
      print_single_space();
      print_token();
    end;
    next_token:
    last_type := token_type;
  end;

  result := join(output);
  if Copy(result, Length(Result), 1)=#10 then
    result:=Copy(result, 1, Length(Result)-1);
  result := StringReplace(result, #10, #13#10, [rfReplaceAll]);
end;

procedure Tcss_min.trim_output(eat_newlines:Boolean = false);
begin
  while ((output.Count > 0) and ((output.Strings[output.Count - 1] = ' ')
    or (output.Strings[output.Count - 1] = indent_string) or
    (eat_newlines and ((output.Strings[output.Count - 1] = #10) or (output.Strings[output.Count - 1] = #13))))) do
  begin
    output.Delete(output.Count - 1);
  end;
end;

procedure Tcss_min.print_newline(ignore_repeated: Boolean = false);
var
  i: Integer;
begin
  trim_output();
  if (output.Count = 0) then
  begin
    exit; // no newline on start of file
  end;

  if ((output.Strings[output.Count - 1] <> #10) or not ignore_repeated) then
  begin
    just_added_newline := true;
    if opt.level=1 then
      output.add(#10);
  end;
end;

procedure Tcss_min.print_single_space;
var
  last_output: string;
begin
  last_output := ' ';
  if (output.count > 0) then
  begin
    last_output := output.Strings[output.count - 1];
  end;
  if ((last_output <> ' ') and (last_output <> #10) and (last_output <> indent_string)) then
  begin // prevent occassional duplicate space
    output.add(' ');
  end;
end;

procedure Tcss_min.print_token;
begin
  just_added_newline := false;
  output.add(token_text);
end;

function Tcss_min.get_next_token: TToken;
var
  c: string;
  comment: string;
  inline_comment: boolean;
  beginLine:Boolean;
begin
  if (parser_pos >= input_length) then
  begin
    result.value := '';
    result.ttype := 'TK_EOF';
    Exit;
  end;

  beginLine:=False;
  if parser_pos=0 then beginLine:=true;
  c := input[parser_pos + 1];
  Inc(parser_pos);
  while (in_array(c, whitespace)) do
  begin
    if c=#10 then beginLine:=True;
    if (parser_pos >= input_length) then
    begin
      result.value := '';
      result.ttype := 'TK_EOF';
      Exit;
    end;

    c := input[parser_pos + 1];
    Inc(parser_pos);
  end;

  if (c = '/') then
  begin
    comment := '';
    // peek for comment /* ... */
    inline_comment := not beginLine;
    if (input[parser_pos + 1] = '*') then
    begin
      Inc(parser_pos);
      if (parser_pos < input_length) then
      begin
        while not ((input[parser_pos + 1] = '*') and
          (input[parser_pos + 2] = '/') and (parser_pos < input_length)) do
        begin
          c := input[parser_pos + 1];
          comment := comment + c;
          if (c = #13) or (c = #10) then
          begin
            inline_comment := false;
          end;
          Inc(parser_pos);
          if (parser_pos >= input_length) then
          begin
            break;
          end;
        end;
      end;
      Inc(parser_pos, 2);
      if (inline_comment) then
      begin
        result.value := '/*' + comment + '*/';
        result.ttype := 'TK_INLINE_COMMENT';
        Exit;
      end
      else
      begin
        Result.value := '/*' + comment + '*/';
        result.ttype := 'TK_BLOCK_COMMENT';
        Exit;
      end;
    end;
  end;

  if (c = '-') and in_html_comment and (Copy(input, parser_pos, 3) = '-->') then
  begin
    in_html_comment := false;
    Inc(parser_pos, 2);
    result.value := '-->';
    result.ttype := 'TK_BLOCK_COMMENT';
    Exit;
  end;

  if (in_array(c, wordchar)) then
  begin
    if (parser_pos < input_length) then
    begin
      while (in_array(input[parser_pos + 1], wordchar)) do
      begin
        c := c + input[parser_pos + 1];
        Inc(parser_pos);
        if (parser_pos = input_length) then
        begin
          break;
        end;
      end;
    end;
    result.value := c;
    result.ttype := 'TK_WORD';
    Exit;
  end;

  if (c = '{') then
  begin
    result.value := c;
    result.ttype := 'TK_START_BLOCK';
    Exit;
  end;

  if (c = '}') then
  begin
    result.value := c;
    result.ttype := 'TK_END_BLOCK';
    Exit;
  end;

  if (c = ';') then
  begin
    result.value := c;
    result.ttype := 'TK_SEMICOLON';
    Exit;
  end;

  if (c = ':') then
  begin
    result.value := c;
    result.ttype := 'TK_COLON';
    Exit;
  end;

  if (c = ',') then
  begin
    result.value := c;
    result.ttype := 'TK_COMMA';
    Exit;
  end;

  if (c = '<') and (Copy(input, parser_pos, 4) = '<!--') then
  begin
    Inc(parser_pos, 3);
    in_html_comment := true;
    result.value := '<!--';
    result.ttype := 'TK_BLOCK_COMMENT';
    Exit;
  end;

  result.value := c;
  result.ttype := 'TK_UNKNOWN';
  Exit;
end;

function css_min(css_source_text: string;
      level: Integer=1;
      remove_last_semicolons: Boolean = true;
      remove_comments: Boolean = true):string;
var jsb:Tcss_min;
begin
  jsb := Tcss_min.Create(
  css_source_text,
  level,
  remove_last_semicolons,
  remove_comments);
  result:=jsb.getMin;
  jsb.free;
end;
end.

