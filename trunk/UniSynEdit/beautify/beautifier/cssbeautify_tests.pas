unit cssbeautify_tests;

interface
procedure run_css_beautifier_tests();
implementation
uses cssbeautify, SysUtils, Classes;
type
  EExpectationException = class(Exception);

var
    flags:record
      indent_size:integer;
      indent_char:char;
    end;

function toUnix(input:string):string;
begin
  result:=StringReplace(input, #13#10, #10, [rfReplaceAll]);
end;

procedure expect(input, expected:string);
var output:string;
begin
  output:= css_beautify(
  input,
  flags.indent_size,
  flags.indent_char,
  0);
  if toUnix(output) <> toUnix(expected) then
    raise EExpectationException.Create('Input:`'#10+input+#10'` Expected:`'#10+expected+#10'`, but get:`'#10+output+#10'`');
end;

// test the input on beautifier with the current flag settings
// does not check the indentation / surroundings as bt() does
procedure test_fragment(input:string; expected:string='');
begin
    if expected='' then expected := input;
    expect(input, expected);
end;

procedure run_css_beautifier_tests();
begin
    flags.indent_size       := 4;
    flags.indent_char       := ' ';

    test_fragment('body{color:#000;margin:3px  0}', 'body {'#10'color:#000;'#10'margin:3px 0'#10'}');
    test_fragment('/*comment*/z{a:b;}',	'/*comment*/'#10'z {'#10'a:b;'#10'}');
    test_fragment('z{a:b;/*comment*/}',	'z {'#10'a:b; /*comment*/'#10'}');
    test_fragment('z{'#10'/*comment*/'#10'a:b;}',	'z {'#10'/*comment*/'#10'a:b;'#10'}');
    test_fragment('z{'#10'/*comment'#10'for attribute*/'#10'a:b;}',	'z {'#10'/*comment'#10'for attribute*/'#10'a:b;'#10'}');
end;
end.
