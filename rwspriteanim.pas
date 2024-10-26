unit rwspriteanim;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils,LazFileUtils,rmcodegen,animbase,gwbasic;


procedure ExportAnimation(filename : string;Lan : Integer);

procedure WriteAnimationCodeToBuffer(var F : Text;AnimIndex : integer);
procedure WriteAllAnimationCodeToBuffer(var F : Text);

implementation

procedure ExportPascalAnimHeader(var mc : CodeGenRec; AnimIndex : integer);
var
  FrameCount : integer;
  ImageName  : string;
begin
 FrameCount:=AnimateBase.GetFrameCount(AnimIndex);
 ImageName:=AnimateBase.GetExportName(AnimIndex);

 MWSetLan(mc,PascalLan);
 MWSetValueFormat(mc,ValueFormatDecimal);
 MWSetValuesTotal(mc,FrameCount);

 Writeln(mc.FTextPtr^,'(* Pascal Sprite Animation Code Created By Raster Master *)');
 Writeln(mc.FTextPtr^,'  ',Imagename,'_FrameCount = ',FrameCount,';');
 Writeln(mc.FTextPtr^,'  ',ImageName,' : array[0..',FrameCount-1,'] of integer = (');
end;

procedure ExportBasicAnimHeader(var mc : CodeGenRec; AnimIndex : integer);
var
  FrameCount : integer;
  ImageName  : string;
begin
 FrameCount:=AnimateBase.GetFrameCount(AnimIndex);
 ImageName:=AnimateBase.GetExportName(AnimIndex);

 MWSetLan(mc,BasicLan);
 MWSetValueFormat(mc,ValueFormatDecimal);
 MWSetValuesTotal(mc,FrameCount);

 Writeln(mc.FTextPtr^,ImageName+'Label:');
 Writeln(mc.FTextPtr^,#39,' Basic Sprite Animation Code Created By Raster Master');
 Writeln(mc.FTextPtr^,#39,' ',Imagename,' Frame Count =',FrameCount);
end;

procedure ExportBasicLNAnimHeader(var mc : CodeGenRec; AnimIndex : integer);
var
  FrameCount : integer;
  ImageName  : string;
begin
 FrameCount:=AnimateBase.GetFrameCount(AnimIndex);
 ImageName:=AnimateBase.GetExportName(AnimIndex);
 MWSetValuesTotal(mc,FrameCount);
 MWSetLan(mc,BasicLNLan);
 MWSetValueFormat(mc,ValueFormatDecimal);

 Writeln(mc.FTextPtr^,GetGWNextLineNumber,' ',#39,' Basic Sprite Animcation Code Created By Raster Master');
 Writeln(mc.FTextPtr^,GetGWNextLineNumber,' ',#39,' ',Imagename,' Frame Count=',FrameCount);
end;


procedure ExportCAnimHeader(var mc : CodeGenRec; AnimIndex : integer);
var
  FrameCount : integer;
  ImageName  : string;
begin
 FrameCount:=AnimateBase.GetFrameCount(AnimIndex);
 ImageName:=AnimateBase.GetExportName(AnimIndex);

 MWSetValuesTotal(mc,FrameCount);
 MWSetLan(mc,CLan);
 MWSetValueFormat(mc,ValueFormatDecimal);

 Writeln(mc.FTextPtr^,'/* C Sprite Animation Code Created By Raster Master */');
 Writeln(mc.FTextPtr^,'#define ',Imagename,'_FrameCount ', FrameCount);
 Writeln(mc.FTextPtr^,'  ','int ',Imagename, '[',FrameCount,']  = {');
end;

procedure WriteAnimationCodeToBuffer(var F : Text;AnimIndex : integer);
var
  AnimProps  : AnimExportFormatRec;
  FrameCount : integer;
  ImageName  : string;
  mc         : CodeGenRec;
  Lan        : integer;
  j          : integer;
begin
    FrameCount:=AnimateBase.GetFrameCount(AnimIndex);
    AnimateBase.GetAnimExportProps(AnimIndex,AnimProps);

    if (AnimProps.Lan > 0) and (AnimProps.AnimateFormat > 0) then
    begin
      MWInit(mc,F);
      MWSetValuesTotal(mc,FrameCount);

      Lan:=AnimProps.Lan;
      Imagename:=AnimProps.Name;

      //write header
      Case Lan of  BasicLan,BAMBasicLan,FBBasicLan,QB64BasicLan,AQBBasicLan:ExportBasicAnimHeader(mc,AnimIndex);
                BasicLnLan:ExportBasicLNAnimHeader(mc,AnimIndex);
                      CLan:ExportCAnimHeader(mc,AnimIndex);
                 PascalLan:ExportPascalAnimHeader(mc,AnimIndex);
      End;

      //write frame values
      For j:=0 to FrameCount-1 do
      begin
         MWWriteInteger(mc,AnimateBase.GetImageIndex(AnimIndex,j));
      end;

      Case Lan of BasicLan,FBBasicLan,QB64BasicLan,AQBBasicLan,BasicLNLan:Writeln(F);
                      CLan:Writeln(F,'};');
                 PascalLan:Writeln(F,');');
      End;
    end;
 end;

procedure WriteAllAnimationCodeToBuffer(var F : Text);
var
  i : integer;
begin
  for i:=0 to AnimateBase.GetAnimationCount-1 do
  begin
     WriteAnimationCodeToBuffer(F,i);
  end;
end;

procedure ExportAnimMain(var mc : CodeGenRec; AnimIndex : integer);
var
  FrameCount : integer;
  i : integer;
begin
  FrameCount:=AnimateBase.GetFrameCount(AnimIndex);
  //write frame values
  For i:=0 to FrameCount-1 do
  begin
    MWWriteInteger(mc,AnimateBase.GetImageIndex(AnimIndex,i));
  end;
end;

procedure ExportAnimation(filename : string;Lan : Integer);
var
  mc : CodeGenRec;
  AnimIndex : integer;
  ImageName : String;
  F : Text;
begin
 SetGWStartLineNumber(1000);
 MWInit(mc,F);
 Imagename:=ExtractFileName(ExtractFileNameWithoutExt(filename));
 {$I-}
  Assign(F,Filename);
  Rewrite(F);
  {$I+}
  if IORESULT<>0 then exit;

  AnimIndex:=AnimateBase.GetCurrentAnimation;
  Case Lan of  BasicLan,BAMBasicLan,FBBasicLan,QB64BasicLan,AQBBasicLan:ExportBasicAnimHeader(mc,AnimIndex);
            BasicLnLan:ExportBasicLNAnimHeader(mc,AnimIndex);
                  CLan:ExportCAnimHeader(mc,AnimIndex);
             PascalLan:ExportPascalAnimHeader(mc,AnimIndex);
  End;
  ExportAnimMain(mc,AnimIndex);
  Case Lan of BasicLan,BasicLNLan:Writeln(F);
                             CLan:Writeln(F,'};');
                        PascalLan:Writeln(F,');');
  End;
  {$I-}
  close(F);
{$I+}
end;

procedure ExportAllAnimation(filename : string);
var
  mc : CodeGenRec;
  AnimIndex : integer;
  F         : Text;
begin
 SetGWStartLineNumber(1000);
 MWInit(mc,F);
 {$I-}
  Assign(F,Filename);
  Rewrite(F);
  {$I+}
  if IORESULT<>0 then exit;

  for AnimIndex:=0 to AnimateBase.GetAnimationCount-1 do
  begin
    WriteAnimationCodeToBuffer(F,AnimIndex);
  end;
  {$I-}
  close(F);
{$I+}
end;

end.

