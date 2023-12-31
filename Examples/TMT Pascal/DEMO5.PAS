(* ************************************************************ *)
(* demo5.pas putimage link to exe demo For Turbo Pascal         *)
(*                                                              *)
(* TMT.XGF was created by Exporting image as putimage file      *)
(* from Raster Master. rtbinojbgui tool was used (check gitgub) *)
(* to convert image to obj format. This allows us to link image *)
(* to exe without creating arrays.                              *)
(*                                                              *)
(* ************************************************************ *)

Program TPDemo5;
 uses Crt,Graph;

procedure tmt;external;
{$L tmt.obj}

var
  key    : char;
  ImgBuf : Pointer;
begin
  SetGraphMode($13);  
  SetFillStyle(SolidFill,1);
  Bar(0,0,GetMaxX,GetMaxY);
  ImgBuf:=@tmt;
  putimage(120,100,ImgBuf^);

  key:=readkey;
  closegraph;
end.

