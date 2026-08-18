//=============================================================================
// CHANGE LOG (Claude edits - newest first)
//-----------------------------------------------------------------------------
// 2026-08-03  MAP LAYERS - phase 3 (project file)
//   * RMProjectVersion 4 -> 5. BREAKING. The project file embeds maps via
//     ReadAllMapsF/WriteAllMapsF, and both MapPropsRec and the tile stream
//     changed shape for layers, so the project version had to move with the
//     map version.
//   * LoadProject now records why a load failed in LastProjectReadStatus.
//     It used to fall through silently on a version mismatch, which with
//     this break would mean every existing project opening to no message.
//=============================================================================

Unit rmthumb;

Interface
  uses rmcore,rmtools,graphics,controls,types,dialogs,sysutils,mapcore,rwmap,animbase;

Const
  RMProjectSig = 'RMP';
  //v7 = sprite hit boxes. v6 = map paths. v5 = map layers.
  //BREAKING at each step - older project files cannot be loaded.
  RMProjectVersion = 7;

  //LastProjectReadStatus values
  ProjectReadOK         = 0;
  ProjectReadBadSig     = 1;  //not a Raster Master project file
  ProjectReadOldVersion = 2;  //older build - cannot be loaded
  ProjectReadNewVersion = 3;  //newer build - cannot be loaded

type
 ImageThumbRec = Record
             Pixel : array of array of integer;
           end;

 ImageExportFormatRec = Packed Record
             Name            : String[20]; // user = RES file used in name/description, in Text output used in array name, for palettes we add pal to name
             Lan             : integer; // auto -ahould be for what compiler eg TPLan
             Image           : integer; // user - 0 = do not export, Image Format, 1 = PutImage format for most compiler
             Mask            : integer; // user - 0 = do not export, 1 = Inverse mode - all black become white, all other colors become black
             Palette         : integer; // user - 0 = do not export, 1 = EGA Index, 2 VGA, 3 Amiga RGB - will determine from palette mode in RM
             Width           : integer; // width overwrite - if not 0 use this value as width
             Height          : integer; // height overwrite - if not 0 use this value as height
 end;

 ImageThumbPropsRec = Packed Record
             UID         : TGUID;
             ExportFormat: ImageExportFormatRec;
             Palette     : TRMPaletteBuf;
             PaletteMode : Integer;
             ColorCount  : Integer;

             Width       : Integer;
             Height      : Integer;
             CurColor    : Integer;
             CurColor2   : integer;
             ColorBox    : Integer;
             DrawTool    : integer;
             ClipArea    : TClipAreaRec;
             GridArea    : TGridAreaRec;
             ScrollPos   : TScrollPosRec;

             //Sprite hit boxes. The record type is shared with the map editor
             //(mapcore), but the COORDINATE SPACE IS DIFFERENT: map hit boxes
             //are in tiles, sprite hit boxes are in PIXELS. Anything reading
             //the exported data needs to know which it is looking at.
             //
             //This rides inside the props record, which WriteImageToProject
             //writes wholesale, so it saves and loads with no extra IO code.
             HitBoxProps : HitBoxesRec;
 end;



 ImageThumbMainRec = Record
                        UndoImage   : ImageThumbRec;
                        Image       : ImageThumbRec;
                        Props       : ImageThumbPropsRec;
                      end;

 ProjectHeaderRec = Packed Record
                        SIG : array[1..3] of char;
                        version : word;
                        ImageCount : word;
                        MapCount   : word;
                        AnimCount  : word;   //try and future proof changing project file
                        Future2    : word;
                        Future3    : word;
 end;

 TImageThumb = Class
             ImageMain        : array of ImageThumbMainRec;
             ImageCount      : integer;
             ImageBufPtr     : ^TRMImageBuf;
             LastPicked      : integer;
             Current         : integer; //image that is being edited
             UndoImageBufPtr : ^TRMImageBuf;


             constructor Create;
             procedure SetListSize(size : integer);
             procedure SetImageSize(index,width,height : integer);
             procedure SetLastPicked(index : integer);
             function GetLastPicked : integer;

             procedure SetCurrent(index : integer);
             function GetCurrent : integer;

             procedure InsertImage(index : integer);
             procedure DeleteImage(index : integer);
             procedure AddImage;  //adds image to end of list

             procedure AddImportImage(width,height : integer);
             procedure CreateNewImageProperties(index,width,height : integer);


             function GetCount : integer;
             procedure SetCount(count : integer);

             function FindUID(uid : TGUID) : integer;
             function GetUID(index : integer) : TGUID;
             function GetExportPaletteCount : integer;
             function GetExportImageCount : integer;
             //How many sprites contribute a hit box resource. Must agree with
             //the RES header and data passes, or the header is the wrong size
             //and every offset in the file is shifted.
             function GetExportHitBoxCount : integer;
             function GetExportMaskCount : integer;

             function GetPixelTColor(index,x,y : integer) : TColor;
             //emulate BGI functions needed elseware
             function GetPixel(index,x,y : integer) : integer;
             procedure PutPixel(index,x,y,color : integer);

             function GetMaxColor(index : integer) : integer;

             procedure GetColor(index : integer;colorIndex : integer; var cr : TRMColorRec);
             procedure SetColor(index : integer;colorIndex : integer; var cr : TRMColorRec);

             procedure SetPalette(index : integer; P : TRMPaletteBuf);
             procedure SetPaletteMode(index, mode : integer);
             function GetPaletteMode(index : integer ) : integer;
             procedure SetColorCount(index,colorcount : integer);


             //--- sprite hit boxes (coordinates are PIXELS) ---------------
             //Deliberately mirrors the mapcore API so the editor side can be
             //ported across with the same call shapes.
             function  GetHitBoxCount(index : integer) : integer;
             procedure SetHitBoxCount(index,count : integer);
             procedure GetHitBox(index,hbindex : integer;var HB : HitBoxRec);
             procedure SetHitBox(index,hbindex : integer;var HB : HitBoxRec);
             procedure AddHitBox(index,x,y,x2,y2 : integer);
             procedure DeleteHitBox(index,hb : integer);
             procedure ClearHitBoxes(index : integer);
             function  IsValidHitBox(index,hb : integer) : boolean;
             procedure MoveHitBox(index,hb,dx,dy : integer);
             function  HitBoxHitTest(index,px,py : integer) : integer;
             procedure ClampHitBoxes(index : integer);
             //Used by Clone. NOT part of AddImage: a brand new image must
             //start with no hit boxes, only a cloned one inherits them.
             procedure CopyHitBoxes(destindex,srcindex : integer);

             function GetWidth(index : integer) : integer;
             function GetHeight(index : integer) : integer;

             function GetExportWidth(index : integer) : integer;
             function GetExportHeight(index : integer) : integer;

             function GetExportName(index : integer) : string;

             procedure MakeThumbImage(index : integer;var imglist : TImageList;action : integer);
             procedure MakeThumbImageFromCore(index : integer;var imglist : TImageList;action : integer);

             procedure CopyCoreToIndexImage(index : integer);  //copy contents of core image and undo to index location
             procedure CopyIndexImageToCore(index : integer); //copy index image and undo to core

             procedure OpenProject(filename : string;insertmode : boolean);
             procedure SaveProject(filename : string);
             procedure WriteImageToProject(Var F : File;Index : integer);
             procedure ReadImageFromProject(Var F : File; index : integer);

             procedure UpdateAllThumbImages(var imglist : TImageList);

             procedure GetExportOptions(index : integer;var EO : ImageExportFormatRec);
             procedure SetExportOptions(index : integer; EO :ImageExportFormatRec);
           end;
