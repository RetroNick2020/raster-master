unit rwjson;

{ rwjson.pas - Save/Open Raster Master projects in JSON format.

  Performs the same functions as the binary project format in rmthumb.pas
  (OpenProject/SaveProject) but reads and writes JSON. The binary format is
  untouched - this is a separate, additional format.

  Public API:
    SaveProjectJSON(filename)             - write current project to JSON
    OpenProjectJSON(filename, insertmode) - read project from JSON;
                                            insertmode appends to the
                                            current project just like the
                                            binary loader

  Both functions return true on success, false on any error (missing file,
  bad JSON, wrong signature/version). On failure the current project data
  is left untouched as much as possible - validation happens before any
  data is modified.

  Notes on the format:
  - The undo image buffer is NOT stored (unlike the binary format). On
    load the undo image is initialized to a copy of the image itself.
  - Pixels are stored as an array of rows, each row an array of palette
    indices, which keeps the file human readable and diff friendly.
  - Image/tile/frame UIDs are stored as GUID strings so insert mode and
    tile verification keep working the same way as the binary format. }

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpjson, jsonparser,
  rmcore, rmtools, rmthumb, mapcore, animbase, rmcodegen, rwpng;

const
  //sprite-side compiler id for JSON - next free slot after QBJSLan=20
  //in the sprite export props combo (see rmexportprops.InitComboBoxes)
  JSONSpriteLan = 21;

  //JSON image types (EO.Image values for the JSON compiler target)
  JSONImageIndexed = 1;  //palette index colors + palette array
  JSONImageRGB     = 2;  //each pixel stored as [r,g,b]
  JSONImageRGBA    = 3;  //each pixel stored as [r,g,b,a] - alpha follows
                         //the PNG Transparent RGBA rules from File->Properties

function SaveProjectJSON(filename : string) : boolean;
function OpenProjectJSON(filename : string; insertmode : boolean) : boolean;

//single-item JSON exports - ImageType is one of the JSONImage* constants;
//PngRGBA supplies the transparency rules for the RGBA type
function ExportSpriteJSON(index : integer; filename : string;
  ImageType : integer; const PngRGBA : PngRGBASettingsRec) : boolean;
function ExportPaletteJSONFile(index : integer; filename : string) : boolean;

//JSON RES - exports every sprite whose export compiler is JSON (using each
//sprite's own image type setting), and every map/animation whose export
//compiler is JSON, into one combined JSON file
function ExportResJSON(filename : string; const PngRGBA : PngRGBASettingsRec) : boolean;

implementation

const
  RMJSONSignature = 'RMP';
  RMJSONVersion   = 4;   //kept in step with RMProjectVersion

{ ===== helpers ===== }

function GUIDToStr(const uid : TGUID) : string;
begin
  GUIDToStr:=GUIDToString(uid);
end;

function StrToGUIDSafe(const s : string) : TGUID;
var
  zero : TGUID;
begin
  FillChar(zero, sizeof(zero), 0);
  try
    StrToGUIDSafe:=StringToGUID(s);
  except
    StrToGUIDSafe:=zero;
  end;
end;

{ ===== image write ===== }

function ImageToJSON(index : integer) : TJSONObject;
var
  Obj, ExpObj, ClipObj, GridObj, ScrollObj : TJSONObject;
  PalArr, RowArr, PixArr, ColorArr : TJSONArray;
  i, j, w, h : integer;
  Props : ImageThumbPropsRec;
