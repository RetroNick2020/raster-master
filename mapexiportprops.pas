//=============================================================================
// CHANGE LOG (Claude edits - newest first)
//-----------------------------------------------------------------------------
// 2026-08-08  APPLY TO ALL MAPS - build fix
//   * Renamed the local 'Changed' to 'ChangedCount'. TControl.Changed is in
//     scope inside any TForm method, so the local was error 5002, not a shadow.
//-----------------------------------------------------------------------------
// 2026-08-08  APPLY TO ALL MAPS - confirmation dialog
//   * ApplyToAllMaps now counts the maps it actually altered and reports them
//     in a ShowMessage. 'Changed' means the stored record differs afterwards,
//     so a map that already held the chosen values is not counted - the number
//     tells you what moved, not how many maps exist.
//   * Nothing is shown when neither box is ticked, so the normal single-map
//     OK press is still one click with no extra dialog.
//-----------------------------------------------------------------------------
// 2026-08-08  APPLY TO ALL MAPS
//   * New 'Apply to ALL maps' group box with two independent check boxes,
//     'Compiler' and 'Map Type'. When ticked, pressing OK writes that one
//     field from this dialog into EVERY map's ExportProps.
//   * The propagation happens in ApplyToAllMaps, called from OKButtonClick,
//     so the calling form needs no change - MenuMapPropsClick in mapeditor.pas
//     still just does GetExportProps/SetMapExportProps for the map it opened.
//   * Export Width / Export Height are deliberately NOT propagated. They are
//     per-map crop overrides and are meaningless applied globally.
//   * The check boxes are transient. They are cleared in InitComboBoxes, which
//     the caller runs every time before ShowModal, so 'apply to all' can never
//     silently fire twice.
//-----------------------------------------------------------------------------
// 2026-08-03  MAP LAYERS - phase 3 (export properties dialog)
//   * ComboMap gained a 'Layered' entry. The combo index IS the stored
//     MapFormat value, so the order here must stay:
//        0 = None, 1 = Simple (rwmap.MapFormatSimple),
//        2 = Layered (rwmap.MapFormatLayered)
//     Do not reorder these without changing those constants.
//=============================================================================

unit mapexiportprops;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, SpinEx,
  rmconst,mapcore, rwmap, rmcodegen;

type

  { TMapExportForm }

  TMapExportForm = class(TForm)
    OKButton: TButton;
    CheckApplyCompiler: TCheckBox;
    CheckApplyMapType: TCheckBox;
    ComboCompiler: TComboBox;
    ComboMap: TComboBox;
    CompilerType: TLabel;
    EditName: TEdit;
    GroupApplyAll: TGroupBox;
    HeightLabel: TLabel;
    MapName: TLabel;
    MapType: TLabel;
    SpinEditExportWidth: TSpinEditEx;
    SpinEditExportHeight: TSpinEditEx;
    WidthLabel: TLabel;
    procedure OKButtonClick(Sender: TObject);
    procedure ComboCompilerChange(Sender: TObject);
  private

  public
       EO : MapExportFormatRec;
       procedure SetExportProps(props : MapExportFormatRec);
       procedure GetExportProps(var props : MapExportFormatRec);
       procedure InitComboBoxes;
       procedure UpdateComboBoxes(compiler : integer);
       procedure ApplyToAllMaps;
  end;

var
  MapExportForm: TMapExportForm;

implementation

{$R *.lfm}

procedure TMapExportForm.ComboCompilerChange(Sender: TObject);
begin
   UpdateComboBoxes(ComboCompiler.ItemIndex);
end;

procedure TMapExportForm.OKButtonClick(Sender: TObject);
begin
  //propagate first, then close. The caller writes this map's own full record
  //after ShowModal returns, so it always wins for the map that was opened.
  ApplyToAllMaps;
  modalresult:= mrOk;
end;

