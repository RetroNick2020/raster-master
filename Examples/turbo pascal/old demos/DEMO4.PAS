(*

   ----------------------------------------------------------
   WriteDef procedure                                    RWDef
   ----------------------------------------------------------

   Function   : Save an area of the screen as a DEF file.

   Decloration: WriteDef(Filename : String; X1,Y1,X2,Y2 : Word)

   Remarks    : I/O checking is NOT performed.
                This method of saving an Image is not very
                efficient, but the format is simple. The
                Image is saved as a Text file, you can
                load it into your regular text editor
                and look at it with no problems. Each pixel's
                color is represented by a HEX degit. The following
                is a white box with a black arrow in the centre.


                FFFFFFFFFF
                FFF0FFFFFF
                FF0FFFFFFF
                F00000000F
                FF0FFFFFFF
                FFF0FFFFFF
                FFFFFFFFFF

*)


Program Demo4;
 Uses Graph,RWDEF;
Var
 Gd   : Integer;
 Gm   : Integer;
Begin
 Gd:=EGA;
 Gm:=EGAhi;
 InitGraph(Gd,Gm,'');
                                           (* Draw something *)
 SetFillStyle(XhatchFill,Blue);
 Bar(0,0,30,30);
 SetFillStyle(SolidFill,LightRed);
 Bar(20,20,40,40);


 WriteDef('BOX2.DEF',0,0,40,40);           (* Save Image as DEF file *)

 ReadLn;                                   (* Wait for Enter Key *)

 CloseGraph;                               (* Close graphics *)
End.