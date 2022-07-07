Unit rmthumb;

Interface
  uses rmcore,rmtools,graphics,controls,types,dialogs,sysutils,mapcore,rwmap;

Const
  RMProjectSig = 'RMP';
  RMProjectVersion = 4;

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
             DrawTool    : integer;
             ClipArea    : TClipAreaRec;
             GridArea    : TGridAreaRec;
             ScrollPos   : TScrollPosRec;
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
                        Future1    : word;   //try and future proof changing project file
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
             procedure SetColorCount(index,colorcount : integer);


             function GetWidth(index : integer) : integer;
             function GetHeight(index : integer) : integer;

             function GetExportWidth(index : integer) : integer;
             function GetExportHeight(index : integer) : integer;

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
  MaxThumbImages = 64;

var
 ImageThumbBase  : TImageThumb;

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
  ImageMain[index].Props.CurColor:=RMCoreBase.GetCurColor;
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
  RMCoreBase.SetCurColor(ImageMain[index].Props.CurColor);

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
 if (head.sig=RMProjectSig) and (head.version=RMProjectVersion) then
 begin
   //delete all current images - use should be warn when oopening files
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

   ReadAllMapsF(F,head.MapCount,insertmode);
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
 head.Future1:=0;
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
