unit rmamigacolor;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, ComCtrls,
  StdCtrls, colorpalette,rmcore;

type

  { TRMAmigaColorDialog }

  TRMAmigaColorDialog = class(TForm)
    Button1: TButton;
    AmigaColorPalette: TColorPalette;
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
    ColorIndexLabel: TLabel;

    procedure AmigaColorPaletteClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure ColorPaletteColorPick(Sender: TObject; AColor: TColor;
      Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure OKClick(Sender: TObject);

    procedure InitColorBox2;
    procedure InitColorBox4;
    procedure InitColorBox8;
    procedure InitColorBox16;
    procedure InitColorBox32;
    procedure Add32;
    procedure Add16;
    procedure Add8;
    procedure Add4;
    procedure Add2;
    procedure TrackBar1Change(Sender: TObject);
    procedure TrackBar2Change(Sender: TObject);
    procedure TrackBar3Change(Sender: TObject);

    procedure UpDateCorePalette2;
    procedure UpDateCorePalette4;
    procedure UpDateCorePalette8;
    procedure UpDateCorePalette16;
    procedure UpDateCorePalette32;

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
  RMAmigaColorDialog: TRMAmigaColorDialog;

implementation

{$R *.lfm}

{ TRMAmigaColorDialog }



procedure TRMAmigaColorDialog.PaletteToCore;
var
  i,count : integer;
  tc      : TColor;
  cr      : TRMColorRec;
begin
  count:=AmigaColorPalette.ColorCount;
 // ShowMessage('count='+inttostr(count));
  for i:=0 to count-1 do
  begin
     tc:=AmigaColorPalette.Colors[i];
     cr.r:=Red(tc);
     cr.g:=Green(tc);
     cr.b:=blue(tc);
     RMCoreBase.Palette.SetColor(i,cr);
  end;
end;

procedure TRMAmigaColorDialog.CoreToPalette;
begin
end;

procedure TRMAmigaColorDialog.UpdateTrackValues;
var
  r,g,b : Byte;
begin
  r:=Red(Shape1.Brush.Color);
  g:=Green(Shape1.Brush.Color);
  b:=Blue(Shape1.Brush.Color);

  TrackBar1.position:=EightToFourBit(r);
  TrackBar2.position:=EightToFourBit(g);
  TrackBar3.position:=EightToFourBit(b);

  Label4.Caption:='['+FormatFloat('0.00',TrackBar1.position*0.0669)+']['+IntToStr(TrackBar1.position)+'] '+IntToStr(FourToEightBit(TrackBar1.Position));
  Label5.Caption:='['+FormatFloat('0.00',TrackBar2.position*0.0669)+']['+IntToStr(TrackBar2.position)+'] '+IntToStr(FourToEightBit(TrackBar2.Position));
  Label6.Caption:='['+FormatFloat('0.00',TrackBar3.position*0.0669)+']['+IntToStr(TrackBar3.position)+'] '+IntToStr(FourToEightBit(TrackBar3.Position));
end;

procedure TRMAmigaColorDialog.OKClick(Sender: TObject);
begin
   modalresult:= mrOk;
end;

procedure TRMAmigaColorDialog.ColorPaletteColorPick(Sender: TObject; AColor: TColor;
  Shift: TShiftState);
begin
   PickedIndex:=AmigaColorPalette.PickedIndex;
 //  EGAIndexLabel.Caption:='EGA Index: '+IntToStr(PickedIndex);
   PickedColor:=AColor;
   Shape1.Brush.Color:=PickedColor;
   UpdateTrackValues;
end;

procedure TRMAmigaColorDialog.FormCreate(Sender: TObject);
begin

end;

procedure TRMAmigaColorDialog.Button1Click(Sender: TObject);
begin

end;

procedure TRMAmigaColorDialog.AmigaColorPaletteClick(Sender: TObject);
begin

end;



procedure TRMAmigaColorDialog.InitColorBox2;
var
  cr : TRMColorRec;
 begin
  SelectedColor:=RMCoreBase.GetCurColor;
  PickedIndex:=SelectedColor;
  AmigaColorPalette.ColumnCount:=1;
  AmigaColorPalette.ButtonHeight:=60;
  AmigaColorPalette.ButtonWidth:=480;
  AmigaColorPalette.ClearColors;
  Add2;
  AmigaColorPalette.PickedIndex:=PickedIndex;
  PickedColor:=AmigaColorPalette.Colors[PickedIndex];
  Shape1.Brush.Color:=PickedColor;
  UpdateTrackValues;
  UpDateColorChange;
end;

procedure TRMAmigaColorDialog.InitColorBox4;
var
  cr : TRMColorRec;
 begin
  SelectedColor:=RMCoreBase.GetCurColor;
  PickedIndex:=SelectedColor;
  AmigaColorPalette.ColumnCount:=2;
  AmigaColorPalette.ButtonHeight:=60;
  AmigaColorPalette.ButtonWidth:=240;
  AmigaColorPalette.ClearColors;
  Add4;
  AmigaColorPalette.PickedIndex:=PickedIndex;
  PickedColor:=AmigaColorPalette.Colors[PickedIndex];
  Shape1.Brush.Color:=PickedColor;
  UpdateTrackValues;
  UpDateColorChange;
end;


procedure TRMAmigaColorDialog.InitColorBox8;
var
  cr : TRMColorRec;
 begin
  SelectedColor:=RMCoreBase.GetCurColor;
  PickedIndex:=SelectedColor;
  AmigaColorPalette.ColumnCount:=4;
  AmigaColorPalette.ButtonHeight:=60;
  AmigaColorPalette.ButtonWidth:=120;
  AmigaColorPalette.ClearColors;
  Add8;
  AmigaColorPalette.PickedIndex:=PickedIndex;
  PickedColor:=AmigaColorPalette.Colors[PickedIndex];
  Shape1.Brush.Color:=PickedColor;
  UpdateTrackValues;
  UpDateColorChange;
end;

procedure TRMAmigaColorDialog.InitColorBox16;
var
  cr : TRMColorRec;
 begin
  SelectedColor:=RMCoreBase.GetCurColor;
  PickedIndex:=SelectedColor;
  AmigaColorPalette.ColumnCount:=8;
  AmigaColorPalette.ButtonHeight:=60;
  AmigaColorPalette.ButtonWidth:=60;
  AmigaColorPalette.ClearColors;
  Add16;
  AmigaColorPalette.PickedIndex:=PickedIndex;
  PickedColor:=AmigaColorPalette.Colors[PickedIndex];
  Shape1.Brush.Color:=PickedColor;
  UpdateTrackValues;
  UpDateColorChange;
end;

procedure TRMAmigaColorDialog.InitColorBox32;
var
  cr : TRMColorRec;
begin
  SelectedColor:=RMCoreBase.GetCurColor;
  PickedIndex:=SelectedColor;
  AmigaColorPalette.ColumnCount:=16;
  AmigaColorPalette.ButtonHeight:=60;
  AmigaColorPalette.ButtonWidth:=30;
  AmigaColorPalette.ClearColors;
  Add32;
  AmigaColorPalette.PickedIndex:=PickedIndex;
  PickedColor:=AmigaColorPalette.Colors[PickedIndex];
  Shape1.Brush.Color:=PickedColor;
  UpdateTrackValues;
  UpDateColorChange;
end;

procedure TRMAmigaColorDialog.Add32;
var
  i : integer;
  tc : TColor;
  cr : TRMColorRec;
begin
  for i:=0 to 31 do
  begin
      RMCoreBase.Palette.GetColor(i,cr);
      TC:=RGBToColor(cr.r,cr.g,cr.b);
      AmigaColorPalette.AddColor(TC);
  end;
end;

procedure TRMAmigaColorDialog.Add16;
var
  i : integer;
  tc : TColor;
  cr : TRMColorRec;
begin
  for i:=0 to 15 do
  begin
      RMCoreBase.Palette.GetColor(i,cr);
      TC:=RGBToColor(cr.r,cr.g,cr.b);
      AmigaColorPalette.AddColor(TC);
  end;
end;

procedure TRMAmigaColorDialog.Add8;
var
  i : integer;
  tc : TColor;
  cr : TRMColorRec;
begin
  for i:=0 to 7 do
  begin
      RMCoreBase.Palette.GetColor(i,cr);
      TC:=RGBToColor(cr.r,cr.g,cr.b);
      AmigaColorPalette.AddColor(TC);
  end;
end;


procedure TRMAmigaColorDialog.Add4;
var
  i : integer;
  tc : TColor;
  cr : TRMColorRec;
begin
  for i:=0 to 3 do
  begin
      RMCoreBase.Palette.GetColor(i,cr);
      TC:=RGBToColor(cr.r,cr.g,cr.b);
      AmigaColorPalette.AddColor(TC);
  end;
end;

procedure TRMAmigaColorDialog.Add2;
var
  i : integer;
  tc : TColor;
  cr : TRMColorRec;
begin
  for i:=0 to 1 do
  begin
      RMCoreBase.Palette.GetColor(i,cr);
      TC:=RGBToColor(cr.r,cr.g,cr.b);
      AmigaColorPalette.AddColor(TC);
  end;
end;



procedure TRMAmigaColorDialog.UpdateColorChange;
  var
  r,g,b : integer;
begin
  r:=FourToEightBit(TrackBar1.position);
  g:=FourToEightBit(TrackBar2.position);
  b:=FourToEightBit(TrackBar3.position);

  PickedColor:=rgbToColor(r,g,b);
  Shape1.Brush.Color:=PickedColor;
  PickedIndex:=AmigaColorPalette.PickedIndex;
  ColorIndexLabel.Caption:='Color Index: '+IntToStr(PickedIndex);
  AmigaColorPalette.Colors[PickedIndex]:=PickedColor;
end;

procedure TRMAmigaColorDialog.TrackBar1Change(Sender: TObject);
begin
  UpdateColorChange;
  UpdateTrackValues;
end;


procedure TRMAmigaColorDialog.TrackBar2Change(Sender: TObject);
begin
  UpdateColorChange;
  UpdateTrackValues;
end;

procedure TRMAmigaColorDialog.TrackBar3Change(Sender: TObject);
begin
  UpdateColorChange;
  UpdateTrackValues;
end;

procedure TRMAmigaColorDialog.UpDateCorePalette2;
var
  i : integer;
  tc : TColor;
  cr : TRMColorRec;
  r,g,b : byte;
begin
  for i:=0 to 1 do
  begin
      tc:=AmigaColorPalette.Colors[i];
      RedGreenBlue(tc,r,g,b);
      cr.r:=r;
      cr.g:=g;
      cr.b:=b;;
      RMCoreBase.Palette.SetColor(i,cr);
  end;
end;


procedure TRMAmigaColorDialog.UpDateCorePalette4;
var
  i : integer;
  tc : TColor;
  cr : TRMColorRec;
  r,g,b : byte;
begin
  for i:=0 to 3 do
  begin
      tc:=AmigaColorPalette.Colors[i];
      RedGreenBlue(tc,r,g,b);
      cr.r:=r;
      cr.g:=g;
      cr.b:=b;;
      RMCoreBase.Palette.SetColor(i,cr);
  end;
end;


procedure TRMAmigaColorDialog.UpDateCorePalette8;
var
  i : integer;
  tc : TColor;
  cr : TRMColorRec;
  r,g,b : byte;
begin
  for i:=0 to 7 do
  begin
      tc:=AmigaColorPalette.Colors[i];
      RedGreenBlue(tc,r,g,b);
      cr.r:=r;
      cr.g:=g;
      cr.b:=b;;
      RMCoreBase.Palette.SetColor(i,cr);
  end;
end;

procedure TRMAmigaColorDialog.UpDateCorePalette16;
var
  i : integer;
  tc : TColor;
  cr : TRMColorRec;
  r,g,b : byte;
begin
  for i:=0 to 15 do
  begin
      tc:=AmigaColorPalette.Colors[i];
      RedGreenBlue(tc,r,g,b);
      cr.r:=r;
      cr.g:=g;
      cr.b:=b;;
      RMCoreBase.Palette.SetColor(i,cr);
  end;
end;

procedure TRMAmigaColorDialog.UpDateCorePalette32;
var
  i : integer;
  tc : TColor;
  cr : TRMColorRec;
  r,g,b : byte;
begin
  for i:=0 to 31 do
  begin
      tc:=AmigaColorPalette.Colors[i];
      RedGreenBlue(tc,r,g,b);
      cr.r:=r;
      cr.g:=g;
      cr.b:=b;;
      RMCoreBase.Palette.SetColor(i,cr);
  end;
end;

function TRMAmigaColorDialog.GetPickedIndex : integer;
begin
   GetPickedIndex:=PickedIndex;
end;

function   TRMAmigaColorDialog.GetPickedColor : TColor;
begin
  GetPickedColor:=PickedColor;
end;



end.

