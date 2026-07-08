unit animationexport;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,AnimBase,rwxgf,rmcodegen;

type

  { TAnimationExportForm }

  TAnimationExportForm = class(TForm)
    ComboCompiler: TComboBox;
    ComboMap: TComboBox;
    CompilerType: TLabel;
    EditName: TEdit;
    AnimationName: TLabel;
    AnimationType: TLabel;
    OKButton: TButton;
    procedure ComboCompilerChange(Sender: TObject);
    procedure OKButtonClick(Sender: TObject);
  private

  public
       EO : AnimExportFormatRec;
       procedure SetExportProps(props : AnimExportFormatRec);
       procedure GetExportProps(var props : AnimExportFormatRec);
       procedure InitComboBoxes;
       procedure UpdateComboBoxes(compiler : integer);

  end;

var
  AnimationExportForm: TAnimationExportForm;

implementation

{$R *.lfm}

procedure TAnimationExportForm.ComboCompilerChange(Sender: TObject);
begin
   UpdateComboBoxes(ComboCompiler.ItemIndex);
end;

procedure TAnimationExportForm.OKButtonClick(Sender: TObject);
begin
  modalresult:= mrOk;
end;

procedure TAnimationExportForm.SetExportProps(props : AnimExportFormatRec);
begin
   EO:=props;
   EditName.caption:=EO.Name;
   ComboCompiler.ItemIndex:=EO.Lan;
   ComboMap.ItemIndex:=EO.AnimateFormat;
   UpdateComboBoxes(ComboCompiler.ItemIndex);
end;

procedure TAnimationExportForm.GetExportProps(var props : AnimExportFormatRec);
begin
  props.Name:=EditName.caption;
  props.Lan:=ComboCompiler.ItemIndex;
  props.AnimateFormat:=ComboMap.ItemIndex;
end;

procedure TAnimationExportForm.InitComboBoxes;
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
   ComboCompiler.Items.Add('JSON');                 //26 JSONLan
   ComboCompiler.ItemIndex:=0;

   ComboMap.Items.Clear;
   ComboMap.Items.Add('None');
   ComboMap.ItemIndex:=0;

end;

procedure TAnimationExportForm.UpdateComboBoxes(compiler : integer);
begin
  if compiler = NoLan then
  begin
    ComboMap.Items.Clear;
    ComboMap.Items.Add('None');
    ComboMap.ItemIndex:=0;
  end
  else
  begin
    //all compiler targets support None/Simple animation format
    ComboMap.Items.Clear;
    ComboMap.Items.Add('None');
    ComboMap.Items.Add('Simple');
    if (EO.AnimateFormat >= 0) and (EO.AnimateFormat < ComboMap.Items.Count) then
      ComboMap.ItemIndex:=EO.AnimateFormat
    else
      ComboMap.ItemIndex:=0;
  end;
end;


end.

