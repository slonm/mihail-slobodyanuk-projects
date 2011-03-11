unit DemoUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, SynEdit, Menus, ImgList, Buttons,
  SynEditHighlighter, SynHighlighterPas, StdCtrls, ComCtrls, Spin,
  SynEditCodeFolding, SynEditMiscClasses;

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
    PageControl1: TPageControl;
    tabFile: TTabSheet;
    outFilename: TLabel;
    btnLoad: TButton;
    cbReadonly: TCheckBox;
    tabDisplay: TTabSheet;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label26: TLabel;
    Label28: TLabel;
    cbHideSelection: TCheckBox;
    inpRightEdge: TSpinEdit;
    cbScrollPastEOL: TCheckBox;
    cbxScrollBars: TComboBox;
    cbxColor: TComboBox;
    cbxForeground: TComboBox;
    cbxBackground: TComboBox;
    btnFont: TButton;
    inpExtraLineSpacing: TSpinEdit;
    cbxREColor: TComboBox;
    cbHalfPageScroll: TCheckBox;
    tabEdit: TTabSheet;
    Label29: TLabel;
    cbAutoIndent: TCheckBox;
    cbWantTabs: TCheckBox;
    inpTabWidth: TSpinEdit;
    cbDragDropEdit: TCheckBox;
    tabSearch: TTabSheet;
    lblSearchResult: TLabel;
    btnSearch: TButton;
    btnSearchNext: TButton;
    btnSearchPrev: TButton;
    btnReplace: TButton;
    tabCaret: TTabSheet;
    Label7: TLabel;
    Label8: TLabel;
    cbxInsertCaret: TComboBox;
    cbxOverwriteCaret: TComboBox;
    cbInsertMode: TCheckBox;
    tabGutter: TTabSheet;
    Label5: TLabel;
    Label6: TLabel;
    Label30: TLabel;
    Label31: TLabel;
    Label32: TLabel;
    cbxGutterColor: TComboBox;
    cbLineNumbers: TCheckBox;
    cbLeadingZeros: TCheckBox;
    cbZeroStart: TCheckBox;
    inpGutterWidth: TSpinEdit;
    inpDigitCount: TSpinEdit;
    inpLeftOffset: TSpinEdit;
    inpRightOffset: TSpinEdit;
    cbAutoSize: TCheckBox;
    cbGutterVisible: TCheckBox;
    cbUseFontStyle: TCheckBox;
    tabBookmarks: TTabSheet;
    Label4: TLabel;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    SpeedButton5: TSpeedButton;
    SpeedButton6: TSpeedButton;
    Label25: TLabel;
    cbEnableKeys: TCheckBox;
    cbGlyphsVisible: TCheckBox;
    inpLeftMargin: TSpinEdit;
    cbInternalImages: TCheckBox;
    inpXOffset: TSpinEdit;
    Label2: TMemo;
    tabUndo: TTabSheet;
    Label11: TLabel;
    Label19: TLabel;
    btnUndo: TButton;
    inpMaxUndo: TSpinEdit;
    btnRedo: TButton;
    tabHighlighter: TTabSheet;
    Label1: TLabel;
    Label3: TLabel;
    Label23: TLabel;
    Label24: TLabel;
    Label22: TLabel;
    cbxHighlighterSelect: TComboBox;
    cbxSettingsSelect: TComboBox;
    cbxAttrSelect: TComboBox;
    cbxAttrBackground: TComboBox;
    cbxAttrForeground: TComboBox;
    btnKeywords: TButton;
    grbAttrComments: TGroupBox;
    cbCommentsBas: TCheckBox;
    cbCommentsAsm: TCheckBox;
    cbCommentsPas: TCheckBox;
    cbCommentsAnsi: TCheckBox;
    cbCommentsC: TCheckBox;
    grbAttrStyle: TGroupBox;
    cbStyleBold: TCheckBox;
    cbStyleStrikeOut: TCheckBox;
    cbStyleUnderline: TCheckBox;
    cbStyleItalic: TCheckBox;
    btnSaveToReg: TButton;
    btnLoadFromReg: TButton;
    tabExporter: TTabSheet;
    Label27: TLabel;
    cbxExporterSelect: TComboBox;
    cbExportSelected: TCheckBox;
    btnExportToFile: TButton;
    btnExportToClipboard: TButton;
    tabInfo: TTabSheet;
    Label9: TLabel;
    Label10: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label20: TLabel;
    Label21: TLabel;
    inpLineText: TEdit;
    outLineCount: TEdit;
    inpLeftChar: TSpinEdit;
    inpTopLine: TSpinEdit;
    inpCaretX: TSpinEdit;
    inpCaretY: TSpinEdit;
    TabSheet1: TTabSheet;
    KeyCmdList: TListView;
    btnEdit: TButton;
    TabSheet2: TTabSheet;
    Label34: TLabel;
    Label35: TLabel;
    Memo2: TMemo;
    Memo3: TMemo;
    cbShrinkList: TCheckBox;
    cbCompletionAttr: TComboBox;
    cbxCompletionColor: TComboBox;
    tabEvents: TTabSheet;
    cbEnableEventLog: TCheckBox;
    lbEventLog: TListBox;
    cbMouse: TCheckBox;
    cbDrag: TCheckBox;
    cbKeyboard: TCheckBox;
    cbOther: TCheckBox;
    btnClear: TButton;
    tabAbout: TTabSheet;
    Label33: TLabel;
    Memo1: TMemo;
    cbCodeFolding: TCheckBox;
    FontDialog1: TFontDialog;
    MainMenu2: TMainMenu;
    File2: TMenuItem;
    Open2: TMenuItem;
    N2: TMenuItem;
    Exit1: TMenuItem;
    Collapsed1: TMenuItem;
    CollapsAll1: TMenuItem;
    N21: TMenuItem;
    OpenDialog1: TOpenDialog;
    ImageList1: TImageList;
    SynEdit1: TSynEdit;
    procedure FormCreate(Sender: TObject);
    procedure cbxGutterColorChange(Sender: TObject);
    procedure inpGutterWidthChange(Sender: TObject);
    procedure inpDigitCountChange(Sender: TObject);
    procedure inpLeftOffsetChange(Sender: TObject);
    procedure inpXOffsetChange(Sender: TObject);
    procedure inpRightOffsetChange(Sender: TObject);
    procedure cbLineNumbersClick(Sender: TObject);
    procedure cbLeadingZerosClick(Sender: TObject);
    procedure cbZeroStartClick(Sender: TObject);
    procedure cbAutoSizeClick(Sender: TObject);
    procedure cbGutterVisibleClick(Sender: TObject);
    procedure cbUseFontStyleClick(Sender: TObject);
    procedure cbCodeFoldingClick(Sender: TObject);
    procedure inpExtraLineSpacingChange(Sender: TObject);
    procedure btnFontClick(Sender: TObject);
    procedure cbxAttrSelectChange(Sender: TObject);
    procedure CollapsAll1Click(Sender: TObject);
    procedure N21Click(Sender: TObject);
    procedure Open2Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure cbEnableKeysClick(Sender: TObject);
    procedure cbGlyphsVisibleClick(Sender: TObject);
    procedure cbInternalImagesClick(Sender: TObject);
    procedure SynEdit1GutterClick(Sender: TObject; Button: TMouseButton; X,
      Y, Line: Integer; Mark: TSynEditMark);
  private
    { Private declarations }
    fMarkButtons: array[0..4] of TSpeedButton;
    fDisableMarkButtons: boolean;
  public
    //    procedure inpLeftMarginChange(Sender: TObject);
  published
    procedure RecalcLeftMargin;
    procedure UpdateEditorSettings;
    procedure RebuildMarks;
    procedure ResetMarkButtons;
    { Public declarations }
  end;

