(* ************************************************************ *)
(* tpdemo5.pas putimage link to exe demo For Turbo Pascal       *)
(*                                                              *)
(* TP.XGF was created by Exporting image as putimage file       *)
(* from Raster Master. Borland's Turbo Pascal BINOBJ was used to*)
(* to convert image to obj format. This allows us to link image *)
(* to exe without creating arrays.                              *)
(*                                                              *)
(* BGIOBJ tp.xgf tp.obj tp                                      *)
(* tpc tpdemo5.pas                                              *)
(* ************************************************************ *)

Program TPDemo5;
 uses Crt,Graph;

procedure tp;external;
{$L tp.obj}

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
  ImgBuf:=@tp;
  putimage(120,100,ImgBuf^,COPYPUT);

  key:=readkey;
  closegraph;
end.

