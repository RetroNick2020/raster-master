unit mapexiportprops;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, SpinEx,
  mapcore, rwmap, rmcodegen;

type

  { TMapExportForm }

  TMapExportForm = class(TForm)
    OKButton: TButton;
    ComboCompiler: TComboBox;
    ComboMap: TComboBox;
    CompilerType: TLabel;
    EditName: TEdit;
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
  modalresult:= mrOk;
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
   ComboCompiler.Items.Add('Basic');                //1  BasicLan
   ComboCompiler.Items.Add('Basic (Line#)');        //2  BasicLNLan
   ComboCompiler.Items.Add('C');                    //3  CLan
   ComboCompiler.Items.Add('Pascal');               //4  PascalLan
   ComboCompiler.Items.Add('FreeBASIC');            //5  FBBasicLan
   ComboCompiler.Items.Add('QB64');                 //6  QB64BasicLan
   ComboCompiler.Items.Add('Amiga QuickBasic AQB'); //7  AQBBasicLan
   ComboCompiler.Items.Add('BAM Basic');            //8  BAMBasicLan
   ComboCompiler.Items.Add('QBJS');                 //9  QBJSBasicLan
   ComboCompiler.Items.Add('GWBASIC');              //10 GWBasicLan
   ComboCompiler.Items.Add('QBasic\QuickBasic');    //11 QBBasicLan
   ComboCompiler.Items.Add('Turbo\Power Basic');    //12 TBBasicLan
   ComboCompiler.Items.Add('AmigaBasic');           //13 ABBasicLan
   ComboCompiler.Items.Add('FreeBASIC - QB Mode');  //14 FBQBBasicLan
   ComboCompiler.Items.Add('Turbo Pascal');         //15 TPPascalLan
   ComboCompiler.Items.Add('Quick Pascal');         //16 QPPascalLan
   ComboCompiler.Items.Add('FreePascal');           //17 FPPascalLan
   ComboCompiler.Items.Add('TMT Pascal');           //18 TMTPascalLan
   ComboCompiler.Items.Add('Amiga Pascal');         //19 APPascalLan
   ComboCompiler.Items.Add('Turbo C');              //20 TCCLan
   ComboCompiler.Items.Add('Quick C');              //21 QCCLan
   ComboCompiler.Items.Add('Open Watcom C');        //22 OWCLan
   ComboCompiler.Items.Add('gcc \ Emscripten');     //23 GCCCLan
   ComboCompiler.Items.Add('Amiga C');              //24 ACCLan
   ComboCompiler.Items.Add('JavaScript');           //25 JSLan
   ComboCompiler.ItemIndex:=0;

   ComboMap.Items.Clear;
   ComboMap.Items.Add('None');
   ComboMap.ItemIndex:=0;

   SpinEditExportWidth.Value:=24;
   SpinEditExportHeight.Value:=8;
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
    //all compiler targets support None/Simple map format
    ComboMap.Items.Clear;
    ComboMap.Items.Add('None');
    ComboMap.Items.Add('Simple');
    if (EO.MapFormat >= 0) and (EO.MapFormat < ComboMap.Items.Count) then
      ComboMap.ItemIndex:=EO.MapFormat
    else
      ComboMap.ItemIndex:=0;
  end;
end;

end.

