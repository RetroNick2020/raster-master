unit flood;
{$mode objfpc}{$H+}

interface
 uses
  Classes, SysUtils,rmcore;

procedure ScanFill(x, y, width, height, newColor : integer);
procedure ReplaceAllFill(x, y, MaxX,MaxY,color : integer);

implementation
const
 MaxQueueSize = 100;
Type
  TFPoint = record
            x,y : integer;
  end;

  TPixelQueue = Class
             Count : integer;
             PointList : array[1..MaxQueueSize] of TFPoint;
             constructor Create;
             procedure push(var pt : TFPoint);
             procedure popfirst(var pt : TFPoint);
             procedure pop(var pt : TFPoint);
             function GetCount : integer;
  end;


constructor TPixelQueue.Create;
begin
 count:=0;
end;

procedure TPixelQueue.push(var pt : TFPoint);
begin
 if (count+1) > MaxQueueSize then exit;
 if (pt.x < 0) or (pt.y<0) then exit;
 inc(count);
 PointList[count]:=pt;
end;
procedure TPixelQueue.popfirst(var pt : TFPoint);
var
i : integer;
begin
 if count > 0 then
 begin
   pt:=PointList[1];
   dec(count);
   for i:=1 to count do
   begin
      PointList[i]:=PointList[i+1];
   end;
 end;
end;

procedure TPixelQueue.pop(var pt : TFPoint);
begin
 if count > 0 then
 begin
   pt:=PointList[count];
   dec(count);
 end;
end;

function TPixelQueue.GetCount : integer;
begin
  GetCount:=count;
end;

function GetPix(x,y : integer) : integer;
begin
//  if (x<0) or (y<0) or (x>RMCoreBase.GetWidth-1) or (y>RMCoreBase.GetHeight-1) then
//     result:=-1
//  else
    result:=RMCoreBase.GetPixel(x,y);
end;

procedure PutPix(x,y,color : integer);
begin
  if (x<0) or (y<0) or (x>RMCoreBase.GetWidth-1) or (y>RMCoreBase.GetHeight-1) then exit;
  RMCoreBase.PutPixel(x,y,color);
end;

procedure ScanFill(x, y, width, height, newColor : integer);
var
  x1 : integer;
  spanAbove, spanBelow : boolean;
  PQ     : TPixelQueue;
  temp   : TFPoint;
  oldColor : integer;
begin
  if GetPix(x,y) = newColor then exit;
  oldColor:=GetPix(x,y);

  PQ:=TPixelQueue.Create;
  temp.x:=x;
  temp.y:=y;
  PQ.push(temp);
  while PQ.GetCount>0 do
  begin
    PQ.popfirst(temp);
    x:=temp.x;
    y:=temp.y;

    x1 := x;
    while ((x1 >= 0) and (GetPix(x1,y) = oldColor)) do
    begin
      x1:=x1-1;
    end;
    x1:=x1+1;
    spanAbove := false;
    spanBelow := false;

    while((x1 < width) and (GetPix(x1,y) = oldColor)) do
    begin
      PutPix( x1,y, newColor);
      if((NOT spanAbove) and  (y > 0) and (GetPix(x1,(y - 1) ) = oldColor)) then
      begin
        temp.x:=x1;
        temp.y:=y-1;
        PQ.push(temp);
        spanAbove := true;
      end
      else if (spanAbove and (y > 0) and (GetPix(x1,(y - 1)) <> oldColor)) then
      begin
        spanAbove := false;
      end;

      if ((NOT spanBelow) and (y < height - 1) and (GetPix(x1,(y + 1)) = oldColor)) then
      begin
        temp.x:=x1;
        temp.y:=y+1;
        PQ.push(temp);
        spanBelow := true;
      end
      else if(spanBelow and (y < height - 1) and (GetPix(x1,(y + 1)) <> oldColor)) then
      begin
        spanBelow := false;
      end;
      x1:=x1+1;
    end;
  end;
end;

//replaces all occurances in Map of selected  Tile - like flood fill but for all - does not need to be connected - mainly to be used for missing tiles
procedure ReplaceAllFill(x, y, MaxX,MaxY,color : integer);
var
 i,j,ReplaceColor : integer;
begin
  if GetPix(x,y) = color then exit;
  ReplaceColor:=GetPix(x,y);
  for j:=0 to MaxY-1 do
  begin
    for i:=0 to MaxX-1 do
    begin
      if GetPix(i,j) = ReplaceColor then  PutPix( i,j, color);
    end;
  end;
end;


end.

