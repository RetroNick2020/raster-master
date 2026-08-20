unit rmexportprops;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, MaskEdit,
  rmthumb, rmconst,rwxgf,rwjson;

type

  { TImageExportForm }

  TImageExportForm = class(TForm)
    Button1: TButton;
    ChkAllImage: TCheckBox;
    ChkAllMask: TCheckBox;
    ChkAllPalette: TCheckBox;
    ChkAllCompiler: TCheckBox;
    ComboImage: TComboBox;
    ComboCompiler: TComboBox;
    ComboMask: TComboBox;
    ComboPalette: TComboBox;
    EditWidth: TEdit;
    EditHeight: TEdit;
    EditName: TEdit;
    ApplyGroup: TGroupBox;
    imageName: TLabel;
    ImageType: TLabel;
    CompilerType: TLabel;
    MaskType: TLabel;
    PaletteType: TLabel;
    WidthLabel: TLabel;
    HeightLabel: TLabel;
    ToggleBox1: TToggleBox;
    procedure Button1Click(Sender: TObject);
    procedure ComboCompilerChange(Sender: TObject);
    procedure ComboPaletteChange(Sender: TObject);
  private

  public
    EO : ImageExportFormatRec;
    procedure SetExportProps(props : ImageExportFormatRec);
    procedure GetExportProps(var props : ImageExportFormatRec);
    procedure InitComboBoxes;
    procedure UpdateComboBoxes(ChkAllCompiler3 : integer);

    //Which properties the user asked to push out to every image. Name, width
    //and height are deliberately NOT offered - those are per image.
    function ApplyAllCompiler : boolean;
    function ApplyAllImage    : boolean;
    function ApplyAllMask     : boolean;
    function ApplyAllPalette  : boolean;
    function ApplyAnyToAll    : boolean;
  end;

var
  ImageExportForm: TImageExportForm;

implementation

{$R *.lfm}




//=============================================================================
// APPLY TO ALL IMAGES
//
// Each property has its own tick, so a ChkAllCompiler change can be pushed to every
// image without also overwriting each one's image or mask type. The ticks are
// cleared every time the dialog opens - applying to all should always be a
// deliberate act, never something left on from last time.
//=============================================================================


function TImageExportForm.ApplyAllCompiler : boolean;
begin
  ApplyAllCompiler:=(ChkAllCompiler <> nil) and ChkAllCompiler.Checked;
end;

function TImageExportForm.ApplyAllImage : boolean;
begin
  ApplyAllImage:=(ChkAllImage <> nil) and ChkAllImage.Checked;
end;

function TImageExportForm.ApplyAllMask : boolean;
begin
  ApplyAllMask:=(ChkAllMask <> nil) and ChkAllMask.Checked;
end;

function TImageExportForm.ApplyAllPalette : boolean;
begin
  ApplyAllPalette:=(ChkAllPalette <> nil) and ChkAllPalette.Checked;
end;

function TImageExportForm.ApplyAnyToAll : boolean;
begin
  ApplyAnyToAll:=ApplyAllCompiler or ApplyAllImage or
                 ApplyAllMask or ApplyAllPalette;
end;

procedure TImageExportForm.Button1Click(Sender: TObject);
begin
   modalresult:= mrOk;
end;