Const
  MaxThumbImages = 2000;

var
 ImageThumbBase  : TImageThumb;

 //Set by LoadProject. The UI checks this to explain a failed load.
 LastProjectReadStatus : integer = ProjectReadOK;

Implementation

constructor TImageThumb.Create;
begin
 SetlistSize(MaxThumbImages);
 ImageCount:=0;

 SetLastPicked(-1); //nothing selected
 SetCurrent(-1);
 ImageBufPtr:=RMCoreBase.GetImageBufPtr;
 UndoImageBufPtr:=RMCoreBase.GetUndoImageBufPtr;
end;

procedure TImageThumb.SetListSize(size : integer);
begin
 Setlength(ImageMain,size);
end;

procedure TImageThumb.SetLastPicked(index : integer);
begin
 LastPicked:=index;
end;

function TImageThumb.GetCurrent :  integer;
begin
 GetCurrent:=Current;
end;

procedure TImageThumb.SetCurrent(index : integer);
begin
 Current:=index;
end;

function TImageThumb.GetLastPicked :  integer;
begin
 GetLastPicked:=LastPicked;
end;

procedure TImageThumb.SetImageSize(index,width,height : integer);
begin
 Setlength(ImageMain[index].Image.Pixel,width,height);
 Setlength(ImageMain[index].UndoImage.Pixel,width,height);
 ImageMain[index].Props.width:=width;
 ImageMain[index].Props.height:=height;
end;

procedure TImageThumb.InsertImage(index : integer);
var
 i : integer;
begin
 if (index < 0) OR (index > (ImageCount-1)) then exit;
 inc(ImageCount);
 for i:=ImageCount-1 downto index+1 do
 begin
    ImageMain[i]:=ImageMain[i-1];
 end;
 CopyCoreToIndexImage(index);
end;

procedure TImageThumb.DeleteImage(index : integer);
var
 i : integer;
begin
 if (index < 0)  then exit;
 for i:=index to ImageCount-2  do
 begin
   ImageMain[i]:=ImageMain[i+1];
 end;
 SetImageSize(ImageCount-1,0,0);
 dec(ImageCount);
