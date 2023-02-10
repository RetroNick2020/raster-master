/* ************************************************************ */
/* tcdemo1.c For Turbo C                                        */
/*                                                              */
/* TC.XGF was created by Exporting image as _putimage file      */
/* from Raster Master.                                          */
/* ************************************************************ */

#include <graphics.h>
#include <stdio.h>
#include <malloc.h>
#include <io.h>
#include <errno.h>


void main()
{
  void *imgBuf;
  FILE *F;
  int driver = EGA;
  int mode   = EGAHI;
  unsigned int size;

  F=fopen("TC.XGF","rb");
  size=filelength(fileno(F));
  imgBuf = malloc(size);
  fread(imgBuf,size,1,F);
  fclose(F);

  initgraph(&driver, &mode, "");
  setfillstyle(SOLID_FILL,BLUE);
  bar(0,0,getmaxx(),getmaxy());

  putimage(150,100,imgBuf,COPY_PUT);

  free(imgBuf);
  getch();
  closegraph();

}



