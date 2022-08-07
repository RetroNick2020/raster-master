unit gpacker;

interface


type
  T_List = array[0..129] of byte;
  T_PackBits_data = packed Record
              //      output_count : integer;
                       list_size : byte;
                 repetition_mode : byte;
                            list : T_List;
                        ncounter : integer;
                    end;

 LineBufType = Array[0..16023] of Byte;


procedure PackBits_pack_init(var data : T_PackBits_data;var dbuffer : lineBufType);
function PackBits_pack_add(var data : T_PackBits_data; b : byte;var dbuffer : lineBufType) : integer;
function PackBits_pack_flush(var data : T_PackBits_data;var dbuffer : lineBufType) : integer;
function gPackRow(var buffer : LineBufType; BufferOffset : word;var dbuffer : LineBufType; size : integer) : integer;

implementation

procedure Write_byte(var data : T_PackBits_data; b : byte;var dbuffer : lineBufType);
begin
//  writeln('opcount',data.output_count);
  dbuffer[data.ncounter]:=b;
  inc(data.ncounter);
end;

procedure Write_bytes(var data : T_PackBits_data;var buffData : T_List; size : word;var dbuffer : lineBufType);
var
i : integer;
begin
//  Move(buffdata,dbuffer[data.output_count],size);
  for i:=0 to size-1 do
  begin
    dbuffer[data.ncounter]:=buffData[i];
    inc(data.ncounter);
  //   dbuffer[data.output_count+i]:=data.list[i];
  end;
end;



procedure PackBits_pack_init(var data : T_PackBits_data;var dbuffer : lineBufType);

begin
  Fillchar(data,sizeof(T_PackBits_data),0);
//  data.output_count:=0;
  data.list_size:=0;
  data.ncounter:=0;
  data.repetition_mode:=0;
  //  Fillchar(dbuffer,sizeof(dbuffer),0);

  //  data.f := f;
end;

function PackBits_pack_add(var data : T_PackBits_data; b : byte;var dbuffer : lineBufType) : integer;
begin
//  writeln('ncounter = ',data.ncounter);
//  writeln('data list size = ',data.list_size);
//  writeln('rp mode = ',data.repetition_mode);
//  writeln('b = ',b);
//  readln;

  PackBits_pack_add:=0; // OK
  if data.list_size = 0 then
  begin // First color
    data.list[0] := b;
    data.list_size := 1;
  end
  else if data.list_size = 1  then
  begin  // second color
    data.repetition_mode:=0;
    if (data.list[0] = b) then  data.repetition_mode:=1;
    data.list[1] := b;
    data.list_size := 2;
  end
  else
  begin // next colors
//    writeln('case else');
//    writeln('data list size = ',data.list_size);

     if (data.list[data.list_size -1] = b) then // repeat detected
     begin
//           writeln('inside 1');
           if (data.repetition_mode=0) AND (data.list_size >= 127) then
           begin
//               writeln('inside 1a');
//               writeln('data list size = ',data.list_size);
//               writeln('rp mode = ',data.repetition_mode);

               // diff mode with 126 bytes then 2 identical bytes
               dec(data.list_size);
               if (PackBits_pack_flush(data,dbuffer) < 0) then
               begin
                  PackBits_pack_add:=-1;
                  exit;
               end;
               data.list[0] := b;
               data.list[1] := b;
               data.list_size := 2;
               data.repetition_mode := 1;
           end
           else if (data.repetition_mode=1) OR (data.list[data.list_size - 2] <> b) then
           begin
//               writeln('inside 1ab');
               // same mode is kept
               if (data.list_size = 128) then
               begin
//                   writeln('inside 1abc');
                   if (PackBits_pack_flush(data,dbuffer) < 0) then
                   begin
                       PackBits_pack_add:=-1;
                       exit;
                   end; //s else writeln('1s packer');
               end;
//               writeln('ding');
               inc(data.list_size);
               data.list[data.list_size-1] := b;
//               writeln('data list size = ',data.list_size);
               exit;
           end
           else
           begin
//              writeln('inside 2');
             // diff mode and 3 identical bytes
             dec(data.list_size,2);
             if (PackBits_pack_flush(data,dbuffer) < 0) then
             begin
                PackBits_pack_add:=-1;
                exit;
             end;//  else writeln('2nd packer');
             data.list[0] := b;
             data.list[1] := b;
             data.list[2] := b;
             data.list_size := 3;
             data.repetition_mode := 1;
          end
    end
    else // the color is different from the previous one
    begin
//          writeln('inside 3');
//          writeln('data list size = ',data.list_size);
//          writeln('rp mode = ',data.repetition_mode);
//          writeln('b = ',b);
//          writeln('last b = ',data.list[data.list_size -1]);

          if (data.repetition_mode=0) then                 // keep mode
          begin
             if (data.list_size = 128) then
             begin
                if (PackBits_pack_flush(data,dbuffer) < 0) then
                begin
                   PackBits_pack_add:=-1;
                exit;
                end;//  else writeln('3rd packer');
            end;
            inc(data.list_size);
            data.list[data.list_size-1] := b;
         end
         else                                        // change mode
         begin
            if (PackBits_pack_flush(data,dbuffer) < 0) then
            begin
              PackBits_pack_add:=-1;
              exit;
            end; //  else writeln('4th packer');
            inc(data.list_size);
            data.list[data.list_size-1] := b;
        end;
    end;
  end;
  PackBits_pack_add:=0; // OK
end;


function PackBits_pack_flush(var data : T_PackBits_data;var dbuffer : lineBufType) : integer;
begin

  if (data.list_size > 0) then
  begin

    if (data.list_size > 128) then
    begin
      //GFX2_Log(GFX2_ERROR, "PackBits_pack_flush() list_size=%d !\n", data->list_size);
      write('error data.list_size > 128');
    end;

    if (data.repetition_mode=1) then
    begin
        Write_byte(data, 257 - data.list_size,dbuffer);
//        inc(data.output_count,1);
        Write_byte(data, data.list[0],dbuffer);
//        inc(data.output_count,1);

    end
    else
    begin
        Write_byte(data, data.list_size-1 ,dbuffer);
//        inc(data.output_count,1);
        Write_bytes(data, data.list, data.list_size,dbuffer);
//        inc(data.output_count, data.list_size);
    end;
    data.list_size := 0;
    data.repetition_mode := 0;
  end;
  PackBits_pack_flush:= data.ncounter;
end;

//function PackBits_pack_add(var data : T_PackBits_data; b : byte) : integer;


function gPackRow(var buffer : LineBufType; BufferOffset : word;var dbuffer : LineBufType; size : integer) : integer;

  var
  pb_data : T_PackBits_data;
  i : integer;
begin
  PackBits_pack_init(pb_data,dbuffer);

  for i:=0 to size-1 do
  begin
    if (PackBits_pack_add(pb_data, buffer[i+Bufferoffset],dbuffer) =-1 ) then
    begin
      gPackRow:=-1;
      writeln('failed');
      exit;
    end;
  end;
  PackBits_pack_flush(pb_data,dbuffer);
  gPackrow:=pb_data.ncounter
end;

begin

end.
