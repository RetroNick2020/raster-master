unit rmexportprops;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,rmthumb,rwxgf2;

type

  { TImageExportForm }

  TImageExportForm = class(TForm)
    Button1: TButton;
    ComboImage: TComboBox;
    ComboCompiler: TComboBox;
    ComboMask: TComboBox;
    ComboPalette: TComboBox;
    EditName: TEdit;
    imageName: TLabel;
    ImageType: TLabel;
    CompilerType: TLabel;
    MaskType: TLabel;
    PaletteType: TLabel;
    ToggleBox1: TToggleBox;
    procedure Button1Click(Sender: TObject);
    procedure ComboCompilerChange(Sender: TObject);
  private

  public
    EO : ImageExportFormatRec;
    procedure SetExportProps(props : ImageExportFormatRec);
    procedure GetExportProps(var props : ImageExportFormatRec);
    procedure InitComboBoxes;
    procedure UpdateComboBoxes(compiler : integer);
  end;

var
  ImageExportForm: TImageExportForm;

implementation

{$R *.lfm}

procedure TImageExportForm.Button1Click(Sender: TObject);
begin
   modalresult:= mrOk;
end;


procedure TImageExportForm.UpdateComboBoxes(compiler : integer);
begin
  case compiler of NoLan:begin
                           ComboImage.Items.Clear;
                           ComboPalette.Items.Clear;
                           ComboImage.Items.Add('None');
                           ComboPalette.Items.Add('None');
                           ComboImage.ItemIndex:=0;
                           ComboPalette.ItemIndex:=0;
                         end;
                   TPLan:begin
                           ComboImage.Items.Clear;
                           ComboPalette.Items.Clear;
                           ComboImage.Items.Add('None');
                           ComboImage.Items.Add('putimage');
                           ComboPalette.Items.Add('None');
                          // ComboPalette.Items.Add('RGB Palette');
                           ComboImage.ItemIndex:=EO.Image;
                           ComboPalette.ItemIndex:=EO.Palette;
                         end;
                   TCLan:begin
                           ComboImage.Items.Clear;
                           ComboPalette.Items.Clear;
                           ComboImage.Items.Add('None');
                           ComboImage.Items.Add('putimage');
                           ComboPalette.Items.Add('None');
                          // ComboPalette.Items.Add('RGB Palette');
                           ComboImage.ItemIndex:=EO.Image;
                           ComboPalette.ItemIndex:=EO.Palette;
                          end;
                   QCLan:begin
                           ComboImage.Items.Clear;
                           ComboPalette.Items.Clear;
                           ComboImage.Items.Add('None');
                           ComboImage.Items.Add('_putimage');
                           ComboPalette.Items.Add('None');
                          // ComboPalette.Items.Add('RGB Palette');
                           ComboImage.ItemIndex:=EO.Image;
                           ComboPalette.ItemIndex:=EO.Palette;
                          end;
                   QBLan:begin
                           ComboImage.Items.Clear;
                           ComboPalette.Items.Clear;
                           ComboImage.Items.Add('None');
                           ComboImage.Items.Add('Put Image');
                           ComboPalette.Items.Add('None');
                          // ComboPalette.Items.Add('RGB Palette');
                           ComboImage.ItemIndex:=EO.Image;
                           ComboPalette.ItemIndex:=EO.Palette;
                          end;

                   PBLan:begin
                           ComboImage.Items.Clear;
                           ComboPalette.Items.Clear;
                           ComboImage.Items.Add('None');
                           ComboImage.Items.Add('Put Image');
                           ComboPalette.Items.Add('None');
                          // ComboPalette.Items.Add('RGB Palette');
                           ComboImage.ItemIndex:=EO.Image;
                           ComboPalette.ItemIndex:=EO.Palette;
                         end;
                   GWLan:begin
                           ComboImage.Items.Clear;
                           ComboPalette.Items.Clear;
                           ComboImage.Items.Add('None');
                           ComboImage.Items.Add('Put Image');
                           ComboPalette.Items.Add('None');
                          // ComboPalette.Items.Add('RGB Palette');
                           ComboImage.ItemIndex:=EO.Image;
                           ComboPalette.ItemIndex:=EO.Palette;
                         end;
                   FPLan:begin
                           ComboImage.Items.Clear;
                           ComboPalette.Items.Clear;
                           ComboImage.Items.Add('None');
                           ComboImage.Items.Add('putimage');
                           ComboPalette.Items.Add('None');
                          // ComboPalette.Items.Add('RGB Palette');
                           ComboImage.ItemIndex:=EO.Image;
                           ComboPalette.ItemIndex:=EO.Palette;
                         end;
                   FBLan:begin
                           ComboImage.Items.Clear;
                           ComboPalette.Items.Clear;
                           ComboImage.Items.Add('None');
                           ComboImage.Items.Add('Put Image');
                           ComboPalette.Items.Add('None');
                          // ComboPalette.Items.Add('RGB Palette');
                           ComboImage.ItemIndex:=EO.Image;
                           ComboPalette.ItemIndex:=EO.Palette;
                         end;
                   ABLan:begin
                           ComboImage.Items.Clear;
                           ComboPalette.Items.Clear;
                           ComboImage.Items.Add('None');
                           ComboImage.Items.Add('Put Image');
                           ComboImage.Items.Add('Bob Image');
                           ComboImage.Items.Add('VSprite Image');
                           ComboPalette.Items.Add('None');
                          // ComboPalette.Items.Add('RGB Palette');
                           ComboImage.ItemIndex:=EO.Image;
                           ComboPalette.ItemIndex:=EO.Palette;
                         end;

                   APLan:begin
                           ComboImage.Items.Clear;
                           ComboPalette.Items.Clear;
                           ComboImage.Items.Add('None');
                           ComboImage.Items.Add('Bob Image');
                           ComboImage.Items.Add('VSprite Image');
                           ComboPalette.Items.Add('None');
                          // ComboPalette.Items.Add('RGB Palette');
                           ComboImage.ItemIndex:=EO.Image;
                           ComboPalette.ItemIndex:=EO.Palette;
                         end;
                   ACLan:begin
                           ComboImage.Items.Clear;
                           ComboPalette.Items.Clear;
                           ComboImage.Items.Add('None');
                           ComboImage.Items.Add('Bob Image');
                           ComboImage.Items.Add('VSprite Image');
                           ComboPalette.Items.Add('None');
                          // ComboPalette.Items.Add('RGB Palette');
                           ComboImage.ItemIndex:=EO.Image;
                           ComboPalette.ItemIndex:=EO.Palette;
                         end;
                   QPLan:begin
                            ComboImage.Items.Clear;
                            ComboPalette.Items.Clear;
                            ComboImage.Items.Add('None');
                            ComboImage.Items.Add('putimage');
                            ComboPalette.Items.Add('None');
                           // ComboPalette.Items.Add('RGB Palette');
                            ComboImage.ItemIndex:=EO.Image;
                            ComboPalette.ItemIndex:=EO.Palette;
                          end;



  end;
