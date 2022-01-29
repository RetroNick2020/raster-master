unit rmabout;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,lclintf;

Const
  ProgramName ='Raster Master v1.0 Beta R31';
  ProgramLicense = 'Released under MIT License';

type

  { TAboutDialog }

  TAboutDialog = class(TForm)
    Image1: TImage;
    ProgramLicenseLabel: TLabel;
    ProgramNameLabel: TLabel;
    Shape1: TShape;
    Shape2: TShape;
    StaticText1: TStaticText;
   procedure InitName;

   procedure StaticText1Click(Sender: TObject);
  private

  public

  end;

var
  AboutDialog: TAboutDialog;

implementation

{$R *.lfm}


procedure TAboutDialog.InitName;
begin
  ProgramNameLabel.caption:=ProgramName;
  ProgramLicenseLabel.caption:=ProgramLicense;
end;


procedure TAboutDialog.StaticText1Click(Sender: TObject);
begin
   OpenUrl('http://www.youtube.com/channel/UCLak9dN2fgKU9keY2XEBRFQ?sub_confirmation=1');
end;

end.

