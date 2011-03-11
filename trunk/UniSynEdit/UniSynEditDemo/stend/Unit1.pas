unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, SynEditHighlighter, SynHighlighterPas, StdCtrls, SynEdit,
  ComCtrls, ToolWin, ExtCtrls, SynEditCodeFolding, SynUnicode, JclDebug,
  JclHookExcept, TypInfo;

type
  TForm1 = class(TForm)
    SynEdit1: TSynEdit;
    ListBox1: TListBox;
    SynEdit2: TSynEdit;
    SynPasSyn1: TSynPasSyn;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    ToolButton2: TToolButton;
    Memo1: TMemo;
    Splitter3: TSplitter;
    procedure FormCreate(Sender: TObject);
    procedure ToolButton1Click(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
    procedure ToolButton2Click(Sender: TObject);
    procedure SynEdit1GutterClick(Sender: TObject; Button: TMouseButton; X,
      Y, Line: Integer; Mark: TSynEditMark);
  private
    { Private declarations }
  public
    procedure AppException(Sender: TObject; E: Exception);
    procedure LogException(ExceptObj: TObject; ExceptAddr: Pointer;       IsOS: Boolean);
    { Public declarations }

  end;
  TExceptHandler = class(TObject)
    procedure OnException(Sender: TObject; E: Exception);
  end;

var
  Form1: TForm1;
  ExceptHandler: TExceptHandler;

implementation

uses Unit2;

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
begin
  JclAddExceptNotifier(Form1.LogException);
//  Application.OnException := AppException;
  with SynEdit1 do
  begin
    CodeFolding.Enabled := true;
    CodeFolding.FolderBarColor := clWindow;
    CodeFolding.FolderBarLinesColor := clHighlight;
    CodeFolding.IndentGuides := True;
    CodeFolding.HighlighterFoldRegions := true;
    //    CodeFolding.CollapsingMarkStyle := TSynCollapsingMarkStyle(0);
    CodeFolding.CollapsedCodeHint := true;
    CodeFolding.ShowCollapsedLine := true;
    CodeFolding.HighlightIndentGuides := true;
    InsertMode := true;

    Lines.LoadFromFile('uHighlighterProcs_res.pas');

    InitCodeFolding;

  end;
  with SynEdit2 do
  begin
    CodeFolding.Enabled := true;
    CodeFolding.FolderBarColor := clWindow;
    CodeFolding.FolderBarLinesColor := clHighlight;
    CodeFolding.IndentGuides := True;
    CodeFolding.HighlighterFoldRegions := true;
    //    CodeFolding.CollapsingMarkStyle := TSynCollapsingMarkStyle(0);
    CodeFolding.CollapsedCodeHint := true;
    CodeFolding.ShowCollapsedLine := true;
    CodeFolding.HighlightIndentGuides := true;
    InsertMode := true;
  end;
end;

procedure TForm1.ToolButton1Click(Sender: TObject);
var
  SubFromLine, SubToLine, i: integer;
begin
  ListBox1.Clear;

  for i := 0 to SynEdit1.AllFoldRanges.AllCount - 1 do
  begin

    if not (SynEdit1.AllFoldRanges[i].SubFoldRanges = nil) and
      (SynEdit1.AllFoldRanges[i].SubFoldRanges.Count > 0) then
    begin
      SubFromLine :=
        SynEdit1.AllFoldRanges[i].SubFoldRanges.FoldRanges[0].FromLine;
      SubToLine := SynEdit1.AllFoldRanges[i].SubFoldRanges.FoldRanges[0].ToLine;
    end;
    ListBox1.Items.AddObject(
      format('Lines:%d - %d, level: %d, ColapsedBy:%d, real: %d,%d sub: %d,%d', [
      SynEdit1.AllFoldRanges[i].FromLine,
        SynEdit1.AllFoldRanges[i].ToLine,
        SynEdit1.AllFoldRanges[i].Level,
        SynEdit1.AllFoldRanges[i].CollapsedBy,
        SynEdit1.GetRealLineNumber(SynEdit1.AllFoldRanges[i].FromLine),
        SynEdit1.GetRealLineNumber(SynEdit1.AllFoldRanges[i].ToLine),
        SubFromLine,
        SubToLine])
        , SynEdit1.AllFoldRanges[i]);
  end;
end;

procedure TForm1.ListBox1Click(Sender: TObject);
var
  i: integer;
  FoldRange: TSynEditFoldRange;
begin
  SynEdit2.Lines.Clear;
  FoldRange := TSynEditFoldRange(ListBox1.Items.Objects[ListBox1.ItemIndex]);
  if FoldRange.CollapsedLines.Count > 0 then
    for i := FoldRange.CollapsedLines.Count - 1 downto 0 do
    begin
      SynEdit2.Lines.Add(FoldRange.CollapsedLines[i]);
    end;
  SynEdit2.InitCodeFolding;

end;

procedure TForm1.ToolButton2Click(Sender: TObject);
var
  StringList: TUnicodeStrings;
  i: integer;
begin
  // i :=SynEdit1.AllFoldRanges.FoldRanges[0].FromLine;
  //SynEdit1.AllFoldRanges.FoldRanges[0]
  StringList := SynEdit1.AllFoldRanges.FoldRanges[0].CollapsableLinesForLine(25,
    nil);
  if StringList <> nil then
    for i := 0 to StringList.Count - 1 do
    begin
      Memo1.Lines.Add(StringList[i]);
    end;
end;

procedure TExceptHandler.OnException(Sender: TObject; E: Exception);
var
  Info: TJclLocationInfo;
  //  addr:Pointer;
begin
  //HandleError(PChar(E.Message));

  if GetLocationInfo(Pointer(e.HelpContext), Info) then
  begin
    MessageDlg(Format('%s: Addr:%p; unit:%s [%d] %s %s', [
      Info.BinaryFileName,
        Info.Address,
        Info.UnitName,
        Info.LineNumber,
        Info.ProcedureName,
        Info.SourceName]), mtError, [mbOK], 0);

  end;
end;

// процедура, вызываемая при возникновении исключения

procedure AnyExceptionNotify(
  ExceptObj: TObject; ExceptAddr: Pointer; OSException: Boolean);
begin
  with Form2 do
  begin
    mmLog.Lines.BeginUpdate;
    mmLog.Clear;
    JclLastExceptStackListToStrings(mmLog.Lines, false, True, True);
    mmLog.Lines.EndUpdate;
    Show;
  end;

end;

procedure TForm1.AppException(Sender: TObject; E: Exception);
var
  Info: TJclLocationInfo;
  //  addr:Pointer;
begin
  //HandleError(PChar(E.Message));
  if GetLocationInfo(Pointer(e.HelpContext), Info) then
  begin
    MessageDlg(Format('%s: Addr:%p; unit:%s [%d] %s %s', [
      Info.BinaryFileName,
        Info.Address,
        Info.UnitName,
        Info.LineNumber,
        Info.ProcedureName,
        Info.SourceName]), mtError, [mbOK], 0);
  end;
end;

procedure TForm1.LogException(ExceptObj: TObject; ExceptAddr: Pointer;
  IsOS: Boolean);
var
  TmpS: string;
  ModInfo: TJclLocationInfo;
  I: Integer;
  ExceptionHandled: Boolean;
  HandlerLocation: Pointer;
  ExceptFrame: TJclExceptFrame;

begin
  with Form2 do
  begin
    TmpS := 'Exception ' + ExceptObj.ClassName;
    if ExceptObj is Exception then
      TmpS := TmpS + ': ' + Exception(ExceptObj).Message;
    if IsOS then
      TmpS := TmpS + ' (OS Exception)';
    mmLog.Lines.Add(TmpS);
    ModInfo := GetLocationInfo(ExceptAddr);
    mmLog.Lines.Add(Format(
      '  Exception occured at $%p (Module "%s", Procedure "%s", Unit "%s", Line %d)',
      [ModInfo.Address,
      ModInfo.UnitName,
        ModInfo.ProcedureName,
        ModInfo.SourceName,
        ModInfo.LineNumber]));
    if stExceptFrame in JclStackTrackingOptions then
    begin
      mmLog.Lines.Add('  Except frame-dump:');
      I := 0;
      ExceptionHandled := False;
      while ({chkShowAllFrames.Checked or }not ExceptionHandled) and
        (I < JclLastExceptFrameList.Count) do
      begin
        ExceptFrame := JclLastExceptFrameList.Items[I];
        ExceptionHandled := ExceptFrame.HandlerInfo(ExceptObj, HandlerLocation);
        if (ExceptFrame.FrameKind = efkFinally) or
          (ExceptFrame.FrameKind = efkUnknown) or
          not ExceptionHandled then
          HandlerLocation := ExceptFrame.CodeLocation;
        ModInfo := GetLocationInfo(HandlerLocation);
        TmpS := Format(
          '    Frame at $%p (type: %s',
          [ExceptFrame.FrameLocation,
          GetEnumName(TypeInfo(TExceptFrameKind), Ord(ExceptFrame.FrameKind))]);
        if ExceptionHandled then
          TmpS := TmpS + ', handles exception)'
        else
          TmpS := TmpS + ')';
        mmLog.Lines.Add(TmpS);
        if ExceptionHandled then
          mmLog.Lines.Add(Format(
            '      Handler at $%p',
            [HandlerLocation]))
        else
          mmLog.Lines.Add(Format(
            '      Code at $%p',
            [HandlerLocation]));
        mmLog.Lines.Add(Format(
          '      Module "%s", Procedure "%s", Unit "%s", Line %d',
          [ModInfo.UnitName,
          ModInfo.ProcedureName,
            ModInfo.SourceName,
            ModInfo.LineNumber]));
        Inc(I);
      end;
    end;
    mmLog.Lines.Add('');
    Show;
  end;
end;

procedure TForm1.SynEdit1GutterClick(Sender: TObject; Button: TMouseButton;
  X, Y, Line: Integer; Mark: TSynEditMark);
begin
     ToolButton1Click(Sender);
end;

initialization

  //...
//  ExceptProc:=@ExceptHandler;

  // инициализация механизма перехвата исключений
  Include(JclStackTrackingOptions, stRawMode);
  Include(JclStackTrackingOptions, stExceptFrame);
  JclStartExceptionTracking;
//  JclAddExceptNotifier(TForm1.LogException);

end.