end;

function TImageThumb.GetUID(index : integer) : TGUID;
begin
  GetUID:=ImageMain[index].Props.UID;
end;

function TImageThumb.FindUID(uid : TGUID) : integer;
var
 i : integer;
begin
 FindUID:=-1;
 for i:=0 to GetCount -1 do
 begin
   if IsEqualGUID(uid,ImageMain[i].Props.UID) then
   begin
      FindUID:=i;
      exit;
   end;
 end;
end;

procedure TImageThumb.AddImage;  //adds image to end of list
begin
 if ImageCount >= MaxThumbImages then exit;
 inc(ImageCount);
 CopyCoreToIndexImage(ImageCount-1);
 if ImageCount = 1 then
 begin
   fillchar(ImageMain[0].Props.ExportFormat,sizeof(ImageMain[0].Props.ExportFormat),0);
   ImageMain[0].Props.ExportFormat.Name:='Image1';
   CreateGUID(ImageMain[0].Props.UID);
 end
 else if ImageCount > 1 then
 begin
    //copy the Export props from the first thum image
    ImageMain[ImageCount-1].Props.ExportFormat:=ImageMain[0].Props.ExportFormat;
    ImageMain[ImageCount-1].Props.ExportFormat.Name:='Image'+IntToStr(ImageCount);
    CreateGUID(ImageMain[ImageCount-1].Props.UID);

//    ImageMain[ImageCount-1].Props.ExportFormat.Width:=0;
//    ImageMain[ImageCount-1].Props.ExportFormat.Height:=0;
 end;
end;

procedure TImageThumb.SetPalette(index : integer;P : TRMPaletteBuf);
begin
  ImageMain[index].Props.Palette:=P;
end;

procedure TImageThumb.SetPaletteMode(index,mode : integer);
begin
  ImageMain[index].Props.PaletteMode:=mode;
end;

function TImageThumb.GetPaletteMode(index : integer ) : integer;
begin
  GetPaletteMode:=ImageMain[index].Props.PaletteMode;
end;

procedure TImageThumb.SetColorCount(index,colorcount : integer);
begin
  ImageMain[index].Props.ColorCount:=colorcount;
end;

procedure TImageThumb.CreateNewImageProperties(index,width,height : integer);
var
 i,j : integer;
begin
//  width:=RMCoreBase.GetWidth;
//  height:=RMCoreBase.GetHeight;
  SetImageSize(index,width,height);
  for j:=0 to height-1 do
  begin
     for i:=0 to width-1 do
     begin
        ImageMain[index].Image.Pixel[i,j]:=0;
        ImageMain[index].UndoImage.Pixel[i,j]:=0;
     end;
  end;
  ImageMain[index].Props.Palette:=VGADefault256;
  ImageMain[index].Props.PaletteMode:=PaletteModeVGA;
  ImageMain[index].Props.ColorCount:= 16;
  ImageMain[index].Props.CurColor:=1;  //blue in ega/vga mode
  ImageMain[index].Props.CurColor2:=1;

  ImageMain[index].Props.ColorBox:=1;  //selected ColorBox

  ImageMain[index].Props.DrawTool:=DrawShapePencil;

  ImageMain[index].Props.ClipArea.status:=0;
  ImageMain[index].Props.ClipArea.sized:=0;
//Todo - create a default setting for GridArea  ImageMain[index].Props.GridArea.;
  RMDrawTools.GetGridArea(ImageMain[index].Props.GridArea);
  ImageMain[index].Props.ScrollPos.HorizPos:=0;
  ImageMain[index].Props.ScrollPos.VirtPos:=0;

end;


procedure TImageThumb.AddImportImage(width,height : integer);  //similar to AddImage but a little different
begin                                  //used for adding images from Sprite Import Utility
                                       //instead of copying current image properties - we create the properties
 if ImageCount >= MaxThumbImages then exit;
 inc(ImageCount);
// CopyCoreToIndexImage(ImageCount-1);
   CreateNewImageProperties(ImageCount-1,width,height);

 if ImageCount = 1 then
 begin
   fillchar(ImageMain[0].Props.ExportFormat,sizeof(ImageMain[0].Props.ExportFormat),0);
   ImageMain[0].Props.ExportFormat.Name:='Image1';
   CreateGUID(ImageMain[0].Props.UID);
 end
 else if ImageCount > 1 then
 begin
    //copy the Export props from the first thum image
    ImageMain[ImageCount-1].Props.ExportFormat:=ImageMain[0].Props.ExportFormat;
    ImageMain[ImageCount-1].Props.ExportFormat.Name:='Image'+IntToStr(ImageCount);
    CreateGUID(ImageMain[ImageCount-1].Props.UID);

//    ImageMain[ImageCount-1].Props.ExportFormat.Width:=0;
//    ImageMain[ImageCount-1].Props.ExportFormat.Height:=0;
 end;