procedure TImageExportForm.UpdateComboBoxes(ChkAllCompiler3 : integer);
begin
  case ChkAllCompiler3 of NoLan:begin
                             ComboImage.Items.Clear;
                             ComboImage.Items.Add('None');
                             ComboImage.ItemIndex:=0;
                           end;
                     TPLan:begin
                             ComboImage.Items.Clear;
                             ComboMask.Items.Clear;
                             ComboImage.Items.Add('None');
                             ComboImage.Items.Add('putimage');
                             ComboImage.Items.Add('Xlib LBM');
                             ComboImage.Items.Add('Xlib PBM');
                             ComboImage.Items.Add('Mouse Image');
                             ComboMask.Items.Add('None');
                             ComboMask.Items.Add('Inverted');
                             ComboImage.ItemIndex:=EO.Image;
                             ComboMask.ItemIndex:=EO.Mask;
                             ComboPalette.ItemIndex:=EO.Palette;
                           end;
                     TCLan:begin
                             ComboImage.Items.Clear;
                             ComboMask.Items.Clear;
                             ComboImage.Items.Add('None');
                             ComboImage.Items.Add('putimage');
                             ComboImage.Items.Add('Xlib LBM');
                             ComboImage.Items.Add('Xlib PBM');
                             ComboImage.Items.Add('Mouse Image');
                             ComboMask.Items.Add('None');
                             ComboMask.Items.Add('Inverted');
                             ComboImage.ItemIndex:=EO.Image;
                             ComboMask.ItemIndex:=EO.Mask;
                             ComboPalette.ItemIndex:=EO.Palette;
                            end;
                     QCLan:begin
                             ComboImage.Items.Clear;
                             ComboMask.Items.Clear;
                             ComboImage.Items.Add('None');
                             ComboImage.Items.Add('_putimage');
                             ComboImage.Items.Add('Mouse Image');
                             ComboMask.Items.Add('None');
                             ComboMask.Items.Add('Inverted');
                             ComboImage.ItemIndex:=EO.Image;
                             ComboMask.ItemIndex:=EO.Mask;
                             ComboPalette.ItemIndex:=EO.Palette;
                            end;
                     OWLan:begin
                             ComboImage.Items.Clear;
                             ComboMask.Items.Clear;
                             ComboImage.Items.Add('None');
                             ComboImage.Items.Add('_putimage');
                             ComboImage.Items.Add('Mouse Image');
                             ComboMask.Items.Add('None');
                             ComboMask.Items.Add('Inverted');
                             ComboImage.ItemIndex:=EO.Image;
                             ComboMask.ItemIndex:=EO.Mask;
                             ComboPalette.ItemIndex:=EO.Palette;
                           end;
                     QBLan:begin
                             ComboImage.Items.Clear;
                             ComboMask.Items.Clear;
                             ComboImage.Items.Add('None');
                             ComboImage.Items.Add('Put Image');
                             ComboImage.Items.Add('Mouse Image');

                             ComboMask.Items.Add('None');
                             ComboMask.Items.Add('Inverted');

                             ComboImage.ItemIndex:=EO.Image;
                             ComboMask.ItemIndex:=EO.Mask;
                             ComboPalette.ItemIndex:=EO.Palette;
                            end;
                     QB64Lan:begin
                               ComboImage.Items.Clear;
                               ComboMask.Items.Clear;
                               ComboImage.Items.Add('None');
                               ComboImage.Items.Add('RGBA Fuchsia');
                               ComboImage.Items.Add('RGBA Index 0');
                               ComboImage.Items.Add('RGBA Custom');
                               ComboImage.Items.Add('RGB');
                               ComboImage.Items.Add('RayLib RGBA Fuchsia');
                               ComboImage.Items.Add('RayLib RGBA Index 0');
                               ComboImage.Items.Add('RayLib RGBA Custom');
                               ComboImage.Items.Add('RayLib RGB');

                               ComboMask.Items.Add('None');
                               ComboImage.ItemIndex:=EO.Image;
                               ComboMask.ItemIndex:=EO.Mask;
                               ComboPalette.ItemIndex:=EO.Palette;
                             end;
                     PBLan:begin
                             ComboImage.Items.Clear;
                             ComboMask.Items.Clear;
                             ComboImage.Items.Add('None');
                             ComboImage.Items.Add('Put Image');
                             ComboImage.Items.Add('Mouse Image');
                             ComboMask.Items.Add('None');
                             ComboMask.Items.Add('Inverted');
                             ComboImage.ItemIndex:=EO.Image;
                             ComboMask.ItemIndex:=EO.Mask;
                             ComboPalette.ItemIndex:=EO.Palette;
                           end;
                     GWLan:begin
                             ComboImage.Items.Clear;
                             ComboMask.Items.Clear;
                             ComboImage.Items.Add('None');
                             ComboImage.Items.Add('Put Image');
                             ComboImage.Items.Add('Mouse Image');
                             ComboMask.Items.Add('None');
                             ComboMask.Items.Add('Inverted');
                             ComboImage.ItemIndex:=EO.Image;
                             ComboMask.ItemIndex:=EO.Mask;
                             ComboPalette.ItemIndex:=EO.Palette;
                           end;
                     BAMLan:begin
                             ComboImage.Items.Clear;
                             ComboMask.Items.Clear;
                             ComboImage.Items.Add('None');
                             ComboImage.Items.Add('Put Image');
                             ComboImage.Items.Add('Put RGB Image');
                             ComboMask.Items.Add('None');
                             ComboMask.Items.Add('Inverted');
                             ComboImage.ItemIndex:=EO.Image;
                             ComboMask.ItemIndex:=EO.Mask;
                             ComboPalette.ItemIndex:=EO.Palette;
                           end;
                     FPLan:begin
                             ComboImage.Items.Clear;
                             ComboMask.Items.Clear;
                             ComboImage.Items.Add('None');
                             ComboImage.Items.Add('putimage');
                             ComboImage.Items.Add('RayLib RGBA Fuchsia');
                             ComboImage.Items.Add('RayLib RGBA Index 0');
                             ComboImage.Items.Add('RayLib RGBA Custom');
                             ComboImage.Items.Add('RayLib RGB');
                             ComboImage.Items.Add('Mouse Image');

                             ComboMask.Items.Add('None');
                             ComboMask.Items.Add('Inverted');

                             ComboImage.ItemIndex:=EO.Image;
                             ComboMask.ItemIndex:=EO.Mask;
                             ComboPalette.ItemIndex:=EO.Palette;
                           end;
                     FBinQBModeLan:begin
                             ComboImage.Items.Clear;
                             ComboMask.Items.Clear;
                             ComboImage.Items.Add('None');
                             ComboImage.Items.Add('Put Image');
                             ComboImage.Items.Add('Mouse Image');

                             ComboMask.Items.Add('None');
                             ComboMask.Items.Add('Inverted');

                             ComboImage.ItemIndex:=EO.Image;
                             ComboMask.ItemIndex:=EO.Mask;
                             ComboPalette.ItemIndex:=EO.Palette;
                           end;
                     FBLan:begin
                             ComboImage.Items.Clear;
                             ComboMask.Items.Clear;
                             ComboImage.Items.Add('None');
                             ComboImage.Items.Add('RGBA Fuchsia');
                             ComboImage.Items.Add('RGBA Index 0');
                             ComboImage.Items.Add('RGBA Custom');
                             ComboImage.Items.Add('RGB');
                             ComboMask.Items.Add('None');
                             ComboImage.ItemIndex:=EO.Image;
                             ComboMask.ItemIndex:=EO.Mask;
                             ComboPalette.ItemIndex:=EO.Palette;
                           end;
                     ABLan:begin
                             ComboImage.Items.Clear;
                             ComboMask.Items.Clear;
                             ComboImage.Items.Add('None');
                             ComboImage.Items.Add('Put Image');
                             ComboImage.Items.Add('Bob Image');
                             ComboImage.Items.Add('VSprite Image');
                             ComboMask.Items.Add('None');
                             ComboMask.Items.Add('Inverted');
                             ComboImage.ItemIndex:=EO.Image;
                             ComboMask.ItemIndex:=EO.Mask;
                             ComboPalette.ItemIndex:=EO.Palette;
                           end;
                     APLan:begin
                             ComboImage.Items.Clear;
                             ComboMask.Items.Clear;
                             ComboImage.Items.Add('None');
                             ComboImage.Items.Add('Bob Image');
                             ComboImage.Items.Add('VSprite Image');
                             ComboImage.ItemIndex:=EO.Image;
                             ComboPalette.ItemIndex:=EO.Palette;
                           end;
                     ACLan:begin
                             ComboImage.Items.Clear;
                             ComboMask.Items.Clear;
                             ComboImage.Items.Add('None');
                             ComboImage.Items.Add('Bob Image');
                             ComboImage.Items.Add('VSprite Image');
                             ComboImage.ItemIndex:=EO.Image;
                             ComboPalette.ItemIndex:=EO.Palette;
                           end;

                     AQBLan:begin
                             ComboImage.Items.Clear;
                             ComboMask.Items.Clear;
                             ComboImage.Items.Add('None');
                             ComboImage.Items.Add('Put Image');
                             ComboImage.Items.Add('Bob Image');
                             ComboImage.Items.Add('Sprite Image');
                             ComboMask.Items.Add('None');
                             ComboMask.Items.Add('Trans Mask &HE0');
                             ComboMask.ItemIndex:=EO.Mask;
                             ComboImage.ItemIndex:=EO.Image;
                             ComboPalette.ItemIndex:=EO.Palette;
                           end;

                     QPLan:begin
                              ComboImage.Items.Clear;
                              ComboMask.Items.Clear;
                              ComboImage.Items.Add('None');
                              ComboImage.Items.Add('putimage');
                              ComboImage.Items.Add('Mouse Image');
                              ComboMask.Items.Add('None');
                              ComboMask.Items.Add('Inverted');
                              ComboImage.ItemIndex:=EO.Image;
                              ComboMask.ItemIndex:=EO.Mask;
                              ComboPalette.ItemIndex:=EO.Palette;
                            end;
                     gccLan:begin
                               ComboImage.Items.Clear;
                               ComboMask.Items.Clear;
                               ComboImage.Items.Add('None');
                               ComboImage.Items.Add('RayLib RGBA Fuchsia');
                               ComboImage.Items.Add('RayLib RGBA Index 0');
                               ComboImage.Items.Add('RayLib RGBA Custom');
                               ComboImage.Items.Add('RayLib RGB');
                               ComboMask.Items.Add('None');
                               ComboImage.ItemIndex:=EO.Image;
                               ComboMask.ItemIndex:=EO.Mask;
                               ComboPalette.ItemIndex:=EO.Palette;
                             end;
                     TMTLan:begin
                             ComboImage.Items.Clear;
                             ComboMask.Items.Clear;
                             ComboImage.Items.Add('None');
                             ComboImage.Items.Add('putimage');
                             ComboMask.Items.Add('None');
                             ComboMask.Items.Add('Inverted');
                             ComboImage.ItemIndex:=EO.Image;
                             ComboMask.ItemIndex:=EO.Mask;
                             ComboPalette.ItemIndex:=EO.Palette;
                           end;
                   QBJSLan:begin
                             ComboImage.Items.Clear;
                             ComboMask.Items.Clear;
                             ComboImage.Items.Add('None');
                             ComboImage.Items.Add('RGBA Fuchsia');
                             ComboImage.Items.Add('RGBA Index 0');
                             ComboImage.Items.Add('RGBA Custom');
                             ComboImage.Items.Add('RGB');
                             ComboMask.Items.Add('None');
                             ComboImage.ItemIndex:=EO.Image;
                             ComboMask.ItemIndex:=EO.Mask;
                             ComboPalette.ItemIndex:=EO.Palette;
                           end;

                   JSONLan:begin
                             ComboImage.Items.Clear;
                             ComboMask.Items.Clear;
                             ComboImage.Items.Add('None');
                             ComboImage.Items.Add('Indexed Pixels + Palette');
                             ComboImage.Items.Add('RGB Pixels');
                             ComboImage.Items.Add('RGBA Pixels');
                             ComboMask.Items.Add('None');
                             ComboImage.ItemIndex:=EO.Image;
                             ComboMask.ItemIndex:=EO.Mask;
                             ComboPalette.ItemIndex:=EO.Palette;
                   end;
    end;
