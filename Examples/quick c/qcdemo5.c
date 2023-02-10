/* ************************************************************ */
/* qcdemo5.c _putimage link to exe demo For MS QuickC           */
/*                                                              */
/* QC.XGF was created by Exporting image as _putimage file      */
/* from Raster Master. Borland's Turbo C BGIOBJ was used to     */
/* to convert image to obj format. This allows us to link image */
/* to exe without creating c arrays.                            */
/*                                                              */
/* BGIOBJ qc.xgf qc.obj _qc                                     */
/* qcl -c qcdemo5.c qc.obj                                      */
/* ************************************************************ */

#include <graph.h>
#include <conio.h>

extern char far qc;  //public name you provide in BGIOBJ command  

void main()
{
  _setvideomode(_MRES16COLOR);  
  _putimage(120,100,&qc,_GPSET); // & required to display image correctly

  getch();
  _setvideomode(_DEFAULTMODE);
}