end;

function TImageThumb.GetCount : integer;
begin
 GetCount:=ImageCount;
end;

procedure TImageThumb.SetCount(count : integer);
begin
  ImageCount:=count;
end;

function TImageThumb.GetExportPaletteCount : integer;
var
 i : integer;
 Exportcount : integer;
begin
 ExportCount:=0;
 for i:=0 to GetCount-1 do
 begin
   if ImageMain[i].Props.ExportFormat.Palette > 0 then inc(ExportCount);
 end;
 GetExportPaletteCount:=ExportCount;
end;

function TImageThumb.GetExportHitBoxCount : integer;
var
  i,c : integer;
begin
  c:=0;
  for i:=0 to ImageCount-1 do
    if (ImageMain[i].Props.ExportFormat.Image > 0) and
       (ImageMain[i].Props.HitBoxProps.HitBoxCount > 0) then inc(c);
  GetExportHitBoxCount:=c;
end;

function TImageThumb.GetExportImageCount : integer;
var
 i : integer;
 Exportcount : integer;
begin
 ExportCount:=0;
 for i:=0 to GetCount-1 do
 begin
   if ImageMain[i].Props.ExportFormat.Image > 0 then inc(ExportCount);
 end;
 GetExportImageCount:=ExportCount;
end;

function TImageThumb.GetExportMaskCount : integer;
var
 i : integer;
 Exportcount : integer;
begin
 ExportCount:=0;
 for i:=0 to GetCount-1 do
 begin
   if (ImageMain[i].Props.ExportFormat.Image=1) and (ImageMain[i].Props.ExportFormat.Mask=1) then inc(ExportCount);
 end;
 GetExportMaskCount:=ExportCount;
end;


procedure TImageThumb.CopyCoreToIndexImage(index : integer);
var
 width,height :integer;
 i,j : integer;
begin
  width:=RMCoreBase.GetWidth;
  height:=RMCoreBase.GetHeight;
  SetImageSize(index,width,height);
  for j:=0 to height-1 do
  begin
     for i:=0 to width-1 do
     begin
        ImageMain[index].Image.Pixel[i,j]:=ImageBufPtr^.Pixel[i,j];
        ImageMain[index].UndoImage.Pixel[i,j]:=UndoImageBufPtr^.Pixel[i,j];
     end;
  end;
  RMCoreBase.Palette.GetPalette(ImageMain[index].Props.Palette);
  ImageMain[index].Props.PaletteMode:=RMCoreBase.Palette.GetPaletteMode;
  ImageMain[index].Props.ColorCount:= RMCoreBase.Palette.GetColorCount;
  ImageMain[index].Props.CurColor:=RMCoreBase.GetCurColor1;
  ImageMain[index].Props.CurColor2:=RMCoreBase.GetCurColor2;
  ImageMain[index].Props.ColorBox:=RMCoreBase.GetCurColorBox;

  ImageMain[index].Props.DrawTool:=RMDrawTools.GetDrawTool;

  RMDrawTools.GetClipAreaCoords(ImageMain[index].Props.ClipArea);
  RMDrawTools.GetGridArea(ImageMain[index].Props.GridArea);
  RMDrawTools.GetScrollPos(ImageMain[index].Props.ScrollPos);
end;

procedure TImageThumb.CopyIndexImageToCore(index : integer);
var
 width,height :integer;
 i,j : integer;
begin
  width:=ImageMain[index].Props.Width;
  height:=ImageMain[index].Props.Height;

  RMCoreBase.SetWidth(Width);
  RMCoreBase.SetHeight(Height);

  //Undo history belongs to the sprite, so point rmcore at this sprite's ring.
  //Without this, undo after switching would restore the previous sprite's
  //pixels into this one.
  RMCoreBase.SetUndoSlot(index);

  for j:=0 to height-1 do
  begin
     for i:=0 to width-1 do
     begin
        ImageBufPtr^.Pixel[i,j]:=ImageMain[index].Image.Pixel[i,j];
        UndoImageBufPtr^.Pixel[i,j]:=ImageMain[index].UndoImage.Pixel[i,j];
     end;
  end;

  RMCoreBase.Palette.SetPalette(ImageMain[index].Props.Palette);
  RMCoreBase.Palette.SetPaletteMode(ImageMain[index].Props.PaletteMode);
  RMCoreBase.Palette.SetColorCount(ImageMain[index].Props.ColorCount);
  RMCoreBase.SetCurColor1(ImageMain[index].Props.CurColor);
  RMCoreBase.SetCurColor2(ImageMain[index].Props.CurColor2);
  RMCoreBase.SetCurColorBox(ImageMain[index].Props.ColorBox);

  RMDrawTools.SetDrawTool(ImageMain[index].Props.DrawTool);
  RMDrawTools.SetClipAreaCoords(ImageMain[index].Props.ClipArea);
  RMDrawTools.SetGridArea(ImageMain[index].Props.GridArea);
  RMDrawTools.SetScrollPos(ImageMain[index].Props.ScrollPos);
