//=============================================================================
// CHANGE LOG (Claude edits - newest first)
//-----------------------------------------------------------------------------
// 2026-08-13  STALE FILES, NOT PATHS
//   * "Referenced files could not be found" turned out to be leftovers from
//     an earlier export into the same folder, NOT a path problem. Exporting
//     to a clean folder works with the paths exactly as written here.
//   * The separator is therefore still ONE forward slash, which is what the
//     TMX format specifies and what Tiled writes on every platform. Do not
//     double it: 'a//b.png' is not a valid relative path, and a loader
//     stricter than Tiled will reject the file - which defeats the whole
//     reason for exporting TMX.
//   * Two theories tried and discarded on the way, recorded so they are not
//     tried again: the separator itself, and the image folder sharing a name
//     with the tileset file. Neither was the cause.
//   * What DOES help is in place: every written image is checked to exist,
//     and the summary reports the folder and every file name, so where a
//     piece landed is answerable without hunting through Explorer.
//-----------------------------------------------------------------------------
// 2026-08-13  TSX OPENED IN TILED BUT SHOWED NOTHING
//   * A standalone .tsx now carries version="1.10" tiledversion="1.11.0" on
//     its <tileset>, which is what Tiled itself writes. Without them Tiled
//     could open the file and display an empty tileset with NO error message.
//     The embedded form still carries firstgid and no version, also matching
//     Tiled - those two attributes are mutually exclusive by role.
//-----------------------------------------------------------------------------
// 2026-08-13  TMX / TSX EXPORT (new unit)
//   * NOTE on clearing records: TmxResultRec and TmxOptionsRec contain
//     strings, so they are cleared with Default() rather than FillChar.
//     FillChar would zero the string reference pointers without releasing
//     them, leaking on every call. Only TTmxTileTable, which is plain data,
//     could safely take a FillChar - and it does not need one.
//   * Writes Tiled maps so RM data can be opened in Tiled and loaded by the
//     many existing TMX runtimes, instead of only by hand written readers.
//
//   * TWO TILESET SHAPES, chosen by TmxOptionsRec.Mode:
//       TmxModeAtlas      - one packed PNG, sliced by tilewidth/tileheight.
//                           THE DEFAULT. This is the shape every loader
//                           supports.
//       TmxModeCollection - one PNG per tile, each named by its own <tile>.
//                           Legal TMX, but several runtimes reject it
//                           (axmol has no support, FXGL divides by zero,
//                           libGDX ships a tool purely to pack it away), so
//                           it is offered as a fallback, not a default.
//
//   * TWO TILESET LOCATIONS, independent of the shape above:
//       embedded  - the <tileset> sits inside the .tmx
//       external  - it goes to a .tsx and the .tmx keeps a one line reference
//     External is the default when more than one map is written, because an
//     embedded collection duplicates two lines PER TILE into every .tmx.
//
//   * GID ALLOCATION. An RM tile is (ImageUID, ImageIndex), and one map can
//     reference several image lists, so tiles are gathered into one table and
//     numbered in first-seen order. GID 0 is reserved by TMX for "empty", so
//     the tileset takes firstgid 1.
//
//   * TileClear (-1) becomes GID 0. TileMissing (-2) ALSO becomes 0 but is
//     counted separately and reported: it means a tile referenced an image
//     that no longer exists, which is information worth surfacing rather
//     than silently flattening into "empty".
//
//   * Hit boxes and paths become an <objectgroup>. Their coordinates are
//     TILES in RM and PIXELS in TMX, and RM's x2,y2 are INCLUSIVE, so a box
//     is (x2-x+1)*tilewidth wide - not (x2-x)*tilewidth.
//
//   * Closed paths are written as <polygon>, open ones as <polyline>. Tiled
//     closes a polygon itself, so the last point must NOT be repeated.
//
//   * Layer data is CSV. Base64+zlib would need a compressor and buys
//     nothing at these map sizes, while CSV is read by every parser.
//
//   * The unit has no LCL dependency and does not touch pixels. The caller
//     supplies a TTileImageWriter callback to save one tile image, which is
//     what keeps this compilable and testable on its own the way mapcore and
//     rwmap are - the LCL side lives in the map editor.
//=============================================================================

unit rwtmx;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, mapcore;

