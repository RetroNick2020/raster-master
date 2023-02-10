/* ************************************************************ */
/* qcdemo1.c For MS C\QuickC                                    */
/*                                                              */
/* QC.XGF was created by Exporting image as _putimage file      */
/* from Raster Master.                                          */
/* ************************************************************ */

#include <graph.h>
#include <stdio.h>
#include <stdlib.h>
#include <malloc.h>
#include <io.h>
#include <errno.h>


void main()
{
  FILE *F;
  char *ImgBuf;
  long  size;

  F=fopen("QC.XGF","rb");
  size =filelength(fileno(F));
  ImgBuf = malloc((size_t) size);
  fread(ImgBuf,(size_t)size,1,F);
  fclose(F);

  _setvideomode(_MRES16COLOR);    /* _MRES256COLOR for 256 color images */
  _setcolor(1);
  _rectangle(_GFILLINTERIOR,0,0,319,199);

  _putimage(0,0,ImgBuf,_GPSET);
  free(ImgBuf);

  getch();
  _setvideomode(_DEFAULTMODE);
}



