/* ************************************************************* */
/* owdemo4.c Mouse Demo for Open Watcom C in DOS4G (32 bit mode) */
/*                                                               */
/* compile with: wcl386 /l=dos4g owdemo4.c                       */
/*                                                               */
/* mshape was created by Exporting image as mouse shape array    */
/* from Raster Master.                                           */
/* ************************************************************* */

#include <graph.h>
#include <stdio.h>
#include <conio.h>
#include <i86.h>
#include <dos.h>

#define  MOUSE_DRIVER_INTERRUPT 0x33
struct SREGS s;           //put sregs/regs globally otherwise it crashes when compiling for 32bit
union  REGS  in, out;     //not a problem when compiling for 16bit
  
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
   in.w.ax = mouse_function;
   int386(MOUSE_DRIVER_INTERRUPT, &in, &out);
}
 
void show_mouse(void){
   call_mouse(1);
} 

void mouse_graph_cursor(int hHot, int vHot,unsigned int mask_segment, unsigned mask_offset){
   in.w.ax  = 0x9;
   in.w.bx  = hHot;
   in.w.cx  = vHot;
   in.x.edx = mask_offset;
   s.es     = mask_segment;
   int386x( 0x33, &in, &out, &s );
}

void main(){
    int i;
   _setvideomode(_MRES16COLOR);  
  
   for(i=0;i<16;i++){
    _setcolor(i);
    _rectangle(_GFILLINTERIOR,i*20,20,i*20+19,180);
   }
 
   show_mouse();
   mouse_graph_cursor(7,7,FP_SEG(mshape),FP_OFF(mshape));
   getch();

  _setvideomode(_DEFAULTMODE);
}

