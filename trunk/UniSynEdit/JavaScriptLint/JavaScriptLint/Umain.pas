unit Umain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ToolWin, SynEditHighlighter, SynHighlighterJScript,
  ExtCtrls, SynEdit, ActnList, StdActns, XPStyleActnCtrls, ActnMan, ImgList,
  JavaScriptLintAPI, StdCtrls, UJSLDefaultConf,
  CheckLst, JvExCheckLst, JvCheckListBox, JvExExtCtrls, JvExtComponent,
  JvSplit, JvExControls, JvArrowButton, JvMRUManager, JvComponentBase,
  JvPrint, Menus, SynEditPrint, JvAppStorage, JvAppRegistryStorage,
  JvFormPlacement, SynEditMiscClasses, SynEditSearch, JvOfficeColorButton,
  JvColorBox, JvColorButton, Mask, JvExMask, JvSpin, JvDBSpinEdit,
  JvExStdCtrls, JvCombobox, JvColorCombo, JvLabel;

type
  TState = (stProgramOpened, stFileOpened, stLintExecuted, stFileSaved);
  TMain = class(TForm)
    ToolBar1: TToolBar;
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
    edit: TSynEdit;
    SynJScriptSyn1: TSynJScriptSyn;
    lst1: TJvCheckListBox;
    pnloutput: TPanel;
    tv1: TTreeView;
    mmo1: TMemo;
    actSave: TAction;
    btn1: TToolButton;
    StatusBar: TStatusBar;
    JvxSplitter1: TJvxSplitter;
    FileExit1: TFileExit;
    btn2: TToolButton;
    btn4: TToolButton;
    btn5: TToolButton;
    Recent: TJvMRUManager;
    JvArrowButton1: TJvArrowButton;
    RecentMenu: TPopupMenu;
    SynEditPrint1: TSynEditPrint;
    PrintDlg1: TPrintDlg;
    JvAppRegistryStorage: TJvAppRegistryStorage;
    JvFormStorage: TJvFormStorage;
    Panel1: TPanel;
    btnFlushLintOptions: TButton;
    actFlushLintOptions: TAction;
    pmnuEditor: TPopupMenu;
    lmiEditUndo: TMenuItem;
    lmiEditRedo: TMenuItem;
    N2: TMenuItem;
    lmiEditCut: TMenuItem;
    lmiEditCopy: TMenuItem;
    lmiEditPaste: TMenuItem;
    lmiEditDelete: TMenuItem;
    N1: TMenuItem;
    lmiEditSelectAll: TMenuItem;
    EditCopy1: TEditCopy;
    EditCut1: TEditCut;
    EditPaste1: TEditPaste;
    EditSelectAll1: TEditSelectAll;
    EditUndo1: TEditUndo;
    EditDelete1: TEditDelete;
    actRedo: TAction;
    actUpdateStatusBar: TAction;
    tsProgramOptions: TTabSheet;
    Bevel1: TBevel;
    JvLabel9: TJvLabel;
    optEditFGColor: TJvColorButton;
    JvLabel1: TJvLabel;
    JvLabel3: TJvLabel;
    optEditBGColor: TJvColorButton;
    optEditFont: TJvFontComboBox;
    JvLabel4: TJvLabel;
    JvLabel2: TJvLabel;
    optEditFontSize: TJvSpinEdit;
    JvLabel10: TJvLabel;
    Bevel2: TBevel;
    JvLabel5: TJvLabel;
    optJSLFGColor: TJvColorButton;
    JvLabel7: TJvLabel;
    optJSLBGColor: TJvColorButton;
    JvLabel6: TJvLabel;
    optJSLFont: TJvFontComboBox;
    JvLabel8: TJvLabel;
    optJSLFontSize: TJvSpinEdit;
    procedure FormCreate(Sender: TObject);
    procedure actLintExecute(Sender: TObject);
    procedure FileOpen1Accept(Sender: TObject);
    procedure tv1Deletion(Sender: TObject; Node: TTreeNode);
    procedure tv1DblClick(Sender: TObject);
    procedure editSpecialLineColors(Sender: TObject; Line: Integer;
      var Special: Boolean; var FG, BG: TColor);
    procedure actSaveExecute(Sender: TObject);
    procedure FileSaveAs1Accept(Sender: TObject);
    procedure RecentClick(Sender: TObject; const RecentName,
      Caption: string; UserData: Integer);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure PrintDlg1Accept(Sender: TObject);
    procedure actFlushLintOptionsExecute(Sender: TObject);
    procedure JvFormStorageBeforeSavePlacement(Sender: TObject);
    procedure JvFormStorageAfterRestorePlacement(Sender: TObject);
    procedure editStatusChange(Sender: TObject;
      Changes: TSynStatusChanges);
    procedure EditCopy1Execute(Sender: TObject);
    procedure EditCopy1Update(Sender: TObject);
    procedure EditCut1Execute(Sender: TObject);
    procedure EditCut1Update(Sender: TObject);
    procedure EditPaste1Execute(Sender: TObject);
    procedure EditPaste1Update(Sender: TObject);
    procedure EditSelectAll1Execute(Sender: TObject);
    procedure EditUndo1Execute(Sender: TObject);
    procedure EditUndo1Update(Sender: TObject);
    procedure EditDelete1Execute(Sender: TObject);
    procedure EditDelete1Update(Sender: TObject);
    procedure actRedoExecute(Sender: TObject);
    procedure actRedoUpdate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure actUpdateStatusBarUpdate(Sender: TObject);
    procedure optChange(Sender: TObject);
  private
    fModified: Boolean;
    LastErrorCoord: TBufferCoord;
    CurrentFile: string;
    ShadowCopy:TMemoryStream;
    ShadowSaved:Boolean;
    procedure FillTree(mess: TStringList);
    procedure FlushConf;
    procedure SetState(state: TState);
    function CheckedFileOpen(name: string): boolean;
    procedure PrintPreSet;
    procedure Open(name: string);
    procedure Save(name: string);
    procedure UpdateCaption;
    procedure EnforceProgramOptions;
  public
    { Public declarations }
  end;

