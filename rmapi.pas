unit rmapi;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,Dialogs,rmxgfcore,rmconst,mapcore, rmcodegen,rmcore,rmtools,rmthumb,gwbasic;

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

procedure rm_getcliparea(var active,x1,y1,x2,y2 : integer);

function  rm_getmaxcolor : integer;

procedure rm_getcolorrgb(index : integer;var r,g,b : byte);
procedure rm_setcolorrgb(index : integer; r,g,b : byte);

procedure rm_SetPaletteMode(mode : integer);
function rm_GetPaletteMode : integer;

procedure rm_settileproperty(x,y : integer;tilepropertyname,value : string);
function rm_gettileproperty(x,y : integer;tilepropertyname : string) : string;
function rm_gettileheight : integer;
function rm_gettilewidth : integer;
function rm_getmapheight(index : integer) : integer;
function rm_getmapwidth : integer;
function rm_gettilecount : integer;


procedure rm_getmapselectarea(var active,x1,y1,x2,y2 : integer);

//--- code generator state ---
function  rm_cg_isopen : boolean;
//Clipboard mode: the next rm_cg_open writes to a temporary file instead of
//the named one, and rm_cg_close copies the result to the clipboard.
procedure rm_cg_setclipboard(onoff : boolean);
function  rm_cg_getclipboard : boolean;

//--- images (sprites) ---
//The image being edited lives in the editor core; the rest are stored in
//ImageThumbBase with their own undo. rm_image_select moves the core to
//another image the same way clicking a thumbnail does.
function  rm_image_count : integer;
function  rm_image_current : integer;
procedure rm_image_select(index : integer);
function  rm_image_name(index : integer) : string;

//--- maps: any map, any layer ---
//Every routine takes the map (and layer) explicitly and checks it, so a
//script can work on maps other than the one open in the map editor.
function  rm_map_count : integer;
function  rm_map_current : integer;
function  rm_map_width(map : integer) : integer;
function  rm_map_height(map : integer) : integer;
function  rm_map_tilewidth(map : integer) : integer;
function  rm_map_tileheight(map : integer) : integer;
function  rm_map_layercount(map : integer) : integer;
function  rm_map_currentlayer(map : integer) : integer;
function  rm_map_gettile(map,layer,x,y : integer) : integer;
procedure rm_map_settile(map,layer,x,y,tile : integer);


implementation

uses
  Clipbrd;

var
  cg     : CodeGenRec;
  cgfile : text;
  cgclip     : boolean = false;   //clipboard mode chosen for the next open
  cgtoclip   : boolean = false;   //the OPEN file goes to the clipboard on close
  cgtempname : string = '';
  //Is cgfile open? rm_cg_close used to close it unconditionally and the
  //writers wrote to it unconditionally, so a stray CGCLOSE or a write before
  //CGOPEN was an I/O error, and a second rm_cg_open re-Assigned an open file.
  cgopen : boolean = false;

//--- checks shared by the routines below. They raise with a message that
//names the problem, so a script error says what was wrong. ---

procedure CheckColor(color : integer; const who : string);
begin
  if (color < 0) or (color > GetMaxColor) then
    raise Exception.Create(who+': colour '+IntToStr(color)+
                           ' is outside 0 to '+IntToStr(GetMaxColor));
end;

procedure CheckCGOpen(const who : string);
begin
  if not cgopen then
    raise Exception.Create(who+': no code file is open - call CGOPEN first');
end;

procedure CheckMap(map : integer; const who : string);
begin
  if (map < 0) or (map >= MapCoreBase.GetMapCount) then
    raise Exception.Create(who+': map '+IntToStr(map)+' does not exist - maps are 0 to '+
                           IntToStr(MapCoreBase.GetMapCount-1));
end;

procedure CheckLayer(map,layer : integer; const who : string);
begin
  CheckMap(map,who);
  if (layer < 0) or (layer >= MapCoreBase.GetLayerCount(map)) then
    raise Exception.Create(who+': layer '+IntToStr(layer)+' does not exist - map '+
                           IntToStr(map)+' has layers 0 to '+
                           IntToStr(MapCoreBase.GetLayerCount(map)-1));
end;