begin
  Props:=ImageThumbBase.ImageMain[index].Props;
  w:=Props.Width;
  h:=Props.Height;

  Obj:=TJSONObject.Create;
  Obj.Add('uid', GUIDToStr(Props.UID));
  Obj.Add('width', w);
  Obj.Add('height', h);
  Obj.Add('paletteMode', Props.PaletteMode);
  Obj.Add('colorCount', Props.ColorCount);
  Obj.Add('curColor', Props.CurColor);
  Obj.Add('curColor2', Props.CurColor2);
  Obj.Add('colorBox', Props.ColorBox);
  Obj.Add('drawTool', Props.DrawTool);

  ExpObj:=TJSONObject.Create;
  ExpObj.Add('name', Props.ExportFormat.Name);
  ExpObj.Add('lan', Props.ExportFormat.Lan);
  ExpObj.Add('image', Props.ExportFormat.Image);
  ExpObj.Add('mask', Props.ExportFormat.Mask);
  ExpObj.Add('palette', Props.ExportFormat.Palette);
  ExpObj.Add('width', Props.ExportFormat.Width);
  ExpObj.Add('height', Props.ExportFormat.Height);
  Obj.Add('exportFormat', ExpObj);

  ClipObj:=TJSONObject.Create;
  ClipObj.Add('x', Props.ClipArea.x);
  ClipObj.Add('y', Props.ClipArea.y);
  ClipObj.Add('x2', Props.ClipArea.x2);
  ClipObj.Add('y2', Props.ClipArea.y2);
  ClipObj.Add('status', Props.ClipArea.status);
  ClipObj.Add('sized', Props.ClipArea.sized);
  Obj.Add('clipArea', ClipObj);

  GridObj:=TJSONObject.Create;
  GridObj.Add('cellWidthMin', Props.GridArea.CellWidthMin);
  GridObj.Add('cellHeightMin', Props.GridArea.CellHeightMin);
  GridObj.Add('cellWidth', Props.GridArea.CellWidth);
  GridObj.Add('cellHeight', Props.GridArea.CellHeight);
  GridObj.Add('gridThickX', Props.GridArea.GridThickX);
  GridObj.Add('gridThickY', Props.GridArea.GridThickY);
  GridObj.Add('zoomMode', Props.GridArea.ZoomMode);
  GridObj.Add('zoomSize', Props.GridArea.ZoomSize);
  GridObj.Add('zoomMaxX', Props.GridArea.ZoomMaxX);
  GridObj.Add('zoomMaxY', Props.GridArea.ZoomMaxY);
  GridObj.Add('gridMode', Props.GridArea.GridMode);
  Obj.Add('gridArea', GridObj);

  ScrollObj:=TJSONObject.Create;
  ScrollObj.Add('horizPos', Props.ScrollPos.HorizPos);
  ScrollObj.Add('virtPos', Props.ScrollPos.VirtPos);
  Obj.Add('scrollPos', ScrollObj);

  //palette - all 256 entries as [r,g,b] triplets
  PalArr:=TJSONArray.Create;
  for i:=0 to 255 do
  begin
    ColorArr:=TJSONArray.Create;
    ColorArr.Add(Props.Palette[i].r);
    ColorArr.Add(Props.Palette[i].g);
    ColorArr.Add(Props.Palette[i].b);
    PalArr.Add(ColorArr);
  end;
  Obj.Add('palette', PalArr);

  //pixels - rows of palette indices
  PixArr:=TJSONArray.Create;
  for j:=0 to h-1 do
  begin
    RowArr:=TJSONArray.Create;
    for i:=0 to w-1 do
      RowArr.Add(ImageThumbBase.ImageMain[index].Image.Pixel[i,j]);
    PixArr.Add(RowArr);
  end;
  Obj.Add('pixels', PixArr);

  ImageToJSON:=Obj;
end;

{ ===== image read ===== }

procedure JSONToImage(Obj : TJSONObject; index : integer);
var
  ExpObj, ClipObj, GridObj, ScrollObj : TJSONObject;
  PalArr, RowArr, PixArr, ColorArr : TJSONArray;
  i, j, w, h : integer;
  Props : ImageThumbPropsRec;
begin
  FillChar(Props, sizeof(Props), 0);

  Props.UID:=StrToGUIDSafe(Obj.Get('uid', ''));
  w:=Obj.Get('width', 16);
  h:=Obj.Get('height', 16);
  Props.Width:=w;
  Props.Height:=h;
  Props.PaletteMode:=Obj.Get('paletteMode', 0);
  Props.ColorCount:=Obj.Get('colorCount', 16);
  Props.CurColor:=Obj.Get('curColor', 1);
  Props.CurColor2:=Obj.Get('curColor2', 0);
  Props.ColorBox:=Obj.Get('colorBox', 0);
  Props.DrawTool:=Obj.Get('drawTool', 0);

  ExpObj:=Obj.Get('exportFormat', TJSONObject(nil));
  if ExpObj <> nil then
  begin
    Props.ExportFormat.Name:=ExpObj.Get('name', '');
    Props.ExportFormat.Lan:=ExpObj.Get('lan', 0);
    Props.ExportFormat.Image:=ExpObj.Get('image', 0);
    Props.ExportFormat.Mask:=ExpObj.Get('mask', 0);
    Props.ExportFormat.Palette:=ExpObj.Get('palette', 0);
    Props.ExportFormat.Width:=ExpObj.Get('width', 0);
    Props.ExportFormat.Height:=ExpObj.Get('height', 0);
  end;

  ClipObj:=Obj.Get('clipArea', TJSONObject(nil));
  if ClipObj <> nil then
  begin
    Props.ClipArea.x:=ClipObj.Get('x', 0);
    Props.ClipArea.y:=ClipObj.Get('y', 0);
    Props.ClipArea.x2:=ClipObj.Get('x2', 0);
    Props.ClipArea.y2:=ClipObj.Get('y2', 0);
    Props.ClipArea.status:=ClipObj.Get('status', 0);
    Props.ClipArea.sized:=ClipObj.Get('sized', 0);
  end;

  GridObj:=Obj.Get('gridArea', TJSONObject(nil));
  if GridObj <> nil then
  begin
    Props.GridArea.CellWidthMin:=GridObj.Get('cellWidthMin', 0);
    Props.GridArea.CellHeightMin:=GridObj.Get('cellHeightMin', 0);
    Props.GridArea.CellWidth:=GridObj.Get('cellWidth', 0);
    Props.GridArea.CellHeight:=GridObj.Get('cellHeight', 0);
    Props.GridArea.GridThickX:=GridObj.Get('gridThickX', 0);
    Props.GridArea.GridThickY:=GridObj.Get('gridThickY', 0);
    Props.GridArea.ZoomMode:=GridObj.Get('zoomMode', 0);
    Props.GridArea.ZoomSize:=GridObj.Get('zoomSize', 0);
    Props.GridArea.ZoomMaxX:=GridObj.Get('zoomMaxX', 0);
    Props.GridArea.ZoomMaxY:=GridObj.Get('zoomMaxY', 0);
    Props.GridArea.GridMode:=GridObj.Get('gridMode', 0);
  end;

  ScrollObj:=Obj.Get('scrollPos', TJSONObject(nil));
  if ScrollObj <> nil then
  begin
    Props.ScrollPos.HorizPos:=ScrollObj.Get('horizPos', 0);
    Props.ScrollPos.VirtPos:=ScrollObj.Get('virtPos', 0);
  end;

  PalArr:=Obj.Get('palette', TJSONArray(nil));
  if PalArr <> nil then
  begin
    for i:=0 to 255 do
    begin
      if i < PalArr.Count then
      begin
        ColorArr:=TJSONArray(PalArr[i]);
        if ColorArr.Count >= 3 then
        begin
          Props.Palette[i].r:=ColorArr.Integers[0];
          Props.Palette[i].g:=ColorArr.Integers[1];
          Props.Palette[i].b:=ColorArr.Integers[2];
        end;
      end;
    end;
  end;

  //same sequence as the binary loader: size first, then props, then pixels
  ImageThumbBase.SetImageSize(index, w, h);
  ImageThumbBase.ImageMain[index].Props:=Props;

  PixArr:=Obj.Get('pixels', TJSONArray(nil));
  if PixArr <> nil then
  begin
    for j:=0 to h-1 do
    begin
      if j >= PixArr.Count then break;
      RowArr:=TJSONArray(PixArr[j]);
      for i:=0 to w-1 do
      begin
        if i >= RowArr.Count then break;
        ImageThumbBase.ImageMain[index].Image.Pixel[i,j]:=RowArr.Integers[i];
        //undo buffer not stored in JSON - init to the image itself
        ImageThumbBase.ImageMain[index].UndoImage.Pixel[i,j]:=RowArr.Integers[i];
      end;
    end;
  end;
