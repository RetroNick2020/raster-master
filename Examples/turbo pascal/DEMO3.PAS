(*

   ----------------------------------------------------------
   DisplayDef procedure                                 RWDef
   ----------------------------------------------------------

   Function   : Reads a DEF file.

   Decloration: ReadDef(Filename : String; X,Y : Word)

   Remarks    : NO I/O checking performed
                NO checking is done to verify that its a valid
                DEF file.

*)




Program Demo3;
 Uses Graph,RWDEF;
Var
 Gd   : Integer;
 Gm   : Integer;
Begin
 Gd:=EGA;
 Gm:=EGAhi;
 InitGraph(Gd,Gm,'');

 ReadDef('RM.DEF',0,0);                    (* Display DEF file to Screen *)

 ReadLn;                                   (* Wait for Enter Key *)

 CloseGraph;                               (* Close graphics *)
End.