(* ************************************************************ *)
(* fpdemo2.pas For FreePascal 8086                              *)
(*                                                              *)
(* compile with: ppcross8086 -WmLarge FPDEMO2.PAS               *)
(*                                                              *)
(* cross was created by Exporting image as putimage+Mask array  *)
(* from Raster Master.                                          *)
(* ************************************************************ *)

Program FPDemo2;
 uses crt,graph;

const
(* FreePascal PutImage Bitmap Code Created By Raster Master *)
(* Size= 2060 Width= 32 Height= 32 Colors= 16 *)
 Cross_Size = 2060;
 Cross_Width = 32;
 Cross_Height = 32;
 Cross_Colors = 16;
 Cross_Id = 0;
 Cross : array[0..2059] of byte = (
  $20,$00,$00,$00,$20,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
  $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0E,$00,
  $0E,$00,$0C,$00,$0C,$00,$0E,$00,$0E,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
  $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
  $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
  $00,$00,$0E,$00,$0E,$00,$0C,$00,$0C,$00,$0E,$00,$0E,$00,$00,$00,$00,$00,$00,$00,
  $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
  $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
  $00,$00,$00,$00,$00,$00,$0E,$00,$0E,$00,$0C,$00,$0C,$00,$0E,$00,$0E,$00,$00,$00,
  $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
  $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
  $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0E,$00,$0E,$00,$0C,$00,$0C,$00,$0E,$00,
  $0E,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
  $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
  $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0E,$00,$0E,$00,$0C,$00,
  $0C,$00,$0E,$00,$0E,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
  $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
  $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0E,$00,
  $0E,$00,$0C,$00,$0C,$00,$0E,$00,$0E,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
  $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
  $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
  $00,$00,$0E,$00,$0E,$00,$0C,$00,$0C,$00,$0E,$00,$0E,$00,$00,$00,$00,$00,$00,$00,
  $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
  $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
  $00,$00,$00,$00,$00,$00,$0E,$00,$0E,$00,$0C,$00,$0C,$00,$0E,$00,$0E,$00,$00,$00,
  $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
  $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
  $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0E,$00,$0E,$00,$0C,$00,$0C,$00,$0E,$00,
  $0E,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
  $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
  $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0E,$00,$0E,$00,$0C,$00,
  $0C,$00,$0E,$00,$0E,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
  $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
  $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0E,$00,
  $0E,$00,$0C,$00,$0C,$00,$0E,$00,$0E,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
  $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
  $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
  $00,$00,$0E,$00,$0E,$00,$0C,$00,$0C,$00,$0E,$00,$0E,$00,$00,$00,$00,$00,$00,$00,
  $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
  $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
  $00,$00,$00,$00,$00,$00,$0E,$00,$0E,$00,$0C,$00,$0C,$00,$0E,$00,$0E,$00,$00,$00,
  $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
  $00,$00,$00,$00,$0E,$00,$0E,$00,$0E,$00,$0E,$00,$0E,$00,$0E,$00,$0E,$00,$0E,$00,
  $0E,$00,$0E,$00,$0E,$00,$0E,$00,$0E,$00,$0E,$00,$0E,$00,$0C,$00,$0C,$00,$0E,$00,
  $0E,$00,$0E,$00,$0E,$00,$0E,$00,$0E,$00,$0E,$00,$0E,$00,$0E,$00,$0E,$00,$0E,$00,
  $0E,$00,$0E,$00,$0E,$00,$0E,$00,$0E,$00,$0E,$00,$0E,$00,$0E,$00,$0E,$00,$0E,$00,
  $0E,$00,$0E,$00,$0E,$00,$0E,$00,$0E,$00,$0E,$00,$0E,$00,$0E,$00,$0E,$00,$0C,$00,
  $0C,$00,$0E,$00,$0E,$00,$0E,$00,$0E,$00,$0E,$00,$0E,$00,$0E,$00,$0E,$00,$0E,$00,
  $0E,$00,$0E,$00,$0E,$00,$0E,$00,$0E,$00,$0E,$00,$0C,$00,$0C,$00,$0C,$00,$0C,$00,
  $0C,$00,$0C,$00,$0C,$00,$0C,$00,$0C,$00,$0C,$00,$0C,$00,$0C,$00,$0C,$00,$0E,$00,
  $0E,$00,$0C,$00,$0C,$00,$0E,$00,$0E,$00,$0C,$00,$0C,$00,$0C,$00,$0C,$00,$0C,$00,
  $0C,$00,$0C,$00,$0C,$00,$0C,$00,$0C,$00,$0C,$00,$0C,$00,$0C,$00,$0C,$00,$0C,$00,
  $0C,$00,$0C,$00,$0C,$00,$0C,$00,$0C,$00,$0C,$00,$0C,$00,$0C,$00,$0C,$00,$0C,$00,
  $0C,$00,$0E,$00,$0E,$00,$0C,$00,$0C,$00,$0E,$00,$0E,$00,$0C,$00,$0C,$00,$0C,$00,
  $0C,$00,$0C,$00,$0C,$00,$0C,$00,$0C,$00,$0C,$00,$0C,$00,$0C,$00,$0C,$00,$0C,$00,
  $0E,$00,$0E,$00,$0E,$00,$0E,$00,$0E,$00,$0E,$00,$0E,$00,$0E,$00,$0E,$00,$0E,$00,
  $0E,$00,$0E,$00,$0E,$00,$0E,$00,$0E,$00,$0C,$00,$0C,$00,$0E,$00,$0E,$00,$0E,$00,
  $0E,$00,$0E,$00,$0E,$00,$0E,$00,$0E,$00,$0E,$00,$0E,$00,$0E,$00,$0E,$00,$0E,$00,
  $0E,$00,$0E,$00,$0E,$00,$0E,$00,$0E,$00,$0E,$00,$0E,$00,$0E,$00,$0E,$00,$0E,$00,
  $0E,$00,$0E,$00,$0E,$00,$0E,$00,$0E,$00,$0E,$00,$0E,$00,$0C,$00,$0C,$00,$0E,$00,
  $0E,$00,$0E,$00,$0E,$00,$0E,$00,$0E,$00,$0E,$00,$0E,$00,$0E,$00,$0E,$00,$0E,$00,
  $0E,$00,$0E,$00,$0E,$00,$0E,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
  $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0E,$00,$0E,$00,$0C,$00,
  $0C,$00,$0E,$00,$0E,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
  $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
  $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0E,$00,
  $0E,$00,$0C,$00,$0C,$00,$0E,$00,$0E,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
  $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
  $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
  $00,$00,$0E,$00,$0E,$00,$0C,$00,$0C,$00,$0E,$00,$0E,$00,$00,$00,$00,$00,$00,$00,
  $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
  $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
  $00,$00,$00,$00,$00,$00,$0E,$00,$0E,$00,$0C,$00,$0C,$00,$0E,$00,$0E,$00,$00,$00,
  $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
  $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
  $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0E,$00,$0E,$00,$0C,$00,$0C,$00,$0E,$00,
  $0E,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
  $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
  $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0E,$00,$0E,$00,$0C,$00,
  $0C,$00,$0E,$00,$0E,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
  $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
  $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0E,$00,
  $0E,$00,$0C,$00,$0C,$00,$0E,$00,$0E,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
  $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
  $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
  $00,$00,$0E,$00,$0E,$00,$0C,$00,$0C,$00,$0E,$00,$0E,$00,$00,$00,$00,$00,$00,$00,
  $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
  $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
  $00,$00,$00,$00,$00,$00,$0E,$00,$0E,$00,$0C,$00,$0C,$00,$0E,$00,$0E,$00,$00,$00,
  $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
  $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
  $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0E,$00,$0E,$00,$0C,$00,$0C,$00,$0E,$00,
  $0E,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
  $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
  $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0E,$00,$0E,$00,$0C,$00,
  $0C,$00,$0E,$00,$0E,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
  $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
  $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0E,$00,
  $0E,$00,$0C,$00,$0C,$00,$0E,$00,$0E,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
  $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
  $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
  $00,$00,$0E,$00,$0E,$00,$0C,$00,$0C,$00,$0E,$00,$0E,$00,$00,$00,$00,$00,$00,$00,
  $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00);