end;

{ ===== map write ===== }

function MapToJSON(index : integer) : TJSONObject;
var
  Obj, PropsObj, ExpObj, ClipObj, ScrollObj, HBObj : TJSONObject;
  HBArr, TileIdxArr, TileUIDArr, RowArr, UIDRowArr : TJSONArray;
  MapProps : MapPropsRec;
  ExportProps : MapExportFormatRec;
  HB : HitBoxRec;
  T : TileRec;
  i, j, w, h, hbcount : integer;
begin
  MapCoreBase.GetMapProps(index, MapProps);
  MapCoreBase.GetMapExportProps(index, ExportProps);
  w:=MapProps.width;
  h:=MapProps.height;

  Obj:=TJSONObject.Create;

  PropsObj:=TJSONObject.Create;
  PropsObj.Add('width', MapProps.width);
  PropsObj.Add('height', MapProps.height);
  PropsObj.Add('tileWidth', MapProps.tilewidth);
  PropsObj.Add('tileHeight', MapProps.tileheight);
  PropsObj.Add('zoomTileWidth', MapProps.ZoomTilewidth);
  PropsObj.Add('zoomTileHeight', MapProps.ZoomTileheight);
  PropsObj.Add('zoomSize', MapProps.ZoomSize);
  PropsObj.Add('drawTool', MapProps.DrawTool);
  PropsObj.Add('tileMode', MapProps.TileMode);
  PropsObj.Add('gridStatus', MapProps.GridStatus);

  ClipObj:=TJSONObject.Create;
  ClipObj.Add('x', MapProps.ClipArea.x);
  ClipObj.Add('y', MapProps.ClipArea.y);
  ClipObj.Add('x2', MapProps.ClipArea.x2);
  ClipObj.Add('y2', MapProps.ClipArea.y2);
  ClipObj.Add('status', MapProps.ClipArea.status);
  PropsObj.Add('clipArea', ClipObj);

  ScrollObj:=TJSONObject.Create;
  ScrollObj.Add('horizPos', MapProps.ScrollPos.HorizPos);
  ScrollObj.Add('virtPos', MapProps.ScrollPos.VirtPos);
  PropsObj.Add('scrollPos', ScrollObj);

  Obj.Add('props', PropsObj);

  ExpObj:=TJSONObject.Create;
  ExpObj.Add('name', ExportProps.Name);
  ExpObj.Add('lan', ExportProps.Lan);
  ExpObj.Add('mapFormat', ExportProps.MapFormat);
  ExpObj.Add('width', ExportProps.Width);
  ExpObj.Add('height', ExportProps.Height);
  Obj.Add('exportProps', ExpObj);

  //hitboxes
  hbcount:=MapCoreBase.GetHitBoxCount(index);
  HBArr:=TJSONArray.Create;
  for i:=0 to hbcount-1 do
  begin
    MapCoreBase.GetHitBox(index, i, HB);
    HBObj:=TJSONObject.Create;
    HBObj.Add('active', HB.active);
    HBObj.Add('id', HB.id);
    HBObj.Add('value', HB.value);
    HBObj.Add('x', HB.x);
    HBObj.Add('y', HB.y);
    HBObj.Add('x2', HB.x2);
    HBObj.Add('y2', HB.y2);
    HBArr.Add(HBObj);
  end;
  Obj.Add('hitBoxes', HBArr);

  //tiles - two parallel row arrays: image indexes and uids
  TileIdxArr:=TJSONArray.Create;
  TileUIDArr:=TJSONArray.Create;
  for j:=0 to h-1 do
  begin
    RowArr:=TJSONArray.Create;
    UIDRowArr:=TJSONArray.Create;
    for i:=0 to w-1 do
    begin
      MapCoreBase.GetMapTile(index, i, j, T);
      RowArr.Add(T.ImageIndex);
      UIDRowArr.Add(GUIDToStr(T.ImageUID));
    end;
    TileIdxArr.Add(RowArr);
    TileUIDArr.Add(UIDRowArr);
  end;
  Obj.Add('tileIndexes', TileIdxArr);
  Obj.Add('tileUIDs', TileUIDArr);

  MapToJSON:=Obj;
