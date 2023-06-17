unit rmcolorxga;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, ComCtrls,
  StdCtrls, ColorPalette,rmcore;

type

  { TRMXgaColorDialog }

  TRMXgaColorDialog = class(TForm)
    Button1: TButton;
    ColorPalette: TColorPalette;
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
    XGAIndexLabel: TLabel;

     procedure Button1Click(Sender: TObject);
    procedure ColorPaletteColorPick(Sender: TObject; AColor: TColor;
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
  RMXgaColorDialog: TRMXgaColorDialog;

implementation

{$R *.lfm}

procedure TRMXgaColorDialog.PaletteToCore;
var
  i,count : integer;
  tc      : TColor;
  cr      : TRMColorRec;
begin
  count:=ColorPalette.ColorCount;
 // ShowMessage('count='+inttostr(count));
  for i:=0 to count-1 do
  begin
     tc:=ColorPalette.Colors[i];
     cr.r:=Red(tc);
     cr.g:=Green(tc);
     cr.b:=blue(tc);
     RMCoreBase.Palette.SetColor(i,cr);
  end;
end;

procedure TRMXgaColorDialog.CoreToPalette;
begin
end;

procedure TRMXgaColorDialog.UpdateTrackValues;
var
  r,g,b : Byte;
begin
  r:=Red(Shape1.Brush.Color);
  g:=Green(Shape1.Brush.Color);
  b:=Blue(Shape1.Brush.Color);
  //TrackBar1.position:=round((double(r) * 63) / 255);
  TrackBar1.position:=r;
  TrackBar2.position:=g;
  TrackBar3.position:=b;
//  Label4.Caption:=IntToStr(TrackBar1.position)+' '+IntToStr((TrackBar1.position * 255) div 63 );
  Label4.Caption:=IntToStr(TrackBar1.position);
  Label5.Caption:=IntToStr(TrackBar2.position);
  Label6.Caption:=IntToStr(TrackBar3.position);
end;

procedure TRMXgaColorDialog.OKClick(Sender: TObject);
begin
   modalresult:= mrOk;
end;

procedure TRMXgaColorDialog.ColorPaletteColorPick(Sender: TObject; AColor: TColor;
  Shift: TShiftState);
begin
   PickedIndex:=ColorPalette.PickedIndex;
 //  EGAIndexLabel.Caption:='EGA Index: '+IntToStr(PickedIndex);
   PickedColor:=AColor;
   Shape1.Brush.Color:=PickedColor;
   UpdateTrackValues;
end;

procedure TRMXgaColorDialog.Button1Click(Sender: TObject);
begin

end;

procedure TRMXgaColorDialog.InitColorBox16;
var
  cr : TRMColorRec;
 begin
  SelectedColor:=RMCoreBase.GetCurColor;
  PickedIndex:=SelectedColor;
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

procedure TRMXgaColorDialog.InitColorBox256;
var
  cr : TRMColorRec;

begin
  SelectedColor:=RMCoreBase.GetCurColor;
  PickedIndex:=SelectedColor;
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

procedure TRMXgaColorDialog.AddVGA256;
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

procedure TRMXgaColorDialog.AddVGA16;
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
      ColorPalette.AddColor(TC);
  end;
 // ShowMessage('after AddVGA16 Count='+IntToStr(RMCoreBase.Palette.GetColorCount));
end;


procedure TRMXgaColorDialog.UpdateColorChange;
  var
  r,g,b : integer;
begin
  r:=TrackBar1.position;
  g:=TrackBar2.position;
  b:=TrackBar3.position;

  PickedColor:=rgbToColor(r,g,b);
  Shape1.Brush.Color:=PickedColor;
  PickedIndex:=ColorPalette.PickedIndex;
  XgaIndexLabel.Caption:='XGA Index: '+IntToStr(PickedIndex);
  ColorPalette.Colors[PickedIndex]:=PickedColor;
end;

procedure TRMXgaColorDialog.TrackBar1Change(Sender: TObject);
begin
  UpdateColorChange;
  UpdateTrackValues;
end;

procedure TRMXgaColorDialog.TrackBar2Change(Sender: TObject);
begin
  UpdateColorChange;
  UpdateTrackValues;
end;

procedure TRMXgaColorDialog.TrackBar3Change(Sender: TObject);
begin
  UpdateColorChange;
  UpdateTrackValues;
end;

procedure TRMXgaColorDialog.UpDateCorePalette16;
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

procedure TRMXgaColorDialog.UpDateCorePalette256;
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

function TRMXgaColorDialog.GetPickedIndex : integer;
begin
   GetPickedIndex:=PickedIndex;
end;

function   TRMXgaColorDialog.GetPickedColor : TColor;
begin
  GetPickedColor:=PickedColor;
end;

end.

