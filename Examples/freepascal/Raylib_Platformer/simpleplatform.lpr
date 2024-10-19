// Simple Platform Demo By RetroNick Oct 19 - 2024
// Jumping logic created chatGPT AI
// Images created with Raster Master
// Youtube video demonstration
// https://youtu.be/DhdHi7fPkhk

program simpleplatform;

uses
  raylib,raymath,sysutils;

const
  ScreenWidth = 512;
  ScreenHeight = 512;
  Gravity = 500.0;
  JumpForce = -300.0;
  PlayerSpeed = 200.0;
  CoinRadius = 10.0;

  MaxPlatForms = 100;
  MaxCoins = 100;

  PIXELFORMAT_UNCOMPRESSED_R8G8B8        = 4;  // 24 bpp
  PIXELFORMAT_UNCOMPRESSED_R8G8B8A8      = 7;  // 32 bpp

  {$I images.inc}

type
  TPlayer = record
    Position: TVector2;
    Size: TVector2;
    Velocity: TVector2;
    OnGround: Boolean;
  end;

  TPlatform = record
    Rect: TRectangle;

  end;

  TCoin = record
    Rect: TRectangle;
    Collected: Boolean;
  end;

var
  Player: TPlayer;
  Platforms: array[0..MaxPlatForms-1] of TPlatform;
  PlatFormCount : integer;
  Coins: array[0..MaxCoins-1] of TCoin;
  CoinCount : integer;
  PlayerScore: Integer;

  MyGrass : TTexture2D;
  MyCoin  : TTexture2D;
  MyBunny : TTexture2D;
  MyImage : Timage;


//load RGB and RGBA images from Raster Master generated arrays
procedure LoadRGBImageFromArray(var Image : TImage; var rgbImage; width,height, rgbformat : integer);
begin
    Image.Data:=@rgbImage;
    Image.format:=rgbformat;            //4 = RGB, 7 = RGBA
    Image.width:=width;
    Image.height:=height;
    Image.mipmaps:=1;
end;

procedure DrawShape(var STexture : TTexture2D; x,y : integer);
begin
  DrawTexture(STexture,X,Y,WHITE);
end;

procedure AddPlatForm(x,y : integer);
begin
 if PlatFormCount < MaxPlatForms then
 begin
   Platforms[PlatFormCount].Rect.x:=x*32;
   Platforms[PlatFormCount].Rect.y:=y*32;
   Platforms[PlatFormCount].Rect.width :=32;
   Platforms[PlatFormCount].Rect.height :=1;
   inc(PlatFormCount);
 end;
end;

procedure InitPlatForms;
var
   c : integer;
   x,y : integer;
begin
  PlatFormCount:=0;
  c:=0;
  for y:=0 to map1_height-1 do
  begin
    for x:=0 to map1_width-1 do
    begin
      if map1[c+4] = Grass_id then AddPlatForm(x,y);
      inc(c);
    end;
  end;
end;

procedure AddCoin(x,y : integer);
begin
 if CoinCount < MaxCoins then
 begin
   Coins[CoinCount].Rect.x:=x+5;
   Coins[CoinCount].Rect.y:=y+5;
   Coins[CoinCount].Rect.width :=10;
   Coins[CoinCount].Rect.height :=10;
   inc(CoinCount);
 end;
end;

Procedure InitCoins;
  var
     c : integer;
     x,y : integer;
  begin
    CoinCount:=0;
    c:=0;
    for y:=0 to map1_height-1 do
    begin
      for x:=0 to map1_width-1 do
      begin
        if map1[c+4] = Coin_id then AddCoin(x*32,y*32);
        inc(c);
      end;
    end;
end;
procedure InitImages;
begin
  LoadRGBImageFromArray(MyImage,Grass,Grass_Width,Grass_Height,Grass_Format);
  MyGrass:=LoadTextureFromImage(MyImage);

  LoadRGBImageFromArray(MyImage,Coin,Coin_Width,Coin_Height,Coin_Format);
  MyCoin:=LoadTextureFromImage(MyImage);

  LoadRGBImageFromArray(MyImage,Bunny,Bunny_Width,Bunny_Height,Bunny_Format);
  MyBunny:=LoadTextureFromImage(MyImage);
