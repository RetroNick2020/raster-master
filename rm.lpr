program rm;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, pascalscript, lazcontrols, lazcolorpalette, rmmain, rmcore, rmtools,
  rmcolor, rmcolorvga, rmabout, rmamigacolor, rwraw, rwpal, rmamigarwxgf, rwgif,
  rmexportprops, rmxgfcore, rwpng, mapcore, mapeditor, rwmap, mapexiportprops,
  gwbasic, spriteimport, wraylib, rmcodegen, rwaqb, rmapi, rmcolorxga,
  fileprops, drawprocs, rmconfig, rmclipboard, soundgen, usfxr,
  SpriteSheetExport, animate, AnimBase, setcustommapsize, animationexport,
rwspriteanim, setcustomspritesize, setcustomtilesize, SetCustomCellSize
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
  Application.CreateForm(TAnimationForm, AnimationForm);
  Application.CreateForm(TSetCustomMapSizeForm, SetCustomMapSizeForm);
  Application.CreateForm(TAnimationExportForm, AnimationExportForm);
  Application.CreateForm(Tsetcustomspritesizeform, setcustomspritesizeform);
  Application.CreateForm(TSetCustomTileSizeForm, SetCustomTileSizeForm);
  Application.CreateForm(TSetCustomCellSizeForm, SetCustomCellSizeForm);
  Application.Run;
end.