end;

procedure TImageExportForm.ComboCompilerChange(Sender: TObject);
begin
  UpdateComboBoxes(ComboCompiler.ItemIndex);
end;

procedure TImageExportForm.ComboPaletteChange(Sender: TObject);
begin
  EO.Palette:=ComboPalette.ItemIndex;
end;

procedure TImageExportForm.SetExportProps(props : ImageExportFormatRec);
begin
   EO:=props;
   EditName.caption:=EO.Name;
   ComboCompiler.ItemIndex:=EO.Lan;
   ComboImage.ItemIndex:=EO.Image;
   ComboMask.ItemIndex:=EO.mask;
   ComboPalette.ItemIndex:=EO.Palette;
   EditWidth.Text:=IntToStr(props.Width);
   EditHeight.Text:=IntToStr(props.Height);
   UpdateComboBoxes(ComboCompiler.ItemIndex);
end;

procedure TImageExportForm.GetExportProps(var props : ImageExportFormatRec);
begin
   props.Name:=EditName.caption;
   props.Lan:=ComboCompiler.ItemIndex;
   props.Image:=ComboImage.ItemIndex;
   props.mask:=ComboMask.ItemIndex;
   props.Palette:=ComboPalette.ItemIndex;
   props.Width:=StrToIntDef(EditWidth.Text,0);
   props.Height:=StrToIntDef(EditHeight.Text,0);
