/* ************************************************************ */
/* owdemo6.c _putimage link to exe demo For Open Watcom C       */
/*                                                              */
/* OW.XGF was created by Exporting image as _putimage file      */
/* from Raster Master. Borland's Turbo C BGIOBJ was used to     */
/* to convert image to obj format. This allows us to link image */
/* to exe without creating c arrays.                            */
/*                                                              */
/* BGIOBJ ow.xgf ow.obj _ow                                     */
/* wcl -c owdemo6.c                                             */
/* wlink name owdemo6.exe file {owdemo6.obj ow.obj}             */
/* ************************************************************ */

#include <graph.h>
#include <conio.h>

extern char far ow;    //far keyword very important - works in all modes 16/32 bit

void main()
{
  _setvideomode(_VRES16COLOR);  
  _putimage(150,150,&ow,_GPSET); // & required to display image correctly

  getch();
  _setvideomode(_DEFAULTMODE);
}