var
  Form1: TForm1;

function IndexToColor(AIndex: integer): TColor;
function ColorToIndex(AColor: TColor): integer;

implementation

{$R *.dfm}
{$R Recource.RES}

procedure TForm1.FormCreate(Sender: TObject);
var
  rs: TResourceStream;
begin
  rs := TResourceStream.Create(hinstance, 'textsemple', RT_RCDATA);
  try
    rs.Position := 0;
    SynEdit1.Lines.LoadFromStream(rs);
  finally
    rs.Free;
  end;
  cbCodeFoldingClick(Self);
  //  SynEditScroll1.Lines.LoadFromFile('test.pas');
  fMarkButtons[0] := SpeedButton1;
  fMarkButtons[1] := SpeedButton2;
  fMarkButtons[2] := SpeedButton3;
  fMarkButtons[3] := SpeedButton4;
  fMarkButtons[4] := SpeedButton5;
end;

procedure TForm1.cbxGutterColorChange(Sender: TObject);
begin
  SynEdit1.Gutter.Color := IndexToColor(cbxGutterColor.ItemIndex);
  SynEdit1.SetFocus;
end;

procedure TForm1.inpGutterWidthChange(Sender: TObject);
begin
  try
    SynEdit1.Gutter.Width := inpGutterWidth.Value;
  except
  end;
  RecalcLeftMargin;
  SynEdit1.SetFocus;
