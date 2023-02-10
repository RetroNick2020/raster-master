/* ************************************************************ */
/* qcdemo2.c For MS QuickC                                      */
/*                                                              */
/* cross was created by Exporting image as _putimage+Mask array */
/* from Raster Master.                                          */
/* ************************************************************ */

#include <graph.h>
#include <stdio.h>
#include <conio.h>

/* QuickC putimage Bitmap Code Created By Raster Master */
/* Size= 516 Width= 32 Height= 32 Colors= 16 */
 #define Cross_Size 516
 #define Cross_Width 32
 #define Cross_Height 32
 #define Cross_Colors 16
 #define Cross_Id 0
 char Cross[516]  = {
  0x20,0x00,0x20,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x80,0x00,0x00,0x03,0xe0,0x00,0x00,0x01,0xc0,0x00,
  0x00,0x00,0x00,0x00,0x00,0x00,0x80,0x00,0x00,0x03,0xe0,0x00,0x00,0x01,0xc0,0x00,0x00,0x00,0x00,0x00,
  0x00,0x00,0x80,0x00,0x00,0x03,0xe0,0x00,0x00,0x01,0xc0,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x80,0x00,
  0x00,0x03,0xe0,0x00,0x00,0x01,0xc0,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x80,0x00,0x00,0x03,0xe0,0x00,
  0x00,0x01,0xc0,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x80,0x00,0x00,0x03,0xe0,0x00,0x00,0x01,0xc0,0x00,
  0x00,0x00,0x00,0x00,0x00,0x00,0x80,0x00,0x00,0x03,0xe0,0x00,0x00,0x01,0xc0,0x00,0x00,0x00,0x00,0x00,
  0x00,0x00,0x80,0x00,0x00,0x03,0xe0,0x00,0x00,0x01,0xc0,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x80,0x00,
  0x00,0x03,0xe0,0x00,0x00,0x01,0xc0,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x80,0x00,0x00,0x03,0xe0,0x00,
  0x00,0x01,0xc0,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x80,0x00,0x00,0x03,0xe0,0x00,0x00,0x01,0xc0,0x00,
  0x00,0x00,0x00,0x00,0x00,0x00,0x80,0x00,0x00,0x03,0xe0,0x00,0x00,0x01,0xc0,0x00,0x00,0x00,0x00,0x00,
  0x00,0x00,0x80,0x00,0x00,0x03,0xe0,0x00,0x00,0x01,0xc0,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
  0xff,0xff,0xff,0xff,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xff,0xff,0xff,0xff,
  0xff,0xff,0xff,0xff,0x00,0x00,0x00,0x00,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,
  0x00,0x00,0x00,0x00,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0x00,0x00,0x00,0x00,
  0x00,0x00,0x00,0x00,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
  0xff,0xff,0xff,0xff,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x80,0x00,0x00,0x03,0xe0,0x00,
  0x00,0x01,0xc0,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x80,0x00,0x00,0x03,0xe0,0x00,0x00,0x01,0xc0,0x00,
  0x00,0x00,0x00,0x00,0x00,0x00,0x80,0x00,0x00,0x03,0xe0,0x00,0x00,0x01,0xc0,0x00,0x00,0x00,0x00,0x00,
  0x00,0x00,0x80,0x00,0x00,0x03,0xe0,0x00,0x00,0x01,0xc0,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x80,0x00,
  0x00,0x03,0xe0,0x00,0x00,0x01,0xc0,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x80,0x00,0x00,0x03,0xe0,0x00,
  0x00,0x01,0xc0,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x80,0x00,0x00,0x03,0xe0,0x00,0x00,0x01,0xc0,0x00,
  0x00,0x00,0x00,0x00,0x00,0x00,0x80,0x00,0x00,0x03,0xe0,0x00,0x00,0x01,0xc0,0x00,0x00,0x00,0x00,0x00,
  0x00,0x00,0x80,0x00,0x00,0x03,0xe0,0x00,0x00,0x01,0xc0,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x80,0x00,
  0x00,0x03,0xe0,0x00,0x00,0x01,0xc0,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x80,0x00,0x00,0x03,0xe0,0x00,
  0x00,0x01,0xc0,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x80,0x00,0x00,0x03,0xe0,0x00,0x00,0x01,0xc0,0x00,
  0x00,0x00,0x00,0x00,0x00,0x00,0x80,0x00,0x00,0x03,0xe0,0x00,0x00,0x01,0xc0,0x00};

