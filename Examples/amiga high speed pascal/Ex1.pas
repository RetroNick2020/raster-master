(* Ex1.pas VSprite Demo for Hisoft High Speed Pascal *)

Program Ex1;
  uses graphics,intuition,exec;

Const
  WTitle : string = 'RM VSprite Demo - Use the arrow keys to move the VSprite!'#0; 
  STitle : string = 'VSprite'#0; 
	
  GRev = 33; (* graphics.library *)
  IRev = 33; (* Intuition.library *)

(* VSprite Colors *)
  vspritepal :  Array[1..3] of WORD = (
   $05F9,
   $0C0C,
   $0980);
   
  vspriteImage : array[0..15] of longint = (
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

var
  my_window : pWindow;
  my_screen : pScreen;
  my_new_window : tNewWindow;
  my_new_screen : tNewScreen;
  my_message : pIntuiMessage;
  my_code    : word;
  my_class   : long;

  vsprite_on : boolean;
  close_me   : Boolean;
  x,y        : integer;
  x_direction : integer;
  y_direction : integer;

  head,tail,my_vsprite : tVSprite;
  ginfo : tGelsInfo;
  nextline : array[0..7] of integer;
  lastcolor : array[0..7] of pointer;

  r : longint;  

procedure InitLibs;
begin
  IntuitionBase := pIntuitionBase(OpenLibrary('intuition.library', IRev));
  if IntuitionBase = NIL then exit;
  GfxBase := pGfxBase(OpenLibrary('graphics.library', GRev));
  if GfxBase = NIL then exit;
end;

Procedure CloseLibs;
begin
  if GfxBase <> NIL then CloseLibrary(pLibrary(GfxBase));
  if IntuitionBase <> NIL then CloseLibrary(pLibrary(IntuitionBase));
end;

procedure Clean_up;
var
 error : boolean;
begin
  (* Remove the VSprites: *)
  if (vsprite_on) then RemVSprite(@my_vsprite);
  (* Free the Allocated Memory *)
  if my_vsprite.ImageData<>NIL then FreeMem(my_vsprite.ImageData,sizeof(vspriteImage)); 
 
  (* close window and screen *) 
  if my_window <> NIL then CloseWindow(my_window);
  if my_screen <> NIL then  error :=CloseScreen(my_screen);
  CloseLibs;
end;


begin
  InitLibs;

  WITH my_new_screen DO
  begin
    leftEdge:=0; 
    topEdge:=0; 
    width:=640; 
    height:=200; 
    depth:=4;
    detailPen:=0; 
    blockPen:=1; 
    viewModes:=hires or sprites; 
    type_:=CUSTOMSCREEN; 
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
    type_:=CUSTOMSCREEN; 
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
  my_vsprite.Flags := VSPRITE;
  my_vsprite.X := x;
  my_vsprite.Y := y;
  my_vsprite.Height :=16;
  my_vsprite.Width := 1;
  my_vsprite.Depth := 2;

  my_vsprite.ImageData := AllocMem(sizeof(vspriteImage),MEMF_CHIP); 
  CopyMem(@vspriteImage, my_vsprite.ImageData, sizeof(vspriteImage));
  my_vsprite.SprColors := @vspritepal;
  AddVSprite(@my_vsprite, my_window^.RPort );

  vsprite_on :=TRUE;
  close_me   := FALSE;
  
  while(close_me = FALSE) do
  begin
    my_message :=pIntuiMessage(GetMsg(my_window^.UserPort));
    while  (my_message <> Nil) and (close_me=FALSE) do
    begin
      my_class := my_message^.Class;
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

    (* Play around with the VSprite: *)
    (* Change the x/y position: *)
    x := x + x_direction;
    y := y + y_direction;

    (* Check that the sprite does not move outside the screen: *)
    if (x > 640) then x := 640;
    if (x < 0) then x := 0;
    if (y > 200) then y := 200;
    if (y < 0) then y := 0;

    my_vsprite.X := x;
    my_vsprite.Y := y;

    (* Sort the Gels list: *)
    SortGList( my_window^.RPort );

    (* Draw the Gels list: *)
    DrawGList( my_window^.RPort, @my_screen^.ViewPort );

    (* Set the Copper and redraw the display: *)
    r:=MakeScreen(my_screen);
    r:=RethinkDisplay;
   end;
   Clean_up;
end.