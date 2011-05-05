unit cssmin_tests;

interface
procedure run_css_min_tests();
implementation
uses cssmin, SysUtils, Classes;
type
  EExpectationException = class(Exception);

var
    flags:record
      level: Integer;
      remove_empty_rulesets: Boolean;
      remove_last_semicolons: Boolean;
      remove_comments: Boolean;
    end;

function toUnix(input:string):string;
begin
  result:=StringReplace(input, #13#10, #10, [rfReplaceAll]);
end;

procedure expect(input, expected:string);
var output:string;
begin
  output:= css_min(
  input,
  flags.level,
  flags.remove_last_semicolons,
  flags.remove_comments);
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

procedure run_css_min_tests();
begin
    flags.level       := 1;
    flags.remove_empty_rulesets       := false;
    flags.remove_last_semicolons       := false;
    flags.remove_comments       := false;

    test_fragment('body {color:#000; margin:3px  0'#10'}', 'body{color:#000;margin:3px 0}');
    test_fragment('z{a:b;}',	'z{a:b;}');
    test_fragment('/*comment*/z{a:b;}',	'/*comment*/'#10'z{a:b;}');
    test_fragment('z{'#10'/*comment*/'#10'a:b;}',	'z{'#10'/*comment*/'#10'a:b;}');
    test_fragment('z{'#10'/*comment'#10'for attribute*/'#10'a:b;}',	'z{'#10'/*comment for attribute*/'#10'a:b;}');

    flags.remove_comments       := true;
    test_fragment('/*comment*/z{a:b;}',	'z{a:b;}');
    test_fragment('z{'#10'/*comment*/'#10'a:b;}',	'z{a:b;}');
    test_fragment('z{'#10'/*comment'#10'for attribute*/'#10'a:b;}',	'z{a:b;}');

    flags.remove_last_semicolons       := true;
    test_fragment('z{a:b;}z{a:b;}',	'z{a:b}'#10'z{a:b}');

    flags.remove_last_semicolons       := false;
    flags.remove_comments       := false;
    flags.level       := 2;
    test_fragment('z { a: b; }'#10'z  {a :b;}',	'z{a:b;}z{a:b;}');
    test_fragment('z{'#10'/*comment'#10'for attribute*/'#10'a:b;}',	'z{/*comment for attribute*/a:b;}');

end;
end.