end;

{ ===== map read ===== }

procedure JSONToMap(Obj : TJSONObject; index : integer);
var
  PropsObj, ExpObj, ClipObj, ScrollObj, HBObj : TJSONObject;
  HBArr, TileIdxArr, TileUIDArr, RowArr, UIDRowArr : TJSONArray;
  MapProps : MapPropsRec;
  ExportProps : MapExportFormatRec;
  HB : HitBoxRec;
  T : TileRec;
  i, j, w, h : integer;
begin
  FillChar(MapProps, sizeof(MapProps), 0);
  FillChar(ExportProps, sizeof(ExportProps), 0);

  PropsObj:=Obj.Get('props', TJSONObject(nil));
  if PropsObj <> nil then
  begin
    MapProps.width:=PropsObj.Get('width', 16);
    MapProps.height:=PropsObj.Get('height', 16);
    MapProps.tilewidth:=PropsObj.Get('tileWidth', 16);
    MapProps.tileheight:=PropsObj.Get('tileHeight', 16);
    MapProps.ZoomTilewidth:=PropsObj.Get('zoomTileWidth', 16);
    MapProps.ZoomTileheight:=PropsObj.Get('zoomTileHeight', 16);
    MapProps.ZoomSize:=PropsObj.Get('zoomSize', 1);
    MapProps.DrawTool:=PropsObj.Get('drawTool', 0);
    MapProps.TileMode:=PropsObj.Get('tileMode', 0);
    MapProps.GridStatus:=PropsObj.Get('gridStatus', 0);

    ClipObj:=PropsObj.Get('clipArea', TJSONObject(nil));
    if ClipObj <> nil then
    begin
      MapProps.ClipArea.x:=ClipObj.Get('x', 0);
      MapProps.ClipArea.y:=ClipObj.Get('y', 0);
      MapProps.ClipArea.x2:=ClipObj.Get('x2', 0);
      MapProps.ClipArea.y2:=ClipObj.Get('y2', 0);
      MapProps.ClipArea.status:=ClipObj.Get('status', 0);
    end;

    ScrollObj:=PropsObj.Get('scrollPos', TJSONObject(nil));
    if ScrollObj <> nil then
    begin
      MapProps.ScrollPos.HorizPos:=ScrollObj.Get('horizPos', 0);
      MapProps.ScrollPos.VirtPos:=ScrollObj.Get('virtPos', 0);
    end;
  end;

  ExpObj:=Obj.Get('exportProps', TJSONObject(nil));
  if ExpObj <> nil then
  begin
    ExportProps.Name:=ExpObj.Get('name', '');
    ExportProps.Lan:=ExpObj.Get('lan', 0);
    ExportProps.MapFormat:=ExpObj.Get('mapFormat', 0);
    ExportProps.Width:=ExpObj.Get('width', 0);
    ExportProps.Height:=ExpObj.Get('height', 0);
  end;

  w:=MapProps.width;
  h:=MapProps.height;

  //same sequence as the binary loader
  MapCoreBase.SetMapSize(index, w, h);
  MapCoreBase.SetMapProps(index, MapProps);
  MapCoreBase.SetMapExportProps(index, ExportProps);

  //hitboxes
  HBArr:=Obj.Get('hitBoxes', TJSONArray(nil));
  if HBArr <> nil then
  begin
    MapCoreBase.SetHitBoxCount(index, HBArr.Count);
    for i:=0 to HBArr.Count-1 do
    begin
      HBObj:=TJSONObject(HBArr[i]);
      FillChar(HB, sizeof(HB), 0);
      HB.active:=HBObj.Get('active', false);
      HB.id:=HBObj.Get('id', 0);
      HB.value:=HBObj.Get('value', 0);
      HB.x:=HBObj.Get('x', 0);
      HB.y:=HBObj.Get('y', 0);
      HB.x2:=HBObj.Get('x2', 0);
      HB.y2:=HBObj.Get('y2', 0);
      MapCoreBase.SetHitBox(index, i, HB);
    end;
  end
  else
    MapCoreBase.SetHitBoxCount(index, 0);

  //tiles
  TileIdxArr:=Obj.Get('tileIndexes', TJSONArray(nil));
  TileUIDArr:=Obj.Get('tileUIDs', TJSONArray(nil));
  if TileIdxArr <> nil then
  begin
    for j:=0 to h-1 do
    begin
      if j >= TileIdxArr.Count then break;
      RowArr:=TJSONArray(TileIdxArr[j]);
      UIDRowArr:=nil;
      if (TileUIDArr <> nil) and (j < TileUIDArr.Count) then
        UIDRowArr:=TJSONArray(TileUIDArr[j]);
      for i:=0 to w-1 do
      begin
        if i >= RowArr.Count then break;
        FillChar(T, sizeof(T), 0);
        T.ImageIndex:=RowArr.Integers[i];
        if (UIDRowArr <> nil) and (i < UIDRowArr.Count) then
          T.ImageUID:=StrToGUIDSafe(UIDRowArr.Strings[i]);
        MapCoreBase.SetMapTile(index, i, j, T);
      end;
    end;
  end;
