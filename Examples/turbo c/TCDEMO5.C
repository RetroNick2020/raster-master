/* ************************************************************ */
/* tcdemo5.c putimage link to exe demo For Turbo C              */
/*                                                              */
/* TC.XGF was created by Exporting image as putimage file       */
/* from Raster Master. Borland's Turbo C BGIOBJ was used to     */
/* to convert image to obj format. This allows us to link image */
/* to exe without creating c arrays.                            */
/*                                                              */
/* BGIOBJ tc.xgf tc.obj _tc                                     */
/* tcc tcdemo5.c tc.obj                                         */
/* ************************************************************ */

#include <graphics.h>
#include <conio.h>

extern char far tc;  //public name you provide in BGIOBJ command

void main()
{
  int driver = EGA;
  int mode   = EGAHI;

  initgraph(&driver, &mode, "");

  putimage(120,100,&tc,COPY_PUT); // & required to display image correctly

  getch();
  closegraph();
}

