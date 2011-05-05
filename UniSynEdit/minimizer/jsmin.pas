unit jsmin;
{
jsmin.pas - 2010-05-04
Author: Mihail Slobodyanuk (slobodyanukma@ukr.net, slobodyanukma@gmail.com)
Delphi port.

jsmin.js - 2010-01-15
Author: NanaLich (http://www.cnblogs.com/NanaLich)
Another patched version for jsmin.js patched by Billy Hoffman,
this version will try to keep CR LF pairs inside the important comments
away from being changed into double LF pairs.

jsmin.js - 2009-11-05
Author: Billy Hoffman
This is a patched version of jsmin.js created by Franck Marcia which
supports important comments denoted with /*! ...
Permission is hereby granted to use the Javascript version under the same
conditions as the jsmin.js on which it is based.

jsmin.js - 2006-08-31
Author: Franck Marcia
This work is an adaptation of jsminc.c published by Douglas Crockford.
Permission is hereby granted to use the Javascript version under the same
conditions as the jsmin.c on which it is based.

jsmin.c
2006-05-04

Copyright (c) 2002 Douglas Crockford  (www.crockford.com)

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

The Software shall be used for Good, not Evil.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

Update:
add level:
1: minimal, keep linefeeds if single
2: normal, the standard algorithm
3: agressive, remove any linefeed and doesn't take care of potential
missing semicolons (can be regressive)
}

interface
function js_min(input: string; level: Integer): string;

implementation
uses Classes, functions, SysUtils;
const
  LETTERS = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
  DIGITS = '0123456789';
  ALNUM = LETTERS + DIGITS + '_$\';
  EOF = 'EOF';
type
  Tjsmin = class
    a, b, input, theLookahead: string;
    iChar, lInput, level: integer;
    constructor Create(input: string; level: Integer);
    function has(s: string; c: string): Boolean;
    function isAlphanum(c: string): Boolean;
    function getc(): string;
    function getcIC(): string;
    function peek(): string;
    function next(): string;
    function action(d: integer): string;
    function m(): string;
    function getOptimized(): string;
  end;

function js_min(input: string; level: Integer): string;
var
  jsb: Tjsmin;
begin
  jsb := Tjsmin.Create(input, level);
  result := jsb.getOptimized;
  jsb.free;
end;

function Tjsmin.has(s: string; c: string): Boolean;
begin
  Result := pos(c, s) > 0;
end;

constructor Tjsmin.Create(input: string; level: Integer);
begin
  a := '';
  b := '';
  theLookahead := EOF;
  iChar := 1;
  lInput := Length(input);
  Self.input := input;
  Self.level := level;
end;

{ isAlphanum -- return true if the character is a letter, digit, underscore,
dollar sign, or non-ASCII character.
}

function Tjsmin.isAlphanum(c: string): Boolean;
begin
  result := (Length(c) = 1) and ((c <> EOF) and (has(ALNUM, c) or (c[1] >
    #126)));
end;

{ getc(IC) -- return the next character. Watch out for lookahead. If the
character is a control character, translate it to a space or
linefeed.
}

function Tjsmin.getc(): string;
var
  c: string;
begin
  c := theLookahead;
  if (iChar > lInput) then
  begin
    result := EOF;
    Exit;
  end;
  theLookahead := EOF;
  if (c = EOF) then
  begin
    c := input[iChar];
    Inc(iChar);
  end;
  if (c >= ' ') or (c = #13) then
  begin
    result := c;
    Exit;
  end;
  if (c = #10) then
  begin
    result := #13;
    Exit;
  end;
  result := ' ';
end;

function Tjsmin.getcIC(): string;
var
  c: string;
begin
  c := theLookahead;
  if (iChar = lInput) then
  begin
    result := EOF;
    Exit;
  end;
  theLookahead := EOF;
  if (c = EOF) then
  begin
    c := input[iChar];
    Inc(iChar);
  end;
  if (c >= ' ') or (c = #13) or (c = #10) then
  begin
    result := c;
    Exit;
  end;
  result := ' ';
end;

{ peek -- get the next character without getting it.
}

function Tjsmin.peek(): string;
begin
  theLookahead := getc();
  Result := theLookahead;
end;

{ next -- get the next character, excluding comments. peek() is used to see
if a '/' is followed by a '/' or '*'.
}

function Tjsmin.next(): string;
var
  c: string;
  d: string;
  pk: string;
begin
  c := getc();
  if (c = '/') then
  begin
    pk := peek;
    if pk = '/' then
      while true do
      begin
        c := getc();
        if (c <= #13) then
        begin
          result := c;
          Exit;
        end;
      end
    else if pk = '*' then
    begin
      //this is a comment. What kind?
      getc();
      if (peek() = '!') then
      begin
        // kill the extra one
        getc();
        //important comment
        d := '/*!';
        while true do
        begin
          c := getcIC(); // let it know it's inside an important comment
          if c = '*' then
          begin
            if (peek() = '/') then
            begin
              getc();
              result := d + '*/';
              Exit;
            end;
          end
          else if c = EOF then
            raise Exception.Create('Error: Unterminated comment.')
          else
            //modern JS engines handle string concats much better than the
            //array+push+join hack.
            d := d + c;
        end;
      end
      else
      begin
        //unimportant comment
        while true do
        begin
          pk:=getc();
          if pk = '*' then
          begin
            if (peek() = '/') then
            begin
              getc();
              result := ' ';
              Exit;
            end;
          end
          else if pk = EOF then
            raise Exception.Create('Error: Unterminated comment.');
        end;
      end;
    end
    else
    begin
      result := c;
      Exit;
    end;
  end;
  result := c;
end;

{ action -- do something! What you do is determined by the argument:
1   Output A. Copy B to A. Get the next B.
2   Copy B to A. Get the next B. (Delete A).
3   Get the next B. (Delete B).
action treats a string as a single character. Wow!
action recognizes a regular expression if it is preceded by ( or , or =.
}

function Tjsmin.action(d: integer): string;
var
  r: TStringList;
begin

  r := TStringList.Create();

  if (d = 1) then
  begin
    r.add(a);
  end;

  if (d < 3) then
  begin
    a := b;
    if (a = '''') or (a = '"') then
    begin
      while true do
      begin
        r.add(a);
        a := getc();
        if (a = b) then
        begin
          break;
        end;
        if (a <= #13) then
        begin
          raise Exception.Create('Error: unterminated string literal: ' + a);
        end;
        if (a = '\') then
        begin
          r.add(a);
          a := getc();
        end;
      end;
    end;
  end;

  b := next();

  if (b = '/') and (has('(,=:[!&|', a)) then
  begin
    r.add(a);
    r.add(b);
    while true do
    begin
      a := getc();
      if (a = '/') then
      begin
        break;
      end
      else if (a = '\') then
      begin
        r.add(a);
        a := getc();
      end
      else if (a <= #13) then
      begin
        raise
          Exception.Create('Error: unterminated Regular Expression literal');
      end;
      r.add(a);
    end;
    b := next();
  end;

  result := join(r);
  r.free;
end;

{ m -- Copy the input to the output, deleting the characters which are
insignificant to JavaScript. Comments will be removed. Tabs will be
replaced with spaces. Carriage returns will be replaced with
linefeeds.
Most spaces and linefeeds will be removed.
}

function Tjsmin.m(): string;
var
  r: TStringList;
begin
  r := TStringList.Create();
  a := #13;
  r.add(action(3));

  while (a <> EOF) do
  begin
    if a = ' ' then
    begin
      if (isAlphanum(b)) then
      begin
        r.add(action(1));
      end
      else
      begin
        r.add(action(2));
      end;
    end
    else if a = #13 then
    begin
      if has('{[(+-', b) then
        r.add(action(1))
      else if b = ' ' then
        r.add(action(3))
      else
      begin
        if (isAlphanum(b)) then
        begin
//          r.add(action(1));
          action(1);
        end
        else
        begin
          if (level = 1) and (b <> #13) then
          begin
            r.add(action(1));
          end
          else
          begin
            r.add(action(2));
          end;
        end;
      end
    end
    else if b = ' ' then
    begin
      if (isAlphanum(a)) then
      begin
        r.add(action(1));
        continue;
      end;
      r.add(action(3));
    end
    else if b = #13 then
    begin
      if (level = 1) and (a <> #13) then
      begin
        r.add(action(1));
      end
      else
      begin
        if has('}])+-"''', a) then
        begin
          if (level = 3) then
          begin
            r.add(action(3));
          end
          else
          begin
            r.add(action(1));
          end
        end
        else if (isAlphanum(a)) then
        begin
          r.add(action(1));
        end
        else
        begin
          r.add(action(3));
        end;
      end;
    end
    else
      r.add(action(1));
  end;
  result := join(r);
  r.free;
end;

function Tjsmin.getOptimized(): string;
begin
  result := m;

end;
end.