end;

procedure TImageExportForm.InitComboBoxes;
begin
   //always start unticked - see the note on BuildApplyToAllControls
   ChkAllCompiler.Checked:=false;
   ChkAllImage.Checked:=false;
   ChkAllMask.Checked:=false;
   ChkAllPalette.Checked:=false;

   EditName.caption:='';
   Combocompiler.Items.Clear;
   ComboCompiler.Items.Add('None');
   ComboCompiler.Items.Add('Turbo Pascal');
   ComboCompiler.Items.Add('Turbo C');
   ComboCompiler.Items.Add('QuickC');
   ComboCompiler.Items.Add('QBasic/QuickBASIC');
   ComboCompiler.Items.Add('QB64');
   ComboCompiler.Items.Add('Power/Turbo Basic');
   ComboCompiler.Items.Add('GWBASIC');
   ComboCompiler.Items.Add('Freepascal');
   ComboCompiler.Items.Add('Freebasic - QB Mode');
   ComboCompiler.Items.Add('Freebasic');
   ComboCompiler.Items.Add('AmigaBASIC');
   ComboCompiler.Items.Add('Amiga Pascal');
   ComboCompiler.Items.Add('Amiga C');
   ComboCompiler.Items.Add('Amiga QuickBasic AQB');
   ComboCompiler.Items.Add('Quick Pascal');
   ComboCompiler.Items.Add('gcc');
   ComboCompiler.Items.Add('Open Watcom C');
   ComboCompiler.Items.Add('BAM Basic');
   ComboCompiler.Items.Add('TMT Pascal');
   ComboCompiler.Items.Add('QBJS');
   ComboCompiler.Items.Add('JSON');            //21 JSONSpriteLan (rwjson)

   ComboCompiler.ItemIndex:=0;
   ComboImage.Items.Clear;
   ComboImage.Items.Add('None');
   ComboImage.ItemIndex:=0;

   ComboMask.Items.Clear;
   ComboMask.Items.Add('None');
   ComboMask.ItemIndex:=0;

   ComboPalette.Items.Clear;
   ComboPalette.Items.Add('None');
   ComboPalette.Items.Add('EGA Palette - Index');
   ComboPalette.Items.Add('Amiga - 4 Bit');
   ComboPalette.Items.Add('PC - 6 Bit');
   ComboPalette.Items.Add('8 Bit');
   ComboPalette.Items.Add('AmigaBASIC/AQB - 4 Bit');
   ComboPalette.Items.Add('PC - 2 Bit');
   ComboPalette.Items.Add('PC - 6 Bit VGA DAC');
   ComboPalette.ItemIndex:=0;
   EditWidth.Text:='0';
   EditHeight.Text:='0';
end;

end.