procedure CheckCell(map,x,y : integer; const who : string);
begin
  if (x < 0) or (x >= MapCoreBase.GetMapWidth(map)) or
     (y < 0) or (y >= MapCoreBase.GetMapHeight(map)) then
    raise Exception.Create(who+': cell '+IntToStr(x)+','+IntToStr(y)+
                           ' is outside the map ('+IntToStr(MapCoreBase.GetMapWidth(map))+
                           ' x '+IntToStr(MapCoreBase.GetMapHeight(map))+')');
end;

//Off the image is clipped silently, as QBasic's PSET does, so shapes can
//hang over the edge. A bad colour is always a mistake, so that raises.
procedure rm_putpixel(x,y,color : integer);
begin
  CheckColor(color,'PUTPIXEL');
  if (x < 0) or (y < 0) or (x >= GetWidth) or (y >= GetHeight) then exit;
  putpixel(x,y,color);
end;

//-1 off the image, as QBasic's POINT - it used to read outside the buffer
function rm_getpixel(x,y : integer) : integer;
begin
  if (x < 0) or (y < 0) or (x >= GetWidth) or (y >= GetHeight) then
    rm_getpixel:=-1
  else
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
  CheckColor(index,'GETCOLOR');
  GetColorRGB(index,r,g,b);
end;

procedure rm_setcolorrgb(index : integer; r,g,b : byte);
begin
  CheckColor(index,'SETCOLORRGB');
  SetColorRGB(index,r,g,b);
end;


function rm_cg_open(filename : string) : boolean;
begin
  if cgopen then rm_cg_close;    //one file at a time - finish the previous one
  //Clipboard mode writes to a temporary file - the code generator needs a
  //text file - and rm_cg_close copies it to the clipboard. The mode is fixed
  //here, so switching it while a file is open affects only the next one.
  cgtoclip:=cgclip;
  if cgtoclip then
  begin
    cgtempname:=GetTempFileName;
    filename:=cgtempname;
  end;
  Assign(cgfile,filename);
{$I-}
  Rewrite(cgfile);
{$I+}
  if IORESULT = 0 then
  begin
     MWInit(cg,cgfile);
     cgopen:=true;
     rm_cg_open:=true;
  end
  else
  begin
    cgtoclip:=false;
    rm_cg_open:=false;
  end;
end;

//closing when nothing is open is harmless, not an I/O error
//the whole file as one string, exactly as written
function ReadWholeFile(const fname : string) : string;
var
  fs : TFileStream;
begin
  result:='';
  fs:=TFileStream.Create(fname,fmOpenRead or fmShareDenyWrite);
  try
    SetLength(result,fs.Size);
    if fs.Size > 0 then fs.ReadBuffer(result[1],fs.Size);
  finally
    fs.Free;
  end;
end;

procedure rm_cg_close;
begin
  if not cgopen then exit;
  close(cgfile);
  cgopen:=false;
  if cgtoclip then
  begin
    cgtoclip:=false;
    try
      Clipboard.AsText:=ReadWholeFile(cgtempname);
    finally
      DeleteFile(cgtempname);     //never leave the temporary file behind
    end;
  end;
end;

procedure rm_cg_setclipboard(onoff : boolean);
begin
  cgclip:=onoff;
end;

function rm_cg_getclipboard : boolean;
begin
  rm_cg_getclipboard:=cgclip;
end;

function rm_cg_isopen : boolean;
begin
  rm_cg_isopen:=cgopen;
end;

//Unknown options and bad values used to be ignored or replaced by a default,
//so a typo quietly produced the wrong output. They are errors now.
procedure rm_cg_options(name, value : string);
var
  n : integer;

  function NumValue : integer;
  begin
    if not TryStrToInt(value,Result) then   //Result, not the bare function name
      raise Exception.Create('CGOPTIONS '+name+': "'+value+'" is not a whole number');
  end;

