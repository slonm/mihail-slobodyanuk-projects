unit main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, ExtCtrls, StdCtrls, SynEditHighlighter,
  SynHighlighterJScript, SynEdit, SynHighlighterCSS, SynHighlighterHtml;

type
  TForm1 = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Button1: TButton;
    Editor: TSynEdit;
    SynJScriptSyn1: TSynJScriptSyn;
    SourceType: TComboBox;
    Label3: TLabel;
    SynCssSyn1: TSynCssSyn;
    CSSOpt: TGroupBox;
    RemLastSemi: TCheckBox;
    RemComments: TCheckBox;
    JSOpt: TGroupBox;
    jslevel: TComboBox;
    Label1: TLabel;
    Label2: TLabel;
    csslevel: TComboBox;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure SourceTypeChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation
uses jsmin, cssmin, cssmin_tests;
{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
begin
//  run_js_min_tests;
  run_css_min_tests;
  Editor.Lines.Add('/*   paste in your code and press Beautify button   */');
  Editor.Lines.Add('if(''this_is''==/an_example/){do_something();}else{var a=b?(c%d):e[f];}');
  Editor.Lines.Add('');
  SourceTypeChange(nil);
end;

procedure TForm1.Button1Click(Sender: TObject);
var source:string;
begin
    editor.BeginUpdate;
    source := Editor.Lines.Text;

    case SourceType.ItemIndex of
     0: Editor.Lines.Text :=
      js_min(source, StrToInt(jslevel.text[1]));
     1: Editor.Lines.Text :=
      css_min(source,
          StrToInt(csslevel.text[1]),
          RemLastSemi.checked,
          RemComments.checked);
    end;
    editor.EndUpdate;

end;

procedure TForm1.SourceTypeChange(Sender: TObject);
begin
  CSSOpt.Visible:=False;
  JSOpt.Visible:=False;
  case SourceType.ItemIndex of
  0:begin
    Editor.Highlighter:=SynJScriptSyn1;
    JSOpt.Visible:=true;
    end;
  1:begin
    Editor.Highlighter:=SynCssSyn1;
    CSSOpt.Visible:=true;
    end;
  end;
end;

end.
