{$mode objfpc}{$H+}
{$PACKRECORDS 1}

Unit wjavascriptarray;
 Interface
   uses SysUtils,FileUtil,rmcore,bits;

Function WriteJavaScriptArray(x,y,x2,y2 : word;filename:string; transparent : boolean):word;
Implementation

type
 BufferRec = Record
                fText  : Text;
                datalist   : array[1..128] of Byte;
                count  : integer;
                maxsize : longint;
                bcount  : longint;
 end;

 //Action 0 = init ncounter/buffer,Action 1 = write byte to buffer, action 2= flush buffer
 ArrayWriterProc = Procedure(inByte : Byte; var Buffer : BufferRec; action : integer);



procedure ArrayWriter(inByte : Byte; var Buffer : BufferRec;action : integer);
var
 i : integer;
begin
   if action = 0 then
   begin
       buffer.Count:=0;
       buffer.bcount:=0;
       buffer.maxsize:=0;
   end
   else if action = 1 then
   begin
       inc(buffer.count);
       buffer.datalist[buffer.count]:=inbyte;
       if buffer.count = 10 then                      //every 10 bytes write to data statement
       begin
           //write the data statement
           write(buffer.ftext,'    ');
           for i:=1 to 10 do
           begin
             write(buffer.ftext,buffer.datalist[i]);
             inc(buffer.bcount);
             if buffer.bcount<>buffer.maxsize  then write(buffer.ftext,',');
           end;
           writeln(buffer.ftext);
           buffer.count:=0;
       end;
   end
   else if action = 2 then  //write the remaining data
   begin
     if buffer.count > 0 then
     begin
       write(buffer.ftext,'    ');
       for i:=1 to buffer.count do
       begin
         write(buffer.ftext,buffer.datalist[i]);
         inc(buffer.bcount);
         if buffer.bcount<>buffer.maxsize  then write(buffer.ftext,',');
       end;
     //  writeln(buffer.ftext);
       buffer.count:=0;
     end;
   end;
end;

 //we emulator graph's getmaxcolor way of counting colors
function GetMaxColor : integer;
begin
  GetMaxColor:=RMCoreBase.Palette.GetColorCount-1;
end;

function GetArraySize(width,height : integer) : longint;
begin
  GetArraySize:=width*height*4;
end;

Function WriteJavaScriptArray(x,y,x2,y2 : word;filename:string; transparent : boolean):word;
var
  width,height : integer;
  data :BufferRec;
  i,j  : word;
  ImageName : string;
  asize : longint;
  r,g,b,a : byte;
  ColorIndex : integer;
 begin
 width:=x2-x+1;
 height:=y2-y+1;
 asize:=GetArraySize(width,height);

 ArrayWriter(0,data,0);  //init
 data.maxsize:=asize;

 Assign(data.ftext,filename);
{$I-}
 Rewrite(data.ftext);

 Imagename:=ExtractFileName(ExtractFileNameWithoutExt(filename));
 writeln(data.ftext,'//',' JavaScript Array ',Imagename,' Size= ', asize,' Width= ',width,' Height= ',height, ' Colors= ',GetMaxColor+1);
 writeln(data.ftext,'var ', Imagename,'Image ',' = new Uint8ClampedArray([');

 for j:=y to y2 do
 begin
  for i:=x to x2 do
  begin
    colorIndex:=RMCoreBase.GetPixel(i,j);

    r:=RMCoreBase.palette.GetRed(ColorIndex);
    g:=RMCoreBase.palette.GetGreen(ColorIndex);
    b:=RMCoreBase.palette.GetBlue(ColorIndex);
    a:=255;
    if transparent then
    begin
       if ColorIndex = 0 then a:=0;
       if (r=255) and (g=0) and (b=255) then a:=0;
    end;
    ArrayWriter(r,data,1);
    ArrayWriter(g,data,1);
    ArrayWriter(b,data,1);
    ArrayWriter(a,data,1);
  end;
 end;

 ArrayWriter(0,data,2);  //flush it
 writeln(data.ftext,']);');

 Close(data.ftext);
{$I+}
 WriteJavaScriptArray:=IORESULT;
end;






begin
end.

