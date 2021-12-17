/* ************************************************************ */
/* Demo1.c For Turbo C                                          */
/*                                                              */
/* TGCAR.XGF was created by saving the image as  TP/TC (Binary) */
/* from Raster Master.                                          */
/* ************************************************************ */

#include <stdio.h>
#include <alloc.h>
#include <graphics.h>

struct rgb {
  unsigned char r,g,b;
};

void main()
{
  void *imgBuf;
  FILE *F;
  int driver = VGA;
  int mode   = VGALO;
  unsigned int size;
  struct rgb mypal[2] = {
			 {10,11,12},
			 {13,14,15}};


  F=fopen("TGCAR.XGF","rb");
  size=filelength(fileno(F));
  imgBuf = malloc(size);
  fread(imgBuf,size,1,F);
  fclose(F);

  initgraph(&driver, &mode, "");
  setfillstyle(SOLID_FILL,BLUE);
  bar(0,0,getmaxx(),getmaxy());
  putimage(0,0,imgBuf,COPY_PUT);
  free(imgBuf);
  getch();
  closegraph();
  printf("%u",mypal[0].g);
  getch();
}