end;

{ ===== animation write ===== }

function AnimationsToJSON : TJSONObject;
var
  Obj, AnimObj, ExpObj, FrameObj : TJSONObject;
  AnimArr, FrameArr : TJSONArray;
  i, j, fcount : integer;
begin
  Obj:=TJSONObject.Create;
  Obj.Add('currentAnimation', AnimateBase.Animations.CurrentAnimation);

  AnimArr:=TJSONArray.Create;
  for i:=0 to AnimateBase.Animations.AnimCount-1 do
  begin
    AnimObj:=TJSONObject.Create;

    ExpObj:=TJSONObject.Create;
    ExpObj.Add('name', AnimateBase.Animations.AnimationList[i].ExportFormat.Name);
    ExpObj.Add('lan', AnimateBase.Animations.AnimationList[i].ExportFormat.Lan);
    ExpObj.Add('animateFormat', AnimateBase.Animations.AnimationList[i].ExportFormat.AnimateFormat);
    AnimObj.Add('exportFormat', ExpObj);

    fcount:=AnimateBase.Animations.AnimationList[i].FrameCount;
    FrameArr:=TJSONArray.Create;
    for j:=0 to fcount-1 do
    begin
      FrameObj:=TJSONObject.Create;
      FrameObj.Add('imageIndex', AnimateBase.Animations.AnimationList[i].Frames[j].ImageIndex);
      FrameObj.Add('uid', GUIDToStr(AnimateBase.Animations.AnimationList[i].Frames[j].UID));
      FrameObj.Add('tagged', AnimateBase.Animations.AnimationList[i].Frames[j].Tagged);
      FrameArr.Add(FrameObj);
    end;
    AnimObj.Add('frames', FrameArr);
    AnimArr.Add(AnimObj);
  end;
  Obj.Add('list', AnimArr);

  AnimationsToJSON:=Obj;
end;

{ ===== animation read ===== }

procedure JSONToAnimations(Obj : TJSONObject; insertmode : boolean);
var
  AnimArr, FrameArr : TJSONArray;
  AnimObj, ExpObj, FrameObj : TJSONObject;
  i, j, target : integer;
begin
  AnimArr:=Obj.Get('list', TJSONArray(nil));
  if AnimArr = nil then exit;

  if not insertmode then
  begin
    AnimateBase.Animations.AnimCount:=AnimArr.Count;
    AnimateBase.Animations.CurrentAnimation:=Obj.Get('currentAnimation', 0);
  end;

  for i:=0 to AnimArr.Count-1 do
  begin
    if insertmode then
    begin
      AnimateBase.AddAnimation;
      target:=AnimateBase.Animations.AnimCount-1;
    end
    else
      target:=i;

    if target >= MaxAnimationList then break;

    AnimObj:=TJSONObject(AnimArr[i]);
    FillChar(AnimateBase.Animations.AnimationList[target], sizeof(FrameListRec), 0);

    ExpObj:=AnimObj.Get('exportFormat', TJSONObject(nil));
    if ExpObj <> nil then
    begin
      AnimateBase.Animations.AnimationList[target].ExportFormat.Name:=ExpObj.Get('name', '');
      AnimateBase.Animations.AnimationList[target].ExportFormat.Lan:=ExpObj.Get('lan', 0);
      AnimateBase.Animations.AnimationList[target].ExportFormat.AnimateFormat:=ExpObj.Get('animateFormat', 0);
    end;

    FrameArr:=AnimObj.Get('frames', TJSONArray(nil));
    if FrameArr <> nil then
    begin
      AnimateBase.Animations.AnimationList[target].FrameCount:=FrameArr.Count;
      for j:=0 to FrameArr.Count-1 do
      begin
        if j >= MaxFrameList then break;
        FrameObj:=TJSONObject(FrameArr[j]);
        AnimateBase.Animations.AnimationList[target].Frames[j].ImageIndex:=FrameObj.Get('imageIndex', 0);
        AnimateBase.Animations.AnimationList[target].Frames[j].UID:=StrToGUIDSafe(FrameObj.Get('uid', ''));
        AnimateBase.Animations.AnimationList[target].Frames[j].Tagged:=FrameObj.Get('tagged', false);
      end;
    end;
  end;
end;

{ ===== public API ===== }

