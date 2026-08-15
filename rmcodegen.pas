unit rmcodegen;

{$mode objfpc}{$H+}

interface
uses
  Classes, SysUtils,rmconst,gwbasic;

const
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
                      LineCount       : integer;  //line counter
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
procedure MWSetIndentOnFirstLine(var mc : CodeGenRec;indent : boolean);
procedure MWSetIndent(var mc : CodeGenRec;isize : integer);

//language family helpers - map a specific compiler Lan to its syntax family
function MapLanIsBasic(Lan : integer) : boolean;    //DATA statements, no line numbers
function MapLanIsBasicLN(Lan : integer) : boolean;  //DATA statements with line numbers
function MapLanIsPascal(Lan : integer) : boolean;   //Pascal const array
function MapLanIsC(Lan : integer) : boolean;        //C array
function MapLanIsJS(Lan : integer) : boolean;       //JavaScript array
function MapLanIsJSON(Lan : integer) : boolean;     //JSON data descriptor

implementation

function MapLanIsBasic(Lan : integer) : boolean;
begin
  MapLanIsBasic:=(Lan=BasicLan) or (Lan=FBLan) or (Lan=QB64Lan) or
                 (Lan=AQBLan) or (Lan=BAMLan) or (Lan=QBJSLan) or
                 (Lan=QBLan) or (Lan=PBLan)  or
                 (Lan=FBinQBModeLan) or (Lan=ABLan);
end;

function MapLanIsBasicLN(Lan : integer) : boolean;
begin
  MapLanIsBasicLN:=(Lan=BasicLNLan) or (Lan=GWLan);
end;

function MapLanIsPascal(Lan : integer) : boolean;
begin
  MapLanIsPascal:=(Lan=TPLan) or (Lan=PascalLan) or (Lan=QPLan) or
                  (Lan=FPLan) or (Lan=TMTLan) or (Lan=APLan);
end;

function MapLanIsC(Lan : integer) : boolean;
begin
  MapLanIsC:=(Lan=CLan) or (Lan=TCLan) or (Lan=QCLan) or (Lan=OWLan) or
             (Lan=GCCLan) or (Lan=ACLan);
end;

function MapLanIsJS(Lan : integer) : boolean;
begin
  MapLanIsJS:=(Lan=JSLan);
end;

function MapLanIsJSON(Lan : integer) : boolean;
begin
  MapLanIsJSON:=(Lan=JSONLan);
end;

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
 if not MapLanIsBasicLN(mc.LanId) then exit;
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
  if MapLanIsBasic(mc.LanId) or MapLanIsBasicLN(mc.LanId) then
  begin
    if mc.VCL = 0 then Write(mc.FTextPtr^,'DATA ');
  end;
end;

procedure MWWriteIndent(var mc : CodeGenRec);
begin
 if MapLanIsBasic(mc.LanId) or MapLanIsBasicLN(mc.LanId) then exit;
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
     if (not MapLanIsBasic(mc.LanId)) and (not MapLanIsBasicLN(mc.LanId)) then Write(mc.FTextPtr^,','); //if not basic write a comma
   end;
 end;
end;

function ByteToHex(num : byte;LanId : integer) : string;
var
 HStr : String;
begin
 HStr:=hexstr(num,2);
 if MapLanIsBasic(LanId) or MapLanIsBasicLN(LanId) then HStr:='&H'+HStr
 else if MapLanIsPascal(LanId) then HStr:='$'+HStr
 else if MapLanIsC(LanId) or MapLanIsJS(LanId) then HStr:='0x'+HStr;
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
 if MapLanIsBasic(LanId) or MapLanIsBasicLN(LanId) then HStr:='&H'+HStr
 else if MapLanIsPascal(LanId) then HStr:='$'+HStr
 else if MapLanIsC(LanId) or MapLanIsJS(LanId) then HStr:='0x'+HStr;
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

