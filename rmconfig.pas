unit rmconfig;

{$mode objfpc}{$H+}

interface
uses
  Classes, SysUtils;

type
TRMConfigBase = class(TObject)
            private
              ExportTextFilesToClip: boolean;
            public
               Constructor create;
               procedure SetExportTextFileToClipStatus(status : boolean);
               function GetExportTextFileToClipStatus : boolean;

end;

var
  RMConfigBase : TRMConfigBase;

implementation

Constructor TRMConfigBase.create;
begin
  ExportTextFilesToClip:=True;
end;

procedure TRMConfigBase.SetExportTextFileToClipStatus(status : boolean);
begin
  ExportTextFilesToClip:=status;
end;

function TRMConfigBase.GetExportTextFileToClipStatus : boolean;
begin
 result:=ExportTextFilesToClip;
end;

initialization
    RMConfigBase:=TRMConfigBase.Create;

end.