function SaveProjectJSON(filename : string) : boolean;
var
  Root, AnimRoot : TJSONObject;
  ImgArr, MapArr : TJSONArray;
  i, count : integer;
  SL : TStringList;
begin
  SaveProjectJSON:=false;

  Root:=TJSONObject.Create;
  try
    try
      Root.Add('signature', RMJSONSignature);
      Root.Add('version', RMJSONVersion);

      count:=ImageThumbBase.GetCount;
      Root.Add('imageCount', count);
      Root.Add('mapCount', MapCoreBase.GetMapCount);
      Root.Add('animCount', AnimateBase.GetAnimationCount);

      //images
      ImgArr:=TJSONArray.Create;
      for i:=0 to count-1 do
        ImgArr.Add(ImageToJSON(i));
      Root.Add('images', ImgArr);

      //maps - always at least one, same as the binary format
      MapArr:=TJSONArray.Create;
      for i:=0 to MapCoreBase.GetMapCount-1 do
        MapArr.Add(MapToJSON(i));
      Root.Add('maps', MapArr);

      //animations
      AnimRoot:=AnimationsToJSON;
      Root.Add('animations', AnimRoot);

      SL:=TStringList.Create;
      try
        SL.Text:=Root.FormatJSON;
        SL.SaveToFile(filename);
      finally
        SL.Free;
      end;

      SaveProjectJSON:=true;
    except
      SaveProjectJSON:=false;
    end;
  finally
    Root.Free;
  end;
end;

function OpenProjectJSON(filename : string; insertmode : boolean) : boolean;
var
  Root : TJSONData;
  Obj, AnimObj : TJSONObject;
  ImgArr, MapArr : TJSONArray;
  SL : TStringList;
  i, count, mapcount : integer;
  indexOffset, ctcount, cmapcount : integer;
begin
  OpenProjectJSON:=false;
  if not FileExists(filename) then exit;

  Root:=nil;
  SL:=TStringList.Create;
  try
    try
      SL.LoadFromFile(filename);
      Root:=GetJSON(SL.Text);
    except
      exit;  //unreadable or invalid JSON
    end;

    if not (Root is TJSONObject) then exit;
    Obj:=TJSONObject(Root);

    //validate signature and version BEFORE touching any project data
    if Obj.Get('signature', '') <> RMJSONSignature then exit;
    if Obj.Get('version', 0) <> RMJSONVersion then exit;

    ImgArr:=Obj.Get('images', TJSONArray(nil));
    if ImgArr = nil then exit;

    try
      { ---- images - same sequence as the binary OpenProject ---- }
      count:=ImgArr.Count;
      indexOffset:=0;
      ctcount:=ImageThumbBase.ImageCount;
      ImageThumbBase.ImageCount:=count;

      if insertmode then
      begin
        indexOffset:=ctcount;
        inc(ImageThumbBase.ImageCount, ctcount);
      end;

      for i:=0 to count-1 do
        JSONToImage(TJSONObject(ImgArr[i]), i + indexOffset);

      { ---- maps - same sequence as ReadAllMapsF ---- }
      MapArr:=Obj.Get('maps', TJSONArray(nil));
      if MapArr <> nil then
      begin
        mapcount:=MapArr.Count;
        if insertmode then
        begin
          cmapcount:=MapCoreBase.GetMapCount;
          MapCoreBase.SetMapCount(cmapcount + mapcount);
        end
        else
        begin
          MapCoreBase.SetMapCount(mapcount);
          cmapcount:=0;
        end;

        for i:=0 to mapcount-1 do
          JSONToMap(TJSONObject(MapArr[i]), i + cmapcount);
      end;

      { ---- animations ---- }
      AnimObj:=Obj.Get('animations', TJSONObject(nil));
      if AnimObj <> nil then
        JSONToAnimations(AnimObj, insertmode);

      OpenProjectJSON:=true;
    except
      OpenProjectJSON:=false;
    end;
  finally
    if Root <> nil then Root.Free;
    SL.Free;
  end;
end;

{ ===== single sprite / palette / RES JSON exports ===== }

//computes the alpha value for one pixel using the same rules as the
//PNG Transparent RGBA export in rwpng.SavePNG
function PixelAlpha(colorIndex : integer; const cr : TRMColorRec;
  const PngRGBA : PngRGBASettingsRec) : integer;
begin
  PixelAlpha:=255;  //solid by default

  if (PngRGBA.UseColorIndex) and (PngRGBA.ColorIndex = colorIndex) then
    PixelAlpha:=0;

  if (PngRGBA.UseFuschia) and (cr.r = 255) and (cr.g = 0) and (cr.b = 255) then
    PixelAlpha:=0;

  if (PngRGBA.UseCustom) and (cr.r = PngRGBA.R) and (cr.g = PngRGBA.G) and (cr.b = PngRGBA.B) then
    PixelAlpha:=PngRGBA.A;
end;

//builds a JSON object for one sprite in the requested image type
function SpriteToExportJSON(index : integer; ImageType : integer;
  const PngRGBA : PngRGBASettingsRec) : TJSONObject;
