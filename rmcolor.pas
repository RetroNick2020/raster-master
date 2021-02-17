unit RMColor;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  ColorPalette, RMCore;

type

  { TRMEGAColorDialog }

  TRMEGAColorDialog = class(TForm)
      EGAIndexLabel: TLabel;
    OK: TButton;
    ColorPalette1: TColorPalette;
    Shape1: TShape;


    procedure ColorPalette1ColorPick(Sender: TObject; AColor: TColor;
      Shift: TShiftState);
    procedure OKClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure InitColorBox;

    procedure AddEGA64;
    function GetPickedIndex : Integer;
    function GetPickedColor : TColor;
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
end;

procedure TRMEGAColorDialog.InitColorBox;
var
  cr : TRMColorRec;
  r,g,b : integer;
begin
   PickedIndex:=-1;
  SelectedColor:=RMCoreBase.GetCurColor;


  // SelectedColor:=2;
  ColorPalette1.ClearColors;
//  ColorPalette1.PickedIndex:=SelectedColor;
 // ColorPalette1.Refresh;
  AddEGA64;
  ColorPalette1.PickedIndex:=SelectedColor;
//  RMCoreBase.Palette.GetColor(2,cr);
  r:=RMCoreBase.Palette.GetRed(SelectedColor);
  g:=RMCoreBase.Palette.GetGreen(SelectedColor);
  b:=RMCoreBase.Palette.GetBlue(SelectedColor);
  PickedColor:=rgbToColor(r,g,b);
  Shape1.Brush.Color:=PickedColor;
  EGAIndexLabel.Caption:='EGA Index: '+IntToStr(RGBToEGAIndex(r,g,b));

end;

procedure TRMEGAColorDialog.AddEGA64;
var
  i : integer;
  tc : TColor;
  cr : TRMColorRec;
begin
  for i:=0 to 63 do
  begin
      GetRGBEGA64(i,cr);
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



end.

