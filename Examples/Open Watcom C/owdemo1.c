/* ************************************************************ */
/* owdemo1.c For Open Watcom                                    */
/*                                                              */
/* OW.XGF was created by Exporting image as _putimage file      */
/* from Raster Master.                                          */
/* ************************************************************ */

#include <graph.h>
#include <stdio.h>
#include <malloc.h>
#include <io.h>

void main()
{
  char *image;
  FILE *F;
  long size;

  _setvideomode(_VRES16COLOR);  
  
  F=fopen("OW.XGF","rb");
  size=filelength(fileno(F));
  image = malloc(size);
  fread(image,size,1,F);
  fclose(F);

  _putimage(150,150,image,_GPSET);

  getch();
  free(image);
  _setvideomode(_DEFAULTMODE);
}

