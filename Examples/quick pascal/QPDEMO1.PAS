(* ************************************************************ *)
(* qcdemo1.pas For MS Quick Pascal                              *)
(*                                                              *)
(* QC.XGF was created by Exporting image as _putimage file      *)
(* from Raster Master.                                          *)
(* ************************************************************ *)

Program QPDemo1;
uses crt,msgraph;

var
  F      : FILE;
  ImgBuf : ^Byte;
  size   : longint;
  result : integer;
  key    : char;
begin
  Assign(F,'QP.XGF');
  Reset(F,1);
  Size := FileSize(F);
  GetMem(ImgBuf, size);
  Blockread(F,ImgBuf^,size);
  Close(F);

  result:=_setvideomode(_MRES16COLOR);    (* MRES256COLOR for 256 color images *)
  _setcolor(1);
  _rectangle(_GFILLINTERIOR,0,0,319,199);

  _putimage(0,0,ImgBuf^,_GPSET);
  Freemem(ImgBuf,size);

  key:=readkey;
  result:=_setvideomode(_DEFAULTMODE);
end.



