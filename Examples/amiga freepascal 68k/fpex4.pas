(* Ex4.pas Raster Master Bob and VSprite demo for Amiga freepascal 68k *)

Program fpex4;
  uses agraphics,intuition,exec;

Const
  WTitle : string = 'RM Bob and VSprite Demo - Use the arrow keys to move the shapes!'#0; 
  STitle : string = 'Bob and VSprite!'#0; 
	
(* VSprite Colors *)
  vspal :  Array[1..3] of WORD = (
   $05F9,
   $0C0C,
   $0980);
   
  vsimg : array[0..15] of longword = (
  $00800140,
  $00800140,
  $00800140,
  $00800140,
  $00800140,
  $00800140,
  $00800140,
  $00800140,
  $00800140,
  $00800140,
  $06B00770,
  $06B00770,
  $0EB80F78,
  $1EBC1F7C,
  $1EBC1F7C,
  $1EBC1F7C);

(* Amiga Pascal, Size= 256 Width= 32 Height= 32 Colors= 4 *)
(* BOB Bitmap *)
 img : array[0..255] of byte = (
  $00,$80,$00,$00,$00,$80,$00,$00,$00,$80,$07,$C0,$00,$80,$0F,$E0,$00,$80,$1C,$70,
  $00,$80,$38,$38,$00,$80,$30,$18,$00,$80,$30,$18,$00,$80,$30,$18,$00,$80,$38,$38,
  $06,$B0,$1C,$70,$06,$B0,$0F,$E0,$0E,$B8,$07,$C0,$1E,$BC,$00,$00,$1E,$BC,$00,$00,
  $1E,$BC,$00,$00,$00,$00,$3D,$78,$00,$00,$3D,$78,$00,$00,$3D,$78,$03,$E0,$1D,$70,
  $07,$F0,$0D,$60,$0E,$38,$0D,$60,$1C,$1C,$01,$00,$18,$0C,$01,$00,$18,$0C,$01,$00,
  $18,$0C,$01,$00,$1C,$1C,$01,$00,$0E,$38,$01,$00,$07,$F0,$01,$00,$03,$E0,$01,$00,
  $00,$00,$01,$00,$00,$00,$01,$00,$01,$40,$00,$00,$01,$40,$00,$00,$01,$40,$00,$00,
  $01,$40,$00,$00,$01,$40,$03,$80,$01,$40,$07,$C0,$01,$40,$0F,$E0,$01,$40,$0F,$E0,
  $01,$40,$0F,$E0,$01,$40,$07,$C0,$07,$70,$03,$80,$07,$70,$00,$00,$0F,$78,$00,$00,
  $1F,$7C,$00,$00,$1F,$7C,$00,$00,$1F,$7C,$00,$00,$00,$00,$3E,$F8,$00,$00,$3E,$F8,
  $00,$00,$3E,$F8,$00,$00,$1E,$F0,$00,$00,$0E,$E0,$01,$C0,$0E,$E0,$03,$E0,$02,$80,
  $07,$F0,$02,$80,$07,$F0,$02,$80,$07,$F0,$02,$80,$03,$E0,$02,$80,$01,$C0,$02,$80,
  $00,$00,$02,$80,$00,$00,$02,$80,$00,$00,$02,$80,$00,$00,$02,$80);
var
  my_window : pWindow;
  my_screen : pScreen;
  my_new_window : tNewWindow;
  my_new_screen : tNewScreen;
  my_message : pIntuiMessage;
  my_code    : word;
  my_class   : long;

  bob_on : boolean;
  vsprite_on : Boolean;
  close_me   : Boolean;
  x,y        : integer;
  x_direction : integer;
  y_direction : integer;

  head,tail,my_vsprite,my_vsprite2 : tVSprite;
  my_bob : tBob;        
  ginfo : tGelsInfo;
  nextline : array[0..7] of integer;
  lastcolor : array[0..7] of pointer;

