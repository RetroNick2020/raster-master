(* ************************************************************ *)
(* fpdemo5.pas putimage link to exe demo For Freepascal Win32   *)
(*                                                              *)
(* FP.XGF was created by Exporting image as putimage file       *)
(* from Raster Master. LD command was used to convert image to  *)
(* obj format. This allows us to link image to exe without      *)
(* creating arrays.                                             *)
(*                                                              *)
(* ld -r -b binary -o fp.obj fp.xgf                             *)
(* fpc -Xe FPDEMO5.PAS                                          *)
(*                                                              *)
(* ************************************************************ *)

Program FPDemo5;
 uses PtcCrt,PtcGraph;

var
  key    : char;
  gd,gm  : integer;

  //execute LD -r -b binary -o fp.obj fp.xgf
  //fp.xgf is the exported image from Raster Master 
  //fp.obj is the object file it is conveted to
  
  {$L fp.obj}
  //link the fp.obj file 
  ImgBuf : pointer;external name '_binary_fp_xgf_start';
  //set ImgBuf to point to fp.obj by specifying name _binary_ + _filename + _extension + _start
  //if your file was named car.xgf your name would be _binary_car_xgf_start

begin
  gd:=EGA;
  gm:=EGAHI;
  initgraph(gd,gm,'');
  SetFillStyle(SolidFill,1);
  Bar(0,0,GetMaxX,GetMaxY);
  putimage(120,100,ImgBuf,COPYPUT);

  key:=readkey;
  closegraph;
  end.