end;

procedure InitGame();
var
  i :integer;
begin
  //convert image arrays to Textures
  InitImages;
  // Initialize player
  Player.Position := Vector2Create(100, 250);
  Player.Size := Vector2Create(17, 30);
  Player.Velocity := Vector2Create(0, 0);
  Player.OnGround := False;

  // Initialize platforms
  InitPlatForms;
  // Init coin
  InitCoins;
  for i := 0 to CoinCount-1 do
  begin
    Coins[i].Collected := False;
  end;
  PlayerScore := 0;
end;

procedure UpdatePlayer(dt: Single);
var
  i :integer;
begin
  // Apply gravity
  if not Player.OnGround then
    Player.Velocity.y := Player.Velocity.y + Gravity * dt;

  // Horizontal movement
  if IsKeyDown(KEY_RIGHT) then
    Player.Position.x := Player.Position.x + PlayerSpeed * dt
  else if IsKeyDown(KEY_LEFT) then
    Player.Position.x := Player.Position.x - PlayerSpeed * dt;

  // Jumping
  if Player.OnGround and IsKeyDown(KEY_UP) then
  begin
    Player.Velocity.y := JumpForce;
    Player.OnGround := False;
  end;

  // Update position based on velocity
  Player.Position := Vector2Add(Player.Position, Vector2Scale(Player.Velocity, dt));

  // Check for collision with platforms (basic AABB collision)
  Player.OnGround := False;
  for i := 0 to High(Platforms) do
  begin
    if CheckCollisionRecs(RectangleCreate(Player.Position.x, Player.Position.y, Player.Size.x, Player.Size.y),
                          Platforms[i].Rect) then
    begin
      // If falling, stop the vertical movement (land on platform)
      if Player.Velocity.y > 0 then
      begin
        Player.Position.y := Platforms[i].Rect.y - Player.Size.y;  // Adjust position to stand on top of platform
        Player.Velocity.y := 0;
        Player.OnGround := True;
      end;
    end;
  end;

  // Prevent player from going below the screen
  if Player.Position.y + Player.Size.y > ScreenHeight then
  begin
    Player.Position.y := ScreenHeight - Player.Size.y;
    Player.Velocity.y := 0;
    Player.OnGround := True;
  end;
end;

procedure CheckCoinCollissions();
var
  i :integer;
begin
  // Check for collision between player and coins
  for i := 0 to CoinCount-1 do
  begin
    if not Coins[i].Collected then
    begin
      if CheckCollisionRecs(RectangleCreate(Player.Position.x,Player.Position.y,Player.Size.x,Player.Size.y),Coins[i].Rect) then
      begin
        Coins[i].Collected := True;
        Inc(PlayerScore);
      end;
    end;
   end;
end;

procedure DrawGame();
var
  i :integer;
begin
  BeginDrawing();
  ClearBackground(BLUE);
  // Draw platforms
  for i := 0 to PlatformCount-1 do
  begin
    DrawTextureEx(MyGrass,Vector2Create(Platforms[i].Rect.x,Platforms[i].Rect.y),0,1,WHITE);
  end;
  // Draw player
  DrawTextureEx(MyBunny,Player.Position,0,1,WHITE);
  // Draw coins
  for i := 0 to CoinCount-1 do
  begin
    if not Coins[i].Collected then
    begin
      DrawTextureEx(MyCoin,Vector2Create(coins[i].Rect.x-5,coins[i].Rect.y-5),0,1,WHITE);
    end;
  end;
  // Draw score
  DrawText(PChar('Score: ' + IntToStr(PlayerScore)), 10, 10, 20, BLACK);
  EndDrawing();
end;

begin
  // Initialization
  InitWindow(ScreenWidth, ScreenHeight, 'Simple Platform Game With Coins');
  SetTargetFPS(60);
  InitGame();
  // Main game loop
  while not WindowShouldClose() do
  begin
    // Update game logic
    UpdatePlayer(GetFrameTime());
    CheckCoinCollissions;
    // Draw everything
    DrawGame();
  end;
  // Cleanup
  CloseWindow();
end.

