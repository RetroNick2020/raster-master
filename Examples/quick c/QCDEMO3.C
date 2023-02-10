/* ************************************************************ */
/* owdemo3.c For Open Watcom                                    */
/*                                                              */
/* mshape was created by Exporting image as mouse shape array   */
/* from Raster Master.                                          */
/* ************************************************************ */

#include <graph.h>
#include <stdio.h>
#include <conio.h>
#include <dos.h>

#define  MOUSE_DRIVER_INTERRUPT 0x33

/* **************** */
/* **************** */
/* **************** */
/* **************** */
/* *****##XXX****** */
/* ***##XXXXXXX**** */
/* ***##XXXXXXX**** */
/* **##XXXXXXXXX*** */
/* **##XXXXXXXXX*** */
/* **##XXXXXXXXX*** */
/* ***##XXXXXXX**** */
/* ***##XXXXXXX**** */
/* *****##XXX****** */
/* **************** */
/* **************** */
/* **************** */
/* C, Size= 64 Width= 16 Height= 16  */
/* DOS Mouse Shape */
 #define mshape_Size 64
 #define mshape_Width 16
 #define mshape_Height 16
 #define mshape_Colors 4
 #define mshape_Id 1

 char mshape[64]  = {
  0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xc0,0x01,0xf0,0x07,0xf0,0x07,0xf8,0x0f,0xf8,0x0f,0xf8,0x0f,
  0xf0,0x07,0xf0,0x07,0xc0,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
  0xc0,0x07,0xf0,0x1f,0xf0,0x1f,0xf8,0x3f,0xf8,0x3f,0xf8,0x3f,0xf0,0x1f,0xf0,0x1f,0xc0,0x07,0x00,0x00,
  0x00,0x00,0x00,0x00};

void call_mouse(int mouse_function){
   union REGS inregs,outregs;

   inregs.x.ax = mouse_function;
   int86(MOUSE_DRIVER_INTERRUPT, &inregs, &outregs);
}
 
void show_mouse(void){
  call_mouse(1);
} 

void mouse_graph_cursor(int hHot, int vHot, char _far  *shape ){
  _asm {
    les     di, shape
    mov     bx, hHot
    mov     cx, vHot
    mov     dx, di
    mov     ax, 9
    int     33h
  }
}

main() {
    int i;
   _setvideomode(_MRES16COLOR);
  
  for(i=0;i<16;i++){
   _setcolor(i);
   _rectangle(_GFILLINTERIOR,i*20,20,i*20+19,180);
  }
 
  show_mouse();
  mouse_graph_cursor(7,7,mshape);
  getch();
  _setvideomode(_DEFAULTMODE);
}

