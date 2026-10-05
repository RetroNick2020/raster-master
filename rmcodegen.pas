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
                      AsmMode         : boolean;  //db/dw lines for a Pascal assembler procedure
  end;

var
  //Pascal image and map exports write assembler procedures instead of
  //typed-constant arrays. Set from the Export menus. The data then lives in
  //the code segment, out of Turbo Pascal's 64K data segment.
  PascalAsmProcs : boolean = false;
  //RES Text Include mode. The include sits INSIDE the program's const
  //section, among palettes and other typed constants, so an assembler block
  //writes no leading const, re-opens the section after its end; and the
  //include finishes with one constant, so it never ends on a bare const.
  PascalAsmInclude   : boolean = false;
  PascalAsmReopened  : boolean = false;   //a const was re-opened in this include

procedure MWInit(var mc : CodeGenRec;var F : Text);
procedure MWSetLan(var mc : CodeGenRec;Lan : integer);
procedure MWSetValuesTotal(var mc : CodeGenRec;amount : longint);
procedure MWSetValueFormat(var mc : CodeGenRec;format : integer);
procedure MWWriteInteger(var mc : CodeGenRec;value : integer);
procedure MWWriteByte(var mc : CodeGenRec;value : byte);
procedure MWSetValuesPerLine(var mc : CodeGenRec;amount : integer);
procedure MWSetIndentOnFirstLine(var mc : CodeGenRec;indent : boolean);
procedure MWSetIndent(var mc : CodeGenRec;isize : integer);
procedure MWSetAsm(var mc : CodeGenRec;AsmOn : boolean);

//Pascal assembler procedures, for image and map data.
//Only compilers with a built-in assembler that understands db/dw: Turbo
//Pascal, TMT, Free Pascal and the generic Pascal target. Not QuickPascal
//(no built-in assembler) or Amiga Pascal (68000).
function  PascalAsmAllowed(Lan : integer) : boolean;
//Open a data block: the const keyword (asm mode only - the constants that
//follow a procedure need their own const section), and the array header or
//the procedure header.
procedure WritePascalConstStart(var F : Text; AsmOn : boolean);
procedure WritePascalDataStart(var F : Text; AsmOn : boolean; const Indent, Name : string;
                               Size : longint; const ElemType : string; Lan : integer);
//Close a data block written with MW*: ");" or "end;"
procedure WritePascalDataEnd(var F : Text; AsmOn : boolean);
//End an assembler procedure: "end;", and in include mode re-open const
procedure WritePascalAsmEnd(var F : Text);
//Last thing an include writes: a constant if a const was left re-opened
procedure WritePascalIncludeEnd(var F : Text; const FileName : string);

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

procedure MWSetAsm(var mc : CodeGenRec;AsmOn : boolean);
begin
  mc.AsmMode:=AsmOn;
end;

function PascalAsmAllowed(Lan : integer) : boolean;
begin
  PascalAsmAllowed:=(Lan=TPLan) or (Lan=TMTLan) or (Lan=FPLan) or (Lan=PascalLan);
end;

procedure WritePascalConstStart(var F : Text; AsmOn : boolean);
begin
  //not in an include - it is already inside a const section, and
  //"const const" would be an error
  if AsmOn and not PascalAsmInclude then Writeln(F,'const');
end;

procedure WritePascalAsmEnd(var F : Text);
begin
  Writeln(F,'end;');
  if PascalAsmInclude then
  begin
    Writeln(F,'const');           //the palettes and constants that follow need it
    PascalAsmReopened:=true;
  end;
end;

procedure WritePascalIncludeEnd(var F : Text; const FileName : string);
var
  nm : string;
  i  : integer;
begin
  if not PascalAsmReopened then exit;
  //named after the file, so two includes in one program do not clash
  nm:=ChangeFileExt(ExtractFileName(FileName),'');
  for i:=1 to Length(nm) do
    if not (nm[i] in ['A'..'Z','a'..'z','0'..'9','_']) then nm[i]:='_';
  Writeln(F,'  RES_',nm,'_End = 0;   (* closes the const section re-opened after the last procedure *)');
  PascalAsmReopened:=false;
end;

procedure WritePascalDataStart(var F : Text; AsmOn : boolean; const Indent, Name : string;
                               Size : longint; const ElemType : string; Lan : integer);
begin
  if AsmOn then
  begin
    { Free Pascal puts entry code in front of an assembler procedure's body
      unless told not to, so @Name would point at instructions, not data.
      Turbo Pascal adds none here (no parameters, no locals) and does not
      know the nostackframe directive, so only Free Pascal gets it. }
    if Lan = FPLan then
      Writeln(F,'procedure ',Name,'; assembler; nostackframe;')
    else
      Writeln(F,'procedure ',Name,'; assembler;');
    Writeln(F,'asm');
  end
  else
    Writeln(F,Indent,Name,' : array[0..',Size-1,'] of ',ElemType,' = (');
end;

procedure WritePascalDataEnd(var F : Text; AsmOn : boolean);
begin
  if AsmOn then
  begin
    Writeln(F);           //the last data line has no line ending of its own
    WritePascalAsmEnd(F);
  end
  else
    Writeln(F,');');
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
 MWSetAsm(mc,false);
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

//Each assembler line starts with its own directive: db for bytes, dw for
//words - the directive covers the values on that line only.
procedure MWWriteAsmPrefix(var mc : CodeGenRec; const Directive : string);
begin
 if mc.VCL = 0 then Write(mc.FTextPtr^,'  ',Directive,' ');
end;

procedure MWWriteIndent(var mc : CodeGenRec);
begin
 if mc.AsmMode then exit;          //the db/dw prefix does the indenting
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
     //if not basic write a comma - nor in asm, where each line stands alone
     if (not MapLanIsBasic(mc.LanId)) and (not MapLanIsBasicLN(mc.LanId)) and
        (not mc.AsmMode) then Write(mc.FTextPtr^,',');
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
 if mc.AsmMode then MWWriteAsmPrefix(mc,'db');

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
 if mc.AsmMode then MWWriteAsmPrefix(mc,'dw');

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

