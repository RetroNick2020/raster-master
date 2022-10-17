unit rmxgfcore;

{$mode objfpc}{$H+}

interface
     uses rmcore,rmthumb;

type
  GetMaxColorProc = function : integer;

  GetWidthProc = function : integer;
  GetHeightProc = function : integer;

  GetPixelProc    = function(x,y : integer) : integer;
  PutPixelProc    = procedure(x,y,color : integer);

  GetColorProc    = procedure(index : integer;var cr : TRMColorRec);
  SetColorProc    = procedure(index : integer;var cr : TRMColorRec);

  GetPaletteModeProc = function : integer;
  SetPaletteModeProc = procedure(mode : integer);

procedure SetThumbIndex(index : integer);
function GetThumbIndex : integer;
function CoreGetMaxColor : integer;
function ThumbGetMaxColor : integer;
function CoreGetPixel(x,y : integer) : integer;
function ThumbGetPixel(x,y : integer) : integer;
procedure SetMaxColorProc(MC : GetMaxColorProc);

procedure SetGetPixelProc(GP : GetPixelProc);
procedure SetPutPixelProc(PP : PutPixelProc);

procedure SetGetColorProc(GC : GetColorProc);
procedure SetSetColorProc(SC : SetColorProc);

procedure SetGetPaletteModeProc(GPM : GetPaletteModeProc);
procedure SetSetPaletteModeProc(SPM : SetPaletteModeProc);



Procedure SetCoreActive;
Procedure SetThumbActive;
Procedure InitXGFProcs;

function GetPixel(x,y : integer) : integer;
procedure PutPixel(x,y,color : integer);
function GetWidth : integer;
function GetHeight : integer;

function  GetMaxColor : integer;
procedure GetColor(index : integer;var cr : TRMColorRec);
procedure SetColor(index : integer;var cr : TRMColorRec);

procedure GetColorRGB(index : integer; var r,g,b : byte);
procedure SetColorRGB(index : integer; r,g,b : byte);

function GetPaletteMode : integer;
procedure SetPaletteMode(mode : integer);


procedure SetMaskMode(mode : integer);
function GetMaskMode : integer;

implementation
var
 XThumbIndex  : integer;
 XGetPixel    : GetPixelProc;
 XPutPixel    : PutPixelProc;

 XGetWidth    : GetWidthProc;
 XGetHeight   : GetHeightProc;

 XGetMaxColor : GetMaxColorProc;

 XGetPaletteMode : GetPaletteModeProc;
 XSetPaletteMode : SetPaletteModeProc;

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


function ThumbGetPaletteMode : integer;
var
 index : integer;
begin
  index:=GetThumbIndex;
  ThumbGetPaletteMode:=ImageThumbBase.GetPaletteMode(index);
end;

procedure CoreSetPaletteMode(mode  : integer);
begin
 RMCoreBase.Palette.SetPaletteMode(mode);
end;

function CoreGetPaletteMode : integer;
begin
 CoreGetPaletteMode:=RMCoreBase.Palette.GetPaletteMode;
end;

procedure ThumbSetPaletteMode(mode  : integer);
var
 index : integer;
begin
  index:=GetThumbIndex;
  ImageThumbBase.SetPaletteMode(index,mode);
end;



function CoreGetPixel(x,y : integer) : integer;
begin
  CoreGetPixel:=RMCoreBase.getPixel(x,y);
end;

procedure CorePutPixel(x,y,color : integer);
begin
  RMCoreBase.PutPixel(x,y,color);
end;

function CoreGetWidth : integer;
begin
  CoreGetWidth:=RMCoreBase.GetWidth;
end;

function CoreGetHeight : integer;
begin
  CoreGetHeight:=RMCoreBase.GetHeight;
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

procedure GetColorRGB(index : integer;var r,g,b : byte);
var
 cr : TRMColorRec;
begin
 XGetcolor(index,cr);
 r:=cr.r;
 g:=cr.g;
 b:=cr.b;
end;

procedure SetColorRGB(index : integer; r,g,b : byte);
var
 cr : TRMColorRec;
begin
 cr.r:=r;
 cr.g:=g;
 cr.b:=b;
 XSetcolor(index,cr);
end;



function ThumbGetPixel(x,y : integer) : integer;
var
  index : integer;
begin
  index:=GetThumbIndex;
  ThumbGetPixel:=ImageThumbBase.GetPixel(index,x,y);
end;

procedure ThumbPutPixel(x,y,color : integer);
var
  index : integer;
begin
  index:=GetThumbIndex;
  ImageThumbBase.PutPixel(index,x,y,color);
end;

function ThumbGetWidth : integer;
var
  index : integer;
begin
  index:=GetThumbIndex;
  ThumbGetWidth:=ImageThumbBase.GetWidth(index);
end;

function ThumbGetHeight : integer;
var
  index : integer;
begin
  index:=GetThumbIndex;
  ThumbGetHeight:=ImageThumbBase.GetHeight(index);
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

procedure SetPutPixelProc(PP : PutPixelProc);
begin
  XPutPixel:=PP;
end;

procedure SetGetColorProc(GC : GetColorProc);
begin
  XGetColor:=GC;
end;

procedure SetSetColorProc(SC : SetColorProc);
begin
  XSetColor:=SC;
end;


procedure SetGetPaletteModeProc(GPM : GetPaletteModeProc);
begin
  XGetPaletteMode:=GPM;
end;

procedure SetSetPaletteModeProc(SPM : SetPaletteModeProc);
begin
  XSetPaletteMode:=SPM;
end;

procedure SetGetWidthProc(SW : GetWidthProc);
begin
  XGetWidth:=SW;
end;

procedure SetGetHeightProc(SH : GetHeightProc);
begin
  XGetHeight:=SH;
end;


Procedure SetCoreActive;
begin
 SetMaskMode(0);
 SetMaxColorProc(@CoreGetMaxColor);

 SetGetPixelProc(@CoreGetPixel);
 SetPutPixelProc(@CorePutPixel);

 SetGetWidthProc(@CoreGetWidth);
 SetGetHeightProc(@CoreGetHeight);

 SetGetColorProc(@CoreGetColor);
 SetSetColorProc(@CoreSetColor);

 SetGetPaletteModeProc(@CoreGetPaletteMode);
 SetSetPaletteModeProc(@CoreSetPaletteMode);

 SetThumbIndex(ImageThumbBase.GetCurrent);
end;

Procedure SetThumbActive;
begin
 SetMaskMode(0);
 SetMaxColorProc(@ThumbGetMaxColor);

 SetGetPixelProc(@ThumbGetPixel);
 SetPutPixelProc(@ThumbPutPixel);

 SetGetWidthProc(@ThumbGetWidth);
 SetGetHeightProc(@ThumbGetHeight);

 SetGetColorProc(@ThumbGetColor);
 SetSetColorProc(@ThumbGetColor);

 SetGetPaletteModeProc(@ThumbGetPaletteMode);
 SetSetPaletteModeProc(@ThumbSetPaletteMode);

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

procedure PutPixel(x,y,color : integer);
begin
 XPutPixel(x,y,color);
end;

function GetWidth : integer;
begin
  GetWidth:=XGetWidth();
end;

function GetHeight : integer;
begin
  GetHeight:=XGetHeight();
end;

procedure SetPaletteMode(mode : integer);
begin
 XSetPaletteMode(mode);
end;

function GetPaletteMode : integer;
begin
 GetPaletteMode:=XGetPaletteMode();
end;



begin
   InitXGFProcs;
end.

