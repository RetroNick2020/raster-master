/* *************************************************************** */
/* qcdemo4.c VGA Palette Demo for QuickC                           */
/*                                                                 */
/* compile with: qcl owdemo4.c                                     */
/*                                                                 */
/* _remappalette commands were created by Exporting palette from   */
/* Raster Master. Palette->Export->QuickC->Palette Commands        */
/* *************************************************************** */

#include <graph.h>
#include <stdio.h>
#include <conio.h>

void init_vga_palette(void){
/* QuickC Palette Commands,  Size= 48 Colors= 16 Format=6 Bit */
_remappalette( 0, 21);
_remappalette( 1, 2752539);
_remappalette( 2, 10782);
_remappalette( 3, 2763297);
_remappalette( 4, 54);
_remappalette( 5, 2752564);
_remappalette( 6, 5432);
_remappalette( 7, 2763316);
_remappalette( 8, 1381668);
_remappalette( 9, 4134187);
_remappalette( 10, 1392432);
_remappalette( 11, 4144940);
_remappalette( 12, 1387327);
_remappalette( 13, 4140351);
_remappalette( 14, 3161919);
_remappalette( 15, 4143420);
}

void main(){
    int i;
   _setvideomode(_MRES16COLOR );  
   
   for(i=0;i<16;i++){
    _setcolor(i);
    _rectangle(_GFILLINTERIOR,i*20,20,i*20+19,180);
   }
   _settextcolor(15);
   _settextposition( 16, 4 );
   _outtext( "Press a key to change palette" );
   getch();
   init_vga_palette();
   getch();

  _setvideomode(_DEFAULTMODE);
}

