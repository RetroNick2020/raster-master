#include "raylib.h"
#include "images.h"

void LoadImageFromArray(Image *myImage,unsigned char *rgbimage, int width,int height,int format)
{
  myImage->data=rgbimage;
  myImage->format=format;            //4 = RGB, 7 = RGBA
  myImage->width=width;
  myImage->height=height;
  myImage->mipmaps=1;
}

int main(void)
{
    const int screenWidth = 800;
    const int screenHeight = 450;
    int x = 400;
    int y = 200;
    Image myImage;
    Texture2D myTexture;
    
    InitWindow(screenWidth, screenHeight, "raylib RGB and RGBA array demo");
    SetTargetFPS(60);               // Set our game to run at 60 frames-per-second
    
    LoadImageFromArray(&myImage,Image1,32,32,7);  //4 = RGB, 7 = RGBA
    myTexture=LoadTextureFromImage(myImage);
    
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        if (IsKeyDown(KEY_UP)) y--;
        if (IsKeyDown(KEY_DOWN)) y++;
        if (IsKeyDown(KEY_LEFT)) x--;
        if (IsKeyDown(KEY_RIGHT)) x++;
        BeginDrawing();
            ClearBackground(BLUE);
            DrawTexture(myTexture,x,y,WHITE);
        EndDrawing();
    }
    CloseWindow();        // Close window and OpenGL context
    return 0;
}