end;


function TImageThumb.GetPixelTColor(index,x,y : integer) : TColor;
var
 r,g,b : integer;
 colindex : integer;
begin
 colindex:=ImageMain[index].Image.Pixel[x,y];
 r:=ImageMain[index].Props.Palette[colindex].r;
 g:=ImageMain[index].Props.Palette[colindex].g;
 b:=ImageMain[index].Props.Palette[colindex].b;
 GetPixelTColor:=RGBToColor(r,g,b);
end;

function TImageThumb.GetPixel(index,x,y : integer) : integer;
begin
  GetPixel:=ImageMain[index].Image.Pixel[x,y];
end;

procedure TImageThumb.PutPixel(index,x,y,color : integer);
begin
  ImageMain[index].Image.Pixel[x,y]:=color;
end;

function TImageThumb.GetMaxColor(index : integer) : integer;
begin
  GetMaxColor:=ImageMain[index].Props.ColorCount-1;
end;

procedure TImageThumb.GetColor(index : integer;colorIndex : integer; var cr : TRMColorRec);
begin
  cr.r:=ImageMain[index].Props.Palette[colorIndex].r;
  cr.g:=ImageMain[index].Props.Palette[colorIndex].g;
  cr.b:=ImageMain[index].Props.Palette[colorIndex].b;
end;

procedure TImageThumb.SetColor(index : integer;colorIndex : integer; var cr : TRMColorRec);
begin
  ImageMain[index].Props.Palette[colorIndex].r:=cr.r;
  ImageMain[index].Props.Palette[colorIndex].g:=cr.g;
  ImageMain[index].Props.Palette[colorIndex].b:=cr.b;
end;

//=============================================================================
// SPRITE HIT BOXES
//
// Coordinates are PIXELS within the sprite, not tiles - the map editor's
// boxes are in tiles and share the record type but not the meaning.
//=============================================================================

function TImageThumb.GetHitBoxCount(index : integer) : integer;
begin
  GetHitBoxCount:=ImageMain[index].Props.HitBoxProps.HitBoxCount;
end;

procedure TImageThumb.SetHitBoxCount(index,count : integer);
begin
  if count < 0 then count:=0;
  if count > MaxHitBoxes then count:=MaxHitBoxes;
  ImageMain[index].Props.HitBoxProps.HitBoxCount:=count;
end;

function TImageThumb.IsValidHitBox(index,hb : integer) : boolean;
begin
  IsValidHitBox:=(hb >= 0) and (hb < ImageMain[index].Props.HitBoxProps.HitBoxCount);
end;

procedure TImageThumb.GetHitBox(index,hbindex : integer;var HB : HitBoxRec);
begin
  if not IsValidHitBox(index,hbindex) then exit;
  HB:=ImageMain[index].Props.HitBoxProps.HitBoxes[hbindex];
end;

procedure TImageThumb.SetHitBox(index,hbindex : integer;var HB : HitBoxRec);
begin
  if not IsValidHitBox(index,hbindex) then exit;
  ImageMain[index].Props.HitBoxProps.HitBoxes[hbindex]:=HB;
end;

procedure TImageThumb.AddHitBox(index,x,y,x2,y2 : integer);
var
  c,temp : integer;
begin
  c:=ImageMain[index].Props.HitBoxProps.HitBoxCount;
  if c >= MaxHitBoxes then exit;

  //normalise so x<=x2 and y<=y2 - a box dragged right to left would
  //otherwise be stored inside out and fail every hit test
  if x > x2 then begin temp:=x; x:=x2; x2:=temp; end;
  if y > y2 then begin temp:=y; y:=y2; y2:=temp; end;

  //NO 'with' here on purpose. Inside a with block the names x, y, x2 and y2
  //resolve to the RECORD FIELDS, not to the parameters of the same name, so
  //"HitBoxes[c].x := x" would assign the field to itself and store garbage.
  ImageMain[index].Props.HitBoxProps.HitBoxes[c].active:=true;
  ImageMain[index].Props.HitBoxProps.HitBoxes[c].id:=0;
  ImageMain[index].Props.HitBoxProps.HitBoxes[c].value:=0;
  ImageMain[index].Props.HitBoxProps.HitBoxes[c].x:=x;
  ImageMain[index].Props.HitBoxProps.HitBoxes[c].y:=y;
  ImageMain[index].Props.HitBoxProps.HitBoxes[c].x2:=x2;
  ImageMain[index].Props.HitBoxProps.HitBoxes[c].y2:=y2;

  inc(ImageMain[index].Props.HitBoxProps.HitBoxCount);
end;

procedure TImageThumb.DeleteHitBox(index,hb : integer);
var
  i : integer;