end;

procedure TForm1.inpDigitCountChange(Sender: TObject);
begin
  try
    SynEdit1.Gutter.DigitCount := inpDigitCount.Value;
  except
  end;
  RecalcLeftMargin;
  SynEdit1.SetFocus;
end;

procedure TForm1.inpLeftOffsetChange(Sender: TObject);
begin
  try
    SynEdit1.Gutter.LeftOffset := inpLeftOffset.Value;
  except
  end;
  RecalcLeftMargin;
  SynEdit1.SetFocus;
end;

procedure TForm1.inpRightOffsetChange(Sender: TObject);
begin
  try
    SynEdit1.Gutter.RightOffset := inpRightOffset.Value;
  except
  end;
  RecalcLeftMargin;
  SynEdit1.SetFocus;
end;

procedure TForm1.cbLineNumbersClick(Sender: TObject);
begin
  SynEdit1.Gutter.ShowLineNumbers := cbLineNumbers.Checked;
  SynEdit1.SetFocus;
end;

procedure TForm1.cbLeadingZerosClick(Sender: TObject);
begin
  SynEdit1.Gutter.LeadingZeros := cbLeadingZeros.Checked;
  SynEdit1.SetFocus;
end;

procedure TForm1.cbZeroStartClick(Sender: TObject);
begin
  SynEdit1.Gutter.ZeroStart := cbZeroStart.Checked;
  SynEdit1.SetFocus;
end;

procedure TForm1.cbAutoSizeClick(Sender: TObject);
begin
  SynEdit1.Gutter.AutoSize := cbAutoSize.Checked;
  SynEdit1.SetFocus;
end;

procedure TForm1.cbGutterVisibleClick(Sender: TObject);
begin
  SynEdit1.Gutter.Visible := cbGutterVisible.Checked;
  SynEdit1.SetFocus;
end;

procedure TForm1.cbUseFontStyleClick(Sender: TObject);
begin
  SynEdit1.Gutter.UseFontStyle := cbUseFontStyle.Checked;
  SynEdit1.SetFocus;
end;

function IndexToColor(AIndex: integer): TColor;
begin
  Result := Colors[AIndex + 1];
end;

procedure TForm1.RecalcLeftMargin;
  procedure ValidateSpinEditValue(SE: TSpinEdit; Value: integer);
  begin
    if SE.Value <> Value then
      SE.Value := Value;
  end;

begin
  with SynEdit1 do
  begin
    inpLeftMargin.MaxValue := Gutter.Width;
    if inpLeftMargin.Value > inpLeftMargin.MaxValue then
      inpLeftMargin.Value := inpLeftMargin.MaxValue;
    ValidateSpinEditValue(inpGutterWidth, Gutter.Width);
    ValidateSpinEditValue(inpDigitCount, Gutter.DigitCount);
    ValidateSpinEditValue(inpLeftOffset, Gutter.LeftOffset);
    ValidateSpinEditValue(inpRightOffset, Gutter.RightOffset);
  end;

end;

procedure TForm1.cbCodeFoldingClick(Sender: TObject);
begin
  SynEdit1.CodeFolding.Enabled := cbCodeFolding.Checked;
  if cbCodeFolding.Checked then
  begin
    with SynEdit1 do
    begin
      CodeFolding.FolderBarColor := clWindow;
      CodeFolding.FolderBarLinesColor := clHotLight;
      CodeFolding.IndentGuides := True;
      CodeFolding.HighlighterFoldRegions := false;
      CodeFolding.CollapsingMarkStyle := TSynCollapsingMarkStyle(0);
      CodeFolding.CollapsedCodeHint := true;
      CodeFolding.ShowCollapsedLine := true;
      CodeFolding.HighlightIndentGuides := true;
      InsertMode := true;
      //      CodeFolding.AlwaysShowCaret := true;

      InitCodeFolding;
    end;
  end;
end;

procedure TForm1.inpExtraLineSpacingChange(Sender: TObject);
begin
  try
    SynEdit1.ExtraLineSpacing := inpExtraLineSpacing.Value;
  except
  end;
  SynEdit1.SetFocus;
end;

procedure TForm1.btnFontClick(Sender: TObject);
begin
  if FontDialog1.Execute then
  begin
    SynEdit1.Font.Assign(FontDialog1.Font);
    UpdateEditorSettings;
    SynEdit1.SetFocus;
  end;
end;

procedure TForm1.UpdateEditorSettings;
begin
  with SynEdit1 do
  begin
    cbReadonly.Checked := ReadOnly;
    cbHideSelection.Checked := HideSelection;
    cbScrollPastEOL.Checked := eoScrollPastEOL in Options;
    cbHalfPageScroll.Checked := eoHalfPageScroll in Options;
    inpExtraLineSpacing.Value := ExtraLineSpacing;
    inpRightEdge.Value := RightEdge;
    cbxREColor.ItemIndex := ColorToIndex(RightEdgeColor);
    cbxScrollBars.ItemIndex := Ord(Scrollbars);
    with SynEdit1.Font do
      btnFont.Caption := Name + ' ' + IntToStr(Size);
    cbxColor.ItemIndex := ColorToIndex(Color);
    cbxForeground.ItemIndex := ColorToIndex(SelectedColor.Foreground);
    cbxBackground.ItemIndex := ColorToIndex(SelectedColor.Background);
    cbAutoIndent.Checked := eoAutoIndent in Options;
    cbWantTabs.Checked := WantTabs;
    inpTabWidth.Value := TabWidth;
    cbDragDropEdit.Checked := eoDragDropEditing in Options;
    cbxInsertCaret.ItemIndex := Ord(InsertCaret);
    cbxOverwriteCaret.ItemIndex := Ord(OverwriteCaret);
    cbInsertMode.Checked := InsertMode;
    cbxGutterColor.ItemIndex := ColorToIndex(Gutter.Color);
    inpGutterWidth.Value := Gutter.Width;
    inpDigitCount.Value := Gutter.DigitCount;
    inpLeftOffset.Value := Gutter.LeftOffset;
    inpRightOffset.Value := Gutter.RightOffset;
    cbLineNumbers.Checked := Gutter.ShowLineNumbers;
    cbLeadingZeros.Checked := Gutter.LeadingZeros;
    cbZeroStart.Checked := Gutter.ZeroStart;
    cbAutoSize.Checked := Gutter.AutoSize;
    cbGutterVisible.Checked := Gutter.Visible;
    cbUseFontStyle.Checked := Gutter.UseFontStyle;
    cbEnableKeys.Checked := BookMarkOptions.EnableKeys;
    cbGlyphsVisible.Checked := BookMarkOptions.GlyphsVisible;
    cbInternalImages.Checked := BookMarkOptions.BookmarkImages = nil;
    inpLeftMargin.Value := BookMarkOptions.LeftMargin;
    inpXOffset.Value := BookmarkOptions.XOffset;
    inpMaxUndo.Value := MaxUndo;
    cbxAttrSelect.ItemIndex := 0;
    cbxAttrSelectChange(Self);
  end;
