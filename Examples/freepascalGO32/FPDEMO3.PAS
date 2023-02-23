(* ************************************************************ *)
(* fpdemo3.pas For Freepascal GO32  with MSMouse unit           *)
(*                                                              *)
(* compile with: fpc FPDEMO3.PAS                                *)
(*                                                              *)
(* mshape was created by Exporting image as mouse shape array   *)
(* from Raster Master.                                          *)
(* ************************************************************ *)

Program FPDEMO3;
 uses Crt,Dos,GO32,Graph,MSMouse;
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
 regs : trealregs;
 { selector to our real mode buffer }
   selector,
 { real mode segment address of buffer }
   segment : Word;

{ Function : dosalloc }
{ Input    : size of a real mode location }
{ Output   : selector and segment of a real mode location }
procedure dosalloc(var selector : word;
        var segment : word; size : longint);
var
        res : longint;
begin
        { try to allocate real mode memory  }
        res := global_dos_alloc(size);
        { the lower 16 bits of the result contain the selector to the
        allocated memory block }
        selector := word(res);
        { the upper 16 bits contain the real mode segment address of
        this block; the offset is always 0, so we don't need to return
        this }
        segment := word(res shr 16);
end;

procedure dosfree(selector : word);
begin
        { call the GO32 function with the selector }
        global_dos_free(selector);
end;

procedure MouseGraphCursor(hHot, vHot: Integer; segment: Word);
begin
  Regs.AX := $09; // Set AX register to 0x09
  Regs.BX := hHot; // Set BX register to hHot
  Regs.CX := vHot; // Set CX register to vHot
  Regs.ES := segment; //Set ES to segment
  realintr(MOUSE_DRIVER_INTERRUPT, regs); // Call the Mouse Interrupt with code 0x33
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

  ShowMouse;

  //allocate real memory - MShape is in protected mode memory
  dosalloc(selector, segment, sizeof(MShape));
  
  //copy from protected memory to real memory
  dosmemput(segment, 0, MShape, sizeof(MShape));
  
  //mouse driver can see real memory but not protected memory
  MouseGraphCursor(7,7,segment);
  
  
  key:=readkey;
  HideMouse;
  dosfree(selector);
 
  closegraph;
end.