end;

procedure TImageExportForm.ComboCompilerChange(Sender: TObject);
begin
  UpdateComboBoxes(ComboCompiler.ItemIndex);
end;

procedure TImageExportForm.SetExportProps(props : ImageExportFormatRec);
begin
   EO:=props;
   EditName.caption:=EO.Name;
   ComboCompiler.ItemIndex:=EO.Lan;
   ComboImage.ItemIndex:=EO.Image;
   ComboMask.ItemIndex:=EO.mask;
   ComboPalette.ItemIndex:=EO.Palette;
   UpdateComboBoxes(ComboCompiler.ItemIndex);
end;

procedure TImageExportForm.GetExportProps(var props : ImageExportFormatRec);
begin
   props.Name:=EditName.caption;
   props.Lan:=ComboCompiler.ItemIndex;
   props.Image:=ComboImage.ItemIndex;
   props.mask:=ComboMask.ItemIndex;
   props.Palette:=ComboPalette.ItemIndex;
end;

procedure TImageExportForm.InitComboBoxes;
begin
   EditName.caption:='';
   Combocompiler.Items.Clear;
   ComboCompiler.Items.Add('None');
   ComboCompiler.Items.Add('Turbo Pascal');
   ComboCompiler.Items.Add('Turbo C');
   ComboCompiler.Items.Add('QuickC');
   ComboCompiler.Items.Add('QuickBASIC');
   ComboCompiler.Items.Add('Power/Turbo Basic');
   ComboCompiler.Items.Add('GWBASIC');
   ComboCompiler.Items.Add('Freepascal');
   ComboCompiler.Items.Add('Freebasic');
   ComboCompiler.Items.Add('AmigaBASIC');
   ComboCompiler.Items.Add('Amiga Pascal');
   ComboCompiler.Items.Add('Amiga C');
   ComboCompiler.Items.Add('Quick Pascal');

   ComboCompiler.ItemIndex:=0;

   ComboImage.Items.Clear;
   ComboImage.Items.Add('None');
   ComboImage.ItemIndex:=0;

   ComboMask.Items.Clear;
   ComboMask.Items.Add('None');
   ComboMask.ItemIndex:=0;

   ComboPalette.Items.Clear;
   ComboPalette.Items.Add('None');
   ComboPalette.ItemIndex:=0;
end;

end.

