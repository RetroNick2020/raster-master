unit rmscripteditor;

{$mode objfpc}{$H+}

//=============================================================================
// Raster Master QBasic script editor
//
// Window layout and file handling are adapted from RetroDP's script manager.
// The scripting API is NOT RetroDP's: the editor knows nothing about pixels
// or palettes. Raster Master registers its own API through OnSetupInterpreter
// - the same routine the Script > Run menu uses - so the editor and the menu
// always run scripts against the identical API.
//
// Hooks, all set by the owner (rmmain):
//   OnSetupInterpreter  once, before the first run - register the API.
//                       Reset/LoadProgram do not clear registrations.
//   OnBeforeRun         after LoadProgram - set globals (LoadProgram wipes
//                       variables), take an undo snapshot
//   OnAfterRun          after the run, even a failed one - refresh the views
//=============================================================================

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  ComCtrls, Buttons, LCLType, SynEdit, SynHighlighterAny,
  QBasicInterp;

type
  TScriptInterpEvent = procedure(Interp : TQBasicInterpreter) of object;
  TScriptNotifyEvent = procedure of object;

  { TRMScriptEditorForm }

  TRMScriptEditorForm = class(TForm)
    btnNew: TBitBtn;
    btnOpen: TBitBtn;
    btnRun: TBitBtn;
    btnSave: TBitBtn;
    btnStop: TBitBtn;
    dlgOpen: TOpenDialog;
    dlgSave: TSaveDialog;
    lblOutput: TLabel;
    lblScripts: TLabel;
    lstScripts: TListBox;
    memoOutput: TMemo;
    pnlLeft: TPanel;
    pnlOutput: TPanel;
    pnlRight: TPanel;
    pnlToolbar: TPanel;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    StatusBar: TStatusBar;
    synBasic: TSynAnySyn;
    synEdit: TSynEdit;
    procedure btnNewClick(Sender: TObject);
    procedure btnOpenClick(Sender: TObject);
    procedure btnRunClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure lstScriptsClick(Sender: TObject);
    procedure synEditChange(Sender: TObject);
    procedure synEditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    FInterpreter : TQBasicInterpreter;
    FScriptsPath : string;
    //Full path of the script being edited, '' when it was never saved.
    //RetroDP tracked a list index instead, which lost the name after Open or
    //Save As and made every later Save ask for a file name again.
    FCurrentFile : string;
    FModified    : boolean;
    FRunning     : boolean;
    FAPIReady    : boolean;

    FOnSetupInterpreter : TScriptInterpEvent;
    FOnBeforeRun        : TScriptInterpEvent;
    FOnAfterRun         : TScriptNotifyEvent;

    procedure SetupSyntaxHighlighter;
    procedure LoadScriptList;
    procedure LoadScript(const FileName : string);
    function  SaveScript(AskForName : boolean) : boolean;
    function  ConfirmSave : boolean;
    procedure SetStatus(const S : string);
    procedure UpdateCaption;
    procedure RunScript(const Code : string);

    procedure OnPrint(const AText : string);
    function  OnInput(const Prompt : string; var Value : string) : boolean;
    procedure YieldToUI;
  public
    //highlight the owner's API names as keywords
    procedure AddAPIKeywords(const Names : array of string);

    property OnSetupInterpreter : TScriptInterpEvent read FOnSetupInterpreter write FOnSetupInterpreter;
    property OnBeforeRun : TScriptInterpEvent read FOnBeforeRun write FOnBeforeRun;
    property OnAfterRun : TScriptNotifyEvent read FOnAfterRun write FOnAfterRun;
    property Running : boolean read FRunning;
  end;

var
  RMScriptEditorForm : TRMScriptEditorForm;

//Created on first use, owned by Application - there is no .lpr auto-create
//entry for this form, so its global starts nil (the same pattern as
//GetIdValuePropsForm).
function GetScriptEditorForm : TRMScriptEditorForm;

implementation

{$R *.lfm}

