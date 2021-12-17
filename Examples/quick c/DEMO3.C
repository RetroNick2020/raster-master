/* ************************************************************ */
/* Demo3.c For QuickC                                           */
/*                                                              */
/* QGCAR.XGF was created by saving the image as  QC/QB (Binary) */
/* from Raster Master.                                           */
/* ************************************************************ */

#include <graph.h>
#include <stdio.h>
#include <stdlib.h>

void main()
{
  void *ImgBuf;
  FILE *F;
  size_t size;

  F=fopen("QGCAR.XGF","rb");
  size =filelength(fileno(F));
  ImgBuf = malloc(size);
  fread(ImgBuf,size,1,F);
  fclose(F);

  _setvideomode(_MRES16COLOR);    /* _MRES256COLOR for 256 color images */
  _setcolor(1);
  _rectangle(_GFILLINTERIOR,0,0,319,199);
  _putimage(0,0,ImgBuf,_GPSET);
  free(ImgBuf);
  getch();
  _setvideomode(_DEFAULTMODE);
}
