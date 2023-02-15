(* *************************************************************** *)
(* fpdemo4.pas VGA Palette Demo for Freepascal GO32                *)
(*                                                                 *)
(* compile with: fpc FPDEMO4.PAS                                   *)
(*                                                                 *)
(* setrgbpalette commands were created by Exporting palette from   *)
(* Raster Master. Palette->Export->FreePascal->Palette Commands    *)
(* *************************************************************** *)
Program FPDemo4;
 uses Crt,Graph;

procedure init_vga_palette;
begin
(* Free Pascal Palette Commands,  Size= 48 Colors= 16 Format=8 Bit *)
setrgbpalette( 0, 85, 0, 0);
setrgbpalette( 1, 109, 0, 170);
setrgbpalette( 2, 121, 170, 0);
setrgbpalette( 3, 133, 170, 170);
setrgbpalette( 4, 218, 0, 0);
setrgbpalette( 5, 210, 0, 170);
setrgbpalette( 6, 226, 85, 0);
setrgbpalette( 7, 210, 170, 170);
setrgbpalette( 8, 145, 85, 85);
setrgbpalette( 9, 174, 85, 255);
setrgbpalette( 10, 194, 255, 85);
setrgbpalette( 11, 178, 255, 255);
setrgbpalette( 12, 255, 174, 85);
setrgbpalette( 13, 255, 182, 255);
setrgbpalette( 14, 255, 255, 194);
setrgbpalette( 15, 242, 230, 255);
end;

var
  gd,gm  : integer;
  key    : char;
  i      : integer;
begin
  gd:=EGA;
  gm:=EGAHI;
  initgraph(gd,gm,'');
  SetFillStyle(SolidFill,1);
  Bar(0,0,GetMaxX,GetMaxY);

  for i:=0 to 15 do
  begin
   setfillstyle(SOLIDFILL,i);
   bar(i*20,20,i*20+19,180);
  end;

  setcolor(15);
  outtextxy(30,200,'Press a key to change palette');
  key:=readkey;
  init_vga_palette;
  key:=readkey;
  closegraph;
end.


