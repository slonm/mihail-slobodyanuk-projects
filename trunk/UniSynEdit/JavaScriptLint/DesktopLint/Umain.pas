unit Umain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ToolWin, SynEditHighlighter, SynHighlighterJScript,
  ExtCtrls, SynEdit, ActnList, StdActns, XPStyleActnCtrls, ActnMan, ImgList,
  JavaScriptLintAPI, StdCtrls;

type
  TMain = class(TForm)
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    btn1: TToolButton;
    btn2: TToolButton;
    btn3: TToolButton;
    il_1: TImageList;
    actmgr1: TActionManager;
    FileOpen1: TFileOpen;
    FileSaveAs1: TFileSaveAs;
    act1: TAction;
    pgcLint: TPageControl;
    tsLint: TTabSheet;
    tsOptions: TTabSheet;
    memo1: TSynEdit;
    tv1: TTreeView;
    spl1: TSplitter;
    SynJScriptSyn1: TSynJScriptSyn;
    mmo1: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure act1Execute(Sender: TObject);
    procedure FileOpen1Accept(Sender: TObject);
  private
    procedure FillTree(mess: TStringList);
  public
    { Public declarations }
  end;

var
  Main: TMain;

implementation

{$R *.dfm}

procedure TMain.FormCreate(Sender: TObject);
begin
memo1.Clear;
end;

procedure TMain.act1Execute(Sender: TObject);
var
  mess:TStringList;
  error:string;
begin
  mess:=TStringList.Create;
  mmo1.Clear;
  tv1.Items.Clear;
  if(LintString('jsl.exe','',memo1.Lines.Text,mess,error)) then
    fillTree(mess)
  else
    mmo1.Lines.Add(error);
  mess.Free;
end;

procedure TMain.FillTree(mess: TStringList);
var
  i:Integer;
  NodeError,NodeWarning,parent,node:TTreeNode;
  sl:TStringList;
begin
  sl:=TStringList.Create;
  NodeError:=tv1.Items.AddChild(nil, 'Errors');
  NodeWarning:=tv1.Items.AddChild(nil, 'Warnings');
  for i:=0 to mess.Count-1 do
  begin
    sl.Text :=stringReplace(Mess[i],#9,#13#10,[rfReplaceAll]);
    if sl[2]='warning' then parent:=NodeWarning
    else if sl[2]='error' then parent:=NodeError;
    node:=tv1.Items.AddChild(parent, sl[3]+' ('+sl[0]+', '+sl[1]+')');
  end;
  sl.Free;
  NodeError.Expand(True);
  NodeWarning.Expand(True);
end;

procedure TMain.FileOpen1Accept(Sender: TObject);
begin
    memo1.LoadFromFile(FileOpen1.Dialog.FileName);

end;

end.
