unit Umain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ToolWin, SynEditHighlighter, SynHighlighterJScript,
  ExtCtrls, SynEdit, ActnList, StdActns, XPStyleActnCtrls, ActnMan, ImgList,
  JavaScriptLintAPI, StdCtrls, UJSLDefaultConf,
  CheckLst, JvExCheckLst, JvCheckListBox;

type
  TMain = class(TForm)
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    btn3: TToolButton;
    il_1: TImageList;
    actmgr1: TActionManager;
    FileOpen1: TFileOpen;
    FileSaveAs1: TFileSaveAs;
    actLint: TAction;
    pgcLint: TPageControl;
    tsLint: TTabSheet;
    tsOptions: TTabSheet;
    memo1: TSynEdit;
    spl1: TSplitter;
    SynJScriptSyn1: TSynJScriptSyn;
    lst1: TJvCheckListBox;
    pnl1: TPanel;
    tv1: TTreeView;
    mmo1: TMemo;
    actSave: TAction;
    btn1: TToolButton;
    stat1: TStatusBar;
    procedure FormCreate(Sender: TObject);
    procedure actLintExecute(Sender: TObject);
    procedure FileOpen1Accept(Sender: TObject);
    procedure tv1Deletion(Sender: TObject; Node: TTreeNode);
    procedure tv1DblClick(Sender: TObject);
    procedure memo1SpecialLineColors(Sender: TObject; Line: Integer;
      var Special: Boolean; var FG, BG: TColor);
    procedure actSaveExecute(Sender: TObject);
    procedure FileSaveAs1Accept(Sender: TObject);
  private
    LastErrorCoord: TBufferCoord;
    procedure FillTree(mess: TStringList);
    function MakeConf(): string;
    procedure FlushConf;
    procedure UpdateCaption;
  public
    { Public declarations }
  end;

var
  Main: TMain;

implementation

type
  PBufferCoord = ^TBufferCoord;
{$R *.dfm}

procedure TMain.FormCreate(Sender: TObject);
var
  i: Integer;
begin
  memo1.Clear;
  mmo1.align := alClient;
  tv1.align := alClient;
  for i := 0 to JSLOptionsCount - 1 do
    lst1.Items.Add(DefaultConf[i].key + '    (' + DefaultConf[i].desc + ')');
  FlushConf;
end;

procedure TMain.FlushConf;
var
  i: Integer;
begin
  for i := 0 to JSLOptionsCount - 1 do
    lst1.Checked[i] := DefaultConf[i].checked;
end;

procedure TMain.actLintExecute(Sender: TObject);
var
  mess: TStringList;
  error: string;
  conf: string;
begin
  conf := MakeConf();
  mess := TStringList.Create;
  tv1.Items.Clear;
  tv1.Visible := True;
  mmo1.Visible := False;
  if (LintString('jsl.exe', conf, memo1.Lines.Text, mess, error)) then
    fillTree(mess)
  else
  begin
    tv1.Visible := False;
    mmo1.Visible := True;
    mmo1.Clear;
    mmo1.Lines.Add(error);
  end;
  mess.Free;
  if conf <> '' then
    DeleteFile(conf);
end;

function TMain.MakeConf: string;
var
  TempFile: array[0..MAX_PATH - 1] of Char;
  TempPath: array[0..MAX_PATH - 1] of Char;
  config: TextFile;
  i: Integer;
  switch: string;
begin
  GetTempPath(MAX_PATH, TempPath);
  if GetTempFileName(TempPath, PChar('abc'), 0, TempFile) = 0 then
    raise Exception.Create(
      'GetTempFileName API failed. ' + SysErrorMessage(GetLastError)
      );
  AssignFile(config, TempFile);
  ReWrite(config);
  for i := 0 to JSLOptionsCount - 1 do
  begin
    if lst1.Checked[i] then
      switch := '+'
    else
      switch := '-';
    Writeln(config, switch + DefaultConf[i].key);
  end;
  CloseFile(config);
  result := string(TempFile);
end;

procedure TMain.FillTree(mess: TStringList);
var
  i: Integer;
  NodeError, NodeWarning, parent, node: TTreeNode;
  sl: TStringList;
  NodeObject: PBufferCoord;
begin
  sl := TStringList.Create;
  NodeError := tv1.Items.AddChild(nil, 'Errors');
  NodeError.ImageIndex := 28;
  NodeError.SelectedIndex := 28;
  NodeError.Data := nil;
  NodeWarning := tv1.Items.AddChild(nil, 'Warnings');
  NodeWarning.ImageIndex := 29;
  NodeWarning.SelectedIndex := 29;
  NodeWarning.Data := nil;
  for i := 0 to mess.Count - 1 do
  begin
    sl.Text := stringReplace(Mess[i], #9, #13#10, [rfReplaceAll]);
    if sl[2] = '' then
      parent := NodeError
    else
      parent := NodeWarning;
    node := tv1.Items.AddChild(parent, sl[3] + ' (' + sl[0] + ', ' + sl[1] +
      ')');
    node.ImageIndex := parent.ImageIndex;
    node.SelectedIndex := parent.SelectedIndex;
    New(NodeObject);
    NodeObject^.Line := StrToInt(sl[0]);
    NodeObject^.Char := StrToInt(sl[1]);
    node.Data := NodeObject;
  end;
  sl.Free;
  if NodeWarning.HasChildren then
  begin
    NodeWarning.Expand(True);
    tv1.Selected := NodeWarning;
  end
  else
    tv1.Items.Delete(NodeWarning);
  if NodeError.HasChildren then
  begin
    NodeError.Expand(True);
    tv1.Selected := NodeError;
  end
  else
    tv1.Items.Delete(NodeError);
end;

procedure TMain.FileOpen1Accept(Sender: TObject);
begin
  memo1.LoadFromFile(FileOpen1.Dialog.FileName);
  updateCaption;
end;

procedure TMain.tv1Deletion(Sender: TObject; Node: TTreeNode);
begin
  if Node.Data <> nil then
    Dispose(Node.Data);
end;

procedure TMain.tv1DblClick(Sender: TObject);
var
  oldLine: Integer;
begin
  if (tv1.Selected <> nil) and (tv1.Selected.Data <> nil) then
  begin
    oldLine := LastErrorCoord.Line;
    LastErrorCoord := PBufferCoord(tv1.Selected.Data)^;
    memo1.CaretXY := LastErrorCoord;
    memo1.SetFocus;
    memo1.InvalidateLine(oldLine);
    memo1.InvalidateLine(LastErrorCoord.Line);
  end;
end;

procedure TMain.memo1SpecialLineColors(Sender: TObject; Line: Integer;
  var Special: Boolean; var FG, BG: TColor);
begin
  Special := False;
  if Line = LastErrorCoord.Line then
  begin
    BG := clYellow;
    Special := True;
  end;
end;

procedure TMain.actSaveExecute(Sender: TObject);
begin
  memo1.SaveToFile(FileOpen1.Dialog.FileName);
end;

procedure TMain.FileSaveAs1Accept(Sender: TObject);
begin
  memo1.SaveToFile(FileSaveAs1.Dialog.FileName);
  FileOpen1.Dialog.FileName := FileSaveAs1.Dialog.FileName;
  updateCaption;
end;

procedure TMain.updateCaption;
begin
  caption := 'JavaScript Lint GUI - ' +
    extractfilename(FileOpen1.Dialog.FileName);
end;

end.