begin
  name:=UpperCase(name);
  value:=UpperCase(value);
  Case Name of 'LAN':begin
                       Case value of 'BASICLAN': MWSetLan(cg,BasicLan);
                                 'BASICLNLAN': MWSetLan(cg,BasicLnLan);
                                    'PASCALLAN': MWSetLan(cg,PascalLan);
                                         'CLAN': MWSetLan(cg,CLan);
                       else
                         if TryStrToInt(value,n) then
                           MWSetLan(cg,n)
                         else
                           raise Exception.Create('CGOPTIONS LAN: "'+value+
                             '" - use BASICLAN, BASICLNLAN, PASCALLAN, CLAN or a language number');
                       end;
                     end;
      'VALUESPERLINE': MWSetValuesPerLine(cg,NumValue);
        'VALUESTOTAL': MWSetValuesTotal(cg,NumValue);
        'VALUEFORMAT': Case value of 'HEX': MWSetValueFormat(cg,ValueFormatHex);
                                 'DECIMAL': MWSetValueFormat(cg,ValueFormatDecimal);
                       else
                         raise Exception.Create('CGOPTIONS VALUEFORMAT: "'+value+'" - use HEX or DECIMAL');
                       end;
             'INDENT': MWSetIndent(cg,NumValue);
  'INDENTONFIRSTLINE': if (value = 'YES') or (value = 'NO') then
                         MWSetIndentOnFirstLine(cg,value='YES')
                       else
                         raise Exception.Create('CGOPTIONS INDENTONFIRSTLINE: "'+value+'" - use YES or NO');
    'LINENUMBERSTART': SetGWStartLineNumber(NumValue);
  else
    raise Exception.Create('CGOPTIONS: unknown option "'+name+'" - use LAN, VALUESPERLINE, '+
                           'VALUESTOTAL, VALUEFORMAT, INDENT, INDENTONFIRSTLINE or LINENUMBERSTART');
  end;
end;

procedure rm_cg_write(Line : string);
begin
  CheckCGOpen('CGWRITE');
  write(cgfile,line);
end;

procedure rm_cg_writeln;
begin
  CheckCGOpen('CGWRITELN');
  writeln(cgfile);
end;

procedure rm_cg_write_byte(value : byte);
begin
  CheckCGOpen('CGWRITEBYTE');
  MWWriteByte(cg,value);
end;

procedure rm_cg_write_integer(value : integer);
begin
  CheckCGOpen('CGWRITEINTEGER');
  MWWriteInteger(cg,value);
end;

procedure rm_getcliparea(var active,x1,y1,x2,y2 : integer);
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
  rm_getmapwidth:=rm_map_width(rm_map_current);
end;

function rm_getmapheight(index : integer) : integer;
begin
  //the index was ignored and the current map always used
  rm_getmapheight:=rm_map_height(index);
end;

function rm_gettilewidth : integer;
begin
  rm_gettilewidth:=rm_map_tilewidth(rm_map_current);
end;

function rm_gettileheight : integer;
begin
  rm_gettileheight:=rm_map_tileheight(rm_map_current);
end;

//Current map and current layer - kept for compatibility, built on the
//checked routines. Unknown property names and non-numbers raise; before,
//an unknown name did nothing and a non-number CLEARED the cell.
function rm_gettileproperty(x,y : integer;tilepropertyname : string) : string;
begin
  if UpperCase(tilepropertyname) <> 'IMAGEINDEX' then
    raise Exception.Create('Unknown tile property "'+tilepropertyname+'" - only IMAGEINDEX');
  rm_gettileproperty:=IntToStr(rm_map_gettile(rm_map_current,
                        rm_map_currentlayer(rm_map_current),x,y));
end;

procedure rm_settileproperty(x,y : integer;tilepropertyname,value : string);
var
  t : integer;
begin
  if UpperCase(tilepropertyname) <> 'IMAGEINDEX' then
    raise Exception.Create('Unknown tile property "'+tilepropertyname+'" - only IMAGEINDEX');
  if not TryStrToInt(value,t) then
    raise Exception.Create('Tile IMAGEINDEX "'+value+'" is not a whole number');
  rm_map_settile(rm_map_current,rm_map_currentlayer(rm_map_current),x,y,t);
end;

function rm_gettilecount : integer;
begin
    result:=ImageThumbBase.GetCount;
end;

procedure rm_getmapselectarea(var active,x1,y1,x2,y2 : integer);
var
  ca : MapClipAreaRec;
begin
  active:=0;
  x1:=0;
  x2:=0;
  y1:=0;
  y2:=0;

  MapCoreBase.GetMapClipAreaCoords(MapCoreBase.GetCurrentMap,ca);
  if (ca.status=1) and (MapCoreBase.GetMapClipStatus(MapCoreBase.GetCurrentMap)=1) then
  begin
    active:=1;
    x1:=ca.x;
    x2:=ca.x2;
    y1:=ca.y;
    y2:=ca.y2;
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

