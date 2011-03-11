unit DemoUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, SynEdit, Menus, ImgList, Buttons,
  SynEditHighlighter, SynHighlighterPas, StdCtrls, ComCtrls, Spin,
  SynEditCodeFolding
  , SynEditMiscClasses, cxStyles, cxGraphics, cxEdit, cxControls,
  cxInplaceContainer, cxVGrid, cxOI, SynHighlighterJava, ExtCtrls,
  SynHighlighterXML, SynHighlighterAsm, SynHighlighterVB,
  SynHighlighterPython, SynHighlighterPHP, SynHighlighterPerl,
  SynHighlighterVBScript, SynHighlighterJScript, SynHighlighterIni,
  SynHighlighterHtml, SynHighlighterCSS, SynHighlighterCpp,
  SynHighlighterCS;

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
    Panel1: TPanel;
    ComboBox1: TComboBox;
    SynCSSyn1: TSynCSSyn;
    SynCppSyn1: TSynCppSyn;
    SynCssSyn1: TSynCssSyn;
    SynHTMLSyn1: TSynHTMLSyn;
    SynIniSyn1: TSynIniSyn;
    SynJavaSyn1: TSynJavaSyn;
    SynJScriptSyn1: TSynJScriptSyn;
    SynVBScriptSyn1: TSynVBScriptSyn;
    SynPerlSyn1: TSynPerlSyn;
    SynPHPSyn1: TSynPHPSyn;
    SynVBSyn1: TSynVBSyn;
    procedure FormCreate(Sender: TObject);
    procedure CollapsAll1Click(Sender: TObject);
    procedure N21Click(Sender: TObject);
    procedure Open2Click(Sender: TObject);
    procedure cxRTTIInspector1PropertyChanged(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    fHighlightr: TStringList;
    AppPath, TypeFile: string;
  public
  published
  end;

var
  Form1: TForm1;

implementation

uses uHighlighterProcs;

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
var
  rs: TResourceStream;
begin
  fHighlightr := TStringList.Create;
  GetHighlighters(Self, fHighlightr, true);
  ComboBox1.Items.Clear;
  ComboBox1.Items.Assign(fHighlightr);
  OpenDialog1.Filter := GetHighlightersFilter(fHighlightr);
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

    TypeFile := Highlighter.GetLanguageName + '.xml';
    AppPath := IncludeTrailingBackslash(ExtractFilePath(Application.ExeName));

    if FileExists(AppPath + 'DocumentTypes\' + TypeFile) then
    begin
      Highlighter.CodeFoldingLoadFromFile(AppPath + 'DocumentTypes\' +
        TypeFile);
    end;

    CodeFolding.Enabled := true;
    CodeFolding.FolderBarColor := clWindow;
    CodeFolding.FolderBarLinesColor := clHighlight;
    CodeFolding.IndentGuides := True;
    CodeFolding.HighlighterFoldRegions := true;
    CodeFolding.CollapsingMarkStyle := TSynCollapsingMarkStyle(0);
    CodeFolding.CollapsedCodeHint := true;
    CodeFolding.ShowCollapsedLine := true;
    CodeFolding.HighlightIndentGuides := true;
    InsertMode := true;
    //      CodeFolding.AlwaysShowCaret := true;

  end;
  cxRTTIInspector1.InspectedObject := SynEdit1;
  rs := TResourceStream.Create(hinstance, 'textsemple', RT_RCDATA);
  try
    rs.Position := 0;
    SynEdit1.Lines.LoadFromStream(rs);
  finally
    rs.Free;
  end;
  SynEdit1.InitCodeFolding;
end;

procedure TForm1.CollapsAll1Click(Sender: TObject);
begin
  SynEdit1.CollapseAll;
end;

procedure TForm1.N21Click(Sender: TObject);
begin
  SynEdit1.CollapseCurrent;
end;

procedure TForm1.Open2Click(Sender: TObject);
begin
  if OpenDialog1.Execute then
  begin
    SynEdit1.Highlighter := GetHighlighterFromFileExt(fHighlightr,
      ExtractFileExt(OpenDialog1.FileName));

    TypeFile := SynEdit1.Highlighter.GetLanguageName + '.xml';
    AppPath := IncludeTrailingBackslash(ExtractFilePath(Application.ExeName));

    ComboBox1.Text := SynEdit1.Highlighter.GetLanguageName;

    if FileExists(AppPath + 'DocumentTypes\' + TypeFile) then
    begin
      SynEdit1.Highlighter.CodeFoldingLoadFromFile(AppPath + 'DocumentTypes\' +
        TypeFile);
    end;
    SynEdit1.Lines.LoadFromFile(OpenDialog1.FileName);
    SynEdit1.InitCodeFolding;
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

end.

