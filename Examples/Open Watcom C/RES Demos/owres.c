// OWRES.C demonstrates how to access palettes and image data exported from 
// raster master. OWIMG.RES was exported from Raster Master using RES Binary 
// File option. This was converted from OWIMG.RES to OWIMG.OBJ using RtBinObj 
// utility. Rhe following res functions below allow access to all the data in 
// the original OWIMG.RES file

#include <conio.h>
#include <dos.h>
#include <graph.h>
#include <stdlib.h>
#include <string.h>
#pragma pack(1)

extern char far owimg; 

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

// r,g,b values 0 to 63
void setrgb(int index, int  r,  int g,  int b){
  _remappalette(index,(r+((long)g << 8) + ((long)b << 16)));  
// _remappalette(index,(long)(r+(g*256) + (b * 65536)));  
}

void setrespal() {
  typedef  unsigned char  * paltype;
  paltype pal = GetResImagePtr(&owimg, GetResIndex(&owimg, "squarePal"));
  int i, c;

  c = 0;
  for (i = 0; i < 16; i++) {
    setrgb(i, pal[c], pal[c + 1], pal[c+2]);
    c += 3;
  }
}

int main() {
  int i;

   _setvideomode(_VRES16COLOR);  
  for(i=0;i<16;i++){
   _setcolor(i);
   _rectangle(_GFILLINTERIOR,i*20,20,i*20+19,180);
  }
  getch();
  setrespal();
  getch();

  _putimage(200, 20, GetResImagePtr(&owimg, GetResIndex(&owimg, "squareMask")), _GAND);
  _putimage(200, 20, GetResImagePtr(&owimg, GetResIndex(&owimg, "square")), _GOR);

  _putimage(100, 20, GetResImagePtr(&owimg, GetResIndex(&owimg, "circleMask")), _GAND);
  _putimage(100, 20, GetResImagePtr(&owimg, GetResIndex(&owimg, "circle")), _GOR);

  _putimage(150, 20, GetResImagePtr(&owimg, GetResIndex(&owimg, "crossMask")), _GAND);
  _putimage(150, 20, GetResImagePtr(&owimg, GetResIndex(&owimg, "cross")), _GOR);

  getch();
  _setvideomode(_DEFAULTMODE);
  return 0;
}
