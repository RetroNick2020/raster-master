(* ************************************************************ *)
(* demo1.pas For TMT Pascal                                 *)
(*                                                              *)
(* TMT.XGF was created by Exporting image as putimage file       *)
(* from Raster Master.                                          *)
(* ************************************************************ *)
Program Demo1;
uses Crt,Graph;

var
  ImgBuf : Pointer;
  F      : FILE;
  size   : longint;
  key    : char;
begin
  Assign(F,'TMT.XGF');
  Reset(F,1);
  Size := FileSize(F);
  GetMem(ImgBuf, size);
  Blockread(F,ImgBuf^,size);
  Close(F);

  SetGraphMode($13);
  SetFillStyle(SolidFill,1);
  Bar(0,0,GetMaxX,GetMaxY);

  putimage(100,100,ImgBuf^);
  Freemem(ImgBuf,size);

  key:=readkey;
  closegraph;
end.




