(* ************************************************************ *)
(* tpdemo1.pas For Turbo Pascal                                 *)
(*                                                              *)
(* TP.XGF was created by Exporting image as putimage file       *)
(* from Raster Master.                                          *)
(* ************************************************************ *)
Program TPDemo1;
uses Crt,Graph;

var
  ImgBuf : Pointer;
  F      : FILE;
  gd,gm  : integer;
  size   : longint;
  key    : char;
begin
  Assign(F,'TP.XGF');
  Reset(F,1);
  Size := FileSize(F);
  GetMem(ImgBuf, size);
  Blockread(F,ImgBuf^,size);
  Close(F);

  gd:=EGA;
  gm:=EGAHI;
  initgraph(gd,gm,'c:\tp7\bgi');
  SetFillStyle(SolidFill,1);
  Bar(0,0,GetMaxX,GetMaxY);

  putimage(100,100,ImgBuf^,NormalPut);
  Freemem(ImgBuf,size);

  key:=readkey;
  closegraph;
end.




