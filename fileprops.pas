unit fileprops;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  ComCtrls, rwpng,rmconfig;

type

  { TFileProperties }

  TFileProperties = class(TForm)
    A: TLabel;
    AV: TEdit;
    B: TLabel;
    BV: TEdit;
    TextToClipboardCheckBox: TCheckBox;
    ColorIndexCheckBox: TCheckBox;
    ColorIndexValue: TEdit;
    CustomCheckBox: TCheckBox;
    FuschiaCheckBox: TCheckBox;
    G: TLabel;
    GV: TEdit;
    Label2: TLabel;
    OKButton: TButton;
    Label1: TLabel;
    R: TLabel;
    RV: TEdit;
    procedure OKButtonClick(Sender: TObject);
    procedure TextToClipboardCheckBoxChange(Sender: TObject);
    procedure ValueChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    PngRGBA : PngRGBASettingsRec;

  public
    procedure UpdateValues;
    procedure SetProps(var props : PngRGBASettingsRec);
    procedure GetProps(var props : PngRGBASettingsRec);

  end;

var
  FilePropertiesDialog: TFileProperties;

implementation

{$R *.lfm}

{ TFileProperties }

function StrToIntHelper(IStr : String) : integer;
var
  SValue : integer;
begin
  Try
    SValue:=StrToInt(IStr);
  except
    SValue:=0;
  end;
  if SValue > 255 then SValue:=255;
  if SValue < 0 then SValue:=0;

  StrToIntHelper:=SValue;
end;

procedure TFileProperties.FormCreate(Sender: TObject);
begin
  // GetProps(PngRGBA); //copy the values we set in the form
   rmconfigbase.GetProps(PngRGBA);
   UpdateValues;
   TextToClipboardCheckBox.Checked:=rmconfigbase.GetExportTextFileToClipStatus;
end;

procedure TFileProperties.ValueChange(Sender: TObject);
begin
   GetProps(PngRGBA);
   UpdateValues;
end;

procedure TFileProperties.OKButtonClick(Sender: TObject);
begin
   modalresult:= mrOk;
end;

procedure TFileProperties.TextToClipboardCheckBoxChange(Sender: TObject);
begin
 rmconfigbase.SetExportTextFileToClipStatus(TextToClipboardCheckBox.Checked);
end;

// to be called after setprops
// takes values from PngRGBA record and transfer to form
procedure TFileProperties.UpdateValues;
begin
// ColorIndexCheckBox.Checked:=false;
// FuschiaCheckBox.Checked:=false;
// CustomCheckBox.Checked:=false;

  ColorIndexCheckBox.Checked:=PngRGBA.UseColorIndex;
  FuschiaCheckBox.Checked:=PngRGBA.UseFuschia;
  CustomCheckBox.Checked:=PngRGBA.UseCustom;

  RV.Text:=IntToStr(PngRGBA.R);
  GV.Text:=IntToStr(PngRGBA.G);
  BV.Text:=IntToStr(PngRGBA.B);
  AV.Text:=IntToStr(PngRGBA.A);
  ColorIndexValue.Text:=IntToStr(PngRGBA.ColorIndex);
end;

procedure TFileProperties.SetProps(var props : PngRGBASettingsRec);
begin
  PngRGBA:=props;
end;

procedure TFileProperties.GetProps(var props : PngRGBASettingsRec);
begin
  props.UseColorIndex:=ColorIndexCheckBox.Checked;
  props.UseFuschia:=FuschiaCheckBox.Checked;
  props.UseCustom:=CustomCheckBox.Checked;
  props.R:=StrToIntHelper(RV.Text);
  props.G:=StrToIntHelper(GV.Text);
  props.B:=StrToIntHelper(BV.Text);
  props.A:=StrToIntHelper(AV.Text);
  props.ColorIndex:=StrToIntHelper(ColorIndexValue.Text);
end;


end.

