unit RMColorVga;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, ComCtrls,
  StdCtrls, ColorPalette,RMCore;

type

  { TRMVgaColorDialog }

  TRMVgaColorDialog = class(TForm)
    Button1: TButton;
    ColorPalette1: TColorPalette;
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

    procedure Button1Click(Sender: TObject);
    procedure ColorPalette1ColorPick(Sender: TObject; AColor: TColor;
      Shift: TShiftState);
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
    function GetPickedColor : TColor;
    procedure PaletteToCore;
    procedure CoreToPalette;

    private
        SelectedColor : integer;
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
  count:=ColorPalette1.ColorCount;
 // ShowMessage('count='+inttostr(count));
  for i:=0 to count-1 do
  begin
     tc:=ColorPalette1.Colors[i];
     cr.r:=Red(tc);
     cr.g:=Green(tc);
     cr.b:=blue(tc);
     RMCoreBase.Palette.SetColor(i,cr);
  end;
end;

procedure TRMVgaColorDialog.CoreToPalette;
begin
end;

procedure TRMVgaColorDialog.UpdateTrackValues;
var
  r,g,b : Byte;
begin
  r:=Red(Shape1.Brush.Color);
  g:=Green(Shape1.Brush.Color);
  b:=Blue(Shape1.Brush.Color);
  //TrackBar1.position:=round((double(r) * 63) / 255);
  TrackBar1.position:=ToSixBit(r);
  TrackBar2.position:=ToSixBit(g);
  TrackBar3.position:=ToSixBit(b);
//  Label4.Caption:=IntToStr(TrackBar1.position)+' '+IntToStr((TrackBar1.position * 255) div 63 );
  Label4.Caption:='['+IntToStr(TrackBar1.position)+'] '+IntToStr(ToEightBit(TrackBar1.Position));
  Label5.Caption:='['+IntToStr(TrackBar2.position)+'] '+IntToStr(ToEightBit(TrackBar2.Position));
  Label6.Caption:='['+IntToStr(TrackBar3.position)+'] '+IntToStr(ToEightBit(TrackBar3.Position));
end;

procedure TRMVgaColorDialog.OKClick(Sender: TObject);
begin
   modalresult:= mrOk;
end;

procedure TRMVgaColorDialog.ColorPalette1ColorPick(Sender: TObject; AColor: TColor;
  Shift: TShiftState);
begin
   PickedIndex:=ColorPalette1.PickedIndex;
 //  EGAIndexLabel.Caption:='EGA Index: '+IntToStr(PickedIndex);
   PickedColor:=AColor;
   Shape1.Brush.Color:=PickedColor;
   UpdateTrackValues;
end;

procedure TRMVgaColorDialog.Button1Click(Sender: TObject);
begin

end;

procedure TRMVgaColorDialog.InitColorBox16;
var
  cr : TRMColorRec;
 begin
  SelectedColor:=RMCoreBase.GetCurColor;
  PickedIndex:=SelectedColor;
  ColorPalette1.ColumnCount:=8;
  ColorPalette1.ButtonHeight:=60;
  ColorPalette1.ButtonWidth:=60;

  ColorPalette1.ClearColors;

  AddVGA16;
  ColorPalette1.PickedIndex:=PickedIndex;

  PickedColor:=ColorPalette1.Colors[PickedIndex];
  Shape1.Brush.Color:=PickedColor;
  UpdateTrackValues;
  UpDateColorChange;
end;

procedure TRMVgaColorDialog.InitColorBox256;
var
  cr : TRMColorRec;

begin
  SelectedColor:=RMCoreBase.GetCurColor;
  PickedIndex:=SelectedColor;
  ColorPalette1.ColumnCount:=32;
  ColorPalette1.ButtonHeight:=15;
  ColorPalette1.ButtonWidth:=15;

  ColorPalette1.ClearColors;
  AddVGA256;

  ColorPalette1.PickedIndex:=PickedIndex;
  PickedColor:=ColorPalette1.Colors[PickedIndex];
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
      ColorPalette1.AddColor(TC);
  end;
end;

procedure TRMVgaColorDialog.AddVGA16;
var
  i : integer;
  tc : TColor;
  cr : TRMColorRec;
begin
 // ShowMessage('Bebore AddVGA16 Count='+IntToStr(RMCoreBase.Palette.GetColorCount));
  for i:=0 to 15 do
  begin
      RMCoreBase.Palette.GetColor(i,cr);
      TC:=RGBToColor(cr.r,cr.g,cr.b);
      ColorPalette1.AddColor(TC);
  end;
 // ShowMessage('after AddVGA16 Count='+IntToStr(RMCoreBase.Palette.GetColorCount));
end;


procedure TRMVgaColorDialog.UpdateColorChange;
  var
  r,g,b : integer;
begin
  r:=ToEightBit(TrackBar1.position);
  g:=ToEightBit(TrackBar2.position);
  b:=ToEightBit(TrackBar3.position);

  PickedColor:=rgbToColor(r,g,b);
  Shape1.Brush.Color:=PickedColor;
  PickedIndex:=ColorPalette1.PickedIndex;
  ColorPalette1.Colors[PickedIndex]:=PickedColor;
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
  for i:=0 to 16 do
  begin
      tc:=ColorPalette1.Colors[i];
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
  for i:=0 to 16 do
  begin
      tc:=ColorPalette1.Colors[i];
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

function   TRMVgaColorDialog.GetPickedColor : TColor;
begin
  GetPickedColor:=PickedColor;
end;


end.

