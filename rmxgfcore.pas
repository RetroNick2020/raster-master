unit rmxgfcore;

{$mode objfpc}{$H+}

interface
     uses rmcore,rmthumb;

type
  GetMaxColorProc = function : integer;
  GetPixelProc    = function(x,y : integer) : integer;
  GetColorProc    = procedure(index : integer;var cr : TRMColorRec);

procedure SetThumbIndex(index : integer);
function GetThumbIndex : integer;
function CoreGetMaxColor : integer;
function ThumbGetMaxColor : integer;
function CoreGetPixel(x,y : integer) : integer;
function ThumbGetPixel(x,y : integer) : integer;
procedure SetMaxColorProc(MC : GetMaxColorProc);
procedure SetGetPixelProc(GP : GetPixelProc);
procedure SetGetColorProc(GC : GetColorProc);

Procedure SetCoreActive;
Procedure SetThumbActive;
Procedure InitXGFProcs;

function GetPixel(x,y : integer) : integer;
function  GetMaxColor : integer;
procedure GetColor(index : integer;var cr : TRMColorRec);

implementation
var
 XThumbIndex  : integer;
 XGetPixel    : GetPixelProc;
 XGetMaxColor : GetMaxColorProc;
 XGetColor    : GetColorProc;

procedure SetThumbIndex(index : integer);
begin
 XThumbIndex:=index;
end;

function GetThumbIndex : integer;
begin
 GetThumbIndex:=XThumbIndex;
end;

function CoreGetMaxColor : integer;
begin
  CoreGetMaxColor:=RMCoreBase.Palette.GetColorCount -1;
end;

function ThumbGetMaxColor : integer;
var
 index : integer;
begin
  index:=GetThumbIndex;
  ThumbGetMaxColor:=ImageThumbBase.GetMaxColor(index);
end;

function  GetMaxColor : integer;
begin
  GetMaxColor:=XGetMaxColor();
end;


function CoreGetPixel(x,y : integer) : integer;
begin
  CoreGetPixel:=RMCoreBase.getPixel(x,y);
end;

procedure CoreGetColor(index : integer;var cr : TRMColorRec);
begin
  RMCoreBase.palette.getcolor(index,cr);
end;

procedure GetColor(index : integer;var cr : TRMColorRec);
begin
  XGetcolor(index,cr);
end;


function ThumbGetPixel(x,y : integer) : integer;
var
  index : integer;
begin
  index:=GetThumbIndex;
  ThumbGetPixel:=ImageThumbBase.GetPixel(index,x,y);
end;

procedure ThumbGetColor(colorindex : integer;var cr : TRMColorRec);
var
 index : integer;
begin
  index:=GetThumbIndex;
  ImageThumbBase.Getcolor(index,colorindex,cr);
end;

procedure SetMaxColorProc(MC : GetMaxColorProc);
begin
  XGetMaxColor:=MC;
end;

procedure SetGetPixelProc(GP : GetPixelProc);
begin
  XGetPixel:=GP;
end;

procedure SetGetColorProc(GC : GetColorProc);
begin
  XGetColor:=GC;
end;



Procedure SetCoreActive;
begin
 SetMaxColorProc(@CoreGetMaxColor);
 SetGetPixelProc(@CoreGetPixel);
 SetGetColorProc(@CoreGetColor);
end;

Procedure SetThumbActive;
begin
 SetMaxColorProc(@ThumbGetMaxColor);
 SetGetPixelProc(@ThumbGetPixel);
 SetGetColorProc(@ThumbGetColor);
 SetThumbIndex(0);
end;

Procedure InitXGFProcs;
begin
 SetCoreActive;
end;

function GetPixel(x,y : integer) : integer;
begin
 GetPixel:=XGetPixel(x,y);
end;

begin
   InitXGFProcs;
end.