begin
  if not IsValidHitBox(index,hb) then exit;
  for i:=hb to ImageMain[index].Props.HitBoxProps.HitBoxCount-2 do
    ImageMain[index].Props.HitBoxProps.HitBoxes[i]:=
      ImageMain[index].Props.HitBoxProps.HitBoxes[i+1];
  dec(ImageMain[index].Props.HitBoxProps.HitBoxCount);
end;

procedure TImageThumb.ClearHitBoxes(index : integer);
begin
  ImageMain[index].Props.HitBoxProps.HitBoxCount:=0;
end;

//Shifts a box, clamped as a unit so its size is preserved.
procedure TImageThumb.MoveHitBox(index,hb,dx,dy : integer);
var
  w,h : integer;
begin
  if not IsValidHitBox(index,hb) then exit;
  w:=ImageMain[index].Props.Width;
  h:=ImageMain[index].Props.Height;

  with ImageMain[index].Props.HitBoxProps.HitBoxes[hb] do
  begin
    if x+dx < 0 then dx:=-x;
    if y+dy < 0 then dy:=-y;
    if x2+dx > w-1 then dx:=w-1-x2;
    if y2+dy > h-1 then dy:=h-1-y2;

    inc(x,dx);   inc(y,dy);
    inc(x2,dx);  inc(y2,dy);
  end;
end;

//Which box contains the pixel. Searched top down so the most recently added
//wins an overlap.
function TImageThumb.HitBoxHitTest(index,px,py : integer) : integer;
var
  i : integer;
begin
  HitBoxHitTest:=-1;
  for i:=ImageMain[index].Props.HitBoxProps.HitBoxCount-1 downto 0 do
    with ImageMain[index].Props.HitBoxProps.HitBoxes[i] do
      if (px >= x) and (px <= x2) and (py >= y) and (py <= y2) then
      begin
        HitBoxHitTest:=i;
        exit;
      end;
end;

//After a resize, pull every box back inside the sprite and drop any that no
//longer fit at all. Clamping beats clearing: a resize is usually a small
//adjustment and losing all the boxes would be worse than nudging them.
//Copies the whole hit box block from one sprite to another. HitBoxProps is a
//fixed size record, so a straight assignment carries every box, its count and
//the id/value fields in one go.
procedure TImageThumb.CopyHitBoxes(destindex,srcindex : integer);
begin
  if (destindex < 0) or (destindex >= MaxThumbImages) then exit;
  if (srcindex  < 0) or (srcindex  >= MaxThumbImages) then exit;
  if destindex = srcindex then exit;

  ImageMain[destindex].Props.HitBoxProps:=ImageMain[srcindex].Props.HitBoxProps;

  //the clone may not be the same size as the source
  ClampHitBoxes(destindex);
end;

procedure TImageThumb.ClampHitBoxes(index : integer);
var
  i,w,h : integer;
begin
  w:=ImageMain[index].Props.Width;
  h:=ImageMain[index].Props.Height;

  i:=0;
  while i < ImageMain[index].Props.HitBoxProps.HitBoxCount do
  begin
    with ImageMain[index].Props.HitBoxProps.HitBoxes[i] do
    begin
      if x  > w-1 then x :=w-1;
      if y  > h-1 then y :=h-1;
      if x2 > w-1 then x2:=w-1;
      if y2 > h-1 then y2:=h-1;
      if x < 0 then x:=0;
      if y < 0 then y:=0;
    end;
    inc(i);
  end;
end;

function TImageThumb.GetWidth(index : integer) : integer;
begin
  GetWidth:=ImageMain[index].Props.Width;
end;

function TImageThumb.GetHeight(index : integer) : integer;
begin
 GetHeight:=ImageMain[index].Props.Height;
end;


//if there is a custom width property (not 0) and less then props width
function TImageThumb.GetExportWidth(index : integer) : integer;
var
 width : integer;
begin
  Width:=ImageMain[index].Props.Width;
  if (ImageMain[index].Props.ExportFormat.Width > 0) AND (ImageMain[index].Props.ExportFormat.Width < ImageMain[index].Props.Width) then
  begin
     Width:=ImageMain[index].Props.ExportFormat.Width;
  end;
  GetExportWidth:=Width;
end;

//if there is a custom height property (not 0) and less then props height
function TImageThumb.GetExportHeight(index : integer) : integer;
var
  height : integer;
begin
 Height:=ImageMain[index].Props.Height;
 if (ImageMain[index].Props.ExportFormat.Height > 0) AND (ImageMain[index].Props.ExportFormat.Height < ImageMain[index].Props.Height) then
 begin
    Height:=ImageMain[index].Props.ExportFormat.Height;
 end;
 GetExportHeight:=Height;
end;

function TImageThumb.GetExportName(index : integer) : string;
begin
 result:=ImageMain[index].Props.ExportFormat.Name;
end;

