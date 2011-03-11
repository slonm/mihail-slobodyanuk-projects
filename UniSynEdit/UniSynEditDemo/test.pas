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