(* FreePascal PutImage Bitmap Code Created By Raster Master *)
(* Size= 2060 Width= 32 Height= 32 Colors= 16 *)
 CrossMask_Size = 2060;
 CrossMask_Width = 32;
 CrossMask_Height = 32;
 CrossMask_Colors = 16;
 CrossMask_Id = 0;
 CrossMask : array[0..2059] of byte = (
  $20,$00,$00,$00,$20,$00,$00,$00,$00,$00,$00,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,
  $0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$00,$00,
  $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,
  $0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,
  $0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,
  $0F,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0F,$00,$0F,$00,$0F,$00,
  $0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,
  $0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,
  $0F,$00,$0F,$00,$0F,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0F,$00,
  $0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,
  $0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,
  $0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
  $00,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,
  $0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,
  $0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$00,$00,$00,$00,$00,$00,
  $00,$00,$00,$00,$00,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,
  $0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,
  $0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$00,$00,
  $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,
  $0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,
  $0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,
  $0F,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0F,$00,$0F,$00,$0F,$00,
  $0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,
  $0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,
  $0F,$00,$0F,$00,$0F,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0F,$00,
  $0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,
  $0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,
  $0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
  $00,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,
  $0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,
  $0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$00,$00,$00,$00,$00,$00,
  $00,$00,$00,$00,$00,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,
  $0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,
  $0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$00,$00,
  $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,
  $0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,
  $0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,
  $0F,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0F,$00,$0F,$00,$0F,$00,
  $0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,
  $0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,
  $0F,$00,$0F,$00,$0F,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0F,$00,
  $0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,
  $0F,$00,$0F,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
  $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
  $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
  $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
  $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
  $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
  $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
  $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
  $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
  $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
  $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
  $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
  $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
  $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
  $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
  $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
  $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
  $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
  $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
  $00,$00,$00,$00,$00,$00,$00,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,
  $0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$00,$00,$00,$00,$00,$00,
  $00,$00,$00,$00,$00,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,
  $0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,
  $0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$00,$00,
  $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,
  $0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,
  $0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,
  $0F,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0F,$00,$0F,$00,$0F,$00,
  $0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,
  $0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,
  $0F,$00,$0F,$00,$0F,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0F,$00,
  $0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,
  $0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,
  $0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
  $00,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,
  $0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,
  $0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$00,$00,$00,$00,$00,$00,
  $00,$00,$00,$00,$00,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,
  $0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,
  $0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$00,$00,
  $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,
  $0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,
  $0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,
  $0F,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0F,$00,$0F,$00,$0F,$00,
  $0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,
  $0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,
  $0F,$00,$0F,$00,$0F,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0F,$00,
  $0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,
  $0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,
  $0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
  $00,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,
  $0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,
  $0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$00,$00,$00,$00,$00,$00,
  $00,$00,$00,$00,$00,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,
  $0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,
  $0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$00,$00,
  $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,
  $0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,
  $0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,
  $0F,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0F,$00,$0F,$00,$0F,$00,
  $0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00,$0F,$00);

var
  gd,gm  : integer;
  size   : longint;
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

  putimage(30,100,Cross,COPYPUT);
  putimage(70,100,Cross,NOTPUT);
  putimage(110,100,Cross,ANDPUT);
  putimage(150,100,Cross,ORPUT);
  putimage(190,100,Cross,XORPUT);

  (* using the CrossMask and cross image together with AND and OR operators
  we make it transparent *)
  putimage(230,100,CrossMask,ANDPUT);
  putimage(230,100,Cross,ORPUT);

  key:=readkey;
  closegraph;

end.

