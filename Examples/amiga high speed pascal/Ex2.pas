(* Ex2.pas Raster Master DrawImage demo for Hisoft High Speed Pascal *)

Program Ex2;
  uses graphics,intuition,exec,AmigaDos;

Const
  WTitle : string = 'RM DrawImage example'#0; 
	
  GRev = 33; (* graphics.library *)
  IRev = 33; (* Intuition.library *)


(* Amiga Pascal, Size= 256 Width= 32 Height= 32 Colors= 4 *)
(* BOB Bitmap *)
 TestImage : array[0..255] of byte = (
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
  my_new_window : tNewWindow;
  my_image : tImage;

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
begin
  (* Free the Allocated Memory *)
  if my_image.ImageData<>NIL then FreeMem(my_image.ImageData,sizeof(TestImage)); 
 
  (* close window and screen *) 
  if my_window <> NIL then CloseWindow(my_window);
  CloseLibs;
end;

begin
  InitLibs;
  WITH my_new_window DO
  begin 
    leftEdge:=40; 
    topEdge:=20; 
    width:=300; 
    height:=200; 
    minwidth:=0;
    minheight:=0;
    maxwidth:=0;
    maxheight:=0;

    detailPen:=0;
    blockPen:=1; 
    idcmpFlags:=0;
    flags := WFLG_SMART_REFRESH or
             WFLG_DRAGBAR or
             WFLG_DEPTHGADGET or 
             WFLG_ACTIVATE;
    firstGadget:=NIL;
    title:=@WTitle[1]; 
    screen:=NIL; 
    bitMap:=NIL; 
    checkMark:=NIL;
    type_:=WBENCHSCREEN; 
  END;

  WITH my_image DO
  begin
    LeftEdge := 45;
    TopEdge  := 35;        
    Width := 32;           
    Height := 32;             
    Depth := 2;
    ImageData :=NIL; 
    PlanePick:= 3;          
    PlaneOnOff:= 0;        
    NextImage:=NIL;          
  end;

  my_window:=OpenWindow(@my_new_window);

  (* Allocate chip memory and copy array data *)
  my_image.ImageData := AllocMem(sizeof(TestImage),MEMF_CHIP); 
  CopyMem(@TestImage, my_image.ImageData, sizeof(TestImage));

  DrawImage(my_window^.RPort, @my_image, 0, 0 );
  Delay(5000);
  Clean_up;
end.