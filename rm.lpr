program rm;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, lazcolorpalette, RMMain, rmcore, rmtools, RMColor, RMColorVga, rmabout,
  rmamigacolor, rwraw, rwpal, rmamigarwxgf
     { you can add units after this };

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Initialize;
  Application.CreateForm(TRMMainForm, RMMainForm);
  Application.CreateForm(TRMEGAColorDialog, RMEGAColorDialog);
  Application.CreateForm(TRMVgaColorDialog, RMVgaColorDialog);
  Application.CreateForm(TAboutDialog, AboutDialog);
  Application.CreateForm(TRMAmigaColorDialog, RMAmigaColorDialog);
  Application.Run;
end.

