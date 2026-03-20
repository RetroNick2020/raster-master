unit rmcolorvga;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, ComCtrls,
  StdCtrls, ColorPalette,rmcore;

type

  { TRMVgaColorDialog }

  TRMVgaColorDialog = class(TForm)
    Button1: TButton;
    ColorPalette: TColorPalette;
    VGAIndexLabel: TLabel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Shape1: TShape;
    TrackBar1: TTrackBar;
    TrackBar2: TTrackBar;
    TrackBar3: TTrackBar;


    procedure ColorPaletteColorPick(Sender: TObject; AColor: TColor;
      Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure OKClick(Sender: TObject);

    procedure InitColorBox16;
    procedure InitColorBox256;
    procedure AddVGA256;
    procedure AddVGA16;
    procedure TrackBar1Change(Sender: TObject);
    procedure TrackBar2Change(Sender: TObject);
    procedure TrackBar3Change(Sender: TObject);
    procedure UpDateCorePalette16;
    procedure UpDateCorePalette256;
    procedure UpdateTrackValues;
    procedure UpDateColorChange;
    function GetPickedIndex : Integer;
    procedure SetPickedIndex(Index : integer);

    function GetPickedColor : TColor;
    procedure PaletteToCore;

    private
        PickedIndex : integer;
        pickedColor : TColor;

  public

  end;

var
  RMVgaColorDialog: TRMVgaColorDialog;

implementation

{$R *.lfm}

procedure TRMVgaColorDialog.PaletteToCore;
var
  i,count : integer;
  tc      : TColor;
  cr      : TRMColorRec;
begin
  count:=ColorPalette.ColorCount;
  for i:=0 to count-1 do
  begin
     tc:=ColorPalette.Colors[i];
     cr.r:=Red(tc);
     cr.g:=Green(tc);
     cr.b:=blue(tc);
     RMCoreBase.Palette.SetColor(i,cr);
  end;
end;

procedure TRMVgaColorDialog.UpdateTrackValues;
var
  r,g,b : Byte;
begin
  r:=Red(Shape1.Brush.Color);
  g:=Green(Shape1.Brush.Color);
  b:=Blue(Shape1.Brush.Color);

  TrackBar1.position:=EightToSixBit(r);
  TrackBar2.position:=EightToSixBit(g);
  TrackBar3.position:=EightToSixBit(b);

  Label4.Caption:='['+IntToStr(TrackBar1.position)+'] '+IntToStr(SixToEightBit(TrackBar1.Position));
  Label5.Caption:='['+IntToStr(TrackBar2.position)+'] '+IntToStr(SixToEightBit(TrackBar2.Position));
  Label6.Caption:='['+IntToStr(TrackBar3.position)+'] '+IntToStr(SixToEightBit(TrackBar3.Position));
end;

procedure TRMVgaColorDialog.OKClick(Sender: TObject);
begin
   modalresult:= mrOk;
end;

procedure TRMVgaColorDialog.ColorPaletteColorPick(Sender: TObject; AColor: TColor;
  Shift: TShiftState);
begin
   PickedIndex:=ColorPalette.PickedIndex;
   PickedColor:=AColor;
   Shape1.Brush.Color:=PickedColor;
   UpdateTrackValues;
end;

procedure TRMVgaColorDialog.FormCreate(Sender: TObject);
begin
  PickedIndex:=1;
end;

procedure TRMVgaColorDialog.InitColorBox16;
 begin
  ColorPalette.ColumnCount:=8;
  ColorPalette.ButtonHeight:=60;
  ColorPalette.ButtonWidth:=60;

  ColorPalette.ClearColors;

  AddVGA16;
  ColorPalette.PickedIndex:=PickedIndex;

  PickedColor:=ColorPalette.Colors[PickedIndex];
  Shape1.Brush.Color:=PickedColor;
  UpdateTrackValues;
  UpDateColorChange;
end;

procedure TRMVgaColorDialog.InitColorBox256;
begin
  ColorPalette.ColumnCount:=32;
  ColorPalette.ButtonHeight:=15;
  ColorPalette.ButtonWidth:=15;

  ColorPalette.ClearColors;
  AddVGA256;

  ColorPalette.PickedIndex:=PickedIndex;
  PickedColor:=ColorPalette.Colors[PickedIndex];
  Shape1.Brush.Color:=PickedColor;
  UpdateTrackValues;
  UpDateColorChange;
end;

procedure TRMVgaColorDialog.AddVGA256;
var
  i : integer;
  tc : TColor;
  cr : TRMColorRec;
begin
  for i:=0 to 255 do
  begin
      RMCoreBase.Palette.GetColor(i,cr);
      TC:=RGBToColor(cr.r,cr.g,cr.b);
      ColorPalette.AddColor(TC);
  end;
end;

procedure TRMVgaColorDialog.AddVGA16;
var
  i : integer;
  tc : TColor;
  cr : TRMColorRec;
begin
  for i:=0 to 15 do
  begin
      RMCoreBase.Palette.GetColor(i,cr);
      TC:=RGBToColor(cr.r,cr.g,cr.b);
      ColorPalette.AddColor(TC);
  end;
end;

procedure TRMVgaColorDialog.UpdateColorChange;
  var
  r,g,b : integer;
begin
  r:=SixToEightBit(TrackBar1.position);
  g:=SixToEightBit(TrackBar2.position);
  b:=SixToEightBit(TrackBar3.position);

  PickedColor:=rgbToColor(r,g,b);
  Shape1.Brush.Color:=PickedColor;
  PickedIndex:=ColorPalette.PickedIndex;
  VgaIndexLabel.Caption:='VGA Index: '+IntToStr(PickedIndex);
  ColorPalette.Colors[PickedIndex]:=PickedColor;
end;

procedure TRMVgaColorDialog.TrackBar1Change(Sender: TObject);
begin
  UpdateColorChange;
  UpdateTrackValues;
end;

procedure TRMVgaColorDialog.TrackBar2Change(Sender: TObject);
begin
  UpdateColorChange;
  UpdateTrackValues;
end;

procedure TRMVgaColorDialog.TrackBar3Change(Sender: TObject);
begin
  UpdateColorChange;
  UpdateTrackValues;
end;

procedure TRMVgaColorDialog.UpDateCorePalette16;
var
  i : integer;
  tc : TColor;
  cr : TRMColorRec;
  r,g,b : byte;
begin
  for i:=0 to 15 do
  begin
      tc:=ColorPalette.Colors[i];
      RedGreenBlue(tc,r,g,b);
      cr.r:=r;
      cr.g:=g;
      cr.b:=b;;
      RMCoreBase.Palette.SetColor(i,cr);
  end;
end;

procedure TRMVgaColorDialog.UpDateCorePalette256;
var
  i : integer;
  tc : TColor;
  cr : TRMColorRec;
  r,g,b : byte;
begin
  for i:=0 to 255 do
  begin
      tc:=ColorPalette.Colors[i];
      RedGreenBlue(tc,r,g,b);
      cr.r:=r;
      cr.g:=g;
      cr.b:=b;;
      RMCoreBase.Palette.SetColor(i,cr);
  end;
end;

function TRMVgaColorDialog.GetPickedIndex : integer;
begin
   GetPickedIndex:=PickedIndex;
end;

procedure TRMVgaColorDialog.SetPickedIndex(Index : integer);
begin
   PickedIndex:=Index;
end;

function   TRMVgaColorDialog.GetPickedColor : TColor;
begin
  GetPickedColor:=PickedColor;
end;


end.

