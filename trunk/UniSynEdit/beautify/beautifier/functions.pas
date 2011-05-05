unit functions;
interface
uses classes;
type
  TStringArray = array of string;
    //split string by delimiter to list. If Delimiter is empty, then split by each character
    function split(Input: string; Delimiter: string = ''): TStringArray;
    function in_array(what: string; arr: array of string): Boolean;
    function join(strings:TStringList; Delimiter: string = ''):string;
implementation
uses StrUtils;

function join(strings:TStringList; Delimiter: string = ''):string;
var i:Integer;
begin
  result := '';
  for i := 0 to strings.Count - 1 do
    result := result + strings.Strings[i];
end;

function split(Input: string; Delimiter: string = ''): TStringArray;
var
  i, position, oldposition, delLen, inputLen, endPos: Integer;
  Strings: TStringArray;
begin
  inputLen := Length(input);
  setlength(Strings, inputLen);
  if Length(delimiter) = 0 then
  begin
    for i := 1 to inputLen do
      Strings[i - 1] := Input[i];
  end
  else
  begin
    dellen := Length(delimiter);
    i := 0;
    position := pos(Delimiter, Input);
    if position=0 then
      Strings[0] := Input
    else
      Strings[0] := Copy(Input, 1, position - 1);
    oldposition:=-1;
    while (position > 0) and (position <= inputLen) and (oldposition <> position) do
    begin
      Inc(i);
      oldposition := position;
      position := posEx(Delimiter, Input, position + 1);
      if (i>0) and (position=0) then
        endPos := inputLen+1
      else
        endPos := position;
      Strings[i] := Copy(Input, oldposition + dellen, endPos- (oldposition + dellen));
    end;
    setlength(Strings, i+1);
  end;
  result := strings;
end;

function in_array(what: string; arr: array of string): Boolean;
var
  i: Integer;
begin
  for i := Low(arr) to high(arr) do
  begin
    if (arr[i] = what) then
    begin
      result := true;
      Exit;
    end;
  end;
  result := false;
end;

end.
