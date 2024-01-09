unit rmconfig;

{$mode objfpc}{$H+}

interface
uses
  Classes, SysUtils,rwpng;

type
TRMConfigBase = class(TObject)
            private
              ExportTextFilesToClip: boolean;
              PngRGBA : PngRGBASettingsRec;
            public
               Constructor create;
               procedure SetDefaultProps(var props : PngRGBASettingsRec);
               procedure GetProps(var props : PngRGBASettingsRec);
               procedure SetProps(var props : PngRGBASettingsRec);

               procedure SetExportTextFileToClipStatus(status : boolean);
               function GetExportTextFileToClipStatus : boolean;

end;

var
  RMConfigBase : TRMConfigBase;

implementation

Constructor TRMConfigBase.create;
begin
  ExportTextFilesToClip:=True;
  SetDefaultProps(PngRGBA);
end;

procedure TRMConfigBase.SetExportTextFileToClipStatus(status : boolean);
begin
  ExportTextFilesToClip:=status;
end;

function TRMConfigBase.GetExportTextFileToClipStatus : boolean;
begin
 result:=ExportTextFilesToClip;
end;

procedure TRMConfigBase.SetDefaultProps(var props : PngRGBASettingsRec);
begin
 props.UseColorIndex:=False;
 props.UseFuschia:=True;
 props.UseCustom:=False;
 props.R:=0;
 props.G:=0;
 props.B:=0;
 props.A:=0;
 props.ColorIndex:=0;
end;


procedure TRMConfigBase.SetProps(var props : PngRGBASettingsRec);
begin
  PngRGBA:=props;
end;

procedure TRMConfigBase.GetProps(var props : PngRGBASettingsRec);
begin
  props:=PngRGBA;
end;

initialization
    RMConfigBase:=TRMConfigBase.Create;

end.

