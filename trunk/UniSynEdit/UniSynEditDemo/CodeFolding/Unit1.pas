unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, SynEdit, SynEditMiscClasses, SynEditHighlighter,
  SynHighlighterPas, SynHighlighterMulti, SynEditCodeFolding;

type
  TForm1 = class(TForm)
    SynEdit1: TSynEdit;
    SynPasSyn1: TSynPasSyn;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
var AppPath:string;
begin
  SynEdit1.Lines.LoadFromFile('test.pas');
  with SynEdit1 do
  begin
    CodeFolding.Enabled := True;
    CodeFolding.IndentGuides := True;
    CodeFolding.HighlighterFoldRegions := false;
    CodeFolding.FolderBarColor := clWindow;
    CodeFolding.FolderBarLinesColor := clDefault;
    CodeFolding.CollapsingMarkStyle := TSynCollapsingMarkStyle(0);
    CodeFolding.CollapsedCodeHint := true;
    CodeFolding.HighlightIndentGuides := true;
    CodeFolding.ShowCollapsedLine := true;

    AppPath := IncludeTrailingBackslash(ExtractFilePath(Application.ExeName));
//		SynUniSyn1.LoadHglFromFile(AppPath + 'DocumentTypes\' + 'Pascal.xml');
//    Highlighter := SynUniSyn1;
//    SynMultiSyn1.LoadFromFile(AppPath + 'DocumentTypes\' + 'Pascal.xml');
//    Highlighter := SynMultiSyn1;
//   SynPasSyn1.LoadFromFile(AppPath + 'DocumentTypes\' + 'Pascal.xml');
   CodeFolding.FoldRegions.Add(TFoldRegionType(1),false, false, false, PChar('begin'), PChar('end'), nil);
   InitCodeFolding;
   CollapseAll;
  end;

end;

end.

