// Nick's Experimental packer
unit nPacker;

Interface
Type
 LineBufType = Array[0..16023] of Byte;

function nPackRow(var unpackedBuf: LineBufType; BufferOffset : Word;
                  var packedBuf :  LineBufType;
                      unpackedSize : integer) : integer;

function nPackRow2(var unpackedBuf: LineBufType; BufferOffset : Word;
                    var packedBuf :  LineBufType;
                     unpackedSize : integer) : integer;

Implementation

const
  MaxRepeatCount = 128; //def 128
  MaxNRCount = 128; // def 128

procedure PackOpRepeat(var packedBuf :  LineBufType;var packedSize : integer; rc,n : integer);
begin
   packedbuf[packedsize]:=255-(rc-2);
   packedbuf[packedsize+1]:=n;
   inc(packedsize,2);
end;

procedure PackOpValues(var packedBuf : LineBufType;var packedSize : integer;var tempbuf ;n : integer);
begin
 packedbuf[packedsize]:=n-1;
 move(tempbuf,packedbuf[packedsize+1],n);
 inc(packedsize,n+1);
end;

function nPackRow(var unpackedBuf: LineBufType; BufferOffset : Word;
                  var packedBuf :  LineBufType;
                      unpackedSize : integer) : integer;
//if n is 0 to 127 - read n+1 chracters fron stream
//if n is -1 to -127 repeat next byte in stream abs(n)+1 , if we add 255 can can get rid of negative values and just use Byte
var
 count,i,tc,rc : integer;
 TempBuf : array[0..130] of byte;
 newvalue,lastvalue : integer;
 packedSize : integer;
begin
 packedSize:=0;
 tc:=0;
 rc:=0;
 FillChar(TempBuf,sizeof(TempBuf),0);
 newvalue:=-1;
 lastvalue:=-1;
 packedsize:=0;
// aaababbb
 for i:=0 to unpackedSize-1 do
 begin
    if UnpackedBuf[BufferOffset+i] = lastvalue then
    begin
//    if (tc = 1) AND (rc<127) then
      if (tc = 1) AND (rc<(MaxRepeatCount-1)) then
      begin
        inc(rc);  // we remove the chractrer from the tempbuf and count it as repeating char
        tc:=0;
      end
//    else if (tc > 1) AND (rc <127) then
      else if (tc > 1) AND (rc <(MaxRepeatCount-1)) then

      begin
        dec(tc); //remove last char  from tempbuf
        inc(rc);
        //write block write opcode and dump tempbuf to file
        PackOpValues(packedBuf,packedSize,tempbuf,tc);
        tc:=0;
      end;
      inc(rc);
//    if rc > 127 then
      if rc > (MaxRepeatCount-1) then

      begin
        //write max repeat opcode and value   - keep repeat count going if over 128
//        PackOpRepeat(packedBuf,packedSize,128,lastvalue);
          PackOpRepeat(packedBuf,packedSize,MaxRepeatCount,lastvalue);

//        rc:=rc-128;
        rc:=rc-MaxRepeatCount;
        lastvalue:=-1;
      end;
    end
    else
    begin
      if rc > 0 then
      begin
        //write repeat opcode and value
        PackOpRepeat(packedBuf,packedSize,rc,lastvalue);
        rc:=0;
      end;
//    if tc > 127 then
      if tc > (MaxNRCount-1) then

      begin
        //write block write opcode and dump tempbuf to file
//        PackOpValues(packedBuf,packedSize,tempbuf,128);
          PackOpValues(packedBuf,packedSize,tempbuf,MaxNRCount);
        tc:=0;
      end;
      inc(tc);
      TempBuf[tc-1]:=UnpackedBuf[BufferOffset+i];
      lastvalue:=UnpackedBuf[BufferOffset+i];
    end;
  end; //for

 if rc > 0 then
 begin
  // writeln('we still have rc data');
   PackOpRepeat(packedBuf,packedSize,rc,lastvalue);
 end;

 if tc > 0 then
 begin
//   writeln(tempbuf);
   PackOpValues(packedBuf,packedSize,tempbuf,tc);

   //writeln('we still have tc data');
 end;
 nPackRow:=packedSize;
end;


Function FindRepeatCode(var unpackedBuf : LineBufType;
                        start, maxcount : integer;
                        var RepeatValue : byte) : integer;

var
 lastvalue : integer;
 FoundCount : integer;
 i : integer;
begin
 lastvalue:=unpackedBuf[start];
 repeatvalue:=unpackedBuf[start];
 FoundCount:=1;
 For i:=start+1 to start+maxcount-1 do
 begin
    if unpackedBuf[i] = lastvalue then inc(FoundCount) else break;
 end;
 if FoundCount > 1 then
    FindRepeatCode:=FoundCount
 else FindRepeatCode:=0;
end;

Function FindNonRepeatCode(var unpackedBuf : LineBufType;
                        start, maxcount : integer) : integer;
var

 FoundCount : integer;
 i : integer;
begin
// repeatvalue:=unpackedBuf[start];
// writeln('lv = ',lastvalue);
 FoundCount:=0;       //even we don't find any non repeat just take next char
 For i:=start to start+maxcount-1 do
 begin
    if unpackedBuf[i] <> unpackedBuf[i+1] then
    begin
      inc(foundcount);
    end
    else break;
 end;
 FindNonRepeatCode:=FoundCount
end;

function FindMaxToRead(counter,maxsize : integer) : integer;
begin
 if (counter + 128) <= maxsize then
   FindMaxToRead:=128
 else
   FindMaxToRead:=maxsize-counter;
end;

function nPackRow2(var unpackedBuf: LineBufType; BufferOffset : Word;
                    var packedBuf :  LineBufType;
                     unpackedSize : integer) : integer;

var
 max_code_to_read : integer;
 start_code_search : integer;
 counter,nrc,rc : integer;
 repeatvalue : byte;
 packedSize : integer;
 TempBuf : array[0..130] of byte;

begin
 start_code_search:=BufferOffset;
 counter:=0;
 packedsize:=0;
 max_code_to_read:=FindMaxToRead(counter,unpackedsize);

 while  counter < unpackedSize do
 begin
   Repeat
     max_code_to_read:=FindMaxToRead(counter,unpackedsize);
     rc:=FindRepeatCode(unpackedBuf,start_code_search,max_code_to_read,repeatvalue);
     if rc > 0 then
     begin
        PackOpRepeat(packedBuf,packedSize,rc,repeatvalue);
        inc(counter,rc);
        inc(start_code_search,rc);
     end;
   Until (rc = 0) or (counter = unpackedSize);
   if (counter < UnpackedSize) then
   begin
     max_code_to_read:=FindMaxToRead(counter,unpackedsize);
     nrc:=FindNonRepeatCode(unpackedBuf,start_code_search,max_code_to_read);
     if nrc > 0 then
     begin
       Move(unpackedBuf[start_code_search],tempbuf,nrc);
       PackOpValues(packedBuf,packedSize,tempbuf,nrc);
       inc(counter,nrc);
       inc(start_code_search,nrc);
    end;
  end;
 end; //while
 nPackRow2:=packedsize;
end;


begin
end.
