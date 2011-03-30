unit DemoUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, SynEdit, Menus, ImgList, Buttons, SynEditHighlighter,
  SynHighlighterPas, StdCtrls, ComCtrls, Spin,
  SynEditCodeFolding, SynEditMiscClasses, cxStyles, cxGraphics, cxEdit,
  cxControls,
  cxInplaceContainer, cxVGrid, cxOI, SynHighlighterJava, ExtCtrls,
  SynHighlighterXML, SynHighlighterAsm, SynHighlighterVB,
  SynHighlighterPython, SynHighlighterPHP, SynHighlighterPerl,
  SynHighlighterVBScript, SynHighlighterJScript, SynHighlighterIni,
  SynHighlighterHtml, SynHighlighterCSS, SynHighlighterCpp,
  SynHighlighterCS, SynHighlighterWeb, JclDebug, JclHookExcept, TypInfo,
  ToolWin, ActnList;

const
  Colors: array[1..42 {sic!}] of TColor = (clBlack, clMaroon, clGreen, clOlive,
    clNavy, clPurple, clTeal, clDkGray, clLtGray, clRed, clLime,
    clYellow, clBlue, clFuchsia, clAqua, clWhite, clScrollBar,
    clBackground, clActiveCaption, clInactiveCaption, clMenu, clWindow,
    clWindowFrame, clMenuText, clWindowText, clCaptionText,
    clActiveBorder, clInactiveBorder, clAppWorkSpace, clHighlight,
    clHighlightText, clBtnFace, clBtnShadow, clGrayText, clBtnText,
    clInactiveCaptionText, clBtnHighlight, cl3DDkShadow, cl3DLight,
    clInfoText, clInfoBk, clNone);