procedure TImageThumb.GetExportOptions(index : integer;var EO : ImageExportFormatRec);
begin
  EO:=ImageMain[index].Props.ExportFormat;
end;

procedure TImageThumb.SetExportOptions(index : integer; EO :ImageExportFormatRec);
begin
  ImageMain[index].Props.ExportFormat:=EO;
end;


// action 4 = update
procedure TImageThumb.MakeThumbImage(index : integer;var imglist : TImageList;action : integer);
var
 DstBitMap : TBitmap;
 SrcBitMap : TBitMap;
 width,height : integer;
 i,j : integer;
begin
   if action = 3 then
   begin
     imglist.delete(index);
     exit;
   end;

   width:=ImageMain[index].Props.Width;
   height:=ImageMain[index].Props.Height;

   //DstBitMap := TBitmap.Create;
   //DstBitMap.SetSize(256,256);
   //DstBitMap.PixelFormat:=pf24bit;
   //DstBitMap.TransparentColor:=RGBToColor(255,0,255);
   //DstBitMap.Transparent:=true;
   //DstBitMap.TransparentMode:=tmFixed;
   //SrcBitMap := TBitmap.Create;
   //SrcBitMap.SetSize(width,height);
   //SrcBitMap.PixelFormat:=pf24bit;
   DstBitMap := TBitmap.Create;
   DstBitMap.SetSize(256,256);
   SrcBitMap := TBitmap.Create;
   SrcBitMap.SetSize(width,height);


   for j:=0 to height-1 do
   begin
     for i:=0 to width-1 do
     begin
        SrcBitMap.Canvas.Pixels[i,j]:=GetPixelTColor(index,i,j);
     end;
   end;
   DstBitMap.canvas.CopyRect(Rect(0, 0, DstBitMap.Width, DstBitMap.Height), SrcBitMap.Canvas, Rect(0, 0, SrcBitMap.Width, SrcBitMap.Height));

   if action = 1 then
   begin
     imglist.Add(DstBitMap,nil);
   end
   else if action = 2 then
   begin
     imglist.insert(index,DstBitMap,nil);
   end
   else if action = 4 then
   begin
     imglist.insert(index,DstBitMap,nil);
     imglist.delete(index+1);
   end;

   DstBitMap.Free;
   SrcBitMap.Free;
end;

procedure TImageThumb.MakeThumbImageFromCore(index : integer;var imglist : TImageList;action : integer);
var
 DstBitMap : TBitmap;
 SrcBitMap : TBitMap;
 width,height : integer;
 i,j : integer;
begin
   if action = 3 then
   begin
     imglist.delete(index);
     exit;
   end;
   width:=RMCoreBase.GetWidth;
   height:=RMCoreBase.GetHeight;

   DstBitMap := TBitmap.Create;
   DstBitMap.SetSize(256,256);
   SrcBitMap := TBitmap.Create;
   SrcBitMap.SetSize(width,height);

   for j:=0 to height-1 do
   begin
      for i:=0 to width-1 do
      begin
         SrcBitMap.Canvas.Pixels[i,j]:=RMCoreBase.GetPixelTColor(i,j);
      end;
   end;

   DstBitMap.canvas.CopyRect(Rect(0, 0, DstBitMap.Width, DstBitMap.Height), SrcBitMap.Canvas, Rect(0, 0, SrcBitMap.Width, SrcBitMap.Height));
   if action = 1 then
   begin
     imglist.Add(DstBitMap,nil);
   end
   else if action = 2 then
   begin
     imglist.insert(index,DstBitMap,nil);
   end
   else if action = 4 then
   begin
     imglist.insert(index,DstBitMap,nil);
     imglist.delete(index+1);
   end;
   DstBitMap.Free;
   SrcBitMap.Free;
end;

procedure TImageThumb.OpenProject(filename : string;insertmode : boolean);
var
 F : File;
 i : integer;
 count : integer;
 head  : ProjectHeaderRec;
 indexOffset : integer;
 ctcount : integer;
begin
 Assign(F,filename);
{$I-}
 Reset(F,1);
 Blockread(F,head,sizeof(head));
{$I+}
 if IORESULT <>0 then exit;
 //classify first so the caller can explain a refusal to load
 if head.sig <> RMProjectSig then
   LastProjectReadStatus:=ProjectReadBadSig
 else if head.version < RMProjectVersion then
   LastProjectReadStatus:=ProjectReadOldVersion
 else if head.version > RMProjectVersion then
   LastProjectReadStatus:=ProjectReadNewVersion
 else
   LastProjectReadStatus:=ProjectReadOK;

 if LastProjectReadStatus = ProjectReadOK then
 begin
   //delete all current images - user should be warn when oopening files
   count:=head.ImageCount;

   IndexOffset:=0;
   ctcount:=ImageCount;  //get cuurent count before project read
   Imagecount:=count;    //if not in insert mode - count is the same as we import

   if insertmode then
   begin
     IndexOffset:=ctCount;
     inc(ImageCount,ctcount);
   end;

   For i:=0 to count-1 do
   begin
     ReadImageFromProject(F,i+indexoffset);
   end;

   ReadAllMapsF(F,head.MapCount,insertmode);  //there is always atleast one map - even if it blank

   if head.AnimCount > 0 then AnimateBase.ReadAnimations(F,head.AnimCount,InsertMode);
 end;
{$I-}
 close(f);
{$I+}
end;

