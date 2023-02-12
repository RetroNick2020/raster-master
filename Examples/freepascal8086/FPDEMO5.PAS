(* ************************************************************ *)
(* fpdemo5.pas putimage link to exe demo For Turbo Pascal       *)
(*                                                              *)
(* FP.XGF was created by Exporting image as putimage file       *)
(* from Raster Master. Borland's Turbo C BGIOBJ was used to     *)
(* to convert image to obj format. This allows us to link image *)
(* to exe without creating arrays.                              *)
(*                                                              *)
(* BGIOBJ fp.xgf fp.obj fp                                      *)
(* ppcross8086 -WmLarge FPDEMO5.PAS                             *)
(*                                                              *)
(* Note: Do not use Turbo Pascal BINOBJ - it does not work      *)
(*       You do need to use Turbo C BGIOBJ - Not a mistake      *)
(*                                                              *)                                                    
(* ************************************************************ *)

Program FPDemo5;
 uses Crt,Graph;

procedure fp;external;
{$L fp.obj}

var
  key    : char;
  ImgBuf : Pointer;
  gd,gm  : integer;
begin
  gd:=EGA;
  gm:=EGAHI;
  initgraph(gd,gm,'');
  SetFillStyle(SolidFill,1);
  Bar(0,0,GetMaxX,GetMaxY);
  ImgBuf:=@fp;
  
  putimage(120,100,ImgBuf^,COPYPUT);

  key:=readkey;
  closegraph;
end.