const
  //TmxOptionsRec.Mode
  TmxModeAtlas      = 0;   //one packed image, sliced - the default
  TmxModeCollection = 1;   //one image per tile

  //TmxOptionsRec.Location
  TmxTilesetEmbedded = 0;
  TmxTilesetExternal = 1;  //separate .tsx

  //TmxWriteStatus
  TmxOK            = 0;
  TmxCreateFailed  = 1;   //could not open an output file
  TmxNoTiles       = 2;   //every cell was empty - nothing to build a tileset from
  TmxImageFailed   = 3;   //the caller's image writer reported a failure

  MaxTmxTiles = 4096;     //distinct (UID,index) pairs one export may reference

type
  //One distinct tile referenced by the maps being exported.
  TTmxTileRef = record
    UID        : TGUID;
    ImageIndex : integer;
    Width      : integer;   //source image size, needed by the collection form
    Height     : integer;
    Missing    : boolean;   //the image list no longer has this entry
  end;

  TTmxTileTable = record
    Count : integer;
    Tiles : array[0..MaxTmxTiles-1] of TTmxTileRef;
  end;

  //Saves ONE tile image, and reports the size it wrote.
  //
  //  Atlas mode      - called once per tile with the destination rectangle
  //                    inside the sheet (sx,sy), FileName is the sheet and is
  //                    the same for every call. Finish is true on the last
  //                    call, which is when the sheet should be flushed.
  //  Collection mode - called once per tile with sx,sy = 0 and its own
  //                    FileName.
  //
  //Returning false aborts the export with TmxImageFailed.
  TTileImageWriter = function(const FileName : string;
                              const UID : TGUID; ImageIndex : integer;
                              sx, sy : integer;
                              Finish : boolean) : boolean of object;

  TmxOptionsRec = record
    Mode        : integer;   //TmxModeAtlas / TmxModeCollection
    Location    : integer;   //TmxTilesetEmbedded / TmxTilesetExternal
    TilesetName : string;    //base name for the tileset, sheet and .tsx
    ImageFolder : string;    //sub folder for collection images, '' = alongside
    WriteObjects: boolean;   //emit hit boxes and paths as an <objectgroup>
    OnlyVisible : boolean;   //skip layers the editor has hidden
  end;

  //Filled in by the writer so the caller can report what happened.
  TmxResultRec = record
    Status       : integer;
    MapsWritten  : integer;
    TilesUsed    : integer;
    MissingTiles : integer;   //cells that pointed at a deleted image
    ObjectsOut   : integer;
    ImageFiles   : integer;
    TsxFile      : string;    //'' when embedded
    SheetFile    : string;    //'' unless atlas
    OutputDir    : string;    //where everything was written
    StaleFiles   : integer;   //leftovers from a previous, different export
    FirstMapFile : string;    //name of the first .tmx written
    ImageDir     : string;    //'' unless a collection sub folder was used
  end;

//Counts files in the target folder left by a PREVIOUS export of the other
//shape. They are not overwritten by this run, so they linger and point at a
//tileset that has since been rewritten - which surfaces in Tiled as
//"referenced files could not be found" in a folder that looks correct.
function TmxCountStaleFiles(const BaseFileName : string;
           const opt : TmxOptionsRec) : integer;

procedure TmxDefaultOptions(var opt : TmxOptionsRec);

//Gathers every distinct tile used by one map, or by all of them when
//index < 0. Pure inspection - nothing is written.
function TmxBuildTileTable(MC : TMapCoreBase; index : integer;
           var tbl : TTmxTileTable; var missing : integer) : boolean;

//The main entry point. BaseFileName is the .tmx path for a single map, or the
//stem that per map names are built from when index < 0.
function TmxExport(MC : TMapCoreBase; index : integer;
           const BaseFileName : string;
           const opt : TmxOptionsRec;
           ImageWriter : TTileImageWriter;
           var res : TmxResultRec) : boolean;

//Exposed for the caller's atlas allocation: an atlas holds Count tiles laid
//out left to right, wrapping at Columns.
procedure TmxAtlasLayout(Count, TileW, TileH : integer;
            var Columns, Rows, SheetW, SheetH : integer);

implementation

//XML text has five characters that must never appear raw. Map names and layer
//names come from the user, so an ampersand in one of them would otherwise
//produce a file Tiled refuses to parse.
function XmlEsc(const t : string) : string;
var
  i : integer;
  r : string;
