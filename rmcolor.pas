unit rmcolor;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  ComCtrls, ColorPalette, RMCore;

type

  { TRMEGAColorDialog }

  TRMEGAColorDialog = class(TForm)
      EGAIndexLabel: TLabel;
      Label1: TLabel;
      Label2: TLabel;
      Label3: TLabel;
      Label4: TLabel;
      Label5: TLabel;
      Label6: TLabel;
    OK: TButton;
    ColorPalette1: TColorPalette;
    Shape1: TShape;
    TrackBar1: TTrackBar;
    TrackBar2: TTrackBar;
    TrackBar3: TTrackBar;


    procedure ColorPalette1ColorPick(Sender: TObject; AColor: TColor;
      Shift: TShiftState);
    procedure OKClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure InitColorBox;

    procedure AddEGA64;
    procedure UpdateColorChange;
    procedure UpdateTrackValues;
   // procedure TRMEGAColorDialog;

    function GetPickedIndex : Integer;
    function GetPickedColor : TColor;
    procedure TrackBar1Change(Sender: TObject);
    procedure TrackBar2Change(Sender: TObject);
    procedure TrackBar3Change(Sender: TObject);
    private
        SelectedColor : integer;
        PickedIndex : integer;
        pickedColor : TColor;

  end;

var
  RMEGAColorDialog: TRMEGAColorDialog;

implementation

{$R *.lfm}






procedure TRMEGAColorDialog.FormCreate(Sender: TObject);

begin

end;

procedure TRMEGAColorDialog.OKClick(Sender: TObject);
begin
   modalresult:= mrOk;
end;

procedure TRMEGAColorDialog.ColorPalette1ColorPick(Sender: TObject; AColor: TColor;
  Shift: TShiftState);
begin
   PickedIndex:=ColorPalette1.PickedIndex;
   EGAIndexLabel.Caption:='EGA Index: '+IntToStr(PickedIndex);
   PickedColor:=AColor;
   Shape1.Brush.Color:=PickedColor;

   UpdateTrackValues;
end;

procedure TRMEGAColorDialog.InitColorBox;
var
  r,g,b : integer;
begin
  PickedIndex:=-1;
  SelectedColor:=RMCoreBase.GetCurColor;
  r:=RMCoreBase.Palette.GetRed(SelectedColor);
  g:=RMCoreBase.Palette.GetGreen(SelectedColor);
  b:=RMCoreBase.Palette.GetBlue(SelectedColor);
  SelectedColor:=RGBToEGAIndex(r,g,b);

  ColorPalette1.ClearColors;
  AddEGA64;

  ColorPalette1.PickedIndex:=SelectedColor;
  PickedColor:=rgbToColor(r,g,b);
  Shape1.Brush.Color:=PickedColor;
  EGAIndexLabel.Caption:='EGA Index: '+IntToStr(RGBToEGAIndex(r,g,b));
  UpdateTrackValues;

end;

procedure TRMEGAColorDialog.AddEGA64;
var
  i : integer;
  tc : TColor;
  cr : TRMColorRec;
begin
  for i:=0 to 63 do
  begin
      GetDefaultRGBEGA64(i,cr);
      TC:=RGBToColor(cr.r,cr.g,cr.b);
      ColorPalette1.AddColor(TC);
  end;
end;

function TRMEGAColorDialog.GetPickedIndex : integer;
begin
   GetPickedIndex:=PickedIndex;
end;

function   TRMEGAColorDialog.GetPickedColor : TColor;
begin
  GetPickedColor:=PickedColor;
end;

procedure TRMEGAColorDialog.UpdateColorChange;
var
  r,g,b : integer;
begin
  r:=TwoToEightBit(TrackBar1.position);
  g:=TwoToEightBit(TrackBar2.position);
  b:=TwoToEightBit(TrackBar3.position);

  PickedColor:=rgbToColor(r,g,b);
  Shape1.Brush.Color:=PickedColor;
  PickedIndex:=RGBToEGAIndex(r,g,b);
//  VgaIndexLabel.Caption:='VGA Index: '+IntToStr(PickedIndex);
  EGAIndexLabel.Caption:='EGA Index: '+IntToStr(PickedIndex);
  ColorPalette1.PickedIndex:=PickedIndex;
//  ColorPalette.Colors[PickedIndex]:=PickedColor;
end;

procedure TRMEGAColorDialog.UpdateTrackValues;
var
  r,g,b : Byte;
begin

  r:=Red(Shape1.Brush.Color);
  g:=Green(Shape1.Brush.Color);
  b:=Blue(Shape1.Brush.Color);
  //TrackBar1.position:=round((double(r) * 63) / 255);
  TrackBar1.position:=EightToTwoBit(r);
  TrackBar2.position:=EightToTwoBit(g);
  TrackBar3.position:=EightToTwoBit(b);
//  Label4.Caption:=IntToStr(TrackBar1.position)+' '+IntToStr((TrackBar1.position * 255) div 63 );
  Label4.Caption:='['+IntToStr(TrackBar1.position)+'] '+IntToStr(TwoToEightBit(TrackBar1.Position));
  Label5.Caption:='['+IntToStr(TrackBar2.position)+'] '+IntToStr(TwoToEightBit(TrackBar2.Position));
  Label6.Caption:='['+IntToStr(TrackBar3.position)+'] '+IntToStr(TwoToEightBit(TrackBar3.Position));


end;

procedure TRMEGAColorDialog.TrackBar1Change(Sender: TObject);
begin
  UpdateColorChange;
  UpdateTrackValues;
end;

procedure TRMEGAColorDialog.TrackBar2Change(Sender: TObject);
begin
  UpdateColorChange;
  UpdateTrackValues;
end;

procedure TRMEGAColorDialog.TrackBar3Change(Sender: TObject);
begin
  UpdateColorChange;
  UpdateTrackValues;
end;



end.

