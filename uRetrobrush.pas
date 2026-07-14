unit uRetrobrush;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Math, rmcore;

type
  //pixel buffer: dynamic 2D array of palette indices
  TPixelBuf = array of array of byte;

  TRetroBrush = class
  private
    FRemapTable     : array[0..255] of byte;
    FRemapValid     : boolean;
    FRemapPalHash   : longword;

    function PaletteHash(var P : TRMPaletteBuf; Count : integer) : longword;
  public
    //original capture - never modified after grab
    OrigPixels   : TPixelBuf;
    OrigWidth    : integer;
    OrigHeight   : integer;

    //working buffer - result of the current transform chain
    WorkPixels   : TPixelBuf;
    WorkWidth    : integer;
    WorkHeight   : integer;

    //palette snapshot from the source sprite at time of capture
    Palette      : TRMPaletteBuf;
    PaletteMode  : integer;
    ColorCount   : integer;

    //index treated as transparent during stamping (default 0)
    TransColor   : integer;

    //true when a brush has been captured
    HasBrush     : boolean;

    constructor Create;
    destructor Destroy; override;

    { === capture === }
    //grab from an indexed pixel source (rmthumb ImageMain or core)
    procedure GrabFromPixels(var SrcPixels : TPixelBuf;
                             SrcW, SrcH : integer;
                             var SrcPalette : TRMPaletteBuf;
                             SrcPalMode, SrcColorCount : integer);
    //grab a rectangular region from the source
    procedure GrabRegion(var SrcPixels : TPixelBuf;
                         SrcW, SrcH : integer;
                         x1, y1, x2, y2 : integer;
                         var SrcPalette : TRMPaletteBuf;
                         SrcPalMode, SrcColorCount : integer);

    { === transforms (always Orig -> Work, so they compose without
          quality loss; call Reset to start fresh) === }
    procedure Reset;            //copy Orig to Work unchanged
    procedure Rotate90CW;       //90 degrees clockwise
    procedure Rotate90CCW;      //90 degrees counter-clockwise
    procedure Rotate180;        //180 degrees
    procedure RotateAngle(Degrees : double);  //arbitrary angle, nearest-neighbor
    procedure FlipHorizontal;
    procedure FlipVertical;
    procedure ScaleNearest(NewW, NewH : integer);
    procedure ScalePercent(Pct : integer);    //percentage, e.g. 200 = 2x
    procedure ShearHorizontal(Amount : integer); //shift rows, -16..16
    procedure ShearVertical(Amount : integer);   //shift columns, -16..16
    procedure GradientHorizontal(startIdx, endIdx : byte);
    procedure GradientVertical(startIdx, endIdx : byte);
    procedure GradientCircular(startIdx, endIdx : byte; cx, cy : integer);

    { === palette remapping === }
    //builds a 256-entry remap table mapping brush palette indices to
    //the nearest colour in the target palette. call whenever the
    //target sprite changes or its palette is edited.
    procedure BuildRemapTable(var TargetPalette : TRMPaletteBuf;
                              TargetPalMode, TargetColorCount : integer);
    //invalidate so it rebuilds on next stamp
    procedure InvalidateRemap;
    //returns the remapped index for a brush pixel
    function RemapIndex(BrushIndex : byte) : byte;

    { === stamping === }
    //stamp the working brush onto a target pixel buffer at (dx,dy).
    //pixels where WorkPixels[x,y] = TransColor are skipped (transparent).
    //applies the remap table if the palettes differ.
    procedure Stamp(var DstPixels : TPixelBuf;
                    DstW, DstH : integer;
                    dx, dy : integer;
                    var TargetPalette : TRMPaletteBuf;
                    TargetPalMode, TargetColorCount : integer);

    { === utility === }
    procedure ClearBrush;
  end;

var
  RetroBrush : TRetroBrush;

implementation

{ ===== private ===== }

function TRetroBrush.PaletteHash(var P : TRMPaletteBuf; Count : integer) : longword;
var
  i : integer;
  h : longword;
begin
  h:=Count;
  for i:=0 to Count-1 do
    h:=h xor (longword(P[i].r) shl 16) xor (longword(P[i].g) shl 8) xor longword(P[i].b)
       xor (h shl 5) xor (h shr 3);
  PaletteHash:=h;