const
  NewScriptText =
    '''' + ' Raster Master script' + LineEnding +
    '''' + ' Runs on the image being edited. Edit > Undo reverts the whole run.' + LineEnding +
    '''' + LineEnding +
    '''' + ' Procedures need parentheses:  PUTPIXEL(x, y, c)' + LineEnding +
    '''' + '   c = GETPIXEL(x, y)      n = GETMAXCOLOR()' + LineEnding +
    '''' + '   w = GETWIDTH()          h = GETHEIGHT()' + LineEnding +
    '''' + '   r = GETCOLORR(c)  g = GETCOLORG(c)  b = GETCOLORB(c)' + LineEnding +
    '''' + ' Selection: CLIP_ACTIVE, CLIP_X1, CLIP_Y1, CLIP_X2, CLIP_Y2' + LineEnding +
    '' + LineEnding +
    'w = GETWIDTH()' + LineEnding +
    'h = GETHEIGHT()' + LineEnding +
    'FOR x = 0 TO w - 1' + LineEnding +
    '  PUTPIXEL(x, 0, 15)' + LineEnding +
    '  PUTPIXEL(x, h - 1, 15)' + LineEnding +
    'NEXT' + LineEnding +
    'FOR y = 0 TO h - 1' + LineEnding +
    '  PUTPIXEL(0, y, 15)' + LineEnding +
    '  PUTPIXEL(w - 1, y, 15)' + LineEnding +
    'NEXT' + LineEnding +
    'PRINT "Drew a border around the image"' + LineEnding;

function GetScriptEditorForm : TRMScriptEditorForm;
begin
  if RMScriptEditorForm = nil then
    RMScriptEditorForm:=TRMScriptEditorForm.Create(Application);
  GetScriptEditorForm:=RMScriptEditorForm;
end;

{ TRMScriptEditorForm }

procedure TRMScriptEditorForm.FormCreate(Sender: TObject);
begin
  FInterpreter:=TQBasicInterpreter.Create;
  FInterpreter.OnPrint:=@OnPrint;
  FInterpreter.OnInput:=@OnInput;
  FInterpreter.OnYield:=@YieldToUI;   //the interpreter calls this every 100 statements

  //A per-user folder: beside the exe is usually read-only under Program Files.
  FScriptsPath:=IncludeTrailingPathDelimiter(GetAppConfigDir(False))+'Scripts'+PathDelim;

  SetupSyntaxHighlighter;
  synEdit.Highlighter:=synBasic;
  synEdit.Text:=NewScriptText;

  FCurrentFile:='';
  FModified:=False;
  FRunning:=False;
  FAPIReady:=False;
  btnStop.Enabled:=False;
  UpdateCaption;
end;

procedure TRMScriptEditorForm.FormDestroy(Sender: TObject);
begin
  FInterpreter.Free;
end;

procedure TRMScriptEditorForm.FormShow(Sender: TObject);
begin
  LoadScriptList;
  synEdit.SetFocus;
end;

procedure TRMScriptEditorForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  //The interpreter yields to the message loop while running, so the window
  //can be closed mid-run. Stop the script first rather than let it keep
  //drawing with nowhere to report to.
  if FRunning then
  begin
    FInterpreter.Stop;
    CloseAction:=caNone;
    exit;
  end;
  if not ConfirmSave then CloseAction:=caNone
  else CloseAction:=caHide;   //keep the text for next time - the form is reused
end;

procedure TRMScriptEditorForm.SetupSyntaxHighlighter;
const
  QBKeywords : array[0..44] of string = (
    'AND','AS','CALL','CASE','CONST','DATA','DECLARE','DEF','DIM','DO',
    'DOUBLE','ELSE','ELSEIF','END','EXIT','FOR','FUNCTION','GOSUB','GOTO','IF',
    'INPUT','INTEGER','IS','LET','LONG','LOOP','MOD','NEXT','NOT','OR',
    'PRINT','READ','REM','RESTORE','RETURN','SELECT','SHARED','SINGLE','STATIC','STEP',
    'STRING','SUB','THEN','TO','WEND');
var
  i : integer;
begin
  synBasic.KeyWords.Clear;
  for i:=Low(QBKeywords) to High(QBKeywords) do synBasic.KeyWords.Add(QBKeywords[i]);
  synBasic.KeyWords.Add('WHILE');
  synBasic.KeyWords.Add('XOR');
  synBasic.KeyWords.Add('UNTIL');

  synBasic.CommentAttri.Foreground:=clGreen;
  synBasic.CommentAttri.Style:=[fsItalic];
  synBasic.KeyAttri.Foreground:=clNavy;
  synBasic.KeyAttri.Style:=[fsBold];
  synBasic.StringAttri.Foreground:=clMaroon;
  synBasic.NumberAttri.Foreground:=clBlue;
  //QBasic comments start with an apostrophe. RetroDP set Pascal and C comment
  //styles here, which never match a QBasic comment.
  synBasic.Comments:=[csBasStyle];
end;

procedure TRMScriptEditorForm.AddAPIKeywords(const Names : array of string);
var
  i : integer;
begin
  for i:=Low(Names) to High(Names) do
    if synBasic.KeyWords.IndexOf(UpperCase(Names[i])) < 0 then
      synBasic.KeyWords.Add(UpperCase(Names[i]));
end;

procedure TRMScriptEditorForm.synEditKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F5 then begin btnRunClick(nil); Key:=0; exit; end;
  if (Key = VK_ESCAPE) and FRunning then begin btnStopClick(nil); Key:=0; exit; end;
  if (ssCtrl in Shift) and (Key = VK_S) then begin btnSaveClick(nil); Key:=0; exit; end;
  if (ssCtrl in Shift) and (Key = VK_N) then begin btnNewClick(nil); Key:=0; exit; end;
  if (ssCtrl in Shift) and (Key = VK_O) then begin btnOpenClick(nil); Key:=0; exit; end;
end;

procedure TRMScriptEditorForm.synEditChange(Sender: TObject);
begin
  if not FModified then
  begin
    FModified:=True;
    UpdateCaption;
  end;
end;

procedure TRMScriptEditorForm.SetStatus(const S : string);
begin
  StatusBar.Panels[0].Text:=S;
end;

procedure TRMScriptEditorForm.UpdateCaption;
var
  nm : string;
begin
  if FCurrentFile = '' then nm:='Untitled' else nm:=ExtractFileName(FCurrentFile);
  if FModified then nm:=nm+' *';
  Caption:='Script Editor - '+nm;
  StatusBar.Panels[1].Text:=nm;
end;

//--- files ------------------------------------------------------------------

procedure TRMScriptEditorForm.LoadScriptList;
var
  SR : TSearchRec;
begin
  lstScripts.Items.BeginUpdate;
  try
    lstScripts.Clear;
    if not DirectoryExists(FScriptsPath) then ForceDirectories(FScriptsPath);
    if FindFirst(FScriptsPath+'*.bas',faAnyFile,SR) = 0 then
    begin
      repeat
        lstScripts.Items.Add(ChangeFileExt(SR.Name,''));
      until FindNext(SR) <> 0;
      FindClose(SR);
    end;
  finally
    lstScripts.Items.EndUpdate;
  end;
  //keep the current script highlighted if it lives in the folder
  if FCurrentFile <> '' then
    lstScripts.ItemIndex:=lstScripts.Items.IndexOf(ChangeFileExt(ExtractFileName(FCurrentFile),''));
end;

procedure TRMScriptEditorForm.LoadScript(const FileName : string);
begin
  synEdit.Lines.LoadFromFile(FileName);
  FCurrentFile:=FileName;
  FModified:=False;
  UpdateCaption;
  SetStatus('Loaded '+ExtractFileName(FileName));
end;

//Returns false if the user cancelled or the save failed.
function TRMScriptEditorForm.SaveScript(AskForName : boolean) : boolean;
var
  FN : string;
begin
  SaveScript:=false;
  FN:=FCurrentFile;
  if AskForName or (FN = '') then
  begin
    if not DirectoryExists(FScriptsPath) then ForceDirectories(FScriptsPath);
    dlgSave.InitialDir:=FScriptsPath;
    dlgSave.Filter:='QBasic Scripts (*.bas)|*.bas|All Files (*.*)|*.*';
    dlgSave.DefaultExt:='.bas';
    if not dlgSave.Execute then exit;
    FN:=dlgSave.FileName;
  end;

  try
    synEdit.Lines.SaveToFile(FN);
  except
    on E: Exception do
    begin
      ShowMessage('Could not save script:'+LineEnding+E.Message);
      exit;
    end;
  end;

  FCurrentFile:=FN;   //remembered, so the next Save does not ask again
  FModified:=False;
  UpdateCaption;
  SetStatus('Saved '+ExtractFileName(FN));
  LoadScriptList;
  SaveScript:=true;
end;

function TRMScriptEditorForm.ConfirmSave : boolean;
begin
  ConfirmSave:=true;
  if not FModified then exit;
  case MessageDlg('Save Script','The script has been modified. Save changes?',
                  mtConfirmation,[mbYes,mbNo,mbCancel],0) of
    mrYes    : ConfirmSave:=SaveScript(false);
    mrCancel : ConfirmSave:=false;
  end;