var
  Obj : TJSONObject;
  PalArr, ColorArr, PixArr, RowArr, PixColorArr : TJSONArray;
  i, j, w, h, ccount, ci : integer;
  cr : TRMColorRec;
  exportname : string;
begin
  w:=ImageThumbBase.GetWidth(index);
  h:=ImageThumbBase.GetHeight(index);
  ccount:=ImageThumbBase.ImageMain[index].Props.ColorCount;
  exportname:=ImageThumbBase.ImageMain[index].Props.ExportFormat.Name;
  if exportname = '' then exportname:='sprite' + IntToStr(index);

  Obj:=TJSONObject.Create;
  Obj.Add('name', exportname);
  Obj.Add('width', w);
  Obj.Add('height', h);
  Obj.Add('paletteMode', ImageThumbBase.ImageMain[index].Props.PaletteMode);
  Obj.Add('colorCount', ccount);

  case ImageType of
    JSONImageRGB:  Obj.Add('format', 'rgb');
    JSONImageRGBA: Obj.Add('format', 'rgba');
  else
    Obj.Add('format', 'indexed');
  end;

  //palette as [r,g,b] triplets - included for all formats for reference
  PalArr:=TJSONArray.Create;
  for i:=0 to ccount-1 do
  begin
    ColorArr:=TJSONArray.Create;
    ColorArr.Add(ImageThumbBase.ImageMain[index].Props.Palette[i].r);
    ColorArr.Add(ImageThumbBase.ImageMain[index].Props.Palette[i].g);
    ColorArr.Add(ImageThumbBase.ImageMain[index].Props.Palette[i].b);
    PalArr.Add(ColorArr);
  end;
  Obj.Add('palette', PalArr);

  //pixels - rows; cell contents depend on the image type
  PixArr:=TJSONArray.Create;
  for j:=0 to h-1 do
  begin
    RowArr:=TJSONArray.Create;
    for i:=0 to w-1 do
    begin
      ci:=ImageThumbBase.ImageMain[index].Image.Pixel[i,j];

      case ImageType of
        JSONImageRGB:
        begin
          cr:=ImageThumbBase.ImageMain[index].Props.Palette[ci and 255];
          PixColorArr:=TJSONArray.Create;
          PixColorArr.Add(cr.r);
          PixColorArr.Add(cr.g);
          PixColorArr.Add(cr.b);
          RowArr.Add(PixColorArr);
        end;

        JSONImageRGBA:
        begin
          cr:=ImageThumbBase.ImageMain[index].Props.Palette[ci and 255];
          PixColorArr:=TJSONArray.Create;
          PixColorArr.Add(cr.r);
          PixColorArr.Add(cr.g);
          PixColorArr.Add(cr.b);
          PixColorArr.Add(PixelAlpha(ci, cr, PngRGBA));
          RowArr.Add(PixColorArr);
        end;

      else //JSONImageIndexed and anything unrecognized
        RowArr.Add(ci);
      end;
    end;
    PixArr.Add(RowArr);
  end;
  Obj.Add('pixels', PixArr);

  SpriteToExportJSON:=Obj;
end;

function ExportSpriteJSON(index : integer; filename : string;
  ImageType : integer; const PngRGBA : PngRGBASettingsRec) : boolean;
var
  Obj : TJSONObject;
  SL : TStringList;
begin
  ExportSpriteJSON:=false;
  if (index < 0) or (index >= ImageThumbBase.GetCount) then exit;

  Obj:=SpriteToExportJSON(index, ImageType, PngRGBA);
  try
    try
      SL:=TStringList.Create;
      try
        SL.Text:=Obj.FormatJSON;
        SL.SaveToFile(filename);
      finally
        SL.Free;
      end;
      ExportSpriteJSON:=true;
    except
      ExportSpriteJSON:=false;
    end;
  finally
    Obj.Free;
  end;
end;

function ExportPaletteJSONFile(index : integer; filename : string) : boolean;
var
  Obj : TJSONObject;
  PalArr, ColorArr : TJSONArray;
  i, ccount : integer;
  exportname : string;
  SL : TStringList;
begin
  ExportPaletteJSONFile:=false;
  if (index < 0) or (index >= ImageThumbBase.GetCount) then exit;

  ccount:=ImageThumbBase.ImageMain[index].Props.ColorCount;
  exportname:=ImageThumbBase.ImageMain[index].Props.ExportFormat.Name;
  if exportname = '' then exportname:='palette' + IntToStr(index);

  Obj:=TJSONObject.Create;
  try
    try
      Obj.Add('name', exportname);
      Obj.Add('colorCount', ccount);
      PalArr:=TJSONArray.Create;
      for i:=0 to ccount-1 do
      begin
        ColorArr:=TJSONArray.Create;
        ColorArr.Add(ImageThumbBase.ImageMain[index].Props.Palette[i].r);
        ColorArr.Add(ImageThumbBase.ImageMain[index].Props.Palette[i].g);
        ColorArr.Add(ImageThumbBase.ImageMain[index].Props.Palette[i].b);
        PalArr.Add(ColorArr);
      end;
      Obj.Add('colors', PalArr);

      SL:=TStringList.Create;
      try
        SL.Text:=Obj.FormatJSON;
        SL.SaveToFile(filename);
      finally
        SL.Free;
      end;
      ExportPaletteJSONFile:=true;
    except
      ExportPaletteJSONFile:=false;
    end;
  finally
    Obj.Free;
  end;