type
  TForm1 = class(TForm)
    SpeedButton1: TSpeedButton;
    SynPasSyn1: TSynPasSyn;
    FontDialog1: TFontDialog;
    SynEdit1: TSynEdit;
    MainMenu2: TMainMenu;
    File2: TMenuItem;
    Open2: TMenuItem;
    N2: TMenuItem;
    Exit1: TMenuItem;
    Collapsed1: TMenuItem;
    CollapsAll1: TMenuItem;
    N21: TMenuItem;
    OpenDialog1: TOpenDialog;
    cxRTTIInspector1: TcxRTTIInspector;
    SynCSSyn1: TSynCSSyn;
    SynCppSyn1: TSynCppSyn;
    SynIniSyn1: TSynIniSyn;
    SynJavaSyn1: TSynJavaSyn;
    SynVBScriptSyn1: TSynVBScriptSyn;
    SynPerlSyn1: TSynPerlSyn;
    SynVBSyn1: TSynVBSyn;
    SynWebEsSyn1: TSynWebEsSyn;
    SynWebXmlSyn1: TSynWebXmlSyn;
    New1: TMenuItem;
    SynWebPhpCliSyn1: TSynWebPhpCliSyn;
    SynWebEngine1: TSynWebEngine;
    SynWebHtmlSyn1: TSynWebHtmlSyn;
    imglMain: TImageList;
    ImageList_1: TImageList;
    tbMain: TToolBar;
    ComboBox1: TComboBox;
    ToolButton1: TToolButton;
    actlMain: TActionList;
    FileNew: TAction;
    FileOpen: TAction;
    FileSave: TAction;
    FileSaveAs: TAction;
    ViewCollapseCurrent: TAction;
    FileSaveAll: TAction;
    FileClose: TAction;
    FileCloseAll: TAction;
    FilePrint: TAction;
    FileExit: TAction;
    EditUndo: TAction;
    EditRedo: TAction;
    EditCut: TAction;
    EditCopy: TAction;
    EditPaste: TAction;
    EditDelete: TAction;
    EditSelectAll: TAction;
    EditIndent: TAction;
    EditUnindent: TAction;
    EditDeleteWord: TAction;
    SearchFind: TAction;
    SearchFindNext: TAction;
    SearchReplace: TAction;
    SearchReplaceNext: TAction;
    SearchGoToLine: TAction;
    HelpTopics: TAction;
    ViewToolbar: TAction;
    ViewStatusBar: TAction;
    ViewCollapseAll: TAction;
    ViewUncollapseAll: TAction;
    ViewShowGutter: TAction;
    ViewShowLineNumbers: TAction;
    ViewShowRightMargin: TAction;
    ViewShowSpecialCharacters: TAction;
    ViewWordWrap: TAction;
    ViewFont: TAction;
    ViewShowIndentGuides: TAction;
    ViewSettings: TAction;
    HelpAbout: TAction;
    ViewCollapseLevel0: TAction;
    ViewCollapseLevel1: TAction;
    ViewCollapseLevel2: TAction;
    ViewCollapseLevel3: TAction;
    ViewCollapseLevel4: TAction;
    ViewCollapseLevel5: TAction;
    ViewCollapseLevel6: TAction;
    ViewCollapseLevel7: TAction;
    ViewCollapseLevel8: TAction;
    ViewCollapseLevel9: TAction;
    ViewUncollapseLevel0: TAction;
    ViewUncollapseLevel1: TAction;
    ViewUncollapseLevel2: TAction;
    ViewUncollapseLevel3: TAction;
    ViewUncollapseLevel4: TAction;
    ViewUncollapseLevel5: TAction;
    ViewUncollapseLevel6: TAction;
    ViewUncollapseLevel7: TAction;
    ViewUncollapseLevel8: TAction;
    ViewUncollapseLevel9: TAction;
    ViewDocumentType0: TAction;
    ViewDocumentType1: TAction;
    ViewDocumentType2: TAction;
    ViewDocumentType3: TAction;
    ViewDocumentType4: TAction;
    ViewDocumentType5: TAction;
    ViewDocumentType6: TAction;
    ViewDocumentType7: TAction;
    ViewDocumentType8: TAction;
    ViewDocumentType9: TAction;
    ViewDocumentType10: TAction;
    FileWorkspaceOpen: TAction;
    FileWorkspaceSave: TAction;
    FileWorkspaceSaveAs: TAction;
    FileWorkspaceClose: TAction;
    ViewFunctionList: TAction;
    EditDeleteLine: TAction;
    EditDeleteToEndOfWord: TAction;
    EditDeleteToEndOfLine: TAction;
    EditDeleteWordBack: TAction;
    EditSelectWord: TAction;
    EditSelectLine: TAction;
    EditColumnSelect: TAction;
    ViewOutput: TAction;
    SearchFunctionList: TAction;
    EditChangeCaseUpper: TAction;
    EditChangeCaseLower: TAction;
    EditChangeCaseToggle: TAction;
    EditChangeCaseCapitalize: TAction;
    FileMRUClear: TAction;
    FileMRUOpenAll: TAction;
    FileWorkspaceMRUClear: TAction;
    ToolButton2: TToolButton;
    mnuUncollapse: TPopupMenu;
    N14: TMenuItem;
    N15: TMenuItem;
    UncollapseLevel02: TMenuItem;
    UncollapseLevel12: TMenuItem;
    UncollapseLevel22: TMenuItem;
    UncollapseLevel32: TMenuItem;
    UncollapseLevel42: TMenuItem;
    UncollapseLevel52: TMenuItem;
    UncollapseLevel62: TMenuItem;
    UncollapseLevel72: TMenuItem;
    UncollapseLevel82: TMenuItem;
    UncollapseLevel92: TMenuItem;
    mnuCollapse: TPopupMenu;
    CollapseAll2: TMenuItem;
    CollapseCurrent2: TMenuItem;
    N13: TMenuItem;
    CollapseLevel02: TMenuItem;
    CollapseLevel12: TMenuItem;
    CollapseLevel22: TMenuItem;
    CollapseLevel32: TMenuItem;
    CollapseLevel42: TMenuItem;
    CollapseLevel52: TMenuItem;
    CollapseLevel62: TMenuItem;
    CollapseLevel72: TMenuItem;
    CollapseLevel82: TMenuItem;
    CollapseLevel92: TMenuItem;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    ToolButton8: TToolButton;
    ToolButton9: TToolButton;
    ToolButton10: TToolButton;
    ImageList1: TImageList;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    SpeedButton5: TSpeedButton;
    SpeedButton6: TSpeedButton;
    btnFileSave: TToolButton;
    dlgSave1: TSaveDialog;
    SynWebCssSyn1: TSynWebCssSyn;
    procedure FormCreate(Sender: TObject);
    procedure cxRTTIInspector1PropertyChanged(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure New1Click(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure ViewCollapseAllExecute(Sender: TObject);
    procedure ViewUncollapseAllExecute(Sender: TObject);
    procedure ViewCollapseLevel0Execute(Sender: TObject);
    procedure ViewUncollapseLevel0Execute(Sender: TObject);
    procedure EditUndoExecute(Sender: TObject);
    procedure EditRedoExecute(Sender: TObject);
    procedure synExecute(Sender: TObject);
    procedure FileOpenExecute(Sender: TObject);
    procedure ViewCollapseCurrentExecute(Sender: TObject);
    procedure FileSaveExecute(Sender: TObject);
    procedure SpeedButton6Click(Sender: TObject);
    {    procedure SynEdit1Change(Sender: TObject);
        procedure BitBtn2Click(Sender: TObject);
        procedure Button1Click(Sender: TObject);}
  private
    { Private declarations }
    fHighlightr: TStringList;
  public
    procedure LogException(ExceptObj: TObject; ExceptAddr: Pointer;
      IsOS: Boolean);
    //    procedure AppException(Sender: TObject; E: Exception);
  published
  end;

  {  TExceptHandler = class(TObject)
      procedure OnException(Sender: TObject; E: Exception);
    end;}

var
  Form1: TForm1;
  //  ExceptHandler: TExceptHandler;

implementation

uses uHighlighterProcs, ConvUtils, Unit2;

{$R *.dfm}
{$R Recource.RES}

procedure TForm1.FormCreate(Sender: TObject);
var
  rs: TResourceStream;
begin
  JclAddExceptNotifier(Form1.LogException);
  //  Application.OnException := AppException;
  fHighlightr := TStringList.Create;
  GetHighlighters(Self, fHighlightr, true);
  ComboBox1.Items.Clear;
  ComboBox1.Items.Assign(fHighlightr);
  OpenDialog1.Filter := GetHighlightersFilter(fHighlightr);
  OpenDialog1.FilterIndex:=9;
  with SynEdit1 do
  begin
    ComboBox1.Text := Highlighter.GetLanguageName;
    //  CodeFolding.FoldRegions.Add(rtKeyWord, false, false, true, PChar('begin'),
    //    PChar('end'), nil);
    //  CodeFolding.FoldRegions.Add(rtKeyWord, false, false, true, PChar('try'),
    //    PChar('end'), nil);
    //  CodeFolding.FoldRegions.Add(rtKeyWord, false, false, true, PChar('case'),
    //    PChar('end'), nil);
    //  CodeFolding.FoldRegions.SkipRegions.Add('{', '}', '', itMultiLineComment);
    //  CodeFolding.FoldRegions.SkipRegions.Add('//', '', '', itSingleLineComment);

{    TypeFile := Highlighter.GetLanguageName + '.xml';
    AppPath := IncludeTrailingBackslash(ExtractFilePath(Application.ExeName));

    if FileExists(AppPath + 'DocumentTypes\' + TypeFile) then
    begin
      Highlighter.CodeFoldingLoadFromFile(AppPath + 'DocumentTypes\' +
        TypeFile);
    end;}

    CodeFolding.Enabled := true;
    CodeFolding.FolderBarColor := clWindow;
    CodeFolding.FolderBarLinesColor := clHighlight;
    CodeFolding.HighlighterFoldRegions := true;
    CodeFolding.CollapsingMarkStyle := TSynCollapsingMarkStyle(0);
    CodeFolding.CollapsedCodeHint := true;
    CodeFolding.ShowCollapsedLine := true;
    CodeFolding.CollapsedLineColor := clSilver;
    CodeFolding.CollapsedLineStyle := psDot;
    InsertMode := true;
    //      CodeFolding.AlwaysShowCaret := true;
    //wordwrap:=True;
  end;
  cxRTTIInspector1.InspectedObject := SynEdit1;
  rs := TResourceStream.Create(hinstance, 'textsemple', RT_RCDATA);
  try
    rs.Position := 0;
    SynEdit1.LoadFromStream(rs);
  finally
    rs.Free;
  end;
end;

procedure TForm1.cxRTTIInspector1PropertyChanged(Sender: TObject);
begin
  SynEdit1.InitCodeFolding;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  fHighlightr.Free;
end;

procedure TForm1.New1Click(Sender: TObject);
begin
         SynEdit1.ClearAll;
end;

procedure TForm1.ComboBox1Change(Sender: TObject);
begin
  SynEdit1.Highlighter := fHighlightr.Objects[ComboBox1.ItemIndex] as
    TSynCustomHighlighter;
  SynEdit1.InitCodeFolding;
  SynEdit1.Refresh;
end;

{procedure TForm1.SynEdit1Change(Sender: TObject);
begin
  //    SynEdit1.InitCodeFolding;
end;

procedure TExceptHandler.OnException(Sender: TObject; E: Exception);
begin
  //HandleError(PChar(E.Message));
end;

procedure TForm1.AppException(Sender: TObject; E: Exception);
begin
//  //  Application.ShowException(E);
//  //  Application.Terminate;
//  SynEdit1.InitCodeFolding;
//  SynEdit1.Refresh;
  Memo1.Lines.BeginUpdate;
  Memo1.Lines.Clear;
  JclLastExceptStackListToStrings(Memo1.Lines, true, true);
  Memo1.Lines.EndUpdate;

end;

{procedure TForm1.BitBtn2Click(Sender: TObject);
var
  StackInfoList: TJclStackInfoList;
begin
  StackInfoList := JclCreateStackList(true, 0, nil);
  try
    Memo1.Lines.BeginUpdate;
    Memo1.Lines.Clear;
    StackInfoList.AddToStrings(Memo1.Lines, true, true, true);
    Memo1.Lines.EndUpdate;
  finally
    StackInfoList.Free;
  end;
end;

procedure TForm1.Button1Click(Sender: TObject);
var i,z : integer;
begin
  RaiseException(868,0,0,nil);

{ SynEdit1.CollapsableFoldRangeForLine(1, @i);
 Memo1.Lines.Add('Lines = '+ intToStr(i));}
{end;

 }

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

procedure TForm1.BitBtn2Click(Sender: TObject);
var AppPath : string;
begin
       AppPath := IncludeTrailingBackslash(ExtractFilePath(Application.ExeName));

       if FileExists(AppPath + 'DocumentTypes\PHP+Java+Css+HTML.xml') then
       begin
      SynEdit1.Highlighter.CodeFoldingLoadFromFile(AppPath + 'DocumentTypes\PHP+Java+Css+HTML.xml');
      SynEdit1.InitCodeFolding;
      end;
end;

// процедура, вызываемая при возникновении исключения
procedure AnyExceptionNotify(
  ExceptObj: TObject; ExceptAddr: Pointer; OSException: Boolean);
begin
  with Form2 do
  begin
    mmLog.Lines.Clear;
    mmLog.Lines.BeginUpdate;
    JclLastExceptStackListToStrings(mmLog.Lines, false, True, True);
    mmLog.Lines.EndUpdate;
  end;
end;

procedure TForm1.ViewCollapseAllExecute(Sender: TObject);
begin
  SynEdit1.CollapseAll;
end;

procedure TForm1.ViewUncollapseAllExecute(Sender: TObject);
begin
     SynEdit1.ExpandAll;
     SynEdit1.InitCodeFolding;
end;

procedure TForm1.ViewCollapseLevel0Execute(Sender: TObject);
begin
     SynEdit1.CollapseLevel( (Sender as TAction).Tag );
end;

procedure TForm1.ViewUncollapseLevel0Execute(Sender: TObject);
begin
     SynEdit1.ExpandLevel( (Sender as TAction).Tag );
end;

procedure TForm1.EditUndoExecute(Sender: TObject);
begin
     SynEdit1.Undo;
end;

procedure TForm1.EditRedoExecute(Sender: TObject);
begin
     SynEdit1.Redo;
end;

procedure TForm1.synExecute(Sender: TObject);
begin
  SynEdit1.ClearAll;
  SynEdit1.InitCodeFolding;
//  SynEdit1.Lines.Clear;
//SynEdit1.CodeFolding.FoldRegions.Clear;
end;

procedure TForm1.FileOpenExecute(Sender: TObject);
begin
  if OpenDialog1.Execute then
  begin
    SynEdit1.Highlighter := GetHighlighterFromFileExt(fHighlightr,
      ExtractFileExt(OpenDialog1.FileName));

    ComboBox1.Text := SynEdit1.Highlighter.GetLanguageName;

    SynEdit1.LoadFromFile(OpenDialog1.FileName);
  end;
end;

procedure TForm1.ViewCollapseCurrentExecute(Sender: TObject);
begin
     SynEdit1.CollapseCurrent;
end;


procedure TForm1.FileSaveExecute(Sender: TObject);
begin
  if OpenDialog1.FileName='' then
    if dlgSave1.Execute then
       OpenDialog1.FileName:=dlgSave1.FileName;
  if OpenDialog1.FileName<>'' then
    SynEdit1.SaveToFile(OpenDialog1.FileName);

end;

procedure TForm1.SpeedButton6Click(Sender: TObject);
var
  p: TBufferCoord;
  Mark: TSynEditMark;
begin
  with SynEdit1 do
  begin
    p := CaretXY;
    Marks.ClearLine(p.Line);
    if (Sender as TSpeedButton).Down then
    begin
      Mark := TSynEditMark.Create(SynEdit1);
      with Mark do
      begin
        Line := p.Line;
        Char := p.Char;
        ImageIndex := (Sender as TSpeedButton).Tag;
        Visible := TRUE;
        InternalImage := BookMarkOptions.BookMarkImages = nil;
      end;
      Marks.Place(Mark);
    end;
  end;
end;

initialization

//...

// инициализация механизма перехвата исключений
  Include(JclStackTrackingOptions, stRawMode);
  Include(JclStackTrackingOptions, stExceptFrame);
//  AddIgnoredException(EListError); 
  JclStartExceptionTracking;
  JclAddExceptNotifier(AnyExceptionNotify);
  JclAddExceptNotifier(Form1.LogException);

end.

