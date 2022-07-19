unit rmcodegen;

{$mode objfpc}{$H+}

interface
uses
  Classes, SysUtils,gwbasic;

const
 NoLan    = 0;
 BasicLan = 1;
 BasicLNLan = 2;
 CLan     = 3;
 PascalLan= 4;

 ValueFormatDecimal = 0;
 ValueFormatHex = 1;

type
  CodeGenRec = Record
                     InDentSize      : integer; //how many characters to pad
                      IndentOnFirst   : Boolean; //indent on first line
                      ValuesPerLine   : integer; //# values seperated by comma
                      ValuesTotal     : longint; //#number of values we are going to write
                      ValueFormat     : integer;

                      VC              : integer;  //value counter - how many byte/integer written
                      VCL             : longint;  //value counter per line
                      LineCount       : integer; //line counter
                      FTextPtr        : ^Text;     //text file handle
                      LanId           : integer;
  end;

procedure MWInit(var mc : CodeGenRec;var F : Text);
procedure MWSetLan(var mc : CodeGenRec;Lan : integer);
procedure MWSetValuesTotal(var mc : CodeGenRec;amount : longint);
procedure MWSetValueFormat(var mc : CodeGenRec;format : integer);
procedure MWWriteInteger(var mc : CodeGenRec;value : integer);
procedure MWWriteByte(var mc : CodeGenRec;value : byte);
procedure MWSetValuesPerLine(var mc : CodeGenRec;amount : integer);

implementation
procedure MWSetIndent(var mc : CodeGenRec;isize : integer);
begin
  mc.InDentSize:=isize;
end;

procedure MWSetIndentOnFirstLine(var mc : CodeGenRec;indent : boolean);
begin
  mc.IndentOnFirst:=indent;
end;

procedure MWSetValuesPerLine(var mc : CodeGenRec;amount : integer);
begin
  mc.ValuesPerLine:=amount;
end;

procedure MWSetValuesTotal(var mc : CodeGenRec;amount : longint);
begin
  mc.ValuesTotal:=amount;
end;

procedure MWSetValueFormat(var mc : CodeGenRec;format : integer);
begin
  mc.ValueFormat:=format;
end;

procedure MWSetLan(var mc : CodeGenRec;Lan : integer);
begin
  mc.LanId:=Lan;
end;

procedure MWInit(var mc : CodeGenRec;var F : Text);
begin
 mc.FTextPtr:=@F;
 mc.VC:=0;
 mc.VCL:=0;
 mc.LineCount:=0;

 MWSetIndent(mc,10);
 MWSetIndentOnFirstLine(mc,true);
 MWSetValuesPerLine(mc,10);
 MWSetValuesTotal(mc,0);
 MWSetValueFormat(mc,ValueFormatDecimal);
 MWSetLan(mc,PascalLan);
end;

procedure MWWriteLineNumber(var mc : CodeGenRec);
begin
 if (mc.LanId<>BasicLNLan) then exit;
 if mc.VCL = 0 then
 begin
    Write(mc.FTextPtr^,GetGWNextLineNumber,' ');
 end;
end;

procedure MWWriteLineFeed(var mc : CodeGenRec);
begin
 if (mc.VC=mc.ValuesTotal) then exit;
 if mc.VCL = mc.ValuesPerLine then
 begin
    WriteLn(mc.FTextPtr^);
    mc.VCL:=0;
    inc(mc.LineCount);
 end;
end;

procedure MWWriteData(var mc : CodeGenRec);
begin
  if (mc.LanId=BasicLan) or (mc.LanId=BasicLNLan) then
  begin
    if mc.VCL = 0 then Write(mc.FTextPtr^,'DATA ');
  end;
end;

procedure MWWriteIndent(var mc : CodeGenRec);
begin
 if (mc.LanId=BasicLan) or (mc.LanId=BasicLNLan)  then exit;
 if (mc.VCL = 0) then
 begin
  if (mc.IndentOnFirst = false) and (mc.LineCount=0) then exit;
  Write(mc.FTextPtr^,' ':mc.InDentSize);
 end;
end;

procedure MWWriteComma(var mc : CodeGenRec);
begin
 if (mc.VC=mc.ValuesTotal) then
 begin
//   write(FTEXT,'END');
   exit;
 end;

 if mc.VCL > 0 then
 begin
   if (mc.VCL<mc.ValuesPerLine) then
   begin
     Write(mc.FTextPtr^,',');
   end
   else if (mc.VCL=mc.ValuesPerLine)  then  //end of line but not last value
   begin
     if (mc.LanId<>BasicLan) and (mc.LanId<>BasicLNLan) then Write(mc.FTextPtr^,','); //if not basic write a comma
   end;
 end;
end;

function ByteToHex(num : byte;LanId : integer) : string;
var
 HStr : String;
begin
 HStr:=hexstr(num,2);
 if LanId=BasicLan then HStr:='&H'+HStr;
 if LanId=PascalLan then HStr:='$'+HStr;
 if LanId=CLan then HStr:='0x'+HStr;
 ByteToHex:=HStr;
end;

procedure MWWriteByte(var mc : CodeGenRec;value : byte);
begin
 MWWriteLineNumber(mc); //line numbers - only if lan - basicLN
 MWWriteData(mc);       //basiclan data statements -  lanid should be basiclan
 MWWriteIndent(mc);    // method will decide if indent needed

 inc(mc.VC);
 inc(mc.VCL);

 if  mc.ValueFormat = ValueFormatDecimal then
 begin
   Write(mc.FTextPtr^,value);
 end
 else if mc.ValueFormat = ValueFormatHex then
 begin
   Write(mc.FTextPtr^,ByteToHEx(value,mc.LanId));
 end;

 MWWriteComma(mc);     // method will decide if comma needed
 MWWriteLineFeed(mc);  // method will decide if line feed needed
end;

function IntegerToHex(num,LanId : integer) : string;
var
 HStr : String;
begin
 HStr:=hexstr(num,4);
 if LanId=BasicLan then HStr:='&H'+HStr;
 if LanId=PascalLan then HStr:='$'+HStr;
 if LanId=CLan then HStr:='0x'+HStr;
 IntegerToHex:=HStr;
end;

procedure MWWriteInteger(var mc : CodeGenRec;value : integer);
begin
 MWWriteLineNumber(mc); //line numbers - only if lan - basicLN
 MWWriteData(mc);       //basiclan data statements -  lanid should be basiclan
 MWWriteIndent(mc);    // method will decide if indent needed

 inc(mc.VC);
 inc(mc.VCL);

 if  mc.ValueFormat = ValueFormatDecimal then
 begin
   Write(mc.FTextPtr^,value);
 end
 else if mc.ValueFormat = ValueFormatHex then
 begin
   Write(mc.FTextPtr^,IntegerToHex(value,mc.LanId));
 end;

 MWWriteComma(mc);     // method will decide if comma needed
 MWWriteLineFeed(mc);  // method will decide if line feed needed
end;

end.

