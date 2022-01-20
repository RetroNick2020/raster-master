unit rmxgfcore;

{$mode objfpc}{$H+}

interface
     uses rmcore,rmthumb;

type
  GetMaxColorProc = function : integer;
  GetPixelProc    = function(x,y : integer) : integer;
  GetColorProc    = procedure(index : integer;var cr : TRMColorRec);
  SetColorProc    = procedure(index : integer;var cr : TRMColorRec);

procedure SetThumbIndex(index : integer);
function GetThumbIndex : integer;
function CoreGetMaxColor : integer;
function ThumbGetMaxColor : integer;
function CoreGetPixel(x,y : integer) : integer;
function ThumbGetPixel(x,y : integer) : integer;
procedure SetMaxColorProc(MC : GetMaxColorProc);
procedure SetGetPixelProc(GP : GetPixelProc);
procedure SetGetColorProc(GC : GetColorProc);
procedure SetSetColorProc(SC : SetColorProc);

Procedure SetCoreActive;
Procedure SetThumbActive;
Procedure InitXGFProcs;

function GetPixel(x,y : integer) : integer;
function  GetMaxColor : integer;
procedure GetColor(index : integer;var cr : TRMColorRec);
procedure SetColor(index : integer;var cr : TRMColorRec);

procedure SetMaskMode(mode : integer);
function GetMaskMode : integer;

implementation
var
 XThumbIndex  : integer;
 XGetPixel    : GetPixelProc;
 XGetMaxColor : GetMaxColorProc;
 XGetColor    : GetColorProc;
 XSetColor    : SetColorProc;
 XMaskMode    : integer;

procedure SetMaskMode(mode : integer);
begin
 XMaskMode:=mode;
end;

function GetMaskMode : integer;
begin
 GetMaskMode:=XMaskMode;
end;

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

procedure CoreSetColor(index : integer;var cr : TRMColorRec);
begin
  RMCoreBase.palette.setcolor(index,cr);
end;

procedure GetColor(index : integer;var cr : TRMColorRec);
begin
  XGetcolor(index,cr);
end;

procedure SetColor(index : integer;var cr : TRMColorRec);
begin
  XSetcolor(index,cr);
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

procedure ThumbSetColor(colorindex : integer;var cr : TRMColorRec);
var
 index : integer;
begin
  index:=GetThumbIndex;
  ImageThumbBase.Setcolor(index,colorindex,cr);
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

procedure SetSetColorProc(SC : SetColorProc);
begin
  XSetColor:=SC;
end;


Procedure SetCoreActive;
begin
 SetMaskMode(0);
 SetMaxColorProc(@CoreGetMaxColor);
 SetGetPixelProc(@CoreGetPixel);
 SetGetColorProc(@CoreGetColor);
 SetSetColorProc(@CoreSetColor);
end;

Procedure SetThumbActive;
begin
 SetMaskMode(0);
 SetMaxColorProc(@ThumbGetMaxColor);
 SetGetPixelProc(@ThumbGetPixel);
 SetGetColorProc(@ThumbGetColor);
 SetSetColorProc(@ThumbGetColor);
 SetThumbIndex(0);
end;

Procedure InitXGFProcs;
begin
 SetCoreActive;
end;

function GetPixel(x,y : integer) : integer;
var
 pixColor : integer;
begin
 pixColor:=XGetPixel(x,y);
 if XMaskMode = 1 then
 begin
    if pixColor = 0 then pixColor:=GetMaxColor else pixColor:=0;  // in 16 color mode any pixel color 0 become 15 (white) and any other color becomes 0
 end;
 GetPixel:=pixColor;
end;

begin
   InitXGFProcs;
end.

