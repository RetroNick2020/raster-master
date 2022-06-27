program rm;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, lazcolorpalette, rmmain, rmcore, rmtools, rmcolor, rmcolorvga, rmabout,
  rmamigacolor, rwraw, rwpal, rmamigarwxgf, rwgif, rmexportprops, rmxgfcore,
  rwpng, mapcore, MapEditor, rwmap, mapexiportprops, gwbasic
     { you can add units after this };

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Scaled:=True;
  Application.Title:='RM';
  Application.Initialize;
  Application.CreateForm(TRMMainForm, RMMainForm);
  Application.CreateForm(TRMEGAColorDialog, RMEGAColorDialog);
  Application.CreateForm(TRMVgaColorDialog, RMVgaColorDialog);
  Application.CreateForm(TAboutDialog, AboutDialog);
  Application.CreateForm(TRMAmigaColorDialog, RMAmigaColorDialog);
  Application.CreateForm(TImageExportForm, ImageExportForm);
  Application.CreateForm(TMapEdit, MapEdit);
  Application.CreateForm(TMapExportForm, MapExportForm);
  Application.Run;
end.