var
  Main: TMain;

implementation
uses Printers;
type
  PBufferCoord = ^TBufferCoord;
{$R *.dfm}

procedure TMain.Open(name: string);
begin
  edit.LoadFromFile(name);
  ShadowCopy.Clear;
  edit.Lines.SaveToStream(ShadowCopy);
  ShadowSaved:=False;
  CurrentFile := name;
end;

procedure TMain.Save(name: string);
begin
  edit.SaveToFile(name);
  CurrentFile := name;
end;

procedure TMain.FormCreate(Sender: TObject);
begin
  edit.Clear;
  mmo1.align := alClient;
  tv1.align := alClient;
  if lst1.Items.Count = 0 then
  begin
    FlushConf;
  end;
  Recent.RecentMenu := RecentMenu.Items;
  EnforceProgramOptions;
  SetState(stProgramOpened);
  PrintPreSet;
  pgcLint.ActivePageIndex := 0;
  fModified := False;
  ShadowCopy:=TMemoryStream.Create;
end;

procedure TMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Recent.RecentMenu := nil;
  ShadowCopy.Free;
end;

procedure TMain.FlushConf;
var
  i: Integer;
begin
  LockWindowUpdate(Handle);
  lst1.Items.Clear;
  for i := 0 to JSLOptionsCount - 1 do
  begin
    lst1.Items.Add(DefaultConf[i].key + '    (' + DefaultConf[i].desc + ')');
    lst1.Checked[i] := DefaultConf[i].checked;
  end;
  LockWindowUpdate(0);
end;

procedure TMain.actLintExecute(Sender: TObject);
  function MakeConf: string;
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
  if (LintString('jsl.exe', conf, edit.Lines.Text, mess, error)) then
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
  SetState(stLintExecuted);
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
  if CheckedFileOpen(FileOpen1.Dialog.FileName) then
    Recent.Add(CurrentFile, 0);
end;

function TMain.CheckedFileOpen(name: string): boolean;
begin
  result := True;
  if Edit.Modified then begin
    case Application.MessageBox(PChar('File "' + ExtractFileName(CurrentFile) + '" modifyed. Overwrite it?'), 'JavaScriptLintGUI', MB_YESNOCANCEL + MB_ICONQUESTION) of
      IDYES:
        if FileExists(name) then begin
          actSaveExecute(nil);
        end;
      IDNO:
        if FileExists(name) then begin
          if FileSaveAs1.Dialog.Execute then
            FileSaveAs1Accept(nil)
          else
            result := false;
        end;
      IDCANCEL:
        if FileExists(name) then begin
          result := false;
        end;
    end;
  end;
  if not Result then exit;
  Open(name);
  SetState(stFileOpened);
end;

procedure TMain.RecentClick(Sender: TObject; const RecentName,
  Caption: string; UserData: Integer);
