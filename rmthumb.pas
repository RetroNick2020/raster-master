Unit rmthumb;

Interface
  uses rmcore,graphics,controls,types;
type
 ImageThumbRec = Record
             Pixel : array of array of integer;
           end;


 ImageThumbPropsRec = Record
                        Palette     : TRMPaletteBuf;
                        PaletteMode : Integer;
                        ColorCount  : Integer;
                        UndoImage   : ImageThumbRec;
                        Image       : ImageThumbRec;
                        Width       : Integer;
                        Height      : Integer;
                        CurColor    : Integer;
                      end;

TImageThumb = Class
         //    ImageProps  : array[0..20] of ImageThumbPropsRec;
             ImageProps  : array of ImageThumbPropsRec;
             ImageCount  : integer;
             ImageBufPtr : ^TRMImageBuf;
             LastPicked    : integer;
             Current       : integer; //image that is being edited
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
             function GetCount : integer;
             function GetPixel(index,x,y : integer) : TColor;
             procedure MakeThumbImage(index : integer;var imglist : TImageList;action : integer);
              procedure MakeThumbImageFromCore(index : integer;var imglist : TImageList;action : integer);
             procedure Info;


             procedure CopyCoreToIndexImage(index : integer);  //copy contents of core image and undo to index location
             procedure CopyIndexImageToCore(index : integer); //copy index image and undo to core
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
 Setlength(ImageProps,size);
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
 Setlength(ImageProps[index].Image.Pixel,width,height);
 Setlength(ImageProps[index].UndoImage.Pixel,width,height);
 ImageProps[index].width:=width;
 ImageProps[index].height:=height;
end;

procedure TImageThumb.InsertImage(index : integer);
var
 i : integer;
// IM : ImageThumbPropsRec;
begin
 if (index < 0) OR (index > (ImageCount-1)) then exit;
 inc(ImageCount);
 //SetListSize(ImageCount);
 for i:=ImageCount-1 downto index+1 do
 begin
//   IM:=ImageProps[i-1];
//   ImageProps[i]:=IM;
    ImageProps[i]:=ImageProps[i-1];
 end;
 CopyCoreToIndexImage(index);

// SetImageSize(index,width,height);
end;

procedure TImageThumb.DeleteImage(index : integer);
var
 i : integer;
// IM : ImageThumbPropsRec;
begin
 if (index < 0)  then exit;
 for i:=index to ImageCount-2  do
 begin
//   IM:=ImageProps[i+1];
//   ImageProps[i]:=IM;
   ImageProps[i]:=ImageProps[i+1];


 end;
 SetImageSize(ImageCount-1,0,0);
 dec(ImageCount);
 //SetListSize(ImageCount);
end;

procedure TImageThumb.AddImage;  //adds image to end of list
begin
 if ImageCount >= MaxThumbImages then exit;
 inc(ImageCount);
// SetListSize(ImageCount);
// SetImageSize(ImageCount-1,width,height);
 CopyCoreToIndexImage(ImageCount-1);
end;

function TImageThumb.GetCount : integer;
begin
 GetCount:=ImageCount;
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
        ImageProps[index].Image.Pixel[i,j]:=ImageBufPtr^.Pixel[i,j];
        ImageProps[index].UndoImage.Pixel[i,j]:=UndoImageBufPtr^.Pixel[i,j];
     end;
  end;
  RMCoreBase.Palette.GetPalette(ImageProps[index].Palette);
  ImageProps[index].PaletteMode:=RMCoreBase.Palette.GetPaletteMode;
  ImageProps[index].ColorCount:= RMCoreBase.Palette.GetColorCount;
  ImageProps[index].CurColor:=RMCoreBase.GetCurColor;
end;

procedure TImageThumb.CopyIndexImageToCore(index : integer);
var
 width,height :integer;
 i,j : integer;
begin
  width:=ImageProps[index].Width;
  height:=ImageProps[index].Height;

  RMCoreBase.SetWidth(Width);
  RMCoreBase.SetHeight(Height);

  for j:=0 to height-1 do
  begin
     for i:=0 to width-1 do
     begin
        ImageBufPtr^.Pixel[i,j]:=ImageProps[index].Image.Pixel[i,j];
        UndoImageBufPtr^.Pixel[i,j]:=ImageProps[index].UndoImage.Pixel[i,j];
     end;
  end;
  RMCoreBase.Palette.SetPalette(ImageProps[index].Palette);
  RMCoreBase.Palette.SetPaletteMode(ImageProps[index].PaletteMode);
  RMCoreBase.Palette.SetColorCount(ImageProps[index].ColorCount);
  RMCoreBase.SetCurColor(ImageProps[index].CurColor);
end;


function TImageThumb.GetPixel(index,x,y : integer) : TColor;
var
 r,g,b : integer;
 colindex : integer;
begin
 colindex:=ImageProps[index].Image.Pixel[x,y];
 r:=ImageProps[index].Palette[colindex].r;
 g:=ImageProps[index].Palette[colindex].g;
 b:=ImageProps[index].Palette[colindex].b;
 GetPixel:=RGBToColor(r,g,b);
end;

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

   width:=ImageProps[index].Width;
   height:=ImageProps[index].Height;

   DstBitMap := TBitmap.Create;
   DstBitMap.SetSize(256,256);
   SrcBitMap := TBitmap.Create;
   SrcBitMap.SetSize(width,height);

   //   MyBitMap.Canvas.TextOut(2,2,'nick');

 // if width > 128 then
 // begin
 //   for j:=0 to height-1 do
 //    begin
//       for i:=0 to width-1 do
 //      begin
//          DstBitMap.Canvas.Pixels[i,j]:=GetPixel(index,i,j);
//       end;
//    end;
//  end
//  else
 // begin

    for j:=0 to height-1 do
    begin
       for i:=0 to width-1 do
       begin
          SrcBitMap.Canvas.Pixels[i,j]:=GetPixel(index,i,j);
       end;
    end;
    DstBitMap.canvas.CopyRect(Rect(0, 0, DstBitMap.Width, DstBitMap.Height), SrcBitMap.Canvas, Rect(0, 0, SrcBitMap.Width, SrcBitMap.Height));
//    MyBitmap.Canvas.StretchDraw(Rect(0, 0, SrcBitMap.Width, SrcBitMap.Height), SrcBitMap);

 // end;

   if action = 1 then
   begin
     imglist.Add(DstBitMap,nil);
   end
   else if action = 2 then
   begin
     imglist.insert(index,DstBitMap,nil);
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



procedure TImageThumb.Info;
begin
  writeln(length(ImageProps[0].image.Pixel[0]));
end;


begin
  ImageThumbBase := TImageThumb.Create;
end.