//=============================================================================
// APPLY TO ALL MAPS
//
// Pushes the Compiler and/or Map Type shown in this dialog into every map in
// MapCoreBase. The two check boxes are independent - tick only 'Compiler' and
// each map keeps its own Map Type, and vice versa.
//
// Only these two fields travel. Name is per-map by definition (it becomes the
// array/RES identifier in the generated source), and Export Width/Height are
// per-map crop overrides, so neither is propagated.
//
// Reports the result, because this is the one action in the dialog that
// reaches outside the map the user opened and there is no undo for it.
//=============================================================================
procedure TMapExportForm.ApplyToAllMaps;
var
  i, Lan, Fmt, Count, ChangedCount : integer;
  props : MapExportFormatRec;
  OldLan, OldFmt : integer;
  what, detail, msg : string;
begin
  //NOTE: do not rename ChangedCount back to 'Changed'. This is a TForm method,
  //so TControl.Changed from the Controls unit is already in scope and a local
  //of that name is a duplicate identifier, not a shadow.

  if (not CheckApplyCompiler.Checked) and (not CheckApplyMapType.Checked) then exit;

  Count:=MapCoreBase.GetMapCount;
  if Count < 1 then
  begin
    ShowMessage('There are no maps to apply these settings to.');
    exit;
  end;

  Lan:=ComboCompiler.ItemIndex;
  Fmt:=ComboMap.ItemIndex;
  //ItemIndex is -1 on an empty combo - treat that as None rather than
  //writing a negative Lan into the record
  if Lan < 0 then Lan:=NoLan;
  if Fmt < 0 then Fmt:=0;

  ChangedCount:=0;
  //GetMapExportProps fills this completely, but clearing it up front keeps the
  //compiler from warning about an uninitialised local
  FillChar(props,SizeOf(props),0);

  for i:=0 to Count-1 do
  begin
    MapCoreBase.GetMapExportProps(i,props);

    //remember what was there so we only count maps that actually moved
    OldLan:=props.Lan;
    OldFmt:=props.MapFormat;

    if CheckApplyCompiler.Checked then props.Lan:=Lan;
    if CheckApplyMapType.Checked then props.MapFormat:=Fmt;

    //keep the record self-consistent - a map format with no compiler to emit
    //it in is not exportable, and this is the same rule UpdateComboBoxes
    //enforces in the UI
    if props.Lan = NoLan then props.MapFormat:=0;

    if (props.Lan <> OldLan) or (props.MapFormat <> OldFmt) then inc(ChangedCount);

    MapCoreBase.SetMapExportProps(i,props);
  end;

  //name the fields that travelled so the count is not ambiguous, and echo
  //only the values that were actually pushed - listing a field that was left
  //alone would read as though it had been applied too
  what:='';
  detail:='';
  if CheckApplyCompiler.Checked then
  begin
    what:='Compiler';
    detail:=sLineBreak+'Compiler: '+ComboCompiler.Text;
  end;
  if CheckApplyMapType.Checked then
  begin
    if what = '' then what:='Map Type' else what:=what+' and Map Type';
    detail:=detail+sLineBreak+'Map Type: '+ComboMap.Text;
  end;

  if ChangedCount = 0 then
    msg:='All '+IntToStr(Count)+' maps already use this '+what+'.'+sLineBreak+
         'No changes were made.'
  else
    msg:=what+' applied to '+IntToStr(ChangedCount)+' of '+IntToStr(Count)+' maps.'+
         sLineBreak+detail;

  ShowMessage(msg);
end;

procedure TMapExportForm.SetExportProps(props : MapExportFormatRec);
begin
   EO:=props;
   EditName.caption:=EO.Name;
   ComboCompiler.ItemIndex:=EO.Lan;
   ComboMap.ItemIndex:=EO.MapFormat;
   SpinEditExportWidth.Value:=props.Width;
   SpinEditExportHeight.Value:=props.Height;
   UpdateComboBoxes(ComboCompiler.ItemIndex);
end;

