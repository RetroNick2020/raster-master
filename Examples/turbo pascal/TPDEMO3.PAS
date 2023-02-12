(* ************************************************************ *)
(* tpdemo3.pas For Turbo Pascal                                 *)
(*                                                              *)
(* mshape was created by Exporting image as mouse shape array   *)
(* from Raster Master.                                          *)
(* ************************************************************ *)

Program TPDEMO3;
 uses Crt,Dos,Graph;
Const
  MOUSE_DRIVER_INTERRUPT = $33;

(* **************** *)
(* **********#####* *)
(* ****XXX***#***#* *)
(* ***XXXXX**#***#* *)
(* **XXXXXXX*#***#* *)
(* **XXXXXXX*#***#* *)
(* **XXXXXXX*#####* *)
(* ***XXXXX******** *)
(* ****XXX***   *** *)
(* *********     ** *)
(* *######*       * *)
(* *#****#*       * *)
(* *#****#*       * *)
(* *#****#**     ** *)
(* *######***   *** *)
(* **************** *)
(* Pascal, Size= 64 Width= 16 Height= 16  *)
(* DOS Mouse Shape *)
 MShape_Size = 64;
 MShape_Width = 16;
 MShape_Height = 16;
 MShape_Colors = 4;
 MShape_Id = 1;
 MShape : array[0..63] of byte = (
  $00,$00,$00,$00,$00,$0E,$00,$1F,$80,$3F,$80,$3F,$80,$3F,$00,$1F,$38,$0E,$7C,$00,
  $FE,$00,$FE,$00,$FE,$00,$7C,$00,$38,$00,$00,$00,$00,$00,$3E,$00,$22,$0E,$22,$1F,
  $A2,$3F,$A2,$3F,$BE,$3F,$00,$1F,$00,$0E,$00,$00,$00,$7E,$00,$42,$00,$42,$00,$42,
  $00,$7E,$00,$00);

var
 regs : Registers;

procedure call_mouse(mouse_function : integer);
begin
   regs.ax := mouse_function;
   intr(MOUSE_DRIVER_INTERRUPT, regs);
end;

procedure show_mouse;
begin
  call_mouse(1);
end;

procedure mouse_graph_cursor(hHot,vHot : integer; mask_segment,mask_offset : word);
begin
  with regs do
  begin
    BX:=hHot;
    CX:=vHot;
    DX:=mask_offset;
    ES:=mask_segment;
  end;
  call_mouse(9);
end;

var
 i      : integer;
 key    : char;
 gd,gm  : integer;
begin
  gd:=EGA;
  gm:=EGAHI;
  initgraph(gd, gm, '');

  for i:=0 to 15 do
  begin
   setfillstyle(SOLIDFILL,i);
   bar(i*20,20,i*20+19,180);
  end;

  show_mouse;
  mouse_graph_cursor(7,7,Seg(MShape),Ofs(MShape));

  key:=readkey;
  closegraph;
end.


