{$mode TP}
{$PACKRECORDS 1}
Unit XGF2SRC;
Interface
      uses SysUtils,FileUtil,RWXGF;
Function XgfToSrc(XgfFile,SrcFile:string;myWidth,myHeight,nColors,myformat,myComp:Word):word;
Procedure FilenameToImageName(Var filename,Imagename : string);

Implementation


Procedure Byte2str(mybyte : byte;Var mystring :string);
const
 hexa : array[0..15] of char=('0','1','2','3','4','5','6','7','8','9',
 'A','B','C','D','E','F');
var
 h1,h2 : byte;
begin
 h1:=mybyte shr 4;
 h2:=mybyte shl 4;
 h2:=h2 shr 4;
 mystring:=hexa[h1]+hexa[h2];
end;

Procedure WriteHeaders(Var F : Text;myImageName : String; myWidth,myHeight,Ncolors,
                              myComp, myFormat:Word;myfilesize : LongInt);
Const
 xprForm : array[SprSource..PPRSource] of String = ('SPR','','PPR');
Var
 myRunCount : LongInt;
begin
{$I-}
 If myFormat = SPRSource then
 begin
  myRunCount:=myFileSize div 2;
 end
 else
 begin
  myRunCount:=(myFileSize div 3)*2;
 end;

 Case myFormat of Source2..Source256:
   begin
     Case myComp of TPLan:
       begin
          WriteLn(F,'(* Turbo Pascal, Width= ',myWidth,
                    ' Height= ',myHeight,' Colors= ',Ncolors,' *)');
       end;
                          FPLan:
                                 begin
                                    WriteLn(F,'(* FreePascal, Width= ',myWidth,
                                              ' Height= ',myHeight,' Colors= ',Ncolors,' *)');
                                 end;

                           TCLan:
       begin
          Writeln(F,'/* Turbo C, Width= ',myWidth,
                    ' Height= ',myHeight,' Colors= ',Ncolors,' */');
       end;
                    QCLan:
       begin
          Writeln(F,'/* QuickC, Width= ',myWidth,
                    ' Height= ',myHeight,' Colors= ',Ncolors,' */');
       end;
                    QBLan:
       begin
          Writeln(F,#39,'  QuickBASIC\QB64, Array Size= ',myFileSize div 2,
          ' Width= ',myWidth,' Height= ',myHeight,' Colors= ',Ncolors);

          Writeln(F,#39,'  ',myImageName);
       end;
                    FBLan:
       begin
          Writeln(F,#39,'  FreeBASIC, Array Size= ',myFileSize div 2,
          ' Width= ',myWidth,' Height= ',myHeight,' Colors= ',Ncolors);

          Writeln(F,#39,'  ',myImageName);
       end;

                    ABLan:
       begin
          Writeln(F,#39,'  AmigaBASIC, Array Size= ',myFileSize div 2,
          ' Width= ',myWidth,' Height= ',myHeight,' Colors= ',Ncolors);

          Writeln(F,#39,'  ',myImageName);
       end;


                    PBLan:
       begin
          Writeln(F,#39,'  PowerBASIC, Array Size= ',myFileSize div 2,
          ' Width= ',myWidth,' Height= ',myHeight,' Colors= ',Ncolors);
          Writeln(F,#39,'  ',myImageName);
       end;
                    GWLan:
       begin
          Writeln(F,'1000 ',#39,'  ',myImageName);
          Writeln(F,'1010 ',#39,'  GWBASIC, Array Size= ',myFileSize div 2,
          ' Width= ',myWidth,' Height= ',myHeight,' Colors= ',Ncolors);
       end;

     End;
   End;
                  SPRSource,PPRSource:
  begin
    Case myComp of TPLan:
      begin
          Writeln(F,'(*  Width= ',myWidth,' Height= ',myHeight,
                    ' Colors= ',Ncolors,' Format= ',xprForm[myFormat],' RunCount= ',myRunCount,' *)');
      end;
                   TCLan,QCLan:
      begin
          Writeln(F,'/*  Width= ',myWidth,' Height= ',myHeight,
                    ' Colors= ',Ncolors,' Format= ',xprForm[myFormat],' RunCount= ',myRunCount,' */');
      end;
                   QBLan,PBLan:
      begin
        Writeln(F,#39,'  ',myImageName);
        Writeln(F,#39,'  Width= ',myWidth,' Height= ',myHeight,' Colors= ',Ncolors);
        Writeln(F,#39,'  String Size= ',myFileSize,' Format= ',xprForm[myFormat],' RunCount= ',myRunCount)

      end;
    End;
  End;
                  PALSource:
  begin
    Case myComp of TPLan:
      begin
          Writeln(F,'(* Pascal Palette Source, ',NColors,' Colors (RGB)  *)');
      end;
                   TCLan,QCLan:
      begin
          Writeln(F,'/* C Palette Source, ',NColors,' Colors (RGB)  */');
      end;
                   QBLan,PBLan:
      begin
        Writeln(F,#39,' BASIC Palette Source, ',NColors,' Colors (RGB)');
      end;
    End;
  End;
 End;


 if myComp=GWLan then
 begin
   writeln(F,'1020 ',#39);
 end
 else
 begin
   Writeln(F);
 end;

 If (myComp = TPlan) OR (myComp =FPLan)  then
 begin
   WriteLn(F,myImageName, ' : Array[1..',myFileSize,'] of Byte = (');
 end
 Else if (myComp = QCLan) or (myComp = TCLan) then
 begin
   WriteLn(F,'char ',myImageName,'[',myFileSize,'] = {');
 end;

{$I+}
end;


Procedure FilenameToImageName(Var filename,Imagename : string);
begin
 Imagename:=ExtractFileName(ExtractFileNameWithoutExt(filename));
end;


Function XgfToSrc(XgfFile,SrcFile:string;myWidth,myHeight,nColors,myformat,myComp:Word):word;
Type
 ImgBuf = array[1..60000] of byte;
Var
 F       : Text;
 f2      : file;
 Error   : Word;
 i       : LongInt;
 mybyte  : integer;

 RunCount     : longint;
 myImageName  : String;
 NumRead      : Longint;
 NumPerLine   : Word;
 Counter      : Word;
 NumToRead    : LongInt;
 S,S2         : String;
 myWord       : Word;
 myFileSize   : LongInt;
 myPercent    : Longint;
 myLineNumber : Word;
 myxprHeader:Array[1..24] of byte;
 myBuf : ^ImgBuf;

begin
{$I-}
 myLineNumber:=1040;
 FilenameToImagename(SrcFile,myImageName);
 Numread:=0;
 NumPerLine:=12;
 Case myComp of GWLan,PBLan,QBLan,FBLan,ABLan: begin
                                     if myFormat < SPRBinary then NumPerLine:=8;
                                   end;

 End;
 Counter:=0;
 Assign(F,Srcfile);
 Rewrite(F);


 Assign(F2,XgfFile);
 reset(F2,1);

 myFileSize:=FileSize(F2);
 Case myFormat of          SPRSource:begin
                                       Dec(myFileSize,16);
                                       BlockRead(F2,myXprHeader,16);
                                      end;
                           PPRSource:begin
                                       Dec(myFileSize,24);
                                       BlockRead(F2,myXprHeader,24);
                                      end;
 end;


 NumToRead:=myFilesize;

 (*
 Case myComp of QBLan,PBLan,GWLan: if myformat < SPRBinary then NumToRead:=myFileSize div 2;
 End;
*)
 WriteHeaders(F,myImageName,myWidth,myHeight,nColors,myComp,myFormat,myFileSize);


 Case myComp of QBLan,PBLan,FBLan,ABLan: Write(F,'DATA ');
                      GWLan: Write(F,'1030 DATA ');
   else
     Write(F,'':10);
 End;

 GetMem(myBuf,NumToRead);
 BlockRead(F2,myBuf^,NumToREad);
 NumRead:=0;
 i:=1;
 Repeat


                               case myComp of   TPlan,FPLan: Write(F,'$');
                                    GWLan,QBLan,PBLan,FBLan,ABLan: Write(F,'&H');
                                          TCLan,QCLan: Write(F,'0x');
                               end;

                               Case myComp of GWLan,QBLan,PBLan,FBLan,ABLan:
                                 begin
                                   If myFormat<SPRsource then
                                   begin
                                     myWord:=(myBuf^[i+1] SHL 8) + myBuf^[i];
                                     Inc(NumRead,2);
                                     Inc(i,2);

                                     Byte2Str(Hi(myWord),S);
                                     Byte2Str(Lo(myWord),S2);
                                     //insert code here for Amiga Byte swapping for integer
                                     if myComp = ABLan then
                                     begin
                                       Write(F,S2,S);
                                     end
                                     else
                                     begin
                                       Write(F,S,S2);
                                     end;
                                   end
                                   else
                                   begin
                                     myByte:=myBuf^[i];
                                     Inc(NumRead);
                                     Inc(i);
                                     Byte2Str(myByte,S);
                                     Write(F,S:2);
                                   end;
                                 end;
                               TCLan,QCLan,TPLan,FPLan:
                                 begin
                                   myByte:=myBuf^[i];
                                   Inc(NumRead);
                                   Inc(i);
                                   Byte2Str(myByte,S);
                                   Write(F,S:2);
                                 end;
                              end;

   inc(Counter);
   if Counter=NumPerLine then
   begin
     Counter:=0;
     If NumRead<NumToRead then
     begin
       Case myComp of QBLan,PBLan,FBLan,ABLan : begin
                                     WriteLn(F);
                                     Write(F,'DATA ');
                                    end;
                            GWLan : begin
                                     WriteLn(F);
                                     Write(F,myLineNumber,' DATA ');
                                     inc(myLineNumber,10);
                                    end;
                 QCLan,TCLan,TPLan,FPLan:begin
                                     WriteLn(F,',');
                                     Write(F,'':10);
                                   end;

       end;
     end;
   end
   else
   begin
    If NumRead < NumToRead then
    begin
      Write(F,',');
    end;
   end;



   error:=ioresult;
   if error<>0 then
   begin
    close(f);
    close(f2);
    erase(f);
    FreeMem(myBuf,NumToRead);
    XgfToSrc:=error;
    Error:=IORESULT;
    exit;
   end;

 Until i > NumToRead;

 FreeMem(myBuf,NumToRead);

 Case myComp of QCLan,TCLan:writeln(F,'};');
                      TPLan,FPLan:writeln(F,');');
 End;
 Close(F);
 close(F2);

 if error<>0 then
 begin
   erase(f);
 end;
 XgfToSrc:=IOResult;
{$I+}
end;




begin
end.
