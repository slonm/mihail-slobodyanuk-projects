unit cssbeautify;
interface
uses Classes;
function css_beautify(css_source_text: string;
      indent_size: Integer = 4;
      indent_char: Char = ' ';
      indent_level: Integer = 0):string;

implementation
uses SysUtils, StrUtils, functions;

type
  TToken = record
    value:string;
    ttype:string;
  end;

  Tcss_beautify = class
    input, token_text, token_type, last_type, indent_string: string;
    output: TStringList;
    whitespace, wordchar: TStringArray;
    parser_pos: integer;
    just_added_newline, do_block_just_closed: Boolean;
    css_source_text: string;
    opt:record
      css_source_text: string;
      indent_size: Integer;
      indent_char: Char;
      indent_level: Integer;
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
      indent_size: Integer;
      indent_char: Char;
      indent_level: Integer);
    destructor Destroy; override;
    function getBeauty: string;
  end;

constructor Tcss_beautify.Create(css_source_text: string;
  indent_size: Integer;
  indent_char: Char;
  indent_level: Integer);
begin
  Self.css_source_text := css_source_text;
  opt.indent_size := indent_size;
  opt.indent_char := indent_char;
  opt.indent_level := indent_level; // starting indentation
  output := TStringList.Create();
  whitespace := split(#13#10#9' ');
  wordchar := split('/abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_!@#$%^&*()=.-+');
  in_html_comment:=False;
end;

destructor Tcss_beautify.Destroy;
begin
  Output.free;
end;

function Tcss_beautify.getBeauty(): string;
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
  while opt.indent_size > 0 do
  begin
    indent_string := indent_string + opt.indent_char;
    opt.indent_size := opt.indent_size - 1;
  end;

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
      if last_type='TK_START_BLOCK' then
        begin
        print_newline;
        end
      else if (last_type='TK_END_BLOCK') then
        begin
        print_newline;
        print_newline;
        end
      else if (last_type='TK_WORD') then
        begin
        print_single_space;
        end
      else if (last_type='TK_SEMICOLON') or (last_type='TK_BLOCK_COMMENT') then
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
      print_single_space();
      print_token();
    end
    else if token_type = 'TK_END_BLOCK' then
    begin
      print_newline();
      print_token();
    end
    else if token_type = 'TK_SEMICOLON' then
    begin
      print_token();
    end
    else if token_type = 'TK_BLOCK_COMMENT' then
    begin
      lines := split(StringReplace(token_text, #13#10, #10, [rfReplaceAll]), #10);
      for i := 0 to high(lines) do
      begin
        print_newline();
        output.add(lines[i]);
      end;
    end
    else if token_type = 'TK_INLINE_COMMENT' then
    begin
      print_single_space();
      print_token();
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

procedure Tcss_beautify.trim_output(eat_newlines:Boolean = false);
begin
  while ((output.Count > 0) and ((output.Strings[output.Count - 1] = ' ')
    or (output.Strings[output.Count - 1] = indent_string) or
    (eat_newlines and ((output.Strings[output.Count - 1] = #10) or (output.Strings[output.Count - 1] = #13))))) do
  begin
    output.Delete(output.Count - 1);
  end;
end;

procedure Tcss_beautify.print_newline(ignore_repeated: Boolean = false);
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
    output.add(#10);
  end;

  for i := 0 to opt.indent_level - 1 do
  begin
    output.add(indent_string);
  end;
end;

procedure Tcss_beautify.print_single_space;
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

procedure Tcss_beautify.print_token;
begin
  just_added_newline := false;
  output.add(token_text);
end;

function Tcss_beautify.get_next_token: TToken;
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

function css_beautify(css_source_text: string;
      indent_size: Integer = 4;
      indent_char: Char = ' ';
      indent_level: Integer = 0):string;
var jsb:Tcss_beautify;
begin
  jsb := Tcss_beautify.Create(
  css_source_text,
  indent_size,
  indent_char,
  indent_level);
  result:=jsb.getBeauty;
  jsb.free;
end;
end.