(*was not finding this procedure with fpc 3.2.0 - remove if current version supports it *)
procedure RemBob(Bob : PBob);
begin
 Bob^.Flags:=Bob^.Flags or BOBSAWAY;
end;

procedure Clean_up;
begin
  (* Remove the Bob *)
  if (bob_on) then RemBob(@my_bob);

  (* Remove the VSprite *)
  if (vsprite_on) then RemVSprite(@my_vsprite2);

  (* Free the Allocated Memory *)
  if my_vsprite.ImageData<>NIL then ExecFreeMem(my_vsprite.ImageData,sizeof(img)); 
  if my_vsprite.BorderLine<>NIL then ExecFreeMem(my_vsprite.Borderline,4);
  if my_vsprite.CollMask<>NIL then ExecFreeMem(my_vsprite.CollMask,4*32);
  if my_bob.SaveBuffer <>NIL then  ExecFreeMem(my_bob.SaveBuffer,sizeof(img));
  
  if my_vsprite2.ImageData<>NIL then ExecFreeMem(my_vsprite2.ImageData,sizeof(vsImg)); 
  if my_vsprite2.BorderLine<>NIL then ExecFreeMem(my_vsprite2.BorderLine,2);
  if my_vsprite2.CollMask<>NIL then ExecFreeMem(my_vsprite2.CollMask,2*16);

  (* close window and screen *) 
  if my_window <> NIL then CloseWindow(my_window);
  if my_screen <> NIL then  CloseScreen(my_screen);
end;