end;

procedure TRMScriptEditorForm.btnNewClick(Sender: TObject);
begin
  if FRunning or not ConfirmSave then exit;
  synEdit.Text:=NewScriptText;
  FCurrentFile:='';
  FModified:=False;
  lstScripts.ItemIndex:=-1;
  UpdateCaption;
  SetStatus('New script');
end;

procedure TRMScriptEditorForm.btnOpenClick(Sender: TObject);
begin
  if FRunning or not ConfirmSave then exit;
  dlgOpen.InitialDir:=FScriptsPath;
  dlgOpen.Filter:='QBasic Scripts (*.bas)|*.bas|All Files (*.*)|*.*';
  if dlgOpen.Execute then
  begin
    LoadScript(dlgOpen.FileName);
    LoadScriptList;
  end;
end;

procedure TRMScriptEditorForm.btnSaveClick(Sender: TObject);
begin
  SaveScript(false);
end;

procedure TRMScriptEditorForm.lstScriptsClick(Sender: TObject);
var
  FN : string;
begin
  if (lstScripts.ItemIndex < 0) or FRunning then exit;
  FN:=FScriptsPath+lstScripts.Items[lstScripts.ItemIndex]+'.bas';
  if SameFileName(FN,FCurrentFile) then exit;
  if not ConfirmSave then
  begin
    LoadScriptList;   //put the highlight back on the script still open
    exit;
  end;
  LoadScript(FN);
end;

//--- running ----------------------------------------------------------------

procedure TRMScriptEditorForm.btnRunClick(Sender: TObject);
begin
  if FRunning then exit;
  RunScript(synEdit.Text);
end;

procedure TRMScriptEditorForm.btnStopClick(Sender: TObject);
begin
  if not FRunning then exit;
  FInterpreter.Stop;
  SetStatus('Stopping...');
end;

procedure TRMScriptEditorForm.RunScript(const Code : string);
var
  ok : boolean;
begin
  memoOutput.Clear;
  FRunning:=True;
  btnRun.Enabled:=False;
  btnStop.Enabled:=True;
  btnNew.Enabled:=False;
  btnOpen.Enabled:=False;
  SetStatus('Running...');
  ok:=false;

  try
    try
      //the API survives Reset and LoadProgram, so it is registered once
      if not FAPIReady then
      begin
        if Assigned(FOnSetupInterpreter) then FOnSetupInterpreter(FInterpreter);
        FAPIReady:=True;
      end;

      FInterpreter.LoadProgram(Code);
      //after LoadProgram - it clears variables, which would wipe the globals
      if Assigned(FOnBeforeRun) then FOnBeforeRun(FInterpreter);
      FInterpreter.Execute;
      ok:=true;
    except
      on E: EQBasicError do
      begin
        memoOutput.Lines.Add('');
        memoOutput.Lines.Add('ERROR at line '+IntToStr(E.Line)+': '+E.Message);
        SetStatus('Error at line '+IntToStr(E.Line));
        //put the cursor on the failing line
        if (E.Line > 0) and (E.Line <= synEdit.Lines.Count) then
        begin
          synEdit.CaretXY:=Point(1,E.Line);
          synEdit.SetFocus;
        end;
      end;
      on E: Exception do
      begin
        memoOutput.Lines.Add('');
        memoOutput.Lines.Add('ERROR: '+E.Message);
        SetStatus('Error: '+E.Message);
      end;
    end;
  finally
    //refresh even after an error - the script may have drawn before failing
    if Assigned(FOnAfterRun) then FOnAfterRun;
    FRunning:=False;
    btnRun.Enabled:=True;
    btnStop.Enabled:=False;
    btnNew.Enabled:=True;
    btnOpen.Enabled:=True;
  end;

  if ok then SetStatus('Script completed');
end;

//--- interpreter callbacks --------------------------------------------------

procedure TRMScriptEditorForm.OnPrint(const AText : string);
begin
  memoOutput.Lines.Add(AText);
end;

function TRMScriptEditorForm.OnInput(const Prompt : string; var Value : string) : boolean;
begin
  OnInput:=InputQuery('Script Input',Prompt,Value);
end;

procedure TRMScriptEditorForm.YieldToUI;
begin
  //keeps Stop, Esc and the output pane responsive during long loops
  Application.ProcessMessages;
end;

end.