end;

{ ===== public ===== }

constructor TRetroBrush.Create;
begin
  inherited Create;
  OrigWidth:=0;
  OrigHeight:=0;
  WorkWidth:=0;
  WorkHeight:=0;
  TransColor:=0;
  HasBrush:=false;
  PaletteMode:=0;
  ColorCount:=0;
  FRemapValid:=false;
  FRemapPalHash:=0;
end;

destructor TRetroBrush.Destroy;
begin
  SetLength(OrigPixels, 0);
  SetLength(WorkPixels, 0);
  inherited Destroy;
end;

{ === capture === }

procedure TRetroBrush.GrabFromPixels(var SrcPixels : TPixelBuf;
                                     SrcW, SrcH : integer;
                                     var SrcPalette : TRMPaletteBuf;
                                     SrcPalMode, SrcColorCount : integer);
var
  i, j : integer;
begin
  OrigWidth:=SrcW;
  OrigHeight:=SrcH;
  SetLength(OrigPixels, SrcW, SrcH);
  for i:=0 to SrcW-1 do
    for j:=0 to SrcH-1 do
      OrigPixels[i][j]:=SrcPixels[i][j];

  Palette:=SrcPalette;
  PaletteMode:=SrcPalMode;
  ColorCount:=SrcColorCount;
  HasBrush:=true;
  FRemapValid:=false;
  Reset;
end;

procedure TRetroBrush.GrabRegion(var SrcPixels : TPixelBuf;
                                 SrcW, SrcH : integer;
                                 x1, y1, x2, y2 : integer;
                                 var SrcPalette : TRMPaletteBuf;
                                 SrcPalMode, SrcColorCount : integer);
var
  i, j, rw, rh : integer;
begin
  //clamp
  if x1 < 0 then x1:=0;
  if y1 < 0 then y1:=0;
  if x2 >= SrcW then x2:=SrcW-1;
  if y2 >= SrcH then y2:=SrcH-1;
  if (x2 < x1) or (y2 < y1) then exit;

  rw:=x2 - x1 + 1;
  rh:=y2 - y1 + 1;
  OrigWidth:=rw;
  OrigHeight:=rh;
  SetLength(OrigPixels, rw, rh);
  for i:=0 to rw-1 do
    for j:=0 to rh-1 do
      OrigPixels[i][j]:=SrcPixels[x1+i][y1+j];

  Palette:=SrcPalette;
  PaletteMode:=SrcPalMode;
  ColorCount:=SrcColorCount;
  HasBrush:=true;
  FRemapValid:=false;
  Reset;
end;

{ === transforms === }

procedure TRetroBrush.Reset;
var
  i, j : integer;
begin
  WorkWidth:=OrigWidth;
  WorkHeight:=OrigHeight;
  SetLength(WorkPixels, WorkWidth, WorkHeight);
  for i:=0 to WorkWidth-1 do
    for j:=0 to WorkHeight-1 do
      WorkPixels[i][j]:=OrigPixels[i][j];
end;

procedure TRetroBrush.Rotate90CW;
var
  i, j : integer;
  Tmp : TPixelBuf;
  TmpW, TmpH : integer;
begin
  if not HasBrush then exit;
  //source is Orig, dest is Work: W becomes H and vice versa
  TmpW:=OrigHeight;
  TmpH:=OrigWidth;
  SetLength(Tmp, TmpW, TmpH);
  for i:=0 to TmpW-1 do
    for j:=0 to TmpH-1 do
      Tmp[i][j]:=OrigPixels[j][OrigHeight-1-i];
  WorkWidth:=TmpW;
  WorkHeight:=TmpH;
  SetLength(WorkPixels, WorkWidth, WorkHeight);
  for i:=0 to WorkWidth-1 do
    for j:=0 to WorkHeight-1 do
      WorkPixels[i][j]:=Tmp[i][j];
  SetLength(Tmp, 0);
end;

procedure TRetroBrush.Rotate90CCW;
var
  i, j : integer;
  Tmp : TPixelBuf;
  TmpW, TmpH : integer;
