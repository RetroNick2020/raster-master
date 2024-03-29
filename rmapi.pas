unit rmapi;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,Dialogs,rmxgfcore,mapcore, rmcodegen,rmcore,rmtools,rmthumb,gwbasic;

procedure rm_putpixel(x,y,color : integer);
function rm_getpixel(x,y : integer) : integer;

function rm_getwidth : integer;
function rm_getheight : integer;

procedure rm_showmessage(const aMsg : string);

function rm_cg_open(filename : string) : boolean;
procedure rm_cg_options(name, value : string);

procedure rm_cg_close;
procedure rm_cg_write(Line : string);
procedure rm_cg_writeln;
procedure rm_cg_write_byte(value : byte);
procedure rm_cg_write_integer(value : integer);

procedure rm_getselectarea(var active,x1,y1,x2,y2 : integer);

function  rm_getmaxcolor : integer;

procedure rm_getcolorrgb(index : integer;var r,g,b : byte);
procedure rm_setcolorrgb(index : integer; r,g,b : byte);

procedure rm_SetPaletteMode(mode : integer);
function rm_GetPaletteMode : integer;


implementation

var
  cg     : CodeGenRec;
  cgfile : text;

procedure rm_putpixel(x,y,color : integer);
begin
  putpixel(x,y,color);
end;

function rm_getpixel(x,y : integer) : integer;
begin
  rm_getpixel:=getpixel(x,y);
end;

function rm_getwidth : integer;
begin
  rm_getwidth:=GetWidth;
end;

function rm_getheight : integer;
begin
  rm_getheight:=GetHeight;
end;

function  rm_getmaxcolor : integer;
begin
  rm_getmaxcolor:=GetMaxColor;
end;

procedure rm_getcolorrgb(index : integer;var r,g,b : byte);
begin
  GetColorRGB(index,r,g,b);
end;

procedure rm_setcolorrgb(index : integer; r,g,b : byte);
begin
  SetColorRGB(index,r,g,b);
end;




function rm_cg_open(filename : string) : boolean;
begin
  Assign(cgfile,filename);
{$I-}
  Rewrite(cgfile);
{$I+}
  if IORESULT = 0 then
  begin
     MWInit(cg,cgfile);
     rm_cg_open:=true;
  end
  else
  begin
    rm_cg_open:=false;
  end;
end;

procedure rm_cg_close;
begin
  close(cgfile);
end;

procedure rm_cg_options(name, value : string);
begin
  name:=UpperCase(name);
  value:=UpperCase(value);
  Case Name of 'LAN':begin
                       Case value of 'BASICLAN': MWSetLan(cg,BasicLan);
                                 'BASICLNLAN': MWSetLan(cg,BasicLnLan);

                                    'PASCALLAN': MWSetLan(cg,PascalLan);
                                         'CLAN': MWSetLan(cg,CLan);
                                            else
                                            begin
                                               try
                                                MWSetLan(cg,StrToInt(value));
                                               except
                                                 MWSetLan(cg,PascalLan);
                                               end;
                                             end;
                        end;
                       end;
                'VALUESPERLINE':begin
                                   try
                                     MWSetValuesPerLine(cg,StrToInt(value));
                                    except
                                     MWSetValuesPerLine(cg,20);
                                    end;
                                  end;
                  'VALUESTOTAL':begin
                                   try
                                     MWSetValuesTotal(cg,StrToInt(value));
                                    except
                                     MWSetValuesTotal(cg,0);
                                    end;
                                  end;
                  'VALUEFORMAT': begin
                                   Case value of 'HEX': MWSetValueFormat(cg,ValueFormatHex);
                                             'DECIMAL': MWSetValueFormat(cg,ValueFormatDecimal);
                                   end;
                                 end;
                       'INDENT': begin
                                   try
                                     MWSetIndent(cg,StrToInt(value));
                                    except
                                     MWSetIndent(cg,10);
                                    end;
                                  end;
            'INDENTONFIRSTLINE': MWSetIndentOnFirstLine(cg,Value='YES');
              'LINENUMBERSTART':begin
                                   try
                                     SetGWStartLineNumber(StrToInt(value))
                                    except
                                      SetGWStartLineNumber(1000)
                                    end;
                                 end;

  end;
end;

procedure rm_cg_write(Line : string);
begin
  write(cgfile,line);
end;

procedure rm_cg_writeln;
begin
  writeln(cgfile);
end;

procedure rm_cg_write_byte(value : byte);
begin
  MWWriteByte(cg,value);
end;

procedure rm_cg_write_integer(value : integer);
begin
  MWWriteInteger(cg,value);
end;

procedure rm_getselectarea(var active,x1,y1,x2,y2 : integer);
var
  ca : TClipAreaRec;
begin
  active:=0;
  x1:=0;
  x2:=0;
  y1:=0;
  y2:=0;

  RMDrawTools.GetClipAreaCoords(ca);
  if (ca.sized=1) and (RMDrawTools.GetClipStatus=1) then
  begin
    active:=1;
    x1:=ca.x;
    x2:=ca.x2;
    y1:=ca.y;
    y2:=ca.y2;
  end;
end;

function rm_getmapwidth : integer;
begin
  rm_getmapwidth:=MapCoreBase.GetMapWidth(MapCoreBase.GetCurrentMap);
end;

function rm_getmapheight(index : integer) : integer;
begin
  rm_getmapheight:=MapCoreBase.GetMapHeight(MapCoreBase.GetCurrentMap);
end;

function rm_gettilewidth : integer;
begin
  rm_gettilewidth:=MapCoreBase.GetMapTileWidth(MapCoreBase.GetCurrentMap);
end;

function rm_gettileheight(index : integer) : integer;
begin
  rm_gettileheight:=MapCoreBase.GetMapTileHeight(MapCoreBase.GetCurrentMap);
end;

function rm_gettileproperty(x,y : integer;tilepropertyname : string) : string;
var
  Tile : TileRec;
begin
  if UpperCase(tilepropertyname) = 'IMAGEINDEX' then
  begin
    MapCoreBase.GetMapTile(MapCoreBase.GetCurrentMap,x,y,Tile);
    rm_gettileproperty:=IntToStr(Tile.ImageIndex);
  end
  else
  begin
    rm_gettileproperty:='';
  end;
end;

procedure rm_settileproperty(x,y : integer;tilepropertyname,value : string);
var
  Tile : TileRec;
begin
  if UpperCase(tilepropertyname) = 'IMAGEINDEX' then
  begin
    MapCoreBase.GetMapTile(MapCoreBase.GetCurrentMap,x,y,Tile);
    try
      Tile.ImageIndex :=StrToInt(value);
    except
     Tile.ImageIndex :=-1;
    end;
    if Tile.ImageIndex > -1 then Tile.ImageUID :=ImageThumbBase.GetUID(Tile.ImageIndex); //fetch the GUID
    MapCoreBase.SetMapTile(MapCoreBase.GetCurrentMap,x,y,Tile);
  end;
end;


procedure rm_showmessage(const aMsg : string);
begin
  showmessage(aMsg);
end;

procedure rm_SetPaletteMode(mode : integer);
begin
  SetPaletteMode(mode);
end;

function rm_GetPaletteMode : integer;
begin
   rm_GetPaletteMode:=GetPaletteMode;
end;


end.