/* QuickC putimage Bitmap Code Created By Raster Master */
/* Size= 516 Width= 32 Height= 32 Colors= 16 */
 #define CrossMask_Size 516
 #define CrossMask_Width 32
 #define CrossMask_Height 32
 #define CrossMask_Colors 16
 #define CrossMask_Id 0
 char CrossMask[516]  = {
  0x20,0x00,0x20,0x00,0xff,0xfc,0x1f,0xff,0xff,0xfc,0x1f,0xff,0xff,0xfc,0x1f,0xff,0xff,0xfc,0x1f,0xff,
  0xff,0xfc,0x1f,0xff,0xff,0xfc,0x1f,0xff,0xff,0xfc,0x1f,0xff,0xff,0xfc,0x1f,0xff,0xff,0xfc,0x1f,0xff,
  0xff,0xfc,0x1f,0xff,0xff,0xfc,0x1f,0xff,0xff,0xfc,0x1f,0xff,0xff,0xfc,0x1f,0xff,0xff,0xfc,0x1f,0xff,
  0xff,0xfc,0x1f,0xff,0xff,0xfc,0x1f,0xff,0xff,0xfc,0x1f,0xff,0xff,0xfc,0x1f,0xff,0xff,0xfc,0x1f,0xff,
  0xff,0xfc,0x1f,0xff,0xff,0xfc,0x1f,0xff,0xff,0xfc,0x1f,0xff,0xff,0xfc,0x1f,0xff,0xff,0xfc,0x1f,0xff,
  0xff,0xfc,0x1f,0xff,0xff,0xfc,0x1f,0xff,0xff,0xfc,0x1f,0xff,0xff,0xfc,0x1f,0xff,0xff,0xfc,0x1f,0xff,
  0xff,0xfc,0x1f,0xff,0xff,0xfc,0x1f,0xff,0xff,0xfc,0x1f,0xff,0xff,0xfc,0x1f,0xff,0xff,0xfc,0x1f,0xff,
  0xff,0xfc,0x1f,0xff,0xff,0xfc,0x1f,0xff,0xff,0xfc,0x1f,0xff,0xff,0xfc,0x1f,0xff,0xff,0xfc,0x1f,0xff,
  0xff,0xfc,0x1f,0xff,0xff,0xfc,0x1f,0xff,0xff,0xfc,0x1f,0xff,0xff,0xfc,0x1f,0xff,0xff,0xfc,0x1f,0xff,
  0xff,0xfc,0x1f,0xff,0xff,0xfc,0x1f,0xff,0xff,0xfc,0x1f,0xff,0xff,0xfc,0x1f,0xff,0xff,0xfc,0x1f,0xff,
  0xff,0xfc,0x1f,0xff,0xff,0xfc,0x1f,0xff,0xff,0xfc,0x1f,0xff,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
  0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
  0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
  0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
  0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
  0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xff,0xfc,0x1f,0xff,0xff,0xfc,0x1f,0xff,0xff,0xfc,0x1f,0xff,
  0xff,0xfc,0x1f,0xff,0xff,0xfc,0x1f,0xff,0xff,0xfc,0x1f,0xff,0xff,0xfc,0x1f,0xff,0xff,0xfc,0x1f,0xff,
  0xff,0xfc,0x1f,0xff,0xff,0xfc,0x1f,0xff,0xff,0xfc,0x1f,0xff,0xff,0xfc,0x1f,0xff,0xff,0xfc,0x1f,0xff,
  0xff,0xfc,0x1f,0xff,0xff,0xfc,0x1f,0xff,0xff,0xfc,0x1f,0xff,0xff,0xfc,0x1f,0xff,0xff,0xfc,0x1f,0xff,
  0xff,0xfc,0x1f,0xff,0xff,0xfc,0x1f,0xff,0xff,0xfc,0x1f,0xff,0xff,0xfc,0x1f,0xff,0xff,0xfc,0x1f,0xff,
  0xff,0xfc,0x1f,0xff,0xff,0xfc,0x1f,0xff,0xff,0xfc,0x1f,0xff,0xff,0xfc,0x1f,0xff,0xff,0xfc,0x1f,0xff,
  0xff,0xfc,0x1f,0xff,0xff,0xfc,0x1f,0xff,0xff,0xfc,0x1f,0xff,0xff,0xfc,0x1f,0xff,0xff,0xfc,0x1f,0xff,
  0xff,0xfc,0x1f,0xff,0xff,0xfc,0x1f,0xff,0xff,0xfc,0x1f,0xff,0xff,0xfc,0x1f,0xff,0xff,0xfc,0x1f,0xff,
  0xff,0xfc,0x1f,0xff,0xff,0xfc,0x1f,0xff,0xff,0xfc,0x1f,0xff,0xff,0xfc,0x1f,0xff,0xff,0xfc,0x1f,0xff,
  0xff,0xfc,0x1f,0xff,0xff,0xfc,0x1f,0xff,0xff,0xfc,0x1f,0xff,0xff,0xfc,0x1f,0xff,0xff,0xfc,0x1f,0xff,
  0xff,0xfc,0x1f,0xff,0xff,0xfc,0x1f,0xff,0xff,0xfc,0x1f,0xff,0xff,0xfc,0x1f,0xff};


void main()
{
    int i;
   _setvideomode(_MRES16COLOR);  
  
  for(i=0;i<16;i++){
   _setcolor(i);
   _rectangle(_GFILLINTERIOR,i*20,20,i*20+19,180);
  }
  _putimage(30,100,Cross,_GPSET);
  _putimage(70,100,Cross,_GPRESET);
  _putimage(110,100,Cross,_GAND);
  _putimage(150,100,Cross,_GOR);
  _putimage(190,100,Cross,_GXOR);

  /* using the CrossMask and cross image together with AND and OR operators
  we make it transparent */
  _putimage(230,100,CrossMask,_GAND);
  _putimage(230,100,Cross,_GOR);

   getch();

  _setvideomode(_DEFAULTMODE);
}