end;

function ColorToIndex(AColor: TColor): integer;
var
  i: integer;
begin
  Result := 0;
  for i := Low(Colors) to High(Colors) do
    if Colors[i] = AColor then
    begin
      Result := i - 1;
      break;
    end;
end;

procedure TForm1.cbxAttrSelectChange(Sender: TObject);
var
  Attr: TSynHighlighterAttributes;
begin
  Attr := TSynHighlighterAttributes.Create('', '');
  try
    if SynEdit1.Highlighter <> nil then
      Attr.Assign(SynEdit1.Highlighter.Attribute[cbxAttrSelect.ItemIndex]);
    cbxAttrForeground.ItemIndex := ColorToIndex(Attr.Foreground);
    cbxAttrBackground.ItemIndex := ColorToIndex(Attr.Background);
    cbStyleBold.Checked := (fsBold in Attr.Style);
    cbStyleItalic.Checked := (fsItalic in Attr.Style);
    cbStyleUnderLine.Checked := (fsUnderline in Attr.Style);
    cbStyleStrikeOut.Checked := (fsStrikeOut in Attr.Style);
  finally
    Attr.Free;
  end;
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
    SynEdit1.Lines.LoadFromFile(OpenDialog1.FileName);
    cbCodeFoldingClick(Self);
  end;
end;

procedure TForm1.SpeedButton2Click(Sender: TObject);
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

procedure TForm1.cbEnableKeysClick(Sender: TObject);
begin
  SynEdit1.BookMarkOptions.EnableKeys := cbEnableKeys.Checked;
  SynEdit1.SetFocus;
end;

procedure TForm1.cbGlyphsVisibleClick(Sender: TObject);
begin
  SynEdit1.BookMarkOptions.GlyphsVisible := cbGlyphsVisible.Checked;
  SynEdit1.SetFocus;
end;

procedure TForm1.cbInternalImagesClick(Sender: TObject);
begin
  RebuildMarks;
  SynEdit1.SetFocus;
end;

procedure TForm1.RebuildMarks;
var
  i: integer;
begin
  with SynEdit1 do
  begin
    BeginUpdate;
    try
      for i := 0 to Marks.Count - 1 do
      begin
        if Marks[i].IsBookmark then
          Marks[i].InternalImage := cbInternalImages.Checked;
      end;
    finally
      EndUpdate;
    end;
  end;
end;

procedure TForm1.inpXOffsetChange(Sender: TObject);
begin
  try
    SynEdit1.BookMarkOptions.XOffset := inpXOffset.Value;
  except
  end;
  SynEdit1.SetFocus;
end;

procedure TForm1.ResetMarkButtons;
var
  marks: TSynEditMarks;
  i: integer;
begin
  fDisableMarkButtons := true;
  try
    SynEdit1.Marks.GetMarksForLine(SynEdit1.CaretY, marks);
    for i := 0 to 4 do
      fMarkButtons[i].Down := false;
    for i := 1 to MAX_MARKS do
    begin
      if not assigned(marks[i]) then
        break;
      if not marks[i].IsBookmark then
        fMarkButtons[marks[i].ImageIndex - 10].Down := true;
    end;
  finally
    fDisableMarkButtons := false;
  end;
end;

procedure TForm1.SynEdit1GutterClick(Sender: TObject; Button: TMouseButton;
  X, Y, Line: Integer; Mark: TSynEditMark);
begin
  SynEdit1.CaretY := Line;
  if not assigned(mark) then
  begin // place first mark
    SpeedButton1.Down := true;
    SpeedButton1.Click;
  end
  else if (not mark.IsBookmark) and (mark.ImageIndex >= SpeedButton1.Tag) then
  begin
    if mark.ImageIndex = SpeedButton5.Tag then
    begin // remove mark
      SpeedButton5.Down := false;
      SpeedButton5.Click;
    end
    else
      mark.ImageIndex := mark.ImageIndex + 1;
  end;
  ResetMarkButtons;
end;

end.