end;

//builds a JSON object for one map - same content as the map editor's
//JSON export: dims, tile size, tile index rows, hitboxes
function MapToExportJSON(index : integer) : TJSONObject;
var
  Obj, HBObj : TJSONObject;
  TileArr, RowArr, HBArr : TJSONArray;
  MapProps : MapPropsRec;
  ExportProps : MapExportFormatRec;
  T : TileRec;
  HB : HitBoxRec;
  i, j, w, h, hbcount : integer;
  exportname : string;
begin
  MapCoreBase.GetMapProps(index, MapProps);
  MapCoreBase.GetMapExportProps(index, ExportProps);
  w:=MapProps.width;
  h:=MapProps.height;
  exportname:=ExportProps.Name;
  if exportname = '' then exportname:='map' + IntToStr(index);

  Obj:=TJSONObject.Create;
  Obj.Add('name', exportname);
  Obj.Add('width', w);
  Obj.Add('height', h);
  Obj.Add('tileWidth', MapProps.tilewidth);
  Obj.Add('tileHeight', MapProps.tileheight);

  TileArr:=TJSONArray.Create;
  for j:=0 to h-1 do
  begin
    RowArr:=TJSONArray.Create;
    for i:=0 to w-1 do
    begin
      MapCoreBase.GetMapTile(index, i, j, T);
      RowArr.Add(T.ImageIndex);
    end;
    TileArr.Add(RowArr);
  end;
  Obj.Add('tiles', TileArr);

  hbcount:=MapCoreBase.GetHitBoxCount(index);
  HBArr:=TJSONArray.Create;
  for i:=0 to hbcount-1 do
  begin
    MapCoreBase.GetHitBox(index, i, HB);
    HBObj:=TJSONObject.Create;
    HBObj.Add('id', HB.id);
    HBObj.Add('value', HB.value);
    HBObj.Add('x', HB.x);
    HBObj.Add('y', HB.y);
    HBObj.Add('x2', HB.x2);
    HBObj.Add('y2', HB.y2);
    HBArr.Add(HBObj);
  end;
  Obj.Add('hitBoxes', HBArr);

  MapToExportJSON:=Obj;
end;

function ExportResJSON(filename : string; const PngRGBA : PngRGBASettingsRec) : boolean;
var
  Root, AnimObj : TJSONObject;
  SpriteArr, MapArr, AnimArr, FrameArr : TJSONArray;
  i, j, fcount, imgtype : integer;
  MapExport : MapExportFormatRec;
  AnimExport : AnimExportFormatRec;
  exportname : string;
  SL : TStringList;
begin
  ExportResJSON:=false;

  Root:=TJSONObject.Create;
  try
    try
      Root.Add('signature', 'RESJ');
      Root.Add('version', 1);

      //sprites whose export compiler is JSON - each sprite exports in
      //its own image type from its export properties
      SpriteArr:=TJSONArray.Create;
      for i:=0 to ImageThumbBase.GetCount-1 do
      begin
        if ImageThumbBase.ImageMain[i].Props.ExportFormat.Lan = JSONSpriteLan then
        begin
          imgtype:=ImageThumbBase.ImageMain[i].Props.ExportFormat.Image;
          if imgtype = 0 then imgtype:=JSONImageIndexed;
          SpriteArr.Add(SpriteToExportJSON(i, imgtype, PngRGBA));
        end;
      end;
      Root.Add('sprites', SpriteArr);

      //maps whose export compiler is JSON
      MapArr:=TJSONArray.Create;
      for i:=0 to MapCoreBase.GetMapCount-1 do
      begin
        MapCoreBase.GetMapExportProps(i, MapExport);
        if MapExport.Lan = JSONLan then
          MapArr.Add(MapToExportJSON(i));
      end;
      Root.Add('maps', MapArr);

      //animations whose export compiler is JSON
      AnimArr:=TJSONArray.Create;
      for i:=0 to AnimateBase.GetAnimationCount-1 do
      begin
        AnimateBase.GetAnimExportProps(i, AnimExport);
        if AnimExport.Lan = JSONLan then
        begin
          exportname:=AnimExport.Name;
          if exportname = '' then exportname:='anim' + IntToStr(i);
          fcount:=AnimateBase.GetFrameCount(i);

          AnimObj:=TJSONObject.Create;
          AnimObj.Add('name', exportname);
          AnimObj.Add('frameCount', fcount);
          FrameArr:=TJSONArray.Create;
          for j:=0 to fcount-1 do
            FrameArr.Add(AnimateBase.GetImageIndex(i, j));
          AnimObj.Add('frames', FrameArr);
          AnimArr.Add(AnimObj);
        end;
      end;
      Root.Add('animations', AnimArr);

      SL:=TStringList.Create;
      try
        SL.Text:=Root.FormatJSON;
        SL.SaveToFile(filename);
      finally
        SL.Free;
      end;
      ExportResJSON:=true;
    except
      ExportResJSON:=false;
    end;
  finally
    Root.Free;
  end;
end;

end.
