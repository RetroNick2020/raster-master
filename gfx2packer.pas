

type 
  T_PackBits_data = Record
                               f : file;
                    output_count : integer;
                       list_size : byte;
                 repetition_mode : byte;
                            list : array[0..129] of byte;
                    end;




procedure PackBits_pack_init(var data : T_PackBits_data;var f : FILE);
begin
  Fillchar(data, 0, sizeof(data));
  data.f := f;
end;

function PackBits_pack_add(var data : T_PackBits_data; b : byte) : integer;
begin
  case data.list_size of  0:begin // First color
                              data.list[0] := b;
                              data.list_size := 1;
                              break;
                            end;  
                          1:begin  // second color
                              data.repetition_mode := (data.list[0] = b);
                              data.list[1] := b;
                              data.list_size := 2;
                              break;
                            end;  
                         else 
                         begin // next colors
                            if (data.list[data.list_size - 1] = b) then // repeat detected
                            begin
                                if (NOT data.repetition_mode AND data.list_size >= 127) then
                                begin
                                  // diff mode with 126 bytes then 2 identical bytes
                                  dec(data.list_size);
                                  if (PackBits_pack_flush(data) < 0) then
                                  begin
                                    PackBits_pack_add:=-1;
                                    exit;
                                  end;
                                  data.list[0] := b;
                                  data.list[1] := b;
                                  data.list_size := 2;
                                  data.repetition_mode := 1;
                                end
                                else if ((data.repetition_mode) OR (data.list[data.list_size - 2] <> b)) then
                                begin
                                  // same mode is kept
                                  if (data.list_size = 128) then
                                  begin
                                    if (PackBits_pack_flush(data) < 0) then
                                    begin  
                                      PackBits_pack_add:=-1;
                                      exit;
                                    end;
                                  end;  
                                  inc(data.list_size);
                                  data.list[data.list_size] := b;
                                end
                                else
                                begin
                                  // diff mode and 3 identical bytes
                                  data.list_size:=data.list_size - 2;
                                  if (PackBits_pack_flush(data) < 0) then
                                  begin  
                                    PackBits_pack_add:=-1;
                                    exit;
                                  end;
                                  data.list[0] := b;
                                  data.list[1] := b;
                                  data.list[2] := b;
                                  data.list_size := 3;
                                  data.repetition_mode := 1;
                                end;
                            end
                            else // the color is different from the previous one
                            begin
                                if (NOT data.repetition_mode) then                 // keep mode
                                begin
                                  if (data.list_size = 128) then
                                  begin
                                    if (PackBits_pack_flush(data) < 0) then
                                    begin
                                      PackBits_pack_add:=-1;
                                      exit;
                                    end;
                                  end;
                                  inc(data.list_size);
                                  data.list[data.list_size] := b;
                                end
                                else                                        // change mode
                                begin
                                  if (PackBits_pack_flush(data) < 0) then
                                  begin
                                    PackBits_pack_add:=-1;
                                    exit;
                                  end;  
                                  inc(data.list_size);
                                  data.list[data.list_size] := b;
                                end;
                            end;
                        end;
  PackBits_pack_add:=0; // OK
end;

int PackBits_pack_flush(T_PackBits_data * data)
{
  if (data->list_size > 0)
  {
    if (data->list_size > 128)
    {
      GFX2_Log(GFX2_ERROR, "PackBits_pack_flush() list_size=%d !\n", data->list_size);
    }
    if (data->repetition_mode)
    {
      if (data->f != NULL)
      {
        if (!Write_byte(data->f, 257 - data->list_size) ||
            !Write_byte(data->f, data->list[0]))
          return -1;
      }
      data->output_count += 2;
    }
    else
    {
      if (data->f != NULL)
      {
        if (!Write_byte(data->f, data->list_size - 1) ||
            !Write_bytes(data->f, data->list, data->list_size))
          return -1;
      }
      data->output_count += 1 + data->list_size;
    }
    data->list_size = 0;
    data->repetition_mode = 0;
  }
  return data->output_count;
}

int PackBits_pack_buffer(FILE * f, const byte * buffer, size_t size)
{
  T_PackBits_data pb_data;

  PackBits_pack_init(&pb_data, f);
  while (size-- > 0)
  {
    if (PackBits_pack_add(&pb_data, *buffer++))
      return -1;
  }
  return PackBits_pack_flush(&pb_data);
}