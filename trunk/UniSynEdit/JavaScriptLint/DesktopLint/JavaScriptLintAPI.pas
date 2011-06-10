unit JavaScriptLintAPI;

interface
uses Classes;

// The path to the configuration file may be blank.
function LintString(sBinaryPath, sConfigPath, code: string;
  messages: TStringList; var error: string): boolean;
function StripCSlashes(encoded: string): string;

implementation
uses SysUtils, Windows, Forms;

function GetLastErrorString: string;
begin
  Result := SysErrorMessage(GetLastError);
end;

function EscapeAndQuoteParameter(parameter: string): string;
begin
  result := parameter;
  StringReplace(result, '\', '\\', [rfReplaceAll]);
  StringReplace(result, '"', '\"', [rfReplaceAll]);
  result := '"' + result + '"';
end;

function StripCSlashes(encoded: string): string;
begin
  result := encoded;
  StringReplace(result, '\n', #10, [rfReplaceAll]);
  StringReplace(result, '\r', #13, [rfReplaceAll]);
  StringReplace(result, '\t', #9, [rfReplaceAll]);
  StringReplace(result, '\''', '''', [rfReplaceAll]);
  StringReplace(result, '\"', '"', [rfReplaceAll]);
  StringReplace(result, '\\', '\', [rfReplaceAll]);
end;

function ExecuteFile(FileName,StdInput: string;
                     TimeOut: integer;
                     var StdOutput:string;
                     var errorMsg: string) : boolean;

label Error;

type
  TPipeHandles = (IN_WRITE,  IN_READ,
                  OUT_WRITE, OUT_READ,
                  ERR_WRITE, ERR_READ);

type
  TPipeArray = array [TPipeHandles] of THandle;

var
  i         : Cardinal;
  ph        : TPipeHandles;
  sa        : TSecurityAttributes;
  Pipes     : TPipeArray;
  StartInf  : TStartupInfo;
  ProcInf   : TProcessInformation;
  Buf       : array[0..1024] of byte;
  TimeStart : TDateTime;


  function ReadOutput: string;
  var
    i: integer;
    s: string;
    BytesRead: Cardinal;

  begin
    Result := '';
    repeat

      Buf[0] := 26;
      WriteFile(Pipes[OUT_WRITE], Buf, 1, BytesRead, nil);
      if ReadFile(Pipes[OUT_READ], Buf, 1024, BytesRead, nil) then
      begin
        if BytesRead > 0 then
        begin
          buf[BytesRead] := 0;
          s := StrPas(@Buf[0]);
          i := Pos(#26, s);
          if i > 0 then
            s := copy(s, 1, i - 1);
          Result := Result + s;
        end;
      end;

      if BytesRead<1024 then
        break;
    until false;
  end;

begin
  Result := false;
  for ph := Low(TPipeHandles) to High(TPipeHandles) do
    Pipes[ph] := INVALID_HANDLE_VALUE;

  // Создаем пайпы
  sa.nLength := sizeof(sa);
  sa.bInheritHandle := TRUE;
  sa.lpSecurityDescriptor := nil;

  if not CreatePipe(Pipes[IN_READ], Pipes[IN_WRITE], @sa, 0) then
    goto Error;
  if not CreatePipe(Pipes[OUT_READ], Pipes[OUT_WRITE], @sa, 0) then
    goto Error;
  if not CreatePipe(Pipes[ERR_READ], Pipes[ERR_WRITE], @sa, 0) then
    goto Error;

  // Пишем StdIn
  StrPCopy(@Buf[0], stdInput + ^Z);
  WriteFile(Pipes[IN_WRITE], Buf, Length(stdInput), i, nil);

  // Хендл записи в StdIn надо закрыть - иначе выполняемая программа
  // может не прочитать или прочитать не весь StdIn.

  CloseHandle(Pipes[IN_WRITE]);

  Pipes[IN_WRITE] := INVALID_HANDLE_VALUE;

  FillChar(StartInf, sizeof(TStartupInfo), 0);
  StartInf.cb := sizeof(TStartupInfo);
  StartInf.dwFlags := STARTF_USESHOWWINDOW or STARTF_USESTDHANDLES;

  StartInf.wShowWindow := SW_SHOW; // SW_HIDE если надо запустить невидимо

  StartInf.hStdInput := Pipes[IN_READ];
  StartInf.hStdOutput := Pipes[OUT_WRITE];
  StartInf.hStdError := Pipes[ERR_WRITE];

  if not CreateProcess(nil, PChar(FileName), nil,
    nil, True, NORMAL_PRIORITY_CLASS,
    nil, nil, StartInf, ProcInf) then
    goto Error;

  TimeStart := Now;

  repeat
    Application.ProcessMessages;
    i := WaitForSingleObject(ProcInf.hProcess, 100);
    if i = WAIT_OBJECT_0 then
      break;
    if (Now - TimeStart) * SecsPerDay > TimeOut then
      break;
  until false;

  if i<WAIT_OBJECT_0 then
    goto Error;
  StdOutput := ReadOutput;

  for ph := Low(TPipeHandles) to High(TPipeHandles) do
    if Pipes[ph]<INVALID_HANDLE_VALUE then
      CloseHandle(Pipes[ph]);

  CloseHandle(ProcInf.hProcess);
  CloseHandle(ProcInf.hThread);
  Result := true;
  Exit;


Error:
  errorMsg:= GetLastErrorString();
  if ProcInf.hProcess=INVALID_HANDLE_VALUE then

  begin
    CloseHandle(ProcInf.hThread);
    i := WaitForSingleObject(ProcInf.hProcess, 1000);
    CloseHandle(ProcInf.hProcess);
    if i<WAIT_OBJECT_0 then

    begin
      ProcInf.hProcess := OpenProcess(PROCESS_TERMINATE,
                                      FALSE,
                                      ProcInf.dwProcessId);

      if ProcInf.hProcess = 0 then
      begin
        TerminateProcess(ProcInf.hProcess, 0);
        CloseHandle(ProcInf.hProcess);
      end;
    end;
  end;

  for ph := Low(TPipeHandles) to High(TPipeHandles) do
    if Pipes[ph] = INVALID_HANDLE_VALUE then
      CloseHandle(Pipes[ph]);

end;

function ExecuteProcess(commandline, input: string; var output: string; var
  error: string): boolean;
var
  saAttr: TSecurityAttributes;
  hChildStdoutRd, hChildStdoutWr, hChildStdinRd, hChildStdinWr: THandle;
  piProcInfo: TProcessInformation;
  siStartInfo: TStartupInfo;
  dwBytesRead, dwBytesWritten: DWORD;
  chBuf: array[0..415] of CHAR;
  i: Integer;
begin
  // SEE http://msdn.microsoft.com/library/en-us/dllproc/base/creating_a_child_process_with_redirected_input_and_output.asp?frame=true
  output := '';
  result := False;
  // Set the bInheritHandle flag so pipe handles are inherited.
  saAttr.nLength := sizeof(TSecurityAttributes);
  saAttr.bInheritHandle := TRUE;
  saAttr.lpSecurityDescriptor := nil;

  // Create a pipe for the child process's STDOUT that is not inherited
  if (not CreatePipe(hChildStdoutRd, hChildStdoutWr, @saAttr, 0)) then
  begin
    error := GetLastErrorString();
    exit;
  end;
  SetHandleInformation(hChildStdoutRd, HANDLE_FLAG_INHERIT, 0);

  // Create a pipe for the child process's STDIN that is not inherited
  if (not CreatePipe(hChildStdinRd, hChildStdinWr, @saAttr, 0)) then
  begin
    error := GetLastErrorString();
    exit;
  end;
  SetHandleInformation(hChildStdinWr, HANDLE_FLAG_INHERIT, 0);

  // Create the child process
  ZeroMemory(@piProcInfo, sizeof(TProcessInformation));

  ZeroMemory(@siStartInfo, sizeof(TStartupInfo));
  siStartInfo.cb := sizeof(TStartupInfo);
  siStartInfo.hStdError := hChildStdoutWr;
  siStartInfo.hStdOutput := hChildStdoutWr;
  siStartInfo.hStdInput := hChildStdinRd;
  siStartInfo.dwFlags := siStartInfo.dwFlags and STARTF_USESTDHANDLES and
    STARTF_USESHOWWINDOW;

  if (not CreateProcess(nil,
    PChar(commandline), // command line
    nil, // process security attributes
    nil, // primary thread security attributes
    TRUE, // handles are inherited
    0, // creation flags
    nil, // use parent's environment
    nil, // use parent's current directory
    siStartInfo, // STARTUPINFO pointer
    piProcInfo)) {// receives PROCESS_INFORMATION} then
  begin
    error := GetLastErrorString();
    exit;
  end;
  CloseHandle(piProcInfo.hProcess);
  CloseHandle(piProcInfo.hThread);

  // write the result and close the file so the client stops reading
  dwBytesWritten := 0;
  if (not WriteFile(hChildStdinWr, PChar(input)^, length(input), dwBytesWritten, nil))
    then
  begin
    error := GetLastErrorString();
    exit;
  end;
  if (not CloseHandle(hChildStdinWr)) then
  begin
    error := GetLastErrorString();
    exit;
  end;

  // Close the write end of the pipe before reading from the read end of the pipe.
  if (not CloseHandle(hChildStdoutWr)) then
  begin
    error := GetLastErrorString();
    exit;
  end;

  // Read output from the child process, and write to parent's STDOUT.
  while True do
  begin
    if (not ReadFile(hChildStdoutRd, chBuf, sizeof(chBuf), dwBytesRead, nil))
      then
    begin
      if (GetLastError() = ERROR_BROKEN_PIPE) then
        break;
      error := 'The output pipe could not be read. ' + GetLastErrorString();
      Exit;
    end;
    if (dwBytesRead = 0) then
      break;
    for i := 0 to dwBytesRead - 1 do
      output := output + chBuf[i];
  end;
  result := true;
end;

function LintString(sBinaryPath, sConfigPath, code: string;
  messages: TStringList; var error: string): boolean;
var
  commandline, results: string;
  lines: TStringList;
  i, j: Integer;
begin
  result := false;
  // Construct the command line
  commandline := commandline + EscapeAndQuoteParameter(sbinaryPath);
  if length(sconfigPath) > 0 then
  begin
    commandline := commandline + ' -conf ';
    commandline := commandline + EscapeAndQuoteParameter(sconfigPath);
  end;
  commandline := commandline + ' -stdin';
  commandline := commandline + ' -context -nologo -nofilelisting -nosummary';
  commandline := commandline +
    ' -output-format "encode:__LINE__'#9'__COL__'#9'__ERROR_PREFIX__'#9'__ERROR_MSG__"';
//    ' -output-format "encode:__LINE__'#9'__COL__'#9'__ERROR_NAME__'#9'__ERROR_PREFIX__'#9'__ERROR_MSG__"';

  // Run the Lint
//  if (not ExecuteProcess(commandline, code, results, error)) then
  if (not ExecuteFile(commandline, code, 1000, results, error)) then
  begin
    error := 'Unable to run JavaScript Lint. ' + error;
    Exit;
  end;

  StringReplace(results, #13#10, #10, [rfReplaceAll]);

  // Parse the messages
  lines := TStringList.Create;
  lines.Delimiter := #10;
  lines.Text := results;
  for i := 0 to lines.Count - 1 do
  begin
    // Skip blank lines
    if Length(Trim(lines.Strings[i])) = 0 then
      continue;
    messages.Add(lines.Strings[i]);
  end;
  lines.Free;
  result := true;
end;
end.

