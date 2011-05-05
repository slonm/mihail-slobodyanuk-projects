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
    ComboBox1: TComboBox;
    Label1: TLabel;
    Bevel1: TBevel;
    Editor: TSynEdit;
    SynJScriptSyn1: TSynJScriptSyn;
    SourceType: TComboBox;
    Label3: TLabel;
    SynHTMLSyn1: TSynHTMLSyn;
    SynCssSyn1: TSynCssSyn;
    HTMLOpt: TGroupBox;
    CheckBox3: TCheckBox;
    CheckBox5: TCheckBox;
    CheckBox6: TCheckBox;
    JSOpt: TGroupBox;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox4: TCheckBox;
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
uses beautify_tests, cssbeautify_tests, jsbeautify, htmlbeautify, cssbeautify;
{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
begin
  run_beautifier_tests;
  run_css_beautifier_tests;
  Editor.Lines.Add('/*   paste in your code and press Beautify button   */');
  Editor.Lines.Add('if(''this_is''==/an_example/){do_something();}else{var a=b?(c%d):e[f];}');
  Editor.Lines.Add('');
end;

procedure TForm1.Button1Click(Sender: TObject);
const tabsize:array[0..4] of Integer = (1,2,3,4,8);
var source:string;
    indent_size:Integer;
    indent_char:Char;
    preserve_newlines:Boolean;
    keep_array_indentation:Boolean;
    braces_on_own_line:Boolean;
begin
    editor.BeginUpdate;
    source := Editor.Lines.Text;
    indent_size := tabsize[ComboBox1.ItemIndex];
    indent_char := ' ';
    preserve_newlines := CheckBox2.Checked;
    keep_array_indentation := CheckBox4.Checked;
    braces_on_own_line := CheckBox1.Checked;

    if (indent_size = 1) then indent_char := #9;

    case SourceType.ItemIndex of
     0: Editor.Lines.Text :=
      html_beautify(source,
          indent_size,
          indent_char,
          80,
          CheckBox3.checked,
          CheckBox5.Checked,
          CheckBox6.Checked
        );

     1: Editor.Lines.Text :=
      js_beautify(source,
          indent_size,
          indent_char,
          preserve_newlines,
          0,
          0,
          true,
          braces_on_own_line,
          keep_array_indentation);
     2: Editor.Lines.Text :=
      css_beautify(source,
          indent_size,
          indent_char);
    end;
    editor.EndUpdate;

end;

procedure TForm1.SourceTypeChange(Sender: TObject);
begin
  HTMLOpt.Visible:=False;
  JSOpt.Visible:=False;
  case SourceType.ItemIndex of
  0:begin
    Editor.Highlighter:=SynHTMLSyn1;
    HTMLOpt.Visible:=true;
    JSOpt.Visible:=true;
    end;
  1:begin
    Editor.Highlighter:=SynJScriptSyn1;
    JSOpt.Visible:=true;
    end;
  2:Editor.Highlighter:=SynCssSyn1;
  end;
end;

end.