begin
  if FileExists(RecentName) then
  begin
    CheckedFileOpen(RecentName);
  end
  else Application.MessageBox('File not found', 'JavaScriptLintGUI', MB_OK + MB_ICONSTOP);
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
    edit.CaretXY := LastErrorCoord;
    edit.SetFocus;
    edit.InvalidateLine(oldLine);
    edit.InvalidateLine(LastErrorCoord.Line);
  end;
end;

procedure TMain.editSpecialLineColors(Sender: TObject; Line: Integer;
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
var
  ext, bakName: string;
begin
  if not ShadowSaved then
    begin
    ext := ExtractFileExt(CurrentFile);
    if Length(ext)>0 then
      ext := Copy(ext, 2, Length(ext));
    bakName := Copy(CurrentFile, 1, Length(CurrentFile) - length(ext)-1) + '.~' + ext;
    ShadowCopy.Position:=0;
    ShadowCopy.SaveToFile(bakName);
    ShadowSaved:=True;
    ShadowCopy.Clear;
    end;
  Save(CurrentFile);
  Edit.Modified := False;
  SetState(stFileSaved);
end;

procedure TMain.FileSaveAs1Accept(Sender: TObject);
begin
  if (FileSaveAs1.Dialog.FileName <> CurrentFile) and
    FileExists(FileSaveAs1.Dialog.FileName) then
    if Application.MessageBox(PChar('File "' +
      ExtractFileName(FileSaveAs1.Dialog.FileName) +
      '" exists. Overwrite it?'), 'JavaScriptLintGUI',
      MB_YESNO + MB_ICONQUESTION) <> IDYES then exit;

  Save(FileSaveAs1.Dialog.FileName);
  FileOpen1.Dialog.FileName := FileSaveAs1.Dialog.FileName;
  Edit.Modified := False;
  SetState(stFileSaved);
  Recent.Add(FileOpen1.Dialog.FileName, 0);
end;

procedure TMain.UpdateCaption;
var modif: string;
begin
  if fModified then modif := ' *';
  caption := 'JavaScript Lint GUI - ' +
    extractfilename(CurrentFile) + modif;
end;

procedure TMain.SetState(state: TState);
begin
  LockWindowUpdate(Handle);
  //SendMessage(HWND, WM_SETREDRAW, 0, 0);
  FileSaveAs1.Enabled := False;
  actSave.Enabled := False;
  PrintDlg1.Enabled := False;
  actLint.Enabled := False;
  pgcLint.Hide;
  pnloutput.Hide;
  JvxSplitter1.Hide;
  case state of
    stFileOpened:
      begin
        FileSaveAs1.Enabled := true;
        actSave.Enabled := true;
        PrintDlg1.Enabled := true;
        actLint.Enabled := true;
        UpdateCaption;
        pgcLint.Show;
        tv1.Items.Clear;
      end;
    stLintExecuted:
      begin
        FileSaveAs1.Enabled := true;
        actSave.Enabled := true;
        PrintDlg1.Enabled := true;
        actLint.Enabled := true;
        pgcLint.Show;
        pnloutput.Show;
        JvxSplitter1.Show;
        UpdateCaption;
      end;
    stFileSaved:
      begin
        FileSaveAs1.Enabled := true;
        actSave.Enabled := true;
        PrintDlg1.Enabled := true;
        actLint.Enabled := true;
        UpdateCaption;
        pgcLint.Show;
        if tv1.Items.Count > 0 then
        begin
          pnloutput.Show;
          JvxSplitter1.Show;
        end;
        UpdateCaption;
      end;
  end;
  LockWindowUpdate(0);
end;

procedure TMain.PrintDlg1Accept(Sender: TObject);
begin
  SynEditPrint1.SynEdit := Edit;
  SynEditPrint1.Title := CurrentFile;
  SynEditPrint1.Copies := PrintDlg1.Dialog.Copies;
  SynEditPrint1.Print;
end;

procedure TMain.PrintPreSet;
begin
  with SynEditPrint1.Header do begin
      {First line, default font, left aligned}
    Add('$TITLE$', nil, taLeftJustify, 1);
  end;
  with SynEditPrint1.Footer do begin
    Add('$PAGENUM$/$PAGECOUNT$', nil, taCenter, 1);
  end;
end;

procedure TMain.actFlushLintOptionsExecute(Sender: TObject);
begin
  FlushConf;
end;

procedure TMain.JvFormStorageBeforeSavePlacement(Sender: TObject);
var val: string;
  i: Integer;
begin
  val := '';
  for i := 0 to lst1.Count - 1 do
  begin
    if lst1.Checked[i] then val := val + '1'
    else val := val + '0';
  end;
  JvFormStorage.StoredValue['LintOptionsState'] := val;
end;

procedure TMain.JvFormStorageAfterRestorePlacement(Sender: TObject);
var val: string;
  i: Integer;
begin
  val := JvFormStorage.StoredValue['LintOptionsState'];
  if val <> '' then
  try
    for i := 0 to length(val) - 1 do
    begin
      if val[i + 1] = '1' then lst1.Checked[i] := true
      else lst1.Checked[i] := false;
    end;
  except
    FlushConf;
  end;
end;

procedure TMain.editStatusChange(Sender: TObject;
  Changes: TSynStatusChanges);
var
  oldLine: Integer;
begin
  if (Changes * [scAll, scModified] <> []) and (fModified <> Edit.Modified) then
  begin
    if LastErrorCoord.Line > 0 then
    begin
      oldLine:=LastErrorCoord.Line;
      LastErrorCoord.Line := 0;
      LastErrorCoord.Char := 0;
      edit.InvalidateLine(oldLine);
    end;
    fModified := Edit.Modified;
    UpdateCaption;
  end;
end;

procedure TMain.EditCopy1Execute(Sender: TObject);
begin
  Edit.CopyToClipboard;
end;

procedure TMain.EditCopy1Update(Sender: TObject);
begin
  EditCopy1.Enabled := Edit.SelLength <> 0;
end;

procedure TMain.EditCut1Execute(Sender: TObject);
begin
  edit.CutToClipboard;
end;

procedure TMain.EditCut1Update(Sender: TObject);
begin
  EditCut1.Enabled := (Edit.SelLength <> 0) and (not edit.ReadOnly);
end;

procedure TMain.EditPaste1Execute(Sender: TObject);
begin
  edit.PasteFromClipboard;
end;

procedure TMain.EditPaste1Update(Sender: TObject);
begin
  EditPaste1.Enabled := edit.CanPaste;
end;

procedure TMain.EditSelectAll1Execute(Sender: TObject);
begin
  edit.SelectAll;
end;

procedure TMain.EditUndo1Execute(Sender: TObject);
begin
  edit.Undo;
end;

procedure TMain.EditUndo1Update(Sender: TObject);
begin
  EditUndo1.Enabled := edit.CanUndo;
end;

procedure TMain.EditDelete1Execute(Sender: TObject);
begin
  edit.seltext := '';
end;

procedure TMain.EditDelete1Update(Sender: TObject);
begin
  EditDelete1.Enabled := edit.SelLength <> 0;
end;

procedure TMain.actRedoExecute(Sender: TObject);
begin
  edit.Redo;
end;

procedure TMain.actRedoUpdate(Sender: TObject);
begin
  actRedo.Enabled := edit.canRedo;
end;

procedure TMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if fModified then begin
    case Application.MessageBox(PChar('File "' + ExtractFileName(CurrentFile) + '" modifyed. Overwrite it?'), 'JavaScriptLintGUI', MB_YESNOCANCEL + MB_ICONQUESTION) of
      IDYES:
        actSaveExecute(nil);
      IDCANCEL:
        CanClose := false;
    end;
  end;
end;
procedure TMain.actUpdateStatusBarUpdate(Sender: TObject);
begin
  actUpdateStatusBar.Enabled := TRUE;
    if (edit.CaretY > 0) and (edit.CaretX > 0) then
      StatusBar.Panels[2].Text := Format(' %6d:%3d ', [edit.CaretY, edit.CaretX])
    else
      StatusBar.Panels[2].Text := '';
    if edit.Modified then
      StatusBar.Panels[1].Text := '*'
    else
      StatusBar.Panels[1].Text := '';
    //StatusBar.Panels[2].Text := GI_ActiveEditor.GetEditorState;
end;

procedure TMain.optChange(Sender: TObject);
begin
  EnforceProgramOptions;
end;

procedure TMain.EnforceProgramOptions;
begin
  edit.Color:=optEditBGColor.Color;
  edit.Font.Color:=optEditFGColor.Color;
  edit.Font.Name:=optEditFont.FontName;
  edit.Font.Size:=trunc(optEditFontSize.value);
  tv1.Color:=optJSLBGColor.Color;
  tv1.Font.Color:=optJSLFGColor.Color;
  tv1.Font.Name:=optJSLFont.FontName;
  tv1.Font.Size:=trunc(optJSLFontSize.value);
end;
end.

