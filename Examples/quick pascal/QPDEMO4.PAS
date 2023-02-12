(* *************************************************************** *)
(* qpdemo4.pas VGA Palette Demo for Quick Pascal                   *)
(*                                                                 *)
(* _remappalette commands were created by Exporting palette from   *)
(* Raster Master. Palette->Export->Quick Pascal->Palette Commands  *)
(* *************************************************************** *)

Program QPDemo4;
 uses Crt,Dos,MSGraph;

procedure init_vga_palette;
var
 error : longint;
begin
(* Quick Pascal Palette Commands,  Size= 48 Colors= 16 Format=6 Bit *)
error:=_remappalette( 0, 21);
error:=_remappalette( 1, 2752539);
error:=_remappalette( 2, 10782);
error:=_remappalette( 3, 2763297);
error:=_remappalette( 4, 54);
error:=_remappalette( 5, 2752564);
error:=_remappalette( 6, 5432);
error:=_remappalette( 7, 2763316);
error:=_remappalette( 8, 1381668);
error:=_remappalette( 9, 4134187);
error:=_remappalette( 10, 1392432);
error:=_remappalette( 11, 4144940);
error:=_remappalette( 12, 1387327);
error:=_remappalette( 13, 4140351);
error:=_remappalette( 14, 3161919);
error:=_remappalette( 15, 4143420);
end;

var
 result : integer;
 key    : char;
 i      : integer;
begin
  result:=_setvideomode(_MRES16COLOR);

  for i:=0 to 15 do
  begin
   _setcolor(i);
   _rectangle(_GFILLINTERIOR,i*20,20,i*20+19,180);
  end;

  _settextcolor(15);
  _settextposition( 16, 4 );
  _outtext('Press a key to change palette');

  key:=readkey;

  init_vga_palette;
  result:=_setvideomode(_DEFAULTMODE);
end.

