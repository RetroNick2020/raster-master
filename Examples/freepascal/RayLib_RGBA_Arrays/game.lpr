program game;

{$mode objfpc}{$H+}

uses cmem, ray_header,SysUtils;

const
 screenWidth = 600;
 screenHeight = 400;
 PIXELFORMAT_UNCOMPRESSED_R8G8B8        = 4;  // 24 bpp
 PIXELFORMAT_UNCOMPRESSED_R8G8B8A8      = 7;  // 32 bpp

{$I rgbaimages.inc}

Var
 Finished  : Boolean;
 MyTexture : TTexture2D;
 MyImage   : Timage;
 X, Y      : integer;


//load RGB and RGBA images from Raster Master generated arrays
procedure LoadRGBImageFromMemory(var Image : TImage; var rgbImage; width,height, rgbformat : integer);
begin
  Image.Data:=@rgbImage;
  Image.format:=rgbformat;            //4 = RGB, 7 = RGBA
  Image.width:=width;
  Image.height:=height;
  Image.mipmaps:=1;
end;

procedure DrawShape;
begin
  DrawTexture(MyTexture,X,Y,WHITE);
end;

begin
 InitWindow(screenWidth, screenHeight, 'RGBA Array Demo for raylib');
 SetTargetFPS(120);

 //change Image1 to Image2 or Image3 to see the different images
 LoadRGBImageFromMemory(MyImage,Image1,Image1_Width,Image1_Height,Image1_Format);
 MyTexture:=LoadTextureFromImage(MyImage);

 X:=300;
 Y:=200;
 Finished:=False;
 while not WindowShouldClose() and (Finished=False) do
 begin
   if (IsKeyDown(KEY_UP)) then DEC(Y);
   if (IsKeyDown(KEY_DOWN)) then  INC(Y);
   if (IsKeyDown(KEY_RIGHT)) then INC(X);
   if (IsKeyDown(KEY_LEFT)) then DEC(X);
   if (IsKeyDown(KEY_Q)) then Finished:=TRUE;

   BeginDrawing();
     ClearBackground(BLUE);
     DrawShape;
   EndDrawing();
  end;
  CloseWindow();
end.
