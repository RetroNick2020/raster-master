/* TWRES.C demonstrates how to access palettes and image data exported from 
   raster master. TWIMG.RES was exported from Raster Master using RES Binary 
   File option. This was converted from TWIMG.RES to TWIMG.OBJ using RtBinObj 
   utility. The following res functions below allow access to all the data in 
   the original TCIMG.RES file 

   tcc /ml tcres.c tcimg.obj graphics.lib   
*/

#include <conio.h>
#include <dos.h>
#include <graphics.h>
#include <stdlib.h>
#include <string.h>
#pragma pack(1)

extern char far tcimg; 

typedef struct {
  char sig[3];
  unsigned char ver;
  short resitemcount;
} reshead;

typedef struct {
  short rt;
  char rid[20];
  long offset;
  long size;
} resrec;

typedef struct {
  reshead head;
  resrec image[1];
} ResMemRec;

void* GetResImagePtr(void* ResPtr, int index) {
  ResMemRec* RecItems = ResPtr;
  char * ImgPtr = ResPtr;
  long Size = sizeof(reshead) + sizeof(resrec) * RecItems->head.resitemcount;
  int i;
  
  for (i = 1; i < index; i++) {
    Size += RecItems->image[i-1].size;
  }
  ImgPtr += Size;
  return ImgPtr;
}

void delspaces(char* s) {
  while (strlen(s) > 0 && s[strlen(s) - 1] == ' ') {
    s[strlen(s) - 1] = '\0';
  }
}

int GetResCount(void* ResPtr) {
  ResMemRec* RecItems = ResPtr;
  return RecItems->head.resitemcount;
}

char* GetResSig(void* ResPtr) {
  ResMemRec* RecItems = ResPtr;
  return RecItems->head.sig;
}

char* GetResName(void* ResPtr, int index) {
  ResMemRec* RecItems = ResPtr;
  char* name;

  if (index > GetResCount(ResPtr)) {
    name = "";
  } else {
    name = RecItems->image[index].rid;
    delspaces(name);
  }
  return name;
}

int GetResIndex(void* ResPtr, char* Name) {
  ResMemRec* RecItems = ResPtr;
  int i;
  char rid[21];

  for (i = 1; i <= RecItems->head.resitemcount; i++) {
    memcpy(rid,RecItems->image[i-1].rid,20);
    rid[20]='\0';
    delspaces(rid);
    if (strcmp(Name, rid) == 0) {
      return i;
    }
  }
  return 0;
}

/* working setrgb function - BGI setrgbpalette does not work
   properly. colors 8,9,10,11,12,14,15 do not get set in 16 color modes
   r,g,b values range from 0 to 63 */

void setrgb(int index, int  r,  int g,  int b){
  union REGS inregs, outregs;
  if (((getmaxcolor()==15) && (index <16))){
   inregs.h.ah = 0x10;
   inregs.h.al = 0x0;
   inregs.h.bl = index;
   inregs.h.bh = index;
   int86(0x10, &inregs, &outregs);
  }
  inregs.h.ah = 0x10;
  inregs.h.al = 0x10;
  inregs.x.bx = index;
  inregs.h.dh = r;
  inregs.h.ch = g;
  inregs.h.cl = b;
  int86(0x10, &inregs, &outregs);
}

void setrespal() {
  typedef  unsigned char  * paltype;
  paltype pal = GetResImagePtr(&tcimg, GetResIndex(&tcimg, "squarePal"));
  int i, c;

  c = 0;
  for (i = 0; i < 16; i++) {
    /* turbo c setrgbpalette is buggy and does not work completely
       setrgbpalette(i, pal[c], pal[c + 1], pal[c+2]); */

    setrgb(i, pal[c], pal[c + 1], pal[c+2]);
    c += 3;
  }
}

int main() {
  int i,gd,gm;
  gd=VGA;
  gm=VGAHI;
  initgraph(&gd,&gm,"C:\\turboc\\BGI");

  for(i=0;i<16;i++){
   setfillstyle(SOLID_FILL,i);
   bar(i*20,20,i*20+19,180);
  }
  getch();
  
  setrespal();
  getch();

  putimage(200, 20, GetResImagePtr(&tcimg, GetResIndex(&tcimg, "squareMask")), AND_PUT);
  putimage(200, 20, GetResImagePtr(&tcimg, GetResIndex(&tcimg, "square")), OR_PUT);

  putimage(100, 20, GetResImagePtr(&tcimg, GetResIndex(&tcimg, "circleMask")), AND_PUT);
  putimage(100, 20, GetResImagePtr(&tcimg, GetResIndex(&tcimg, "circle")), OR_PUT);

  putimage(150, 20, GetResImagePtr(&tcimg, GetResIndex(&tcimg, "crossMask")), AND_PUT);
  putimage(150, 20, GetResImagePtr(&tcimg, GetResIndex(&tcimg, "cross")), OR_PUT);

  getch();
  closegraph();
  return 0;
}