procedure TMapExportForm.GetExportProps(var props : MapExportFormatRec);
begin
  props.Name:=EditName.caption;
  props.Lan:=ComboCompiler.ItemIndex;
  props.MapFormat:=ComboMap.ItemIndex;
  props.Width:=SpinEditExportWidth.Value;
  props.Height:=SpinEditExportHeight.Value;
end;

procedure TMapExportForm.InitComboBoxes;
begin
   EditName.caption:='';
   Combocompiler.Items.Clear;
   //order must match the Lan constants in rmcodegen.pas
   ComboCompiler.Items.Add('None');                 //0  NoLan
   ComboCompiler.Items.Add('Turbo Pascal');         //1  TPLan
   ComboCompiler.Items.Add('Turbo C');              //2  TCLan
   ComboCompiler.Items.Add('Quick C');              //3  QCLan
   ComboCompiler.Items.Add('QBasic\QuickBasic');    //4  QBLan
   ComboCompiler.Items.Add('QB64');                 //5  QB64Lan
   ComboCompiler.Items.Add('Turbo\Power Basic');    //6  TBLan
   ComboCompiler.Items.Add('GWBASIC');              //7  GWLan
   ComboCompiler.Items.Add('FreePascal');           //8  FPLan
   ComboCompiler.Items.Add('FreeBASIC - QB Mode');  //9  FBinQBModeLan
   ComboCompiler.Items.Add('FreeBASIC');            //10 FBLan
   ComboCompiler.Items.Add('AmigaBasic');           //11 ABLan
   ComboCompiler.Items.Add('Amiga Pascal');         //12 APLan
   ComboCompiler.Items.Add('Amiga C');              //13 ACLan
   ComboCompiler.Items.Add('Amiga QuickBasic AQB'); //14 AQBLan
   ComboCompiler.Items.Add('Quick Pascal');         //15 QPLan
   ComboCompiler.Items.Add('gcc \ Emscripten');     //16 GCCLan
   ComboCompiler.Items.Add('Open Watcom C');        //17 OWLan
   ComboCompiler.Items.Add('BAM Basic');            //18  BAMLan
   ComboCompiler.Items.Add('TMT Pascal');           //19 TMTLan
   ComboCompiler.Items.Add('QBJS');                 //20  QBJSLan
   ComboCompiler.Items.Add('JSON');                 //21 JSONLan

   ComboCompiler.Items.Add('Basic');                //22  BasicLan
   ComboCompiler.Items.Add('Basic (Line#)');        //23  BasicLNLan
   ComboCompiler.Items.Add('C');                    //24  CLan
   ComboCompiler.Items.Add('Pascal');               //25  PascalLan
   ComboCompiler.Items.Add('JavaScript');           //26 JSLan
   ComboCompiler.ItemIndex:=0;

   ComboMap.Items.Clear;
   ComboMap.Items.Add('None');
   ComboMap.ItemIndex:=0;

   SpinEditExportWidth.Value:=24;
   SpinEditExportHeight.Value:=8;

   //transient - never remembered between openings of the dialog
   CheckApplyCompiler.Checked:=False;
   CheckApplyMapType.Checked:=False;
end;

procedure TMapExportForm.UpdateComboBoxes(compiler : integer);
begin
  if compiler = NoLan then
  begin
    ComboMap.Items.Clear;
    ComboMap.Items.Add('None');
    ComboMap.ItemIndex:=0;
  end
  else
  begin
    //all compiler targets support None/Simple/Layered map format.
    //Item index = MapFormat value, so order matters - see header note.
    ComboMap.Items.Clear;
    ComboMap.Items.Add('None');      //0 - do not export
    ComboMap.Items.Add('Simple');    //1 - layer 0 only, pre v4 output
    ComboMap.Items.Add('Layered');   //2 - every layer, layer count in header
    if (EO.MapFormat >= 0) and (EO.MapFormat < ComboMap.Items.Count) then
      ComboMap.ItemIndex:=EO.MapFormat
    else
      ComboMap.ItemIndex:=0;
  end;
end;

end.

