{

 JS Beautifier
---------------

  Delphi port by Mihail Slobodyanuk, <slobodyanukma@gmail.com>
  Written by Einar Lielmanis, <einar@jsbeautifier.org>
      http://jsbeautifier.org/

  Originally converted to javascript by Vital, <vital76@gmail.com>

  You are free to use this in any way you want, in case you find this useful or working for you.

  Usage:
    js_beautify(js_source_text);
    js_beautify(js_source_text, options);

  The options are:
    indent_size (default 4)          - indentation size,
    indent_char (default space)      - character to indent with,
    preserve_newlines (default true) - whether existing line breaks should be preserved,
    preserve_max_newlines (default 0) - maximum number of line breaks to be preserved in one chunk 0 - unlimited,
    indent_level (default 0)         - initial indentation level, you probably won't need this ever,

    space_after_anon_function (default false) - if true, then space is added between "function ()"
            (jslint is happy about this); if false, then the common "function()" output is used.
    braces_on_own_line (default false) - ANSI / Allman brace style, each opening/closing brace gets its own line.

    e.g

    js_beautify(js_source_text, 1, #9);
}
unit jsbeautify;
interface
uses Classes;
function js_beautify(js_source_text: string;
      indent_size: Integer = 4;
      indent_char: Char = ' ';
      preserve_newlines: Boolean = True;
      max_preserve_newlines: Integer = 0;
      indent_level: Integer = 0;
      space_after_anon_function: Boolean = False;
      braces_on_own_line: Boolean = False;
      keep_array_indentation: Boolean = False):string;

implementation
uses SysUtils, StrUtils, functions;

type
  TToken = array[0..1] of string;
  TFlags = class
  public
    previous_mode: string;
    mode: string;
    var_line: Boolean;
    var_line_tainted: Boolean;
    var_line_reindented: Boolean;
    in_html_comment: Boolean;
    if_line: Boolean;
    in_case: Boolean;
    eat_next_space: Boolean;
    indentation_baseline: Integer;
    indentation_level: Integer;
  end;

  Tjs_beautify = class
    input, token_text, last_type, last_text, last_last_text, last_word, indent_string: string;
    flags: TFlags;
    output, flag_store: TStringList;
    whitespace, wordchar, punct, line_starters, digits: TStringArray;
    parser_pos: integer;
    prefix, token_type: string;
    wanted_newline, just_added_newline, do_block_just_closed: Boolean;
    n_newlines: Integer;
    js_source_text: string;
    opt_braces_on_own_line: Boolean;
    opt_indent_size: Integer;
    opt_indent_char: Char;
    opt_preserve_newlines: Boolean;
    opt_max_preserve_newlines: Integer;
    opt_indent_level: Integer; // starting indentation
    opt_space_after_anon_function: Boolean;
    opt_keep_array_indentation: Boolean;
    input_length: Integer;
    procedure set_mode(mode: string);
    function get_next_token(): TToken;
    procedure print_single_space;
    procedure print_token;
    procedure trim_output(eat_newlines:Boolean = false);
    function is_array(mode: string): Boolean;
    procedure print_newline(ignore_repeated: Boolean = true);
    procedure indent;
    procedure remove_indent;
    function is_expression(mode: string): Boolean;
    procedure restore_mode;
    function is_ternary_op(): Boolean;
  public
    constructor Create(js_source_text: string;
      indent_size: Integer = 4;
      indent_char: Char = ' ';
      preserve_newlines: Boolean = True;
      max_preserve_newlines: Integer = 0;
      indent_level: Integer = 0;
      space_after_anon_function: Boolean = False;
      braces_on_own_line: Boolean = False;
      keep_array_indentation: Boolean = False);
    destructor Destroy; override;
    function getBeauty: string;
  end;

constructor Tjs_beautify.Create(js_source_text: string;
  indent_size: Integer;
  indent_char: Char;
  preserve_newlines: Boolean;
  max_preserve_newlines: Integer;
  indent_level: Integer;
  space_after_anon_function: Boolean;
  braces_on_own_line: Boolean;
  keep_array_indentation: Boolean);
begin
  Self.js_source_text := js_source_text;
  self.opt_braces_on_own_line := braces_on_own_line;
  self.opt_indent_size := indent_size;
  self.opt_indent_char := indent_char;
  self.opt_preserve_newlines := preserve_newlines;
  self.opt_max_preserve_newlines := max_preserve_newlines;
  self.opt_indent_level := indent_level; // starting indentation
  self.opt_space_after_anon_function := space_after_anon_function;
  self.opt_keep_array_indentation := keep_array_indentation;
  output := TStringList.Create();
  whitespace := split(#13#10#9' ');
  wordchar := split('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_$');
  punct := split('+ - * / % & ++ -- = += -= *= /= %= == === != !== > < >= <= >> << >>> >>>= >>= <<= && &= | || ! !! , : ? ^ ^= |= ::', ' ');
  // words which should always start on new line.
  line_starters := split('continue,try,throw,return,var,if,switch,case,default,for,while,break,function', ',');
  digits := split('0123456789');
  // states showing if we are currently in expression (i.e. "if" case) - 'EXPRESSION', or in usual block (like, procedure), 'BLOCK'.
  // some formatting depends on that.
  flag_store := TStringList.Create();
  self.flags := TFlags.Create;
  self.flags.previous_mode := '';
  self.flags.mode := 'BLOCK';
  self.flags.indentation_level := self.opt_indent_level;
  self.flags.var_line := false;
  self.flags.var_line_tainted := false;
  self.flags.var_line_reindented := false;
  self.flags.in_html_comment := false;
  self.flags.if_line := false;
  self.flags.in_case := false;
  self.flags.eat_next_space := false;
  self.flags.indentation_baseline := -1;
end;

destructor Tjs_beautify.Destroy;
begin
  Output.free;
  flag_store.free;
  FreeAndNil(flags);
end;

function Tjs_beautify.getBeauty(): string;
var
  t: TToken;
  i: Integer;
  space_before, space_after: Boolean;
  lines: TStringArray;
label
  next_token;

begin
  just_added_newline := false;

  // cache the source's length.
  input_length := length(js_source_text);

  //----------------------------------
  indent_string := '';
  while opt_indent_size > 0 do
  begin
    indent_string := indent_string + opt_indent_char;
    opt_indent_size := opt_indent_size - 1;
  end;

  input := js_source_text;

  last_word := ''; // last 'TK_WORD' passed
  last_type := 'TK_START_EXPR'; // last token type
  last_text := ''; // last token text
  last_last_text := ''; // pre-last token text

  do_block_just_closed := false;

  set_mode('BLOCK');

  parser_pos := 0;
  while true do
  begin
    t := get_next_token;
    token_text := t[0];
    token_type := t[1];
    if token_type = 'TK_EOF' then
    begin
      break;
    end;

    //swich ro string
    if token_type = 'TK_START_EXPR' then
    begin
      if token_text = '[' then
      begin
        if (last_type = 'TK_WORD') or (last_text = ')') then
        begin
          // this is array index specifier, break immediately
          // a[x], fn()[x]
          if in_array(last_text, line_starters) then
          begin
            print_single_space;
          end;
          set_mode('(EXPRESSION)');
          print_token;
          goto next_token;
        end;

        if (flags.mode = '[EXPRESSION]') or (flags.mode = '[INDENTED-EXPRESSION]') then
        begin
          if (last_last_text = ']') and (last_text = ',') then
          begin
            // ], [ goes to new line
            if flags.mode = '[EXPRESSION]' then
            begin
              flags.mode := '[INDENTED-EXPRESSION]';
              if not opt_keep_array_indentation then
              begin
                indent;
              end;
            end;
            set_mode('[EXPRESSION]');
            if not opt_keep_array_indentation then
            begin
              print_newline;
            end;
          end
          else if last_text = '[' then
          begin
            if flags.mode = '[EXPRESSION]' then
            begin
              flags.mode := '[INDENTED-EXPRESSION]';
              if not opt_keep_array_indentation then
              begin
                indent();
              end;
            end;
            set_mode('[EXPRESSION]');

            if not opt_keep_array_indentation then
            begin
              print_newline;
            end;
          end
          else
          begin
            set_mode('[EXPRESSION]');
          end;
        end
        else
        begin
          set_mode('[EXPRESSION]');
        end;

      end
      else
      begin
        set_mode('(EXPRESSION)');
      end;

      if (last_text = ';') or (last_type = 'TK_START_BLOCK') then
      begin
        print_newline();
      end
      else if (last_type = 'TK_END_EXPR') or (last_type = 'TK_START_EXPR') or (last_type = 'TK_END_BLOCK') or (last_text = '.') then
      begin
        // do nothing on (( and )( and ][ and ]( and .(
      end
      else if (last_type <> 'TK_WORD') and (last_type <> 'TK_OPERATOR') then
      begin
        print_single_space;
      end
      else if last_word = 'function' then
      begin
        // function() vs function ()
        if opt_space_after_anon_function then
        begin
          print_single_space;
        end;
      end
      else if (in_array(last_text, line_starters)) or (last_text = 'catch') then
      begin
        print_single_space;
      end;
      print_token();

    end
    else if token_type = 'TK_END_EXPR' then
    begin
      if token_text = ']' then
      begin
        if (opt_keep_array_indentation) then
        begin
          if (last_text = '}') then
          begin
            // trim_output();
            // print_newline(true);
            remove_indent();
            print_token();
            restore_mode();
            goto next_token;
          end;
        end
        else
        begin
          if (flags.mode = '[INDENTED-EXPRESSION]') then
          begin
            if (last_text = ']') then
            begin
              restore_mode();
              print_newline();
              print_token();
              goto next_token;
            end;
          end;
        end;
      end;
      restore_mode();
      print_token();
    end
    else if token_type = 'TK_START_BLOCK' then
    begin
      if (last_word = 'do') then
      begin
        set_mode('DO_BLOCK');
      end
      else
      begin
        set_mode('BLOCK');
      end;
      if (opt_braces_on_own_line) then
      begin
        if (last_type <> 'TK_OPERATOR') then
        begin
          if (last_text = 'return') then
          begin
            print_single_space();
          end
          else
          begin
            print_newline(true);
          end;
        end;
        print_token();
        indent();
      end
      else
      begin
        if (last_type <> 'TK_OPERATOR') and (last_type <> 'TK_START_EXPR') then
        begin
          if (last_type = 'TK_START_BLOCK') then
          begin
            print_newline();
          end
          else
          begin
            print_single_space();
          end;
        end
        else
        begin
          // if TK_OPERATOR or TK_START_EXPR
          if is_array(flags.previous_mode) and (last_text = ',') then
          begin
            print_newline(); // [a, b, c, begin
          end;
        end;
        indent();
        print_token();
      end;

    end
    else if token_type = 'TK_END_BLOCK' then
    begin
      restore_mode();
      if (opt_braces_on_own_line) then
      begin
        print_newline();
        print_token();
      end
      else
      begin
        if (last_type = 'TK_START_BLOCK') then
        begin
          // nothing
          if (just_added_newline) then
          begin
            remove_indent();
          end
          else
          begin
            // {};
            trim_output();
          end;
        end
        else
        begin
          if is_array(flags.mode) and opt_keep_array_indentation then
          begin
              // we REALLY need a newline here, but newliner would skip that
              opt_keep_array_indentation := false;
              print_newline();
              opt_keep_array_indentation := true;
          end
          else print_newline();
        end;
        print_token();
      end;
    end
    else if token_type = 'TK_WORD' then
    begin
      // no, it's not you. even I have problems understanding how this works
      // and what does what.
      if (do_block_just_closed) then
      begin
        // do beginend; ## while ()
        print_single_space();
        print_token();
        print_single_space();
        do_block_just_closed := false;
        goto next_token;
      end;

      if (token_text = 'function') then
      begin
        if (just_added_newline or (last_text = ';')) and (last_text <> '{') then
        begin
          // make sure there is a nice clean space of at least one blank line
          // before a new function definition
          if just_added_newline then
            n_newlines := n_newlines
          else n_newlines := 0;
          if not opt_preserve_newlines then n_newlines := 1;

          for i := 0 to 1 - n_newlines do
          begin
            print_newline(false);
          end;

        end;
      end;

      if ((token_text = 'case') or (token_text = 'default')) then
      begin
        if (last_text = ':') then
        begin
          // switch cases following one another
          remove_indent();
        end
        else
        begin
          // case statement starts in the same line where switch
          Dec(flags.indentation_level);
          print_newline();
          Inc(flags.indentation_level);
        end;
        print_token();
        flags.in_case := true;
        goto next_token;
      end;

      prefix := 'NONE';

      if (last_type = 'TK_END_BLOCK') then
      begin
        if not in_array(LowerCase(token_text), ['else', 'catch', 'finally']) then
        begin
          prefix := 'NEWLINE';
        end
        else
        begin
          if (opt_braces_on_own_line) then
          begin
            prefix := 'NEWLINE';
          end
          else
          begin
            prefix := 'SPACE';
            print_single_space();
          end;
        end;
      end
      else if (last_type = 'TK_SEMICOLON') and ((flags.mode = 'BLOCK') or (flags.mode = 'DO_BLOCK')) then
      begin
        prefix := 'NEWLINE';
      end
      else if ((last_type = 'TK_SEMICOLON') and is_expression(flags.mode)) then
      begin
        prefix := 'SPACE';
      end
      else if (last_type = 'TK_STRING') then
      begin
        prefix := 'NEWLINE';
      end
      else if (last_type = 'TK_WORD') then
      begin
        prefix := 'SPACE';
      end
      else if (last_type = 'TK_START_BLOCK') then
      begin
        prefix := 'NEWLINE';
      end
      else if (last_type = 'TK_END_EXPR') then
      begin
        print_single_space();
        prefix := 'NEWLINE';
      end;

      if (flags.if_line and (last_type = 'TK_END_EXPR')) then flags.if_line := false;

      if (in_array(LowerCase(token_text), ['else', 'catch', 'finally'])) then
      begin
        if (last_type <> 'TK_END_BLOCK') or opt_braces_on_own_line then
          print_newline()
        else
        begin
          trim_output(true);
          print_single_space();
        end;
      end
      else if (in_array(token_text, line_starters) or (prefix = 'NEWLINE')) then
      begin
        if (((last_type = 'TK_START_EXPR') or (last_text = '=') or (last_text = ',')) and (token_text = 'function')) then
        begin
          // no need to force newline on 'function': (function
          // DONOTHING
        end
        else if ((last_text = 'return') or (last_text = 'throw')) then
        begin
          // no newline between 'return nnn'
          print_single_space();
        end
        else if (last_type <> 'TK_END_EXPR') then
        begin
          if (((last_type <> 'TK_START_EXPR') or (token_text <> 'var')) and (last_text <> ':')) then
          begin
            // no need to force newline on 'var': for (var x = 0...)
            if ((token_text = 'if') and (last_word = 'else') and (last_text <> '{')) then
            begin
              // no newline for end; else if begin
              print_single_space();
            end
            else
            begin
              print_newline();
            end;
          end;
        end
        else
        begin
          if (in_array(token_text, line_starters) and (last_text <> ')')) then
          begin
            print_newline();
          end;
        end;
      end
      else if (is_array(flags.mode) and (last_text = ',') and (last_last_text = '}')) then
      begin
        print_newline(); // end;, in lists get a newline treatment
      end
      else if (prefix = 'SPACE') then
      begin
        print_single_space();
      end;
      print_token();
      last_word := token_text;

      if (token_text = 'var') then
      begin
        flags.var_line := true;
        flags.var_line_reindented := false;
        flags.var_line_tainted := false;
      end;

      if (token_text = 'if') then
      begin
        flags.if_line := true;
      end;

      if (token_text = 'else') then
      begin
        flags.if_line := false;
      end;
    end
    else if token_type = 'TK_SEMICOLON' then
    begin
      print_token();
      flags.var_line := false;
      flags.var_line_reindented := false;
    end
    else if token_type = 'TK_STRING' then
    begin
      if (last_type = 'TK_START_BLOCK') or (last_type = 'TK_END_BLOCK') or (last_type = 'TK_SEMICOLON') then
      begin
        print_newline();
      end
      else if (last_type = 'TK_WORD') then
      begin
        print_single_space();
      end;
      print_token();
    end
    else if token_type = 'TK_EQUALS' then
    begin
      if (flags.var_line) then
      begin
        // just got an '=' in a var-line, different formatting/line-breaking, etc will now be done
        flags.var_line_tainted := true;
      end;
      print_single_space();
      print_token();
      print_single_space();
    end
    else if token_type = 'TK_OPERATOR' then
    begin
      space_before := true;
      space_after := true;
      if (flags.var_line and (token_text = ',') and (is_expression(flags.mode))) then
      begin
        // do not break on comma, for(var a = 1, b = 2)
        flags.var_line_tainted := false;
      end;

      if (flags.var_line) then
      begin
        if (token_text = ',') then
        begin
          if (flags.var_line_tainted) then
          begin
            print_token();
            flags.var_line_reindented := true;
            flags.var_line_tainted := false;
            print_newline();
            goto next_token;
          end
          else
          begin
            flags.var_line_tainted := false;
          end;
          // end; else if (token_text = ':') begin
              // hmm, when does this happen? tests don't catch this
              // flags.var_line = false;
        end;
      end;

      if ((last_text = 'return') or (last_text = 'throw')) then
      begin
        // "return" had a special handling in TK_WORD. Now we need to return the favor
        print_single_space();
        print_token();
        goto next_token;
      end;

      if (token_text = ':') and flags.in_case then
      begin
        print_token(); // colon really asks for separate treatment
        print_newline();
        flags.in_case := false;
        goto next_token;
      end;

      if (token_text = '::') then
      begin
        // no spaces around exotic namespacing syntax operator
        print_token();
        goto next_token;
      end;

      if (token_text = ',') then
      begin
        if (flags.var_line) then
        begin
          if (flags.var_line_tainted) then
          begin
            print_token();
            print_newline();
            flags.var_line_tainted := false;
          end
          else
          begin
            print_token();
            print_single_space();
          end;
        end
        else if (last_type = 'TK_END_BLOCK') and (flags.mode <> '(EXPRESSION)') then
        begin
          print_token();
          if (flags.mode = 'OBJECT') and (last_text = '}') then
          begin
            print_newline();
          end
          else
          begin
            print_single_space();
          end;
        end
        else
        begin
          if (flags.mode = 'OBJECT') then
          begin
            print_token();
            print_newline();
          end
          else
          begin
            // EXPR or DO_BLOCK
            print_token();
            print_single_space();
          end;
        end;
        goto next_token;
      end
      else if (in_array(token_text, ['--', '++', '!']) or (in_array(token_text, ['-', '+']) and (in_array(last_type, ['TK_START_BLOCK', 'TK_START_EXPR', 'TK_EQUALS', 'TK_OPERATOR']) or in_array(last_text, line_starters)))) then
      begin
        // unary operators (and binary +/- pretending to be unary) special cases

        space_before := false;
        space_after := false;

        if (last_text = ';') and is_expression(flags.mode) then
        begin
          // for (;; ++i)
          //        ^^^
          space_before := true;
        end;
        if (last_type = 'TK_WORD') and in_array(last_text, line_starters) then
        begin
          space_before := true;
        end;

        if (flags.mode = 'BLOCK') and ((last_text = '{') or (last_text = ';')) then
        begin
          // begin foo; --i end;
          // foo(); --bar;
          print_newline();
        end;
      end
      else if (token_text = '.') then
      begin
        // decimal digits or object.property
        space_before := false;

      end
      else if (token_text = ':') then
      begin
        if (not is_ternary_op()) then
        begin
          flags.mode := 'OBJECT';
          space_before := false;
        end;
      end;
      if (space_before) then
      begin
        print_single_space();
      end;

      print_token();

      if (space_after) then
      begin
        print_single_space();
      end;

      if (token_text = '!') then
      begin
        // flags.eat_next_space = true;
      end;
    end
    else if token_type = 'TK_BLOCK_COMMENT' then
    begin
      lines := split(StringReplace(token_text, #13#10, #10, [rfReplaceAll]), #10);

      if (Pos('/**', token_text) > 0) then
      begin
        // javadoc: reformat and reindent
        print_newline();
        output.add(lines[0]);
        for i := 1 to high(lines) do
        begin
          print_newline();
          output.add(' ');
          output.add(Trim(lines[i]));
        end;
      end
      else
      begin
        // simple block comment: leave intact
        if (length(lines) > 1) then
        begin
          // multiline comment block starts with a new line
          print_newline();
          trim_output();
        end
        else
        begin
          // single-line /* comment */ stays where it is
          print_single_space();
        end;
        for i := 0 to high(lines) do
        begin
          output.add(lines[i]);
          output.add(#10);
        end;

      end;
      print_newline();
    end
    else if token_type = 'TK_INLINE_COMMENT' then
    begin
      print_single_space();
      print_token();
      if (is_expression(flags.mode)) then
      begin
        print_single_space();
      end
      else
      begin
        print_newline();
      end;
    end
    else if token_type = 'TK_COMMENT' then
    begin
      // print_newline();
      if (wanted_newline) then
      begin
        print_newline();
      end
      else
      begin
        print_single_space();
      end;
      print_token();
      print_newline();
    end
    else if token_type = 'TK_UNKNOWN' then
    begin
      if (last_text = 'return') or (last_text = 'throw') then
        print_single_space();
      print_token();
    end;
    next_token:
    last_last_text := last_text;
    last_type := token_type;
    last_text := token_text;
  end;

  result := join(output);
  if Copy(result, Length(Result), 1)=#10 then
    result:=Copy(result, 1, Length(Result)-1);
  result := StringReplace(result, #10, #13#10, [rfReplaceAll]);
end;

procedure Tjs_beautify.trim_output(eat_newlines:Boolean = false);
begin
  while ((output.Count > 0) and ((output.Strings[output.Count - 1] = ' ')
    or (output.Strings[output.Count - 1] = indent_string) or
    (eat_newlines and ((output.Strings[output.Count - 1] = #10) or (output.Strings[output.Count - 1] = #13))))) do
  begin
    output.Delete(output.Count - 1);
  end;
end;

function Tjs_beautify.is_array(mode: string): Boolean;
begin
  result := (mode = '[EXPRESSION]') or (mode = '[INDENTED-EXPRESSION]');
end;

procedure Tjs_beautify.print_newline(ignore_repeated: Boolean = true);
var
  i: Integer;
begin

  flags.eat_next_space := false;
  if (opt_keep_array_indentation and is_array(flags.mode)) then
  begin
    exit;
  end;

  flags.if_line := false;
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
  for i := 0 to flags.indentation_level - 1 do
  begin
    output.add(indent_string);
  end;
  if (flags.var_line and flags.var_line_reindented) then
  begin
    if (opt_indent_char = ' ') then
    begin
      output.add('    '); // var_line always pushes 4 spaces, so that the variables would be one under another
    end
    else
    begin
      output.add(indent_string); // skip space-stuffing, if indenting with a tab
    end;
  end;
end;

procedure Tjs_beautify.print_single_space;
var
  last_output: string;
begin
  if (flags.eat_next_space) then
  begin
    flags.eat_next_space := false;
    exit;
  end;
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

procedure Tjs_beautify.print_token;
begin
  just_added_newline := false;
  flags.eat_next_space := false;
  output.add(token_text);
end;

procedure Tjs_beautify.indent;
begin
  Inc(flags.indentation_level);
end;

procedure Tjs_beautify.remove_indent;
begin
  if ((output.count > 0) and (output.Strings[output.count - 1] = indent_string)) then
  begin
    output.Delete(output.Count - 1);
  end;
end;

procedure Tjs_beautify.set_mode(mode: string);
var
  newflags: TFlags;
begin
  flag_store.AddObject('', flags);
  newflags := TFlags.Create;
  newflags.previous_mode := flags.mode;
  newflags.mode := mode;
  newflags.var_line := false;
  newflags.var_line_tainted := false;
  newflags.var_line_reindented := false;
  newflags.in_html_comment := false;
  newflags.if_line := false;
  newflags.in_case := false;
  newflags.eat_next_space := false;
  newflags.indentation_baseline := -1;
  newflags.indentation_level := flags.indentation_level;
  if flags.var_line and flags.var_line_reindented then
    Inc(newflags.indentation_level);
  flags := newflags;
end;

function Tjs_beautify.is_expression(mode: string): Boolean;
begin
  result := (mode = '[EXPRESSION]') or (mode = '[INDENTED-EXPRESSION]') or (mode = '(EXPRESSION)');
end;

procedure Tjs_beautify.restore_mode;
begin
  do_block_just_closed := (flags.mode = 'DO_BLOCK');
  flags.mode := 'DO_BLOCK';
  if (flag_store.count > 0) then
  begin
    flags.free();
    flags := TFlags(flag_store.Objects[flag_store.Count - 1]);
    flag_store.Delete(flag_store.Count - 1);
  end;
end;

// Walk backwards from the colon to find a '?' (colon is part of a ternary op)
// or a '{' (colon is part of a class literal).  Along the way, keep track of
// the blocks and expressions we pass so we only trigger on those chars in our
// own level, and keep track of the colons so we only trigger on the matching '?'.

function Tjs_beautify.is_ternary_op(): Boolean;
var
  i, level, colon_count: Integer;
begin
  result := false;
  level := 0;
  colon_count := 0;
  for i := output.count - 1 downto 0 do
  begin
    if output.Strings[i] = ':' then
    begin
      if (level = 0) then
      begin
        Inc(colon_count);
      end;
    end
    else if output.Strings[i] = '?' then
    begin
      if (level = 0) then
      begin
        if (colon_count = 0) then
        begin
          result := true;
          Exit;
        end
        else
        begin
          Dec(colon_count);
        end;
      end;
    end
    else if output.Strings[i] = '{' then
    begin
      if (level = 0) then
      begin
        result := false;
        Exit;
      end;
      Dec(level);
    end
    else if in_array(output.Strings[i], ['(', '[']) then
      Dec(level)
    else if in_array(output.Strings[i], ['}', ')', ']']) then
      inc(level)
  end;
end;

function Tjs_beautify.get_next_token(): TToken;
var
  c: string;
  keep_whitespace: Boolean;
  whitespace_count, i: Integer;
  sign, comment: string;
  t: TToken;
  inline_comment: boolean;
  tmp_float: Extended;
  sep, resulting_string: string;
  esc, in_char_class: boolean;
  sharp: string;
begin
  n_newlines := 0;

  if (parser_pos >= input_length) then
  begin
    result[0] := '';
    result[1] := 'TK_EOF';
    Exit;
  end;

  wanted_newline := false;

  c := input[parser_pos + 1];
  Inc(parser_pos);

  keep_whitespace := opt_keep_array_indentation and is_array(flags.mode);

  if (keep_whitespace) then
  begin

    //
    // slight mess to allow nice preservation of array indentation and reindent that correctly
    // first time when we get to the arrays:
    // var a = [
    // ....'something'
    // we make note of whitespace_count = 4 into flags.indentation_baseline
    // so we know that 4 whitespaces in original source match indent_level of reindented source
    //
    // and afterwards, when we get to
    //    'something,
    // .......'something else'
    // we know that this should be indented to indent_level + (7 - indentation_baseline) spaces
    //
    whitespace_count := 0;

    while (in_array(c, whitespace)) do
    begin

      if (c = #10) then
      begin
        trim_output();
        output.add(#10);
        just_added_newline := true;
        whitespace_count := 0;
      end
      else
      begin
        if (c = #9) then
        begin
          Inc(whitespace_count, 4);
        end
        else if c = #10 then
        begin
          //nothing
        end
        else
        begin
          Inc(whitespace_count, 1);
        end;
      end;

      if (parser_pos >= input_length) then
      begin
        result[0] := '';
        result[1] := 'TK_EOF';
        Exit;
      end;

      c := input[parser_pos + 1];
      Inc(parser_pos);

    end;
    if (flags.indentation_baseline = -1) then
    begin
      flags.indentation_baseline := whitespace_count;
    end;

    if (just_added_newline) then
    begin
      for i := 0 to flags.indentation_level do
      begin
        output.add(indent_string);
      end;
      if (flags.indentation_baseline <> -1) then
      begin
        for i := 0 to whitespace_count - flags.indentation_baseline - 1 do
        begin
          output.add(' ');
        end;
      end;
    end;

  end
  else
  begin
    while (in_array(c, whitespace)) do
    begin

      if (c = #10) then
      begin
        if opt_max_preserve_newlines > 0 then
          begin
          if n_newlines <= opt_max_preserve_newlines then Inc(n_newlines);
          end
        else
          Inc(n_newlines);
      end;

      if (parser_pos >= input_length) then
      begin
        result[0] := '';
        result[1] := 'TK_EOF';
        Exit;
      end;

      c := input[parser_pos + 1];
      Inc(parser_pos);

    end;

    if (opt_preserve_newlines) then
    begin
      if (n_newlines > 1) then
      begin
        for i := 0 to n_newlines - 1 do
        begin
          print_newline(i = 0);
          just_added_newline := true;
        end;
      end;
    end;
    wanted_newline := n_newlines > 0;
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
    // small and surprisingly unugly hack for 1E-10 representation
    if (parser_pos <> input_length) and in_array(Copy(c, length(c), 1), ['e', 'E']) and
     TryStrToFloat(Copy(c, 1, length(c) - 1), tmp_float) and
      in_array(input[parser_pos + 1], ['-', '+']) then
    begin

      sign := input[parser_pos + 1];
      Inc(parser_pos);

      t := get_next_token;
      c := c + sign + t[0];
      result[0] := c;
      result[1] := 'TK_WORD';
      Exit;
    end;

    if (c = 'in') then
    begin // hack for 'in' operator
      result[0] := c;
      result[1] := 'TK_OPERATOR';
      Exit;
    end;
    if (wanted_newline and (last_type <> 'TK_OPERATOR') and
      not flags.if_line and (opt_preserve_newlines or (last_text <> 'var'))) then
    begin
      print_newline();
    end;
    result[0] := c;
    result[1] := 'TK_WORD';
    Exit;
  end;

  if (c = '(') or (c = '[') then
  begin
    result[0] := c;
    result[1] := 'TK_START_EXPR';
    Exit;
  end;

  if (c = ')') or (c = ']') then
  begin
    result[0] := c;
    result[1] := 'TK_END_EXPR';
    Exit;
  end;

  if (c = '{') then
  begin
    result[0] := c;
    result[1] := 'TK_START_BLOCK';
    Exit;
  end;

  if (c = '}') then
  begin
    result[0] := c;
    result[1] := 'TK_END_BLOCK';
    Exit;
  end;

  if (c = ';') then
  begin
    result[0] := c;
    result[1] := 'TK_SEMICOLON';
    Exit;
  end;

  if (c = '/') then
  begin
    comment := '';
    // peek for comment /* ... */
    inline_comment := true;
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
        result[0] := '/*' + comment + '*/';
        result[1] := 'TK_INLINE_COMMENT';
        Exit;
      end
      else
      begin
        result[0] := '/*' + comment + '*/';
        result[1] := 'TK_BLOCK_COMMENT';
        Exit;
      end;
    end;
    // peek for comment // ...
    if (input[parser_pos + 1] = '/') then
    begin
      comment := c;
      while (input[parser_pos + 1] <> #13) and (input[parser_pos + 1] <> #10) do
      begin
        comment := comment + input[parser_pos + 1];
        Inc(parser_pos);
        if (parser_pos >= input_length) then
        begin
          break;
        end;
      end;
      Inc(parser_pos);
      if (wanted_newline) then
      begin
        print_newline();
      end;
      result[0] := comment;
      result[1] := 'TK_COMMENT';
      Exit;
    end;

  end;

  if (c = '''') or // string
  (c = '"') or // string
  ((c = '/') and (((last_type = 'TK_WORD') and in_array(last_text, ['return', 'do']))
    or ((last_type = 'TK_START_EXPR') or (last_type = 'TK_START_BLOCK')
    or (last_type = 'TK_END_BLOCK') or (last_type = 'TK_OPERATOR')
    or (last_type = 'TK_EQUALS') or (last_type = 'TK_EOF')
    or (last_type = 'TK_SEMICOLON') or (last_type = 'TK_COMMENT')))) then
  begin // regexp
    sep := c;
    esc := false;
    resulting_string := c;

    if (parser_pos < input_length) then
    begin
      if (sep = '/') then
      begin
        //
        // handle regexp separately...
        //
        in_char_class := false;
        while (esc or in_char_class or (input[parser_pos + 1] <> sep)) do
        begin
          resulting_string := resulting_string + input[parser_pos + 1];
          if (not esc) then
          begin
            esc := input[parser_pos + 1] = '\';
            if (input[parser_pos + 1] = '[') then
            begin
              in_char_class := true;
            end
            else if (input[parser_pos + 1] = ']') then
            begin
              in_char_class := false;
            end;
          end
          else
          begin
            esc := false;
          end;
          Inc(parser_pos);
          if (parser_pos >= input_length) then
          begin
            // incomplete string/rexp when end-of-file reached.
            // bail out with what had been received so far.
            result[0] := resulting_string;
            result[1] := 'TK_STRING';
            Exit;
          end;
        end;

      end
      else
      begin
        //
        // and handle string also separately
        //
        while (esc or (input[parser_pos + 1] <> sep)) do
        begin
          resulting_string := resulting_string + input[parser_pos + 1];
          if (not esc) then
          begin
            esc := input[parser_pos + 1] = '\';
          end
          else
          begin
            esc := false;
          end;
          Inc(parser_pos);
          if (parser_pos >= input_length) then
          begin
            // incomplete string/rexp when end-of-file reached.
            // bail out with what had been received so far.
            result[0] := resulting_string;
            result[1] := 'TK_STRING';
            Exit;
          end;
        end;
      end;

    end;

    Inc(parser_pos);

    resulting_string := resulting_string + sep;

    if (sep = '/') then
    begin
      // regexps may have modifiers /regexp/MOD , so fetch those, too
      while (parser_pos < input_length) and in_array(input[parser_pos + 1], wordchar) do
      begin
        resulting_string := resulting_string + input[parser_pos + 1];
        Inc(parser_pos);
      end;
    end;
    result[0] := resulting_string;
    result[1] := 'TK_STRING';
    Exit;
  end;

  if (c = '#') then
  begin
    // Spidermonkey-specific sharp variables for circular references
    // https://developer.mozilla.org/En/Sharp_variables_in_JavaScript
    // http://mxr.mozilla.org/mozilla-central/source/js/src/jsscan.cpp around line 1935
    sharp := '#';
    if (parser_pos < input_length) and in_array(input[parser_pos + 1], digits) then
    begin
      repeat
        c := input[parser_pos + 1];
        sharp := sharp + c;
        Inc(parser_pos);
      until not ((parser_pos < input_length) and (c <> '#') and (c <> '='));
      if (c = '#') then
      begin
        //
      end
      else if (input[parser_pos + 1] = '[') and (input[parser_pos + 2] = ']') then
      begin
        sharp := sharp + '[]';
        Inc(parser_pos, 2);
      end
      else if (input[parser_pos + 1] = '{') and (input[parser_pos + 2] = '}') then
      begin
        sharp := sharp + '{}';
        Inc(parser_pos, 2);
      end;
      result[0] := sharp;
      result[1] := 'TK_WORD';
      Exit;
    end;
  end;

  if (c = '<') and (Copy(input, parser_pos, 4) = '<!--') then
  begin
    Inc(parser_pos, 3);
    flags.in_html_comment := true;
    result[0] := '<!--';
    result[1] := 'TK_COMMENT';
    Exit;
  end;

  if (c = '-') and flags.in_html_comment and (Copy(input, parser_pos, 3) = '-->') then
  begin
    flags.in_html_comment := false;
    Inc(parser_pos, 2);
    if (wanted_newline) then
    begin
      print_newline();
    end;
    result[0] := '-->';
    result[1] := 'TK_COMMENT';
    Exit;
  end;

  if (in_array(c, punct)) then
  begin
    while (parser_pos < input_length) and in_array(c + input[parser_pos + 1], punct) do
    begin
      c := c + input[parser_pos + 1];
      Inc(parser_pos);
      if (parser_pos >= input_length) then
      begin
        break;
      end;
    end;

    if (c = '=') then
    begin
      result[0] := c;
      result[1] := 'TK_EQUALS';
      Exit;
    end
    else
    begin
      result[0] := c;
      result[1] := 'TK_OPERATOR';
      Exit;
    end;
  end;

  result[0] := c;
  result[1] := 'TK_UNKNOWN';
  Exit;
end;

function js_beautify(js_source_text: string;
      indent_size: Integer = 4;
      indent_char: Char = ' ';
      preserve_newlines: Boolean = True;
      max_preserve_newlines: Integer = 0;
      indent_level: Integer = 0;
      space_after_anon_function: Boolean = False;
      braces_on_own_line: Boolean = False;
      keep_array_indentation: Boolean = False):string;
var jsb:Tjs_beautify;
begin
  jsb := Tjs_beautify.Create(
  js_source_text,
  indent_size,
  indent_char,
  preserve_newlines,
  max_preserve_newlines,
  indent_level,
  space_after_anon_function,
  braces_on_own_line,
  keep_array_indentation
  );
  result:=jsb.getBeauty;
  jsb.free;
end;
end.

