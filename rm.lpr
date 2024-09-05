program rm;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, pascalscript, lazcolorpalette, rmmain, rmcore, rmtools, rmcolor,
  rmcolorvga, rmabout, rmamigacolor, rwraw, rwpal, rmamigarwxgf, rwgif,
  rmexportprops, rmxgfcore, rwpng, mapcore, mapeditor, rwmap, mapexiportprops,
  gwbasic, spriteimport, wraylib, rmcodegen, rwaqb, rmapi, rmcolorxga,
  fileprops, drawprocs, rmconfig, rmclipboard, soundgen, usfxr, 
SpriteSheetExport
     { you can add units after this };

{$R *.res}

begin
  RequireDerivedFormResource:=True;
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
  Application.CreateForm(TSpriteImportForm, SpriteImportForm);
  Application.CreateForm(TRMXgaColorDialog, RMXgaColorDialog);
  Application.CreateForm(TFileProperties, FilePropertiesDialog);
  Application.CreateForm(TSoundGeneratorForm, SoundGeneratorForm);
  Application.CreateForm(TSpriteSheetExportForm, SpriteSheetExportForm);
  Application.Run;
end.