begin
  r:='';
  for i:=1 to Length(t) do
    case t[i] of
      '&' : r:=r+'&amp;';
      '<' : r:=r+'&lt;';
      '>' : r:=r+'&gt;';
      '"' : r:=r+'&quot;';
      '''': r:=r+'&apos;';
    else
      //control bytes are not legal in XML 1.0 at all, not even escaped
      if t[i] >= ' ' then r:=r+t[i];
    end;
  XmlEsc:=r;
end;

//Tiled is happy with any name, but a name that has to survive being a file
//name as well needs to be tamer than that.
function SafeName(const t : string) : string;
var
  i : integer;
  r : string;
begin
  r:='';
  for i:=1 to Length(t) do
    if t[i] in ['A'..'Z','a'..'z','0'..'9','_','-'] then r:=r+t[i]
    else if t[i] = ' ' then r:=r+'_';
  if r = '' then r:='rm';
  SafeName:=r;
end;

function TmxCountStaleFiles(const BaseFileName : string;
           const opt : TmxOptionsRec) : integer;
var
  Dir, SheetPath, ImgDir : string;
  n : integer;
  sr : TSearchRec;
begin
  n:=0;
  Dir:=ExtractFilePath(BaseFileName);

  if opt.Mode = TmxModeAtlas then
  begin
    //about to write a sheet, so any collection images from last time are dead
    ImgDir:=Dir;
    if opt.ImageFolder <> '' then ImgDir:=Dir+opt.ImageFolder+PathDelim;
    if DirectoryExists(ImgDir) then
      if FindFirst(ImgDir+SafeName(opt.TilesetName)+'_*.png',faAnyFile,sr) = 0 then
      begin
        repeat inc(n) until FindNext(sr) <> 0;
        FindClose(sr);
      end;
  end
  else
  begin
    //about to write a collection, so last run's sheet is dead
    SheetPath:=Dir+SafeName(opt.TilesetName)+'.png';
    if FileExists(SheetPath) then inc(n);
  end;

  TmxCountStaleFiles:=n;
end;

procedure TmxDefaultOptions(var opt : TmxOptionsRec);
begin
  //atlas by default: it is the shape every runtime can read
  opt.Mode        := TmxModeAtlas;
  opt.Location    := TmxTilesetEmbedded;
  opt.TilesetName := 'tiles';
  //A sub folder for collection images. This keeps a few hundred tile PNGs
  //out of the map folder, and 'tiles' beside 'tiles.tsx' resolves correctly -
  //verified against Tiled 1.12.2 in a clean folder.
  opt.ImageFolder := 'tiles';
  opt.WriteObjects:= true;
  opt.OnlyVisible := false;
end;

procedure TmxAtlasLayout(Count, TileW, TileH : integer;
            var Columns, Rows, SheetW, SheetH : integer);
begin
  Columns:=0; Rows:=0; SheetW:=0; SheetH:=0;
  if Count < 1 then exit;

  //A roughly square sheet keeps the texture within the size limits older
  //hardware imposes, rather than one very long strip.
  Columns:=Trunc(Sqrt(Count));
  if Columns < 1 then Columns:=1;
  while Columns*Columns < Count do inc(Columns);

  Rows:=Count div Columns;
  if (Count mod Columns) <> 0 then inc(Rows);

  SheetW:=Columns*TileW;
  SheetH:=Rows*TileH;
end;

//---------------------------------------------------------------------------
// TILE TABLE
//
// A tile is identified by (UID,index), so a single map may pull from several
// image lists. They are gathered into one table and numbered in the order
// first seen, which keeps the numbering stable for a given map and makes the
// atlas layout reproducible.
//---------------------------------------------------------------------------
function FindTile(const tbl : TTmxTileTable; const UID : TGUID;
           ImageIndex : integer) : integer;
var
  i : integer;
begin
  FindTile:=-1;
  for i:=0 to tbl.Count-1 do
    if (tbl.Tiles[i].ImageIndex = ImageIndex) and
       IsEqualGUID(tbl.Tiles[i].UID,UID) then
    begin
      FindTile:=i;
      exit;
    end;
end;

function AddMapToTable(MC : TMapCoreBase; index : integer;
           var tbl : TTmxTileTable; var missing : integer) : boolean;
var
  l,x,y,ti : integer;
  T : TileRec;
begin
  //mapcore fills this through a var parameter, which the compiler cannot see
  //into. Default() rather than FillChar: FillChar takes the variable as an
  //untyped var parameter too, so it reads it and raises the same hint 5057.
  T:=Default(TileRec);
  AddMapToTable:=true;
  for l:=0 to MC.GetLayerCount(index)-1 do
    for y:=0 to MC.GetMapHeight(index)-1 do
      for x:=0 to MC.GetMapWidth(index)-1 do
      begin
        MC.GetMapTileL(index,l,x,y,T);

        if T.ImageIndex = TileClear then continue;

        //A missing tile is a dangling reference, not an empty cell. It still
        //exports as empty - there is no art to point at - but it is counted
        //so the caller can say so rather than quietly losing it.
        if T.ImageIndex = TileMissing then
        begin
          inc(missing);
          continue;
        end;

        if T.ImageIndex < 0 then continue;

        ti:=FindTile(tbl,T.ImageUID,T.ImageIndex);
        if ti >= 0 then continue;

        if tbl.Count >= MaxTmxTiles then
        begin
          AddMapToTable:=false;
          exit;
        end;

        tbl.Tiles[tbl.Count].UID       :=T.ImageUID;
        tbl.Tiles[tbl.Count].ImageIndex:=T.ImageIndex;
        tbl.Tiles[tbl.Count].Width     :=MC.GetMapTileWidth(index);
        tbl.Tiles[tbl.Count].Height    :=MC.GetMapTileHeight(index);
        tbl.Tiles[tbl.Count].Missing   :=false;
        inc(tbl.Count);
      end;
end;

function TmxBuildTileTable(MC : TMapCoreBase; index : integer;
           var tbl : TTmxTileTable; var missing : integer) : boolean;
var
  m : integer;
begin
  tbl.Count:=0;
  missing:=0;
  TmxBuildTileTable:=true;

  if index >= 0 then
    TmxBuildTileTable:=AddMapToTable(MC,index,tbl,missing)
  else
    for m:=0 to MC.GetMapCount-1 do
      if not AddMapToTable(MC,m,tbl,missing) then
      begin
        TmxBuildTileTable:=false;
        exit;
      end;
end;

//---------------------------------------------------------------------------
// TILESET
//---------------------------------------------------------------------------

//The image file for one tile in collection mode. Named from the UID as well
//as the index: indices shift when a user inserts an image, and a name built
//from the index alone would then point a previously exported map at the
//wrong art.
function CollectionTileFile(const opt : TmxOptionsRec;
           const tr : TTmxTileRef) : string;
var
  g : string;
begin
  g:=GUIDToString(tr.UID);
  //GUIDToString gives {xxxxxxxx-....}; the leading group is enough to tell
  //two image lists apart and keeps the file name short
  g:=Copy(g,2,8);
  CollectionTileFile:=Format('%s_%s_%3.3d.png',[SafeName(opt.TilesetName),g,tr.ImageIndex]);
end;

function CollectionTilePath(const opt : TmxOptionsRec;
           const tr : TTmxTileRef) : string;
begin
  if opt.ImageFolder = '' then
    //the common case now: a bare file name, no separator to resolve
    CollectionTilePath:=CollectionTileFile(opt,tr)
  else
    //A single forward slash is what the TMX format specifies and what Tiled
    //writes on every platform including Windows. Do NOT "fix" a path problem
    //by doubling it: 'a//b.png' is not a valid relative path, and a loader
    //that is stricter than Tiled will reject the file - which defeats the
    //whole reason for exporting TMX. If images are not being found, the
    //cause is where they were written, not the separator.
    CollectionTilePath:=opt.ImageFolder+'/'+CollectionTileFile(opt,tr);
end;

//Writes the <tileset> body. Used for both the embedded and the external form
//- the only difference is the opening tag, which the callers supply.
procedure WriteTilesetBody(var F : Text; const opt : TmxOptionsRec;
            const tbl : TTmxTileTable; TileW, TileH : integer;
            const SheetName : string; Indent : string);
var
  i,cols,rows,sw,sh : integer;
begin
  if opt.Mode = TmxModeAtlas then
  begin
    cols:=0; rows:=0; sw:=0; sh:=0;
    TmxAtlasLayout(tbl.Count,TileW,TileH,cols,rows,sw,sh);
    Writeln(F,Indent,' <image source="',XmlEsc(SheetName),'" width="',sw,
              '" height="',sh,'"/>');
  end
  else
  begin
    //columns="0" is how Tiled marks a collection, and tilewidth/tileheight on
    //the tileset become the MAXIMUM size rather than a slicing instruction
    Writeln(F,Indent,' <grid orientation="orthogonal" width="',TileW,
              '" height="',TileH,'"/>');
    for i:=0 to tbl.Count-1 do
    begin
      Writeln(F,Indent,' <tile id="',i,'">');
      Writeln(F,Indent,'  <image source="',XmlEsc(CollectionTilePath(opt,tbl.Tiles[i])),
                '" width="',tbl.Tiles[i].Width,'" height="',tbl.Tiles[i].Height,'"/>');
      Writeln(F,Indent,' </tile>');
    end;
  end;
end;

//WithFirstGid distinguishes the two places a tileset tag appears:
//  embedded in a .tmx - carries firstgid, no version attributes
//  standalone .tsx    - carries version/tiledversion, no firstgid
//A .tsx that Tiled itself writes always states its version, and without it
//Tiled can open the file and show an empty tileset with no error at all.
function TilesetOpenTag(const opt : TmxOptionsRec; const tbl : TTmxTileTable;
           TileW, TileH : integer; WithFirstGid : boolean) : string;
var
  cols,rows,sw,sh : integer;
  s : string;
begin
  cols:=0; rows:=0; sw:=0; sh:=0;
  if opt.Mode = TmxModeAtlas then
    TmxAtlasLayout(tbl.Count,TileW,TileH,cols,rows,sw,sh);
  //cols stays 0 for a collection, which is how Tiled marks one

  s:='<tileset';
  if WithFirstGid then
    s:=s+' firstgid="1"'
  else
    //standalone .tsx - state the format version, exactly as Tiled does
    s:=s+' version="1.10" tiledversion="1.11.0"';
  s:=s+' name="'+XmlEsc(opt.TilesetName)+'"'+
       ' tilewidth="'+IntToStr(TileW)+'"'+
       ' tileheight="'+IntToStr(TileH)+'"'+
       ' tilecount="'+IntToStr(tbl.Count)+'"'+
       ' columns="'+IntToStr(cols)+'"';
  TilesetOpenTag:=s+'>';
end;

function WriteTsx(const FileName : string; const opt : TmxOptionsRec;
           const tbl : TTmxTileTable; TileW, TileH : integer;
           const SheetName : string) : boolean;
var
  F : Text;
begin
  WriteTsx:=false;
  {$I-}
  System.Assign(F,FileName);
  Rewrite(F);
  {$I+}
  if IOResult <> 0 then exit;

  Writeln(F,'<?xml version="1.0" encoding="UTF-8"?>');
  //a .tsx carries no firstgid: that is a property of how a MAP uses the
  //tileset, not of the tileset, which is what lets two maps share one file
  Writeln(F,TilesetOpenTag(opt,tbl,TileW,TileH,false));
  WriteTilesetBody(F,opt,tbl,TileW,TileH,SheetName,'');
  Writeln(F,'</tileset>');

  {$I-}
  System.Close(F);
  {$I+}
  WriteTsx:=IOResult = 0;
end;

//---------------------------------------------------------------------------
// OBJECTS
//---------------------------------------------------------------------------
procedure WriteProperty(var F : Text; const nm, ty, val : string);
begin
  if ty = '' then
    Writeln(F,'    <property name="',XmlEsc(nm),'" value="',XmlEsc(val),'"/>')
  else
    Writeln(F,'    <property name="',XmlEsc(nm),'" type="',ty,
              '" value="',XmlEsc(val),'"/>');
end;

//Hit boxes and paths for one map. Returns how many objects were written.
function WriteObjectGroup(var F : Text; MC : TMapCoreBase; index : integer;
           LayerId : integer; var NextObjId : integer) : integer;
var
  h,p,pt,n,tw,th : integer;
  HB : HitBoxRec;
  PP : PathPointRec;
  ox,oy,px,py : integer;
  pts : string;
  count : integer;
begin
  //filled by mapcore through var parameters - see AddMapToTable
  HB:=Default(HitBoxRec);
  PP:=Default(PathPointRec);
  count:=0;
  tw:=MC.GetMapTileWidth(index);
  th:=MC.GetMapTileHeight(index);

  Writeln(F,' <objectgroup id="',LayerId,'" name="Objects">');

  //--- hit boxes -----------------------------------------------------------
  for h:=0 to MC.GetHitBoxCount(index)-1 do
  begin
    if not MC.IsValidHitBox(index,h) then continue;
    MC.GetHitBox(index,h,HB);
    if not HB.active then continue;

    //RM stores tiles and treats x2,y2 as INSIDE the box, so a one tile box
    //has x2=x. TMX wants pixels and an exclusive size, hence the +1.
    Writeln(F,'  <object id="',NextObjId,'" name="hitbox',h,'" type="hitbox"',
              ' x="',HB.x*tw,'" y="',HB.y*th,
              '" width="',(HB.x2-HB.x+1)*tw,'" height="',(HB.y2-HB.y+1)*th,'">');
    Writeln(F,'   <properties>');
    WriteProperty(F,'rm_id','int',IntToStr(HB.id));
    WriteProperty(F,'rm_value','int',IntToStr(HB.value));
    Writeln(F,'   </properties>');
    Writeln(F,'  </object>');
    inc(NextObjId);
    inc(count);
  end;

  //--- paths ---------------------------------------------------------------
  for p:=0 to MC.GetPathCount(index)-1 do
  begin
    if not MC.IsValidPath(index,p) then continue;
    //active, not visible: visibility is an editing aid and hiding a path to
    //draw underneath it must never drop it from an export
    if not MC.GetPathActive(index,p) then continue;

    n:=MC.GetPathPointCount(index,p);
    if n < 2 then continue;

    //polyline/polygon points are relative to the object's own x,y, so the
    //first waypoint becomes the origin and every point is offset from it
    MC.GetPathPoint(index,p,0,PP);
    ox:=PP.x*tw + tw div 2;    //centre of the tile, matching the runtime
    oy:=PP.y*th + th div 2;

    pts:='';
    for pt:=0 to n-1 do
    begin
      MC.GetPathPoint(index,p,pt,PP);
      px:=(PP.x*tw + tw div 2) - ox;
      py:=(PP.y*th + th div 2) - oy;
      if pts <> '' then pts:=pts+' ';
      pts:=pts+IntToStr(px)+','+IntToStr(py);
    end;

    Writeln(F,'  <object id="',NextObjId,'" name="',
              XmlEsc(MC.GetPathName(index,p)),'" type="path"',
              ' x="',ox,'" y="',oy,'">');
    Writeln(F,'   <properties>');
    WriteProperty(F,'rm_mode','int',IntToStr(MC.GetPathMode(index,p)));
    WriteProperty(F,'rm_closed','bool',BoolToStr(MC.GetPathClosed(index,p),'true','false'));
    Writeln(F,'   </properties>');

    //Tiled closes a polygon itself, so the first point must NOT be repeated
    //at the end - doing so would leave a zero length final segment
    if MC.GetPathClosed(index,p) then
      Writeln(F,'   <polygon points="',pts,'"/>')
    else
      Writeln(F,'   <polyline points="',pts,'"/>');

    Writeln(F,'  </object>');
    inc(NextObjId);
    inc(count);
  end;

  Writeln(F,' </objectgroup>');
  WriteObjectGroup:=count;
end;

//---------------------------------------------------------------------------
// MAP
//---------------------------------------------------------------------------
function WriteTmx(const FileName : string; MC : TMapCoreBase; index : integer;
           const opt : TmxOptionsRec; const tbl : TTmxTileTable;
           const TsxName, SheetName : string;
           var ObjectsOut : integer) : boolean;
var
  F : Text;
  l,x,y,w,h,tw,th : integer;
  T : TileRec;
  gid,ti : integer;
  LayerId, NextObjId, LayerCount : integer;
  sep : string;
begin
  T:=Default(TileRec);   //see AddMapToTable
  WriteTmx:=false;
  {$I-}
  System.Assign(F,FileName);
  Rewrite(F);
  {$I+}
  if IOResult <> 0 then exit;

  w :=MC.GetMapWidth(index);
  h :=MC.GetMapHeight(index);
  tw:=MC.GetMapTileWidth(index);
  th:=MC.GetMapTileHeight(index);

  LayerCount:=MC.GetLayerCount(index);
  //nextlayerid/nextobjectid must sit PAST everything used, or Tiled warns on
  //load and can hand out a duplicate id the next time the user adds one
  NextObjId:=1;

  Writeln(F,'<?xml version="1.0" encoding="UTF-8"?>');
  Write  (F,'<map version="1.10" tiledversion="1.11.0" orientation="orthogonal"');
  Write  (F,' renderorder="right-down" width="',w,'" height="',h,'"');
  Write  (F,' tilewidth="',tw,'" tileheight="',th,'" infinite="0"');
  Writeln(F,' nextlayerid="',LayerCount+2,'" nextobjectid="1">');

  //--- tileset -------------------------------------------------------------
  if opt.Location = TmxTilesetExternal then
    Writeln(F,' <tileset firstgid="1" source="',XmlEsc(TsxName),'"/>')
  else
  begin
    Writeln(F,' ',TilesetOpenTag(opt,tbl,tw,th,true));
    WriteTilesetBody(F,opt,tbl,tw,th,SheetName,' ');
    Writeln(F,' </tileset>');
  end;

  //--- tile layers ---------------------------------------------------------
  //document order is bottom to top in TMX, which matches RM's layer 0 being
  //the one drawn first
  for l:=0 to LayerCount-1 do
  begin
    if opt.OnlyVisible and (not MC.GetLayerVisible(index,l)) then continue;

    Write(F,' <layer id="',l+1,'" name="',XmlEsc(MC.GetLayerName(index,l)),'"');
    Write(F,' width="',w,'" height="',h,'"');
    if not MC.GetLayerVisible(index,l) then Write(F,' visible="0"');
    Writeln(F,'>');
    Writeln(F,'  <data encoding="csv">');

    for y:=0 to h-1 do
    begin
      for x:=0 to w-1 do
      begin
        MC.GetMapTileL(index,l,x,y,T);

        //GID 0 is TMX for "no tile". Both TileClear and TileMissing land
        //here: there is no art to point a missing one at.
        gid:=0;
        if T.ImageIndex >= 0 then
        begin
          ti:=FindTile(tbl,T.ImageUID,T.ImageIndex);
          if ti >= 0 then gid:=ti+1;   //+1 because firstgid is 1
        end;

        //no trailing comma on the very last cell of the layer
        if (x = w-1) and (y = h-1) then sep:='' else sep:=',';
        Write(F,gid,sep);
      end;
      Writeln(F);
    end;

    Writeln(F,'  </data>');
    Writeln(F,' </layer>');
  end;

  //--- objects -------------------------------------------------------------
  if opt.WriteObjects then
  begin
    LayerId:=LayerCount+1;
    ObjectsOut:=ObjectsOut + WriteObjectGroup(F,MC,index,LayerId,NextObjId);
  end;

  Writeln(F,'</map>');

  {$I-}
  System.Close(F);
  {$I+}
  WriteTmx:=IOResult = 0;
end;

//---------------------------------------------------------------------------
// ENTRY POINT
//---------------------------------------------------------------------------
function TmxExport(MC : TMapCoreBase; index : integer;
           const BaseFileName : string;
           const opt : TmxOptionsRec;
           ImageWriter : TTileImageWriter;
           var res : TmxResultRec) : boolean;
var
  tbl : TTmxTileTable;
  m,i,tw,th : integer;
  cols,rows,sw,sh : integer;
  Dir, Stem, TsxPath, TsxName, SheetName, SheetPath, MapPath : string;
  FirstMap, LastMap : integer;
  ImgDir : string;
begin
  TmxExport:=false;
  //Default(), NOT FillChar. TmxResultRec holds two strings, and FillChar
  //would overwrite their reference pointers without releasing them - a leak
  //on every call, and it also raises hint 5091 for the managed type.
  res:=Default(TmxResultRec);
  //TmxBuildTileTable sets Count itself, but the compiler only sees a var
  //parameter. Zero just the field that is read before it is written - the
  //4096 entry array behind it does not need clearing and Default() on the
  //whole record would blank it on every export.
  tbl.Count:=0;
  cols:=0; rows:=0; sw:=0; sh:=0;
  res.Status:=TmxOK;

  if index >= 0 then
  begin
    FirstMap:=index;
    LastMap :=index;
  end
  else
  begin
    FirstMap:=0;
    LastMap :=MC.GetMapCount-1;
  end;
  if LastMap < FirstMap then begin res.Status:=TmxNoTiles; exit; end;

  //the tile size comes from the first map exported; TMX allows one tile size
  //per map and the tileset has to agree with it
  tw:=MC.GetMapTileWidth(FirstMap);
  th:=MC.GetMapTileHeight(FirstMap);

  if not TmxBuildTileTable(MC,index,tbl,res.MissingTiles) then
  begin
    res.Status:=TmxNoTiles;
    exit;
  end;
  if tbl.Count = 0 then
  begin
    res.Status:=TmxNoTiles;
    exit;
  end;
  res.TilesUsed:=tbl.Count;

  Dir :=ExtractFilePath(BaseFileName);
  Stem:=ChangeFileExt(ExtractFileName(BaseFileName),'');

  //counted BEFORE anything is written, or this run's own output would show up
  res.StaleFiles:=TmxCountStaleFiles(BaseFileName,opt);
  if Stem = '' then Stem:='map';

  //--- images --------------------------------------------------------------
  SheetName:='';
  if opt.Mode = TmxModeAtlas then
  begin
    SheetName:=SafeName(opt.TilesetName)+'.png';
    SheetPath:=Dir+SheetName;
    cols:=0; rows:=0; sw:=0; sh:=0;
    TmxAtlasLayout(tbl.Count,tw,th,cols,rows,sw,sh);

    for i:=0 to tbl.Count-1 do
      if not ImageWriter(SheetPath,tbl.Tiles[i].UID,tbl.Tiles[i].ImageIndex,
                         (i mod cols)*tw,(i div cols)*th,i = tbl.Count-1) then
      begin
        res.Status:=TmxImageFailed;
        exit;
      end;

    //A writer that reports success but leaves no file on disk produces a
    //tileset full of red crosses and an unhelpful "file not found" from
    //Tiled. Catch it here, where we still know which file was meant.
    if not FileExists(SheetPath) then
    begin
      res.Status:=TmxImageFailed;
      exit;
    end;

    res.ImageFiles:=1;
    res.SheetFile :=SheetName;
  end
  else
  begin
    ImgDir:=Dir;
    if opt.ImageFolder <> '' then ImgDir:=Dir+opt.ImageFolder+PathDelim;
    if not DirectoryExists(ImgDir) then
      if not CreateDir(ImgDir) then
      begin
        res.Status:=TmxCreateFailed;
        exit;
      end;

    for i:=0 to tbl.Count-1 do
    begin
      if not ImageWriter(ImgDir+CollectionTileFile(opt,tbl.Tiles[i]),
                         tbl.Tiles[i].UID,tbl.Tiles[i].ImageIndex,
                         0,0,i = tbl.Count-1) then
      begin
        res.Status:=TmxImageFailed;
        exit;
      end;
      //see the note in the atlas branch - a silent no-op writer is the worst
      //case, because everything downstream looks correct
      if not FileExists(ImgDir+CollectionTileFile(opt,tbl.Tiles[i])) then
      begin
        res.Status:=TmxImageFailed;
        exit;
      end;
    end;
    res.ImageFiles:=tbl.Count;
    res.ImageDir  :=opt.ImageFolder;
  end;

  //--- tileset -------------------------------------------------------------
  TsxName:='';
  if opt.Location = TmxTilesetExternal then
  begin
    TsxName:=SafeName(opt.TilesetName)+'.tsx';
    TsxPath:=Dir+TsxName;
    if not WriteTsx(TsxPath,opt,tbl,tw,th,SheetName) then
    begin
      res.Status:=TmxCreateFailed;
      exit;
    end;
    res.TsxFile:=TsxName;
  end;

  //--- maps ----------------------------------------------------------------
  for m:=FirstMap to LastMap do
  begin
    if FirstMap = LastMap then
      MapPath:=Dir+Stem+'.tmx'
    else
      //one .tmx per map, numbered, all sharing the one tileset
      MapPath:=Dir+Format('%s_%2.2d.tmx',[Stem,m]);

    if not WriteTmx(MapPath,MC,m,opt,tbl,TsxName,SheetName,res.ObjectsOut) then
    begin
      res.Status:=TmxCreateFailed;
      exit;
    end;
    if res.FirstMapFile = '' then res.FirstMapFile:=ExtractFileName(MapPath);
    inc(res.MapsWritten);
  end;

  res.OutputDir:=Dir;

  TmxExport:=true;
end;

end.
