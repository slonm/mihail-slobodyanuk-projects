procedure TSynEditScroll.PaintGutterGlyphs(ACanvas: TCanvas; AClip: TRect;
  FirstLine, LastLine: integer);
var'
  LH, X, Y: integer;
  LI: TFoldingLineInfos;
  ImgIndex: integer;
begin
  if FCodeFolding then
  begin
    FirstLine := RowToLine(FirstLine);
    LastLine := RowToLine(LastLine);
    X := 14;
    LH := LineHeight;
    while FirstLine <= LastLine do
    begin
      Y := (LH - imglGutterGlyphs.Height) div 2
        + LH * (LineToRow(FirstLine) - TopLine);
      LI := GetLineInfos(FirstLine);
      if dlBeginLine in LI then
        ImgIndex := 0
      else
      begin
        if dlEndLine in LI then
          ImgIndex := 4
        else
          ImgIndex := -1;
      end;

      if ImgIndex >= 0 then
        imglGutterGlyphs.Draw(ACanvas, X, Y, ImgIndex);
      Inc(FirstLine);
    end;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
var AppPath:string;
begin
  SynEdit1.Lines.LoadFromFile('test.pas');
  with SynEdit1 do
  begin
    CodeFolding.Enabled := True;
    case
      CodeFolding.FolderBarLinesColor := clDefault;
      CodeFolding.HighlighterFoldRegions := false;
      CodeFolding.CollapsingMarkStyle := TSynCollapsingMarkStyle(0);
      CodeFolding.CollapsedCodeHint := true;
    end;
    CodeFolding.IndentGuides := True;
{    CodeFolding.FolderBarColor := clWindow;
    CodeFolding.FolderBarLinesColor := clDefault;
    CodeFolding.HighlighterFoldRegions := false;
    CodeFolding.CollapsingMarkStyle := TSynCollapsingMarkStyle(0);
    CodeFolding.CollapsedCodeHint := true;
    CodeFolding.HighlightIndentGuides := true;
    CodeFolding.ShowCollapsedLine := true;
 }
 try
    AppPath := IncludeTrailingBackslash(ExtractFilePath(Application.ExeName));
//    SynUniSyn1.LoadHglFromFile(AppPath + 'DocumentTypes\' + 'Pascal.xml');
//    Highlighter := SynUniSyn1;
//    SynMultiSyn1.LoadFromFile(AppPath + 'DocumentTypes\' + 'Pascal.xml');
//    Highlighter := SynMultiSyn1;
//   SynPasSyn1.LoadFromFile(AppPath + 'DocumentTypes\' + 'Pascal.xml');
   CodeFolding.FoldRegions.Add(TFoldRegionType(1),false, false, false, PChar('begin'), PChar('end'), nil);
   InitCodeFolding;
   finally
   end;
  end;

end;
