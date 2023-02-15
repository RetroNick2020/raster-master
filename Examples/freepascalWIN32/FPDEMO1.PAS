(* ************************************************************ *)
(* fpdemo1.pas For Freepacal WIN32                              *)
(*                                                              *)
(* compile with: fpc FPDEMO1.PAS                                *)
(*                                                              *)
(* FP.XGF was created by Exporting image as putimage file       *)
(* from Raster Master.                                          *)
(* ************************************************************ *)
Program FPDemo1;
uses PtcCrt,PtcGraph;

var
  ImgBuf : Pointer;
  F      : FILE;
  gd,gm  : integer;
  size   : longint;
  key    : char;
begin
  Assign(F,'FP.XGF');
  Reset(F,1);
  Size := FileSize(F);
  GetMem(ImgBuf, size);
  Blockread(F,ImgBuf^,size);
  Close(F);

  gd:=EGA;
  gm:=EGAHI;
  initgraph(gd,gm,'');
  SetFillStyle(SolidFill,1);
  Bar(0,0,GetMaxX,GetMaxY);

  putimage(100,100,ImgBuf^,NormalPut);
  Freemem(ImgBuf,size);

  key:=readkey;
  closegraph;
end.