begin
  if not HasBrush then exit;
  TmpW:=OrigHeight;
  TmpH:=OrigWidth;
  SetLength(Tmp, TmpW, TmpH);
  for i:=0 to TmpW-1 do
    for j:=0 to TmpH-1 do
      Tmp[i][j]:=OrigPixels[OrigWidth-1-j][i];
  WorkWidth:=TmpW;
  WorkHeight:=TmpH;
  SetLength(WorkPixels, WorkWidth, WorkHeight);
  for i:=0 to WorkWidth-1 do
    for j:=0 to WorkHeight-1 do
      WorkPixels[i][j]:=Tmp[i][j];
  SetLength(Tmp, 0);
end;

procedure TRetroBrush.Rotate180;
var
  i, j : integer;
begin
  if not HasBrush then exit;
  WorkWidth:=OrigWidth;
  WorkHeight:=OrigHeight;
  SetLength(WorkPixels, WorkWidth, WorkHeight);
  for i:=0 to WorkWidth-1 do
    for j:=0 to WorkHeight-1 do
      WorkPixels[i][j]:=OrigPixels[OrigWidth-1-i][OrigHeight-1-j];
end;

procedure TRetroBrush.RotateAngle(Degrees : double);
var
  i, j, sx, sy : integer;
  cx, cy : double;
  cosA, sinA : double;
  Rad : double;
begin
  if not HasBrush then exit;

  Rad:=Degrees * Pi / 180.0;
  cosA:=Cos(Rad);
  sinA:=Sin(Rad);

  //rotate within the original bounding box
  WorkWidth:=OrigWidth;
  WorkHeight:=OrigHeight;
  SetLength(WorkPixels, WorkWidth, WorkHeight);

  cx:=(OrigWidth - 1) / 2.0;
  cy:=(OrigHeight - 1) / 2.0;

  for i:=0 to WorkWidth-1 do
  begin
    for j:=0 to WorkHeight-1 do
    begin
      //inverse map: destination -> source
      sx:=Round( cosA * (i - cx) + sinA * (j - cy) + cx);
      sy:=Round(-sinA * (i - cx) + cosA * (j - cy) + cy);

      if (sx >= 0) and (sx < OrigWidth) and (sy >= 0) and (sy < OrigHeight) then
        WorkPixels[i][j]:=OrigPixels[sx][sy]
      else
        WorkPixels[i][j]:=TransColor;
    end;
  end;
end;

procedure TRetroBrush.FlipHorizontal;
var
  i, j : integer;
begin
  if not HasBrush then exit;
  WorkWidth:=OrigWidth;
  WorkHeight:=OrigHeight;
  SetLength(WorkPixels, WorkWidth, WorkHeight);
  for i:=0 to WorkWidth-1 do
    for j:=0 to WorkHeight-1 do
      WorkPixels[i][j]:=OrigPixels[OrigWidth-1-i][j];
end;

procedure TRetroBrush.FlipVertical;
var
  i, j : integer;
begin
  if not HasBrush then exit;
  WorkWidth:=OrigWidth;
  WorkHeight:=OrigHeight;
  SetLength(WorkPixels, WorkWidth, WorkHeight);
  for i:=0 to WorkWidth-1 do
    for j:=0 to WorkHeight-1 do
      WorkPixels[i][j]:=OrigPixels[i][OrigHeight-1-j];
end;

procedure TRetroBrush.ScaleNearest(NewW, NewH : integer);
var
  i, j, sx, sy : integer;
begin
  if not HasBrush then exit;
  if (NewW < 1) or (NewH < 1) then exit;

  WorkWidth:=NewW;
  WorkHeight:=NewH;
  SetLength(WorkPixels, NewW, NewH);

  for i:=0 to NewW-1 do
  begin
    for j:=0 to NewH-1 do
    begin
      sx:=(i * OrigWidth) div NewW;
      sy:=(j * OrigHeight) div NewH;
      if sx >= OrigWidth then sx:=OrigWidth-1;
      if sy >= OrigHeight then sy:=OrigHeight-1;
      WorkPixels[i][j]:=OrigPixels[sx][sy];
    end;
  end;
end;

procedure TRetroBrush.ScalePercent(Pct : integer);
var
  NewW, NewH : integer;