begin
  bob_on :=FALSE;
  vsprite_on:=FALSE;

  WITH my_new_screen DO
  begin
    leftEdge:=0; 
    topEdge:=0; 
    width:=640; 
    height:=200; 
    depth:=2;
    detailPen:=0; 
    blockPen:=1; 
    viewModes:=hires or sprites; 
    stype:=CUSTOMSCREEN_F; 
    font:=NIL; 
    defaultTitle:=@STitle[1]; 
    gadgets:=NIL;
    customBitMap:=NIL; 
  END;

  WITH my_new_window DO
  begin 
    leftEdge:=0; 
    topEdge:=0; 
    width:=640; 
    height:=200; 
    minwidth:=80;
    minheight:=30;
    detailPen:=0;
    blockPen:=1; 
    idcmpFlags:=IDCMP_RAWKEY  or IDCMP_CLOSEWINDOW;
    flags := WFLG_SMART_REFRESH or
             WFLG_DRAGBAR or
             WFLG_DEPTHGADGET or 
             WFLG_ACTIVATE or 
             WFLG_CLOSEGADGET or 
             WFLG_SIZEGADGET; 
    firstGadget:=NIL;
    title:=@WTitle[1]; 
    screen:=NIL; 
    bitMap:=NIL; 
    checkMark:=NIL;
    wtype:=CUSTOMSCREEN_F; 
  END;

  my_screen:=OpenScreen(@my_new_screen); 
  my_new_window.screen:=my_screen; 
  my_window:=OpenWindow(@my_new_window);

  ginfo.sprRsrvd:=-128;  (* need to confirm value for this  - seems to work with -128*)
  (* various ways that nextline and lastcolor are handled in books and examples I have looked at *)
  (*
  ginfo.nextLine:=AllocMem(sizeof(integer)*8, MEMF_CHIP or MEMF_CLEAR); 
  ginfo.lastColor:=AllocMem(sizeof(longint)*8,MEMF_CHIP or MEMF_CLEAR); 
  *)
  ginfo.nextLine := @nextline;
  ginfo.lastColor := @lastcolor; 

  my_window^.RPort^.GelsInfo := @ginfo;
  InitGels(@head,@tail,@ginfo); 

  x:=40;
  y:=40;
  my_vsprite.Flags := OVERLAY or SAVEBACK;
  my_vsprite.X := x;
  my_vsprite.Y := y;
  my_vsprite.Height :=32;
  my_vsprite.Width := 2;
  my_vsprite.Depth := 2;
  my_vsprite.PlanePick :=3;
  my_vsprite.PlaneOnOff :=0;

  my_vsprite.ImageData := ExecAllocMem(sizeof(img),MEMF_CHIP); 
  CopyMem(@img, my_vsprite.ImageData, sizeof(img));
  
  my_vsprite.VSBob := @my_bob;
  my_vsprite.BorderLine := ExecAllocMem(4,MEMF_CHIP);
  my_vsprite.CollMask := ExecAllocMem(4*32,MEMF_CHIP);

  my_vsprite.SprColors := NIL;
  
  my_bob.Flags := 0;
  my_bob.SaveBuffer := ExecAllocMem(sizeof(img), MEMF_CHIP);
  my_bob.ImageShadow := my_vsprite.CollMask;
  my_bob.Before := NIL;
  my_bob.After := NIL;
  my_bob.BobVSprite :=@my_vsprite;
  
  my_bob.BobComp := NIL;  
  my_bob.DBuffer := NIL;
  my_bob.BUserExt :=0;

  InitMasks(@my_vsprite);
  (*  Add the Bob to the Bob list: *)
  
  AddBob(@my_bob, my_window^.RPort );
  bob_on :=TRUE;

  my_vsprite2.Flags := VSPRITE_f;
  my_vsprite2.X := x+40;
  my_vsprite2.Y := y;
  my_vsprite2.Height :=16;
  my_vsprite2.Width := 1;
  my_vsprite2.Depth := 2;

  my_vsprite2.ImageData := ExecAllocMem(sizeof(vsimg),MEMF_CHIP); 
  CopyMem(@vsimg, my_vsprite2.ImageData, sizeof(vsimg));
  
  my_vsprite2.BorderLine := ExecAllocMem(2,MEMF_CHIP); 
  my_vsprite2.CollMask := ExecAllocMem(2*16,MEMF_CHIP); 

  my_vsprite2.SprColors := @vspal;
  
  InitMasks(@my_vsprite2);
  AddVSprite(@my_vsprite2,my_window^.RPort );
  
  vsprite_on := TRUE;
  
  close_me   := FALSE;
  
  while(close_me = FALSE) do
  begin
    my_message :=pIntuiMessage(GetMsg(my_window^.UserPort));
    while  (my_message <> Nil) and (close_me=FALSE) do
    begin
      my_class := my_message^.IClass;
      my_code  := my_message^.Code;
 
      if my_class = IDCMP_CLOSEWINDOW then  
      begin
        close_me:=TRUE;
      end  
      else if my_class = IDCMP_RAWKEY then 
      begin         
         if my_code =  $4C then  y_direction := -1
         else if my_code = $4C+$80 then y_direction := 0
         else if my_code = $4D then y_direction := 1
         else if my_code = $4D+$80 then y_direction := 0
         else if my_code = $4E then    x_direction := 2
         else if my_code = $4E + $80 then x_direction := 0
         else if my_code = $4F then  x_direction := -2
         else if my_code = $4F+$80 then x_direction := 0;
      end;
      ReplyMsg(pMessage(my_message));
      my_message :=pIntuiMessage(GetMsg(my_window^.UserPort));
    end;  

    (* Play around with the bob *)
    (* Change the x/y position: *)
    x := x + x_direction;
    y := y + y_direction;

    (* Check that the bob does not move outside the screen: *)
    if (x > 640) then x := 640;
    if (x < 0) then x := 0;
    if (y > 200) then y := 200;
    if (y < 0) then y := 0;

    my_vsprite.X := x;
    my_vsprite.Y := y;

    my_vsprite2.X := x+50;
    my_vsprite2.Y := y;

    (* Sort the Gels list: *)
    SortGList( my_window^.RPort );

    (* Draw the Gels list: *)
    DrawGList( my_window^.RPort, @my_screen^.ViewPort );
    
    (* Set the Copper and redraw the display: *)
    MakeScreen(my_screen);
    RethinkDisplay;
    
    (* Try commenting this command out to see if it makes a difference *)
    WaitTOF;
   end;
   Clean_up;
end.