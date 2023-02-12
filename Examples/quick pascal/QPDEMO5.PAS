(* ************************************************************ *)
(* qpdemo5.pas _putimage link to exe demo For MS Quick Pascal   *)
(*                                                              *)
(* QP.XGF was created by Exporting image as _putimage file      *)
(* from Raster Master. Borland's Turbo Pascal BINOBJ was used to*)
(* to convert image to obj format. This allows us to link image *)
(* to exe without creating pascal arrays.                       *)
(*                                                              *)
(* BINOBJ qp.xgf qp.obj qp                                      *)
(* qpl  qpdemo5.pas                                             *)
(* ************************************************************ *)
Program QPDemo5;
 uses Crt,MSGraph;


procedure qp;external;
{$L qp.obj}

var
 result : integer;
 key    : char;
 ImgBuf : ^Byte;
begin
  result:=_setvideomode(_MRES16COLOR);
  ImgBuf:=@qp;
  _putimage(120,100,ImgBuf^,_GPSET);

  key:=readkey;
  result:=_setvideomode(_DEFAULTMODE);
end.