begin
  if Pct < 1 then exit;
  NewW:=(OrigWidth * Pct) div 100;
  NewH:=(OrigHeight * Pct) div 100;
  if NewW < 1 then NewW:=1;
  if NewH < 1 then NewH:=1;
  ScaleNearest(NewW, NewH);
end;

{ === shearing === }

procedure TRetroBrush.ShearHorizontal(Amount : integer);
var
  i, j, sx : integer;
  shift : integer;
begin
  if not HasBrush then exit;
  if OrigHeight <= 1 then exit;

  WorkWidth:=OrigWidth + Abs(Amount);
  WorkHeight:=OrigHeight;
  SetLength(WorkPixels, WorkWidth, WorkHeight);

  //fill with transparent
  for i:=0 to WorkWidth-1 do
    for j:=0 to WorkHeight-1 do
      WorkPixels[i][j]:=TransColor;

  for j:=0 to OrigHeight-1 do
  begin
    //shift proportional to row position
    shift:=(Amount * j) div (OrigHeight - 1);
    if Amount < 0 then
      shift:=shift + Abs(Amount);
    for i:=0 to OrigWidth-1 do
    begin
      sx:=i + shift;
      if (sx >= 0) and (sx < WorkWidth) then
        WorkPixels[sx][j]:=OrigPixels[i][j];
    end;
  end;
end;

procedure TRetroBrush.ShearVertical(Amount : integer);
var
  i, j, sy : integer;
  shift : integer;
begin
  if not HasBrush then exit;
  if OrigWidth <= 1 then exit;

  WorkWidth:=OrigWidth;
  WorkHeight:=OrigHeight + Abs(Amount);
  SetLength(WorkPixels, WorkWidth, WorkHeight);

  //fill with transparent
  for i:=0 to WorkWidth-1 do
    for j:=0 to WorkHeight-1 do
      WorkPixels[i][j]:=TransColor;

  for i:=0 to OrigWidth-1 do
  begin
    //shift proportional to column position
    shift:=(Amount * i) div (OrigWidth - 1);
    if Amount < 0 then
      shift:=shift + Abs(Amount);
    for j:=0 to OrigHeight-1 do
    begin
      sy:=j + shift;
      if (sy >= 0) and (sy < WorkHeight) then
        WorkPixels[i][sy]:=OrigPixels[i][j];
    end;
  end;
end;

{ === gradients === }

procedure TRetroBrush.GradientHorizontal(startIdx, endIdx : byte);
var
  i, j, ci : integer;
begin
  if not HasBrush then exit;
  if WorkWidth <= 1 then exit;

  for i:=0 to WorkWidth-1 do
  begin
    ci:=startIdx + ((endIdx - startIdx) * i) div (WorkWidth - 1);
    for j:=0 to WorkHeight-1 do
      if WorkPixels[i][j] <> TransColor then
        WorkPixels[i][j]:=ci;
  end;
end;

procedure TRetroBrush.GradientVertical(startIdx, endIdx : byte);
var
  i, j, ci : integer;
begin
  if not HasBrush then exit;
  if WorkHeight <= 1 then exit;

  for j:=0 to WorkHeight-1 do
  begin
    ci:=startIdx + ((endIdx - startIdx) * j) div (WorkHeight - 1);
    for i:=0 to WorkWidth-1 do
      if WorkPixels[i][j] <> TransColor then
        WorkPixels[i][j]:=ci;
  end;
end;

procedure TRetroBrush.GradientCircular(startIdx, endIdx : byte; cx, cy : integer);
var
  i, j, ci : integer;
  maxDist, dist : double;
  dx, dy : integer;
begin
  if not HasBrush then exit;

  //find max distance from center to any corner for normalization
  maxDist:=0;
  dx:=cx;             dy:=cy;              dist:=Sqrt(dx*dx + dy*dy); if dist > maxDist then maxDist:=dist;
  dx:=WorkWidth-1-cx; dy:=cy;              dist:=Sqrt(dx*dx + dy*dy); if dist > maxDist then maxDist:=dist;
  dx:=cx;             dy:=WorkHeight-1-cy; dist:=Sqrt(dx*dx + dy*dy); if dist > maxDist then maxDist:=dist;
  dx:=WorkWidth-1-cx; dy:=WorkHeight-1-cy; dist:=Sqrt(dx*dx + dy*dy); if dist > maxDist then maxDist:=dist;
  if maxDist < 1 then maxDist:=1;

  for i:=0 to WorkWidth-1 do
  begin
    for j:=0 to WorkHeight-1 do
    begin
      if WorkPixels[i][j] <> TransColor then
      begin
        dx:=i - cx;
        dy:=j - cy;
        dist:=Sqrt(dx*dx + dy*dy);
        ci:=startIdx + Round((endIdx - startIdx) * (dist / maxDist));
        if ci < 0 then ci:=0;
        if ci > 255 then ci:=255;
        WorkPixels[i][j]:=ci;
      end;
    end;
  end;
end;

{ === palette remapping (implementation) === }

procedure TRetroBrush.BuildRemapTable(var TargetPalette : TRMPaletteBuf;
                                      TargetPalMode, TargetColorCount : integer);
var
  i, k : integer;
  BestIdx, BestDist, Dist, DR, DG, DB : integer;
  TargetHash : longword;
begin
  TargetHash:=PaletteHash(TargetPalette, TargetColorCount);

  //skip if already built for this exact target palette
  if FRemapValid and (FRemapPalHash = TargetHash) then exit;

  for i:=0 to 255 do
  begin
    if i < ColorCount then
    begin
      //find nearest colour in the target palette using weighted
      //perceptual distance (same as RetroDP / sprite importer)
      BestIdx:=0;
      BestDist:=MaxInt;
      for k:=0 to TargetColorCount-1 do
      begin
        DR:=Palette[i].r - TargetPalette[k].r;
        DG:=Palette[i].g - TargetPalette[k].g;
        DB:=Palette[i].b - TargetPalette[k].b;
        Dist:=DR*DR*2 + DG*DG*4 + DB*DB*3;
        if Dist < BestDist then
        begin
          BestDist:=Dist;
          BestIdx:=k;
          if Dist = 0 then break;
        end;
      end;
      FRemapTable[i]:=BestIdx;
    end
    else
      FRemapTable[i]:=0;
  end;

  FRemapValid:=true;
  FRemapPalHash:=TargetHash;
end;

procedure TRetroBrush.InvalidateRemap;
begin
  FRemapValid:=false;
end;

function TRetroBrush.RemapIndex(BrushIndex : byte) : byte;
begin
  RemapIndex:=FRemapTable[BrushIndex];
end;

{ === stamping === }

procedure TRetroBrush.Stamp(var DstPixels : TPixelBuf;
                            DstW, DstH : integer;
                            dx, dy : integer;
                            var TargetPalette : TRMPaletteBuf;
                            TargetPalMode, TargetColorCount : integer);
var
  i, j, tx, ty : integer;
  ci : byte;
  NeedRemap : boolean;
begin
  if not HasBrush then exit;

  //determine if we need palette remapping
  NeedRemap:=(PaletteHash(Palette, ColorCount) <>
              PaletteHash(TargetPalette, TargetColorCount));

  if NeedRemap then
    BuildRemapTable(TargetPalette, TargetPalMode, TargetColorCount);

  for i:=0 to WorkWidth-1 do
  begin
    for j:=0 to WorkHeight-1 do
    begin
      ci:=WorkPixels[i][j];
      if ci = TransColor then continue;  //transparent - skip

      tx:=dx + i;
      ty:=dy + j;
      if (tx < 0) or (tx >= DstW) or (ty < 0) or (ty >= DstH) then continue;

      if NeedRemap then
        DstPixels[tx][ty]:=FRemapTable[ci]
      else
        DstPixels[tx][ty]:=ci;
    end;
  end;
end;

{ === utility === }

procedure TRetroBrush.ClearBrush;
begin
  SetLength(OrigPixels, 0);
  SetLength(WorkPixels, 0);
  OrigWidth:=0;
  OrigHeight:=0;
  WorkWidth:=0;
  WorkHeight:=0;
  HasBrush:=false;
  FRemapValid:=false;
end;

initialization
  RetroBrush := TRetroBrush.Create;

finalization
  FreeAndNil(RetroBrush);

end.