//=============================================================================
// IMAGES
//=============================================================================

function rm_image_count : integer;
begin
  rm_image_count:=ImageThumbBase.GetCount;
end;

function rm_image_current : integer;
begin
  rm_image_current:=ImageThumbBase.GetCurrent;
end;

//Stores the core (image AND its undo) back to its slot and loads another -
//the same sequence as clicking a thumbnail. Pixel routines then act on the
//newly selected image. Screen refresh is the caller's job.
procedure rm_image_select(index : integer);
begin
  if (index < 0) or (index >= ImageThumbBase.GetCount) then
    raise Exception.Create('SETIMAGE: image '+IntToStr(index)+' does not exist - images are 0 to '+
                           IntToStr(ImageThumbBase.GetCount-1));
  if index = ImageThumbBase.GetCurrent then exit;
  ImageThumbBase.CopyCoreToIndexImage(ImageThumbBase.GetCurrent);
  ImageThumbBase.CopyIndexImageToCore(index);
  ImageThumbBase.SetCurrent(index);
  SetCoreActive;
end;

function rm_image_name(index : integer) : string;
begin
  if (index < 0) or (index >= ImageThumbBase.GetCount) then
    raise Exception.Create('GETIMAGENAME$: image '+IntToStr(index)+' does not exist');
  rm_image_name:=ImageThumbBase.GetExportName(index);
end;

//=============================================================================
// MAPS
//=============================================================================

function rm_map_count : integer;
begin
  rm_map_count:=MapCoreBase.GetMapCount;
end;

function rm_map_current : integer;
begin
  rm_map_current:=MapCoreBase.GetCurrentMap;
end;

function rm_map_width(map : integer) : integer;
begin
  CheckMap(map,'GETMAPWIDTH');
  rm_map_width:=MapCoreBase.GetMapWidth(map);
end;

function rm_map_height(map : integer) : integer;
begin
  CheckMap(map,'GETMAPHEIGHT');
  rm_map_height:=MapCoreBase.GetMapHeight(map);
end;

function rm_map_tilewidth(map : integer) : integer;
begin
  CheckMap(map,'GETTILEWIDTH');
  rm_map_tilewidth:=MapCoreBase.GetMapTileWidth(map);
end;

function rm_map_tileheight(map : integer) : integer;
begin
  CheckMap(map,'GETTILEHEIGHT');
  rm_map_tileheight:=MapCoreBase.GetMapTileHeight(map);
end;

function rm_map_layercount(map : integer) : integer;
begin
  CheckMap(map,'GETLAYERCOUNT');
  rm_map_layercount:=MapCoreBase.GetLayerCount(map);
end;

function rm_map_currentlayer(map : integer) : integer;
begin
  CheckMap(map,'GETLAYER');
  rm_map_currentlayer:=MapCoreBase.GetCurrentLayer(map);
end;

//The tile's image index; -1 for an empty cell.
function rm_map_gettile(map,layer,x,y : integer) : integer;
var
  T : TileRec;   //not Tile - that is the same name as the tile parameter
begin
  CheckLayer(map,layer,'GETTILE');
  CheckCell(map,x,y,'GETTILE');
  MapCoreBase.GetMapTileL(map,layer,x,y,T);
  rm_map_gettile:=T.ImageIndex;
end;

//tile = an image index, or -1 to clear the cell
procedure rm_map_settile(map,layer,x,y,tile : integer);
var
  T : TileRec;   //not Tile - that is the same name as the tile parameter
begin
  CheckLayer(map,layer,'SETTILE');
  CheckCell(map,x,y,'SETTILE');
  FillChar(T,sizeof(T),0);
  if tile = TileClear then
    T.ImageIndex:=TileClear          //empty cell - UID zeroed, not left stale
  else
  begin
    //checked here: GetUID used to be called with whatever number arrived
    if (tile < 0) or (tile >= ImageThumbBase.GetCount) then
      raise Exception.Create('SETTILE: tile '+IntToStr(tile)+' does not exist - tiles are 0 to '+
                             IntToStr(ImageThumbBase.GetCount-1)+', or -1 to clear');
    T.ImageIndex:=tile;
    T.ImageUID:=ImageThumbBase.GetUID(tile);
  end;
  MapCoreBase.SetMapTileL(map,layer,x,y,T);
end;

end.