procedure TImageThumb.SaveProject(filename : string);
var
 F : File;
 i : integer;
 count : integer;
 head  : ProjectHeaderRec;
begin
 Assign(F,filename);
{$I-}
 Rewrite(F,1);

 count:=GetCount;

 head.ImageCount:=count;
 head.MapCount:=MapCoreBase.GetMapCount;
 head.AnimCount:=AnimateBase.GetAnimationCount;
 head.Future2:=0;
 head.Future3:=0;

 head.SIG:=RMProjectSig;   // Raster Master Project
 head.version:=RMProjectVersion;   // v3 added in R46 (added unique id), v2 introduced in R38 (added ExportWidth/ExportHieght), all previous up v37 were v1
 Blockwrite(F,head,sizeof(head));
 {$I+}
 if IORESULT <>0 then exit;

 For i:=0 to count-1 do
 begin
     WriteImageToProject(F,i);
 end;

 WriteAllMapsF(F);

 if AnimateBase.GetAnimationCount > 0 then AnimateBase.WriteAnimations(F,AnimateBase.GetAnimationCount);
{$I-}
 close(f);
{$I+}
end;

procedure TImageThumb.WriteImageToProject(Var F : File;Index : integer);
var
 width,height : integer;
 LineBuf      : array[0..255] of byte;
 i,j : integer;
begin
 width:=ImageMain[index].Props.Width;
 height:=ImageMain[index].Props.Height;

 //write header for image - this includes the Palette
 BlockWrite(F,ImageMain[index].Props,sizeof(ImageMain[index].Props));
 //write Image
 for j:=0 to height -1 do
 begin
   for i:=0 to width-1 do
   begin
     LineBuf[i]:=ImageMain[index].Image.Pixel[i,j];
   end;
   {$I-}
   blockwrite(f,LineBuf,width);
   {$I+}
   if IORESULT <>0 then exit;
 end;

 //write Undo Image
 for j:=0 to height -1 do
 begin
   for i:=0 to width-1 do
   begin
     LineBuf[i]:=ImageMain[index].UndoImage.Pixel[i,j];
   end;
   {$I-}
   blockwrite(f,LineBuf,width);
   {$I+}
    if IORESULT <>0 then exit;
 end;
end;


procedure TImageThumb.ReadImageFromProject(Var F : File; index : integer);
var
 width,height : integer;
 LineBuf      : array[0..255] of byte;
 i,j : integer;
 ImageProps : ImageThumbPropsRec;
begin
 {$I-}
 Blockread(F,ImageProps,sizeof(ImageProps));
 {$I+}
  if IORESULT <>0 then exit;

 width:=ImageProps.Width;
 height:=ImageProps.Height;

 SetImageSize(Index,width,height);
 ImageMain[Index].Props:=ImageProps;

 //read Image
 for j:=0 to height -1 do
 begin
   {$I-}
   blockread(f,LineBuf,width);
   {$I+}
   if IORESULT <>0 then exit;

   for i:=0 to width-1 do
   begin
     ImageMain[Index].Image.Pixel[i,j]:=LineBuf[i];
   end;
 end;

 //read Undo Image
 for j:=0 to height -1 do
 begin
   {$I-}
   blockread(f,LineBuf,width);
   {$I+}
   if IORESULT <>0 then exit;

   for i:=0 to width-1 do
   begin
     ImageMain[Index].UndoImage.Pixel[i,j]:=LineBuf[i];
   end;
 end;
end;

procedure TImageThumb.UpdateAllThumbImages(var imglist : TImageList);
var
 count     : integer;
 imgcount  : integer;
 amount    : integer;
 i         : integer;
 DstBitMap : TBitMap;
begin
 count:=GetCount;
 imgcount:=imglist.Count;
 amount:=count-imgcount;

 if amount < 0 then
 begin
   //delete abs(amount) imglist items
   for i:=1 to abs(amount) do
   begin
     imglist.delete(0);
   end;
 end
 else if amount > 0 then
 begin
   //add amount to imglist
   DstBitMap := TBitmap.Create;
   DstBitMap.SetSize(256,256);

   for i:=1 to amount do
   begin
     imglist.Add(DstBitMap,nil);
   end;
   DstBitMap.Free;
 end;

 for i:=0 to Count-1 do
 begin
   MakeThumbImage(i,imglist,4); // update
 end;
end;

begin
  ImageThumbBase := TImageThumb.Create;
end.
