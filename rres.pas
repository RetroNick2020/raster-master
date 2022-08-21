{$MODE TP}
{$PACKRECORDS 1}
Unit rres;

Interface
   uses rmcore,rmthumb,rmxgfcore,rwxgf,rmamigarwxgf,rwpal,wmodex,rwmap,gwbasic,mapcore,rmcodegen,
     wraylib,rwaqb;

//Function RESInclude(filename:string):word;
Function RESInclude(filename:string; index : integer; ExportOnlyIndex : Boolean):word;

Function RESBinary(filename:string):word;

const
 MaxResItems = 255;
type
 resheadrec = Packed Record
                   sig : array[1..3] of char;
                   ver : byte;
                   resitemcount : integer;
              end;

 resrec = Packed Record
             rt     : integer;
             rid    : array[1..20] of char;
             offset : longint;
             size   : longint;
          end;

 resIndex = array[1..MaxResItems] of resrec;

 RFILE = Packed Record
            ResFile  : File;
            ResList  : ^resIndex;
            ResItems : integer;
         end;

Procedure res_open(Var IRFILE : RFILE;filename : string);
Procedure res_close(var IRFILE : RFILE);
Function  res_getsize(VAR IRFILE : RFILE; ri : integer) : longint;
Procedure res_read(VAR IRFILE : RFILE; var rbuf; ri : integer);
(*
Procedure res_dis_xgf(Var IRFILE : RFILE; x,y : integer;ri : integer;dmode : integer);
*)

Implementation

Procedure res_open(Var IRFILE : RFILE;filename : string);
type
  ExeHeaderRec = Record
                    Sig    : Word; (* EXE File signature *)
                    bleft  : Word; (* Number of Bytes in last page of EXE image*)
                    nPages : Word; (* Number of 512 Byte pages in EXE image *)
                 end;

Var
 i,error   : word;
 ressig    : array[1..3] of char;
 ExeHeader : ExeHeaderRec;
 ExeSize   : LongInt;
begin
{$I-}
  assign(IRFILE.Resfile,filename);
  Reset(IRFILE.ResFile,1);
  error:=ioresult;
  if error <> 0 then
  begin
    writeln('error opening resource file ',filename);
    halt;
  end;

  exesize:=0;
  If Filename=ParamStr(0) then
  begin
    BlockRead(IRFILE.ResFile,ExeHeader,SizeOf(ExeHeaderRec));
    ExeSize:=Longint(ExeHeader.bleft)+LongInt((ExeHeader.npages-1))*512;
    Seek(IRFILE.ResFile,ExeSize);
  end;

  blockread(IRFILE.Resfile,ressig,3);
  if ressig <> 'RES' then
  begin
    writeln('not a valid resource file');
    halt;
  end;

  blockread(IRFILE.resfile,IRFILE.resitems,2);
  getmem(IRFILE.reslist,sizeof(resrec)*IRFILE.resitems);
  blockread(IRFILE.resfile,IRFILE.reslist^,sizeof(resrec)*IRFILE.resitems);
  error:=ioresult;
  if error<>0 then
  begin
    writeln('error reading resource file header');
    halt;
  end;

  For i:=1 to IRFILE.resitems do
  begin
    Inc(IRFILE.ResList^[i].offset,exesize);
  end;

{$I+}
end;

Procedure res_close(var IRFILE : RFILE);
var
 error : word;
begin
{$I-}
  close(IRFILE.resfile);
  Freemem(IRFILE.reslist,sizeof(resrec)*IRFILE.resitems);
  error:=ioresult;
  if error <> 0 then
  begin
    writeln('error closing resource file');
    halt;
  end;
{$I+}
end;

Function res_getsize(VAR IRFILE : RFILE; ri : integer) : longint;
begin
 res_getsize:=IRFILE.reslist^[ri].size;
end;

Procedure res_read(VAR IRFILE : RFILE; var rbuf; ri : integer);
var
 error        : word;
begin
{$I-}
   seek(IRFILE.resfile,IRFILE.reslist^[ri].offset);
   blockread(IRFILE.resfile,rbuf,IRFILE.reslist^[ri].size);
   error:=ioresult;
   if error <> 0 then
   begin
     writeln('error reading resource file');
     halt;
   end;
{$I+}
end;

function GetRESImageSize(width,height,nColors,Lan,ImageType : integer) : longint;
var
 size : longint;
begin
 size:=0;
 Case Lan of TPLan,TCLan:begin
                           Case ImageType of 1:size:=GetXImageSize(width,height,ncolors);
                                             2,3:size:=GetLBMPBMImageSize(width,height); // Xlib LBM/PBM

                           end;
                         end;
             QCLan,QPLan,GWLan,PBLan:size:=GetXImageSize(width,height,ncolors);
             QBLan:begin
                      if ImageType = 1 then
                      begin
                       size:=GetXImageSize(width,height,ncolors);
                      end;
                    end;
             QB64Lan:begin
                       if (ImageType >0)  and (ImageType < 4) then
                       begin
                          size:=ResRayLibImageSize(width,height,ImageType);
                       end;
                     end;
             FPLan:begin
                      if ImageType = 1 then
                      begin
                         size:=GetXImageSizeFP(width,height);
                      end
                      else if (ImageType >1)  and (ImageType < 5) then
                      begin
                         size:=ResRayLibImageSize(width,height,ImageType-1);
                      end;
                   end;
             FBinQBModeLan:begin
                             if ImageType = 1 then
                             begin
                               size:=GetXImageSizeFB(width,height);
                             end;
                           end;
             FBLan:begin
                      if (ImageType >0)  and (ImageType < 4) then
                      begin
                         size:=ResRayLibImageSize(width,height,ImageType);
                      end;
                    end;
             ABLan:begin
                     Case ImageType of 1:size:=GetABXImageSize(width,height,nColors);
                                       2:size:=GetBobDataSize(width,height,nColors,false); //bob
                                       3:size:=GetBobDataSize(width,height,nColors,true);  //vsprite
                     end;
                   end;
             AQBLan:size:=width*height;
             APLan,ACLan:size:=GetAmigaBitMapSize(width,height,ncolors);
             gccLan:size:=ResRayLibImageSize(width,height,ImageType);
 end;

GetRESImageSize:=size;
end;

function GetRESPaletteSize(nColors,Lan,rgbFormat : integer) : longint;
var
 size : longint;
begin
  size:=0;
  if rgbFormat = ColorIndexFormat then Size:=nColors
    else Size:=nColors*3;
  GetRESPaletteSize:=Size;
end;

function GetRESMapSize(mwidth,mheight : integer) : longint;
var
 size : longint;
begin
  size:=(mwidth*mheight*sizeof(integer))+(4*sizeof(integer));
  GetRESMapSize:=Size;
end;

Procedure WriteBasicLabel(var data : BufferRec;Lan : integer;LabelName : string);
begin
  //we don't want GWLan  - it has line number already
  case Lan of ABLan,AQBLan,FBinQBModeLan,FBLan,QBLan,QB64Lan,PBLan:Writeln(data.fText,LabelName,'Label:');
  end;
end;

procedure WriteBasicVariable(var data : BufferRec;Lan : integer;vname,vsubname : string;value : longint);
var
 DotOrUnderScore : String;
begin
  DotOrUnderScore:='.';

  if (Lan=AQBLan) or (Lan = FBinQBModeLan) or (Lan = FBLan) then
  begin
    DotOrUnderScore:='_';
  end;
  if (Lan=AQBLan) or (Lan = FBLan) then
  begin
    writeln(data.fText,LineCountToStr(Lan),'Dim ',vname,DotOrUnderScore,vsubname,' As Integer = ',value);
  end
  else
  begin
    writeln(data.fText,LineCountToStr(Lan),vname,DotOrUnderScore,vsubname,' = ',value);
  end;
end;

procedure WriteFBBasicDimReadStub(var data : BufferRec;Lan : integer; name : string;size : longint);
begin
  if (Lan<>GWLan) then writeln(data.fText,LineCountToStr(Lan),'Restore ',name,'Label');

  writeln(data.fText,LineCountToStr(Lan),'Dim ',name,'(',size,') As Integer');
  writeln(data.fText,LineCountToStr(Lan),'For _rmi=0 to ',size-1);
  writeln(data.fText,LineCountToStr(Lan),'   Read ',name,'(_rmi)');
  writeln(data.fText,LineCountToStr(Lan),'Next _rmi');
end;


procedure WriteBasicDimReadStub(var data : BufferRec;Lan : integer; name : string;size : longint);
begin
  if (Lan<>GWLan) then writeln(data.fText,LineCountToStr(Lan),'Restore ',name,'Label');

  writeln(data.fText,LineCountToStr(Lan),'Dim ',name,'(',size,')');
  writeln(data.fText,LineCountToStr(Lan),'For i=0 to ',size-1);
  writeln(data.fText,LineCountToStr(Lan),'   Read ',name,'(i)');
  writeln(data.fText,LineCountToStr(Lan),'Next i');
end;

procedure WriteFBBasicReadStub(var data : BufferRec;Lan : integer; name : string;size : longint);
begin
  writeln(data.fText,LineCountToStr(Lan),'Restore ',name,'Label');
  writeln(data.fText,LineCountToStr(Lan),'Dim As Any Ptr ',name);
  writeln(data.fText,LineCountToStr(Lan),name,' = ImageCreate(',name,'_Width,',name,'_Height)');
  writeln(data.fText,LineCountToStr(Lan),'For _rmy=0 to ',name,'_Height-1');
  writeln(data.fText,LineCountToStr(Lan),'  For _rmx=0 to ',name,'_Width-1');
  writeln(data.fText,LineCountToStr(Lan),'   Read _rmr,_rmg,_rmb');
  writeln(data.fText,LineCountToStr(Lan),'   if ',name,'_Format = 7 Then');
  writeln(data.fText,LineCountToStr(Lan),'      Read _rma');
  writeln(data.fText,LineCountToStr(Lan),'      PSet ',name,',(_rmx, _rmy),RGBA(_rmr,_rmg,_rmb,_rma)');
  writeln(data.fText,LineCountToStr(Lan),'   else');
  writeln(data.fText,LineCountToStr(Lan),'       PSet ',name,',(_rmx, _rmy),RGB(_rmr,_rmg,_rmb)');
  writeln(data.fText,LineCountToStr(Lan),'   end if');

  writeln(data.fText,LineCountToStr(Lan),'  Next _rmx');
  writeln(data.fText,LineCountToStr(Lan),'Next _rmy');
end;

procedure WriteQB64BasicReadStub(var data : BufferRec;Lan : integer; name : string;size : longint);
begin
  writeln(data.fText,LineCountToStr(Lan),'Restore ',name,'Label');
  writeln(data.fText,LineCountToStr(Lan),'Dim ',name,'&');
  writeln(data.fText,LineCountToStr(Lan),name,'& = _NewImage(',name,'.Width,',name,'.Height,32)');
  writeln(data.fText,LineCountToStr(Lan),'prevdest = _Dest');
  writeln(data.fText,LineCountToStr(Lan),'_Dest ',name,'&');
  writeln(data.fText,LineCountToStr(Lan),'For y=0 to ',name,'.Height-1');
  writeln(data.fText,LineCountToStr(Lan),'  For x=0 to ',name,'.Width-1');
  writeln(data.fText,LineCountToStr(Lan),'   Read r,g,b');
  writeln(data.fText,LineCountToStr(Lan),'   if ',name,'.Format = 7 Then');
  writeln(data.fText,LineCountToStr(Lan),'      Read a');
  writeln(data.fText,LineCountToStr(Lan),'      PSet(x,y),_RGBA(r,g,b,a)');
  writeln(data.fText,LineCountToStr(Lan),'   else');
  writeln(data.fText,LineCountToStr(Lan),'      PSet(x,y),_RGB(r,g,b)');
  writeln(data.fText,LineCountToStr(Lan),'   end if');
  writeln(data.fText,LineCountToStr(Lan),'  Next x');
  writeln(data.fText,LineCountToStr(Lan),'Next y');
  writeln(data.fText,LineCountToStr(Lan),'_Dest prevdest');
end;



procedure WriteAQBImageStub(var data : BufferRec;Lan,Image,Mask : integer; name : string;size : longint);
begin
 writeln(data.fText,LineCountToStr(Lan),'Restore ',name,'Label');
 writeln(data.fText,LineCountToStr(Lan),'Dim As BITMAP_t PTR ',name,'BitMap = NULL');
 if Image = 2 then
 begin
   writeln(data.fText,LineCountToStr(Lan),'Dim As BOB_t PTR ',name,'Bob');
 end
 else if Image = 3 then
 begin
   writeln(data.fText,LineCountToStr(Lan),'Dim As SPRITE_t PTR ',name,'Sprite');
 end;
 writeln(data.fText,LineCountToStr(Lan),name,'BitMap = BITMAP(',name,'_Width,',name,'_Height,',name,'_Depth,TRUE)');
 writeln(data.fText,LineCountToStr(Lan),'BITMAP OUTPUT ',name,'BitMap');
 writeln(data.fText,LineCountToStr(Lan),'For _rmj=0 to ',name,'_Height-1');
 writeln(data.fText,LineCountToStr(Lan),'   For _rmi=0 to ',name,'_Width-1');
 writeln(data.fText,LineCountToStr(Lan),'      Read _rma');
 writeln(data.fText,LineCountToStr(Lan),'      Pset(_rmi,_rmj),_rma');
 writeln(data.fText,LineCountToStr(Lan),'   Next _rmi');
 writeln(data.fText,LineCountToStr(Lan),'Next _rmj');
 if Mask = 1 then writeln(data.fText,LineCountToStr(Lan),'BITMAP MASK ',name,'BitMap');
 if Image = 2 then
  begin
    writeln(data.fText,LineCountToStr(Lan),name,'Bob = BOB(',name,'BitMap)');
  end
  else if Image = 3 then
  begin
    writeln(data.fText,LineCountToStr(Lan),name,'Sprite = SPRITE(',name,'BitMap)');
  end;
  writeln(data.fText,LineCountToStr(Lan),'WINDOW OUTPUT 1');
end;

procedure WriteAmigaBasicBobVSprite(var data : BufferRec;Lan : integer; name : string;size : longint);
begin
 writeln(data.fText,LineCountToStr(Lan),'Restore ',name,'Label');

 writeln(data.fText,LineCountToStr(Lan),name,'$=""');
 writeln(data.fText,LineCountToStr(Lan),'For i=0 to ',size-1);
 writeln(data.fText,LineCountToStr(Lan),'   Read a');
 writeln(data.fText,LineCountToStr(Lan),'   ',name,'$=',name,'$+chr$(a)');
 writeln(data.fText,LineCountToStr(Lan),'Next i');
end;

procedure WriteAmigaBasicPaletteReadStub(var data : BufferRec;Lan : integer; name : string;size : longint);
var
 fv : string;
begin
  fv:='i';
  if Lan = AQBLan then fv:='_rmi';
  writeln(data.fText,LineCountToStr(Lan),'Restore ',name,'Label');

  writeln(data.fText,LineCountToStr(Lan),'Dim ',name,'!(',size,')');
  writeln(data.fText,LineCountToStr(Lan),'For ',fv,'=0 to ',size-1);
  writeln(data.fText,LineCountToStr(Lan),'   Read ',name,'!(',fv,')');
  writeln(data.fText,LineCountToStr(Lan),'Next ',fv);
end;


procedure WriteBasicRMInit(var data : BufferRec);
var
 count : integer;
 width,height : integer;
 EO : ImageExportFormatRec;
 nColors : integer;
 Size    : LongInt;
 PalSize : Longint;
 i       : integer;
 DefIntFlag : Boolean;
 MP : MapPropsRec;
 MPE : MapExportFormatRec;
 mwidth,mheight : integer;
 Lan   : integer;
 Format : integer;
begin
  DefIntFlag:=True;
  count:=ImageThumbBase.GetCount;
  for i:=0 to count-1 do
  begin
     width:=ImageThumbBase.GetExportWidth(i);
     height:=ImageThumbBase.GetExportHeight(i);
     ImageThumbBase.GetExportOptions(i,EO);
     nColors:=ImageThumbBase.GetMaxColor(i)+1;
     size:=GetRESImageSize(width,height,nColors,EO.Lan,EO.Image);

     if (EO.LAN = QB64Lan) or (EO.LAN=FBLan) then         //size is different for RGBA formats
     begin
        if (EO.Image > 0) and (EO.Image < 4) then
        begin
           size:=RayLibImageSize(width,height,EO.Image);
        end;
     end;


     if (EO.LAN = ABLan) or (EO.LAN = AQBLan) or (EO.LAN = GWLan) or (EO.LAN = QBLan) or (EO.LAN = QB64Lan) or (EO.LAN = FBinQBModeLan) or (EO.LAN = FBLan) or (EO.LAN = PBLan) then
     begin
       if DefIntFlag then
       begin
          if (EO.Lan=AQBLan) or (EO.Lan=FBLan) then
          begin
            writeln(data.fText,LineCountToStr(EO.Lan),'Dim As Integer _rmx,_rmy,_rmr,_rmg,_rmb,_rma,_rmi,_rmj');
          end
          else
          begin
            Writeln(data.fText,LineCountToStr(EO.Lan),'DEFINT A-Z');
          end;
          DefIntFlag:=False;  // we only write this once - we put it here because we don't know which language until we pull the first image
       end;

       //write palette first
       if EO.Palette > 0 then
       begin
         PalSize:=GetRESPaletteSize(nColors,EO.Lan,EO.Palette);
         WriteBasicVariable(data,EO.Lan,EO.Name+'Pal','Size',PalSize);
         WriteBasicVariable(data,EO.Lan,EO.Name+'Pal','Colors',nColors);
         WriteBasicVariable(data,EO.Lan,EO.Name+'Pal','Id',i);
         if ((EO.Lan=ABLan) or (EO.Lan=AQBLan)) and  (EO.Palette=5) then   // uses SINGLE(!) variable for palette in n.nn format
         begin
           WriteAmigaBasicPaletteReadStub(data,EO.Lan,EO.Name+'Pal',PalSize);
         end
         else
         begin
           WriteBasicDimReadStub(data,EO.Lan,EO.Name+'Pal',PalSize);
         end;
       end;

       if (EO.Image > 0) then  //we have an image
       begin
          if (EO.Image = 1) and ((EO.Lan = FBinQBModeLan) or (EO.Lan = ABLan) or (EO.Lan = QBLan) or (EO.Lan = GWLan) or (EO.Lan = PBLan)) then size := size div 2;  //we writing basic integers for Image format 1
          WriteBasicVariable(data,EO.Lan,EO.Name,'Size',size);
          if ((EO.Lan = QB64Lan) or (EO.Lan = FBLan)) and ((EO.Image > 0) and (EO.Image < 4)) then
          begin
             Format:=7;
             if EO.Image = 3 then Format:=4;
             WriteBasicVariable(data,EO.Lan,EO.Name,'Format',Format);   // for QB64/Freebasic RayLib formats
          end;
          WriteBasicVariable(data,EO.Lan,EO.Name,'Width',width);
          WriteBasicVariable(data,EO.Lan,EO.Name,'Height',height);
          WriteBasicVariable(data,EO.Lan,EO.Name,'Colors',nColors);
          WriteBasicVariable(data,EO.Lan,EO.Name,'Id',i);

          //write loader code
          if (EO.Lan=ABLan) and ((EO.Image=2) or (EO.Image=3)) then   //these are stored in strings so we need a diffent way
          begin
            WriteAmigaBasicBobVSprite(data,EO.Lan,EO.Name,size);
          end
          else if (EO.Lan=AQBLan) then
          begin
            WriteBasicVariable(data,EO.Lan,EO.Name,'Depth',nColorsToBitPlanes(nColors));
            WriteAQBImageStub(data,EO.Lan,EO.Image,EO.Mask,EO.Name,size);
          end
          else if (EO.Lan=FBLan) and ((EO.Image>0) and (EO.Image<4)) then
          begin
            WriteFBBasicReadStub(data,EO.Lan,EO.Name,size);   //FreeBASIC - not QB mode - RGB/RGBA Load code
          end
          else if (EO.Lan=QB64Lan) and ((EO.Image>0) and (EO.Image<4)) then
          begin
            WriteQB64BasicReadStub(data,EO.Lan,EO.Name,size);   //FreeBASIC - not QB mode - RGB/RGBA Load code
          end
          else
          begin
            if (EO.Image = 1) then WriteBasicDimReadStub(data,EO.Lan,EO.Name,size);   //we only generate loading stub for putimage code. RayLib RGB/RGBA still needs to be loaded by you!
          end;
       end;

       if (EO.Image = 1) and (EO.Mask > 0)  then    //we have putimage mask - except for
       begin
         WriteBasicVariable(data,EO.Lan,EO.Name+'Mask','Size',size);
         WriteBasicVariable(data,EO.Lan,EO.Name+'Mask','Width',width);
         WriteBasicVariable(data,EO.Lan,EO.Name+'Mask','Height',height);
         WriteBasicVariable(data,EO.Lan,EO.Name+'Mask','Colors',nColors);
         WriteBasicVariable(data,EO.Lan,EO.Name+'Mask','Id',i);
         if (EO.LAN<>AQBLan) then WriteBasicDimReadStub(data,EO.Lan,EO.Name+'Mask',size);  //aqb does need this. it uses different format for mask
       end;
     end;
  end;


  //write map info
 count:=MapCoreBase.GetMapCount;
 For i:=0 to count-1 do
 begin
   MapCoreBase.GetMapProps(i,MP);
   MapCoreBase.GetMapExportProps(i,MPE);
   mwidth:=MapCoreBase.GetExportWidth(i);
   mheight:=MapCoreBase.GetExportHeight(i);
   size:=mwidth*mheight+4;

   if ((MPE.Lan=BasicLan) or (MPE.Lan=AQBBasicLan) or  (MPE.Lan=FBBasicLan) or (MPE.Lan=QB64BasicLan) or (MPE.Lan=BasicLnLan)) and (MPE.MapFormat=1) then   //hack alert - fix FBBasicLan
   begin
     Lan:=QBLan;
     if MPE.Lan = BasicLnLan then
     begin
       Lan:=GWLan;
     end
     else if MPE.Lan = FBBasicLan then
     begin
       Lan:=FBLan;
     end
     else if MPE.Lan = AQBBasicLan then
     begin
       Lan:=AQBLan;
     end;

     WriteBasicVariable(data,Lan,MPE.Name+'Map','Size',size);
     WriteBasicVariable(data,Lan,MPE.Name+'Map','Width',mwidth);
     WriteBasicVariable(data,Lan,MPE.Name+'Map','Height',mheight);
     WriteBasicVariable(data,Lan,MPE.Name+'Map','TileWidth',MP.tilewidth);
     WriteBasicVariable(data,Lan,MPE.Name+'Map','TileHeight',MP.tileheight);
     WriteBasicVariable(data,Lan,MPE.Name+'Map','Id',i);
     if (Lan = FBLan) or (Lan = AQBLan) then
     begin
        WriteFBBasicDimReadStub(data,Lan,MPE.Name+'Map',size);
     end
     else
     begin
        WriteBasicDimReadStub(data,Lan,MPE.Name+'Map',size)
     end;
   end;
 end;
end;



//exportonlyindex means export only the index, none of the other images.palette maps
Function RESInclude(filename:string; index : integer; ExportOnlyIndex : Boolean):word;
var
 data    : BufferRec;
 EO      : ImageExportFormatRec;
 i       : integer;
 count   : integer;
 width   : integer;
 height  : integer;
 StartIndex : integer;
begin
 SetThumbActive;   // we are getting pixel data from core object ThumbBase
 SetGWStartLineNumber(1000); // this is only used for exporting GWBASIC/PCBASIC code

 assign(data.fText,filename);
{$I-}
 rewrite(data.fText);

 if ExportOnlyIndex then
 begin
   StartIndex:=index;
   count:=StartIndex+1;
 end
 else
 begin
   WriteBasicRMinit(data);      //generates the dims, variable assignments,  and loader code for all the basic languages
   StartIndex:=0;
   count:=ImageThumbBase.GetCount;
 end;

 for i:=StartIndex to count-1 do
 begin
   width:=ImageThumbBase.GetExportWidth(i);
   height:=ImageThumbBase.GetExportHeight(i);
   ImageThumbBase.GetExportOptions(i,EO);
   SetThumbIndex(i);  //important - otherwise the GetMaxColor and GetPixel functions will not get the right data

   if (EO.Lan>0) and (EO.Palette > 0) then
   begin
     WriteBasicLabel(data,EO.Lan,EO.Name+'Pal');
     WritePalToArrayBuffer(data,EO.Name+'Pal',EO.Lan,EO.Palette);
   end;

   case EO.Lan of TPLan,TCLan,FPLan,FBinQBModeLan,QBLan,GWLan,QCLan,QPLan,PBLan:
        begin
          if EO.Image = 1 then   //put image format
          begin
            WriteBasicLabel(data,EO.Lan,EO.Name);  //checks if it's basic lan then writes lable - ignoes other lan
            WriteXGFCodeToBuffer(data,0,0,width-1,height-1,EO.Lan,0,EO.Name);
          end;
          if (EO.Image = 1) and (EO.Mask=1) and (EO.Lan<>AQBLan) then    //put image mask
          begin
            WriteBasicLabel(data,EO.Lan,EO.Name+'Mask');
            WriteXGFCodeToBuffer(data,0,0,width-1,height-1,EO.Lan,1,EO.Name+'Mask');
          end;
        end;
   end;

   if (EO.LAN=TPLan) AND (EO.Image = 2) then  // XLib LBM
   begin
     WriteTPLBMCodeToBuffer(data,0,0,width-1,height-1,i,EO.Name);
   end;

   if (EO.LAN=TPLan) AND (EO.Image = 3) then // XLib PBM
   begin
     WriteTPPBMCodeToBuffer(data,0,0,width-1,height-1,i,EO.Name);
   end;

   if (EO.LAN=TCLan) AND (EO.Image = 2) then  // XLib LBM
   begin
     WriteTCLBMCodeToBuffer(data,0,0,width-1,height-1,i,EO.Name);
   end;

   if (EO.LAN=TCLan) AND (EO.Image = 3) then // XLib PBM
   begin
     WriteTCPBMCodeToBuffer(data,0,0,width-1,height-1,i,EO.Name);
   end;



   if (EO.LAN=ABLan) and (EO.Image = 1) then
   begin
     WriteBasicLabel(data,EO.Lan,EO.Name);
     WriteAmigaBasicXGFDataBuffer(0,0,width-1,height-1,0,data,EO.Name);        // put
   end;
   if (EO.LAN=ABLan) and (EO.Image = 1) and (EO.Mask=1) then
   begin
     WriteBasicLabel(data,EO.Lan,EO.Name+'Mask');
     WriteAmigaBasicXGFDataBuffer(0,0,width-1,height-1,1,data,EO.Name+'Mask');        // mask
   end;

   if (EO.LAN=ABLan) and (EO.Image = 2) then
   begin
     WriteBasicLabel(data,EO.Lan,EO.Name);
     WriteAmigaBasicBobDataBuffer(0,0,width-1,height-1,data,EO.Name,false); //bob
   end;
   if (EO.LAN=ABLan) and (EO.Image = 3) then
   begin
     WriteBasicLabel(data,EO.Lan,EO.Name);
     WriteAmigaBasicBobDataBuffer(0,0,width-1,height-1,data,EO.Name,true); // vsprite
   end;

   if (EO.LAN=ACLan) and (EO.Image = 1) then WriteAmigaCBobCodeToBuffer(0,0,width-1,height-1,EO.Name,data,false);        // bob
   if (EO.LAN=ACLan) and (EO.Image = 2) then WriteAmigaCBobCodeToBuffer(0,0,width-1,height-1,EO.Name,data,true);  //vsprite

   if (EO.LAN=APLan) and (EO.Image = 1) then WriteAmigaPascalBobCodeToBuffer(0,0,height-1,width-1,EO.Name,data,false);        // bob
   if (EO.LAN=APLan) and (EO.Image = 2) then WriteAmigaPascalBobCodeToBuffer(0,0,height-1,width-1,EO.Name,data,true);  //vsprite

   if (EO.LAN=AQBLan) and ((EO.Image > 0) and (EO.Image < 4)) then
   begin
     WriteBasicLabel(data,EO.Lan,EO.Name);
     WriteAQBBitMapCodeToBuffer(data.fText,0,0,height-1,width-1,EO.Name);
   end;

   //FP RayLib formats
   if (EO.Lan = FPLan) and (EO.Image > 1) and (EO.Image < 5) then
   begin
     // -1 in image format is to make it like gcc format numbers
     WriteRayLibCodeToBuffer(data.fText,0,0,width-1,height-1, EO.Lan,EO.Image-1,EO.Name);
   end;

   //QB/FB RayLib formats
   if ((EO.Lan = QB64Lan) or (EO.Lan = FBLan)) and (EO.Image > 0) and (EO.Image < 4) then
   begin
     WriteBasicLabel(data,EO.Lan,EO.Name);
     // -1 in image format is to make it like gcc format numbers
     WriteRayLibCodeToBuffer(data.fText,0,0,width-1,height-1, EO.Lan,EO.Image,EO.Name);
   end;

   //gcc RayLib Format
   if (EO.Lan = gccLan) and (EO.Image > 0) and (EO.Image < 4) then
   begin
      WriteRayLibCodeToBuffer(data.fText,0,0,width-1,height-1, EO.Lan,EO.Image,EO.Name);
   end;

 end;

 if ExportOnlyIndex = false then     //export the maps
 begin
     WriteMapsCodeToBuffer(data.fText);
 end;
 close(data.fText);
 {$I+}
 RESInclude:=IOResult;
end;


Function RESBinary(filename:string):word;
var
 data    : BufferRec;
 EO      : ImageExportFormatRec;
 RR      : resrec;
 RH      : resheadrec;
 i       : integer;
 count   : integer;
 width   : integer;
 height  : integer;
 nColors : integer;
 Size    : LongInt;
 PalSize : Longint;

 HeaderSize  : LongInt;
 OffsetCount : LongInt;
 ExportCount : Integer;
 SLen        : integer;
 Error       : integer;
 MaskName    : string;
 PalName     : string;
 MapCount    : integer;
 MapName     : string;
 MapSize     : longint;
 MapExport   :  MapExportFormatRec;
begin
 ExportCount:=ImageThumbBase.GetExportImageCount;
 inc(ExportCount,ImageThumbBase.GetExportMaskCount);
 inc(ExportCount,ImageThumbBase.GetExportPaletteCount);
 inc(ExportCount,MapCoreBase.GetExportMapCount);

 if ExportCount = 0 then exit;

 SetThumbActive;   // we are getting pixel data from core object ThumbBase
 assign(data.f,filename);
{$I-}
 rewrite(data.f,1);
{$I+}
 Error:=IORESULT;
 if Error<>0 then
 begin
    RESBinary:=Error;
    exit;
 end;
 count:=ImageThumbBase.GetCount;
 HeaderSize:=sizeof(RH)+Exportcount*sizeof(resrec);
 OffsetCount:=HeaderSize;

 //write the signature and record count
 RH.sig:='RES';
 RH.ver:=1;
 RH.resitemcount:=Exportcount;
 {$I-}
 Blockwrite(data.f,RH,sizeof(RH));
 {$I+}
 Error:=IORESULT;
 if Error<>0 then
 begin
  RESBinary:=Error;
  exit;
 end;

 //write the header with all the correct offsets where the image is going to be located
 for i:=0 to count-1 do
 begin
   ImageThumbBase.GetExportOptions(i,EO);

   width:=ImageThumbBase.GetExportWidth(i);
   height:=ImageThumbBase.GetExportHeight(i);
   nColors:=ImageThumbBase.GetMaxColor(i)+1;
   Size:=GetRESImageSize(width,height,nColors,EO.Lan,EO.Image);


   //write the palette first - if there is a palette
   if EO.Palette > 0 then
   begin
     PalSize:=GetRESPaletteSize(nColors,EO.Lan,EO.Palette);

     PalName:=EO.Name+'Pal';
     fillchar(RR.rid,sizeof(RR.rid),32);
     slen:=Length(PalName);
     if slen > 20 then slen:=20;
     Move(PalName[1],RR.rid,slen);

     RR.size:=PalSize;
     RR.offset:=OffsetCount;
     RR.rt:=EO.Palette; // id's less than 100 are palettes

     inc(OffsetCount,PalSize);
     {$I-}
     Blockwrite(data.f,RR,sizeof(RR));
     {$I+}
     Error:=IORESULT;
     if Error<>0 then
     begin
       RESBinary:=Error;
       exit;
     end;
   end;

   //copy name field
   fillchar(RR.rid,sizeof(RR.rid),32);
   slen:=Length(EO.Name);
   if slen > 20 then slen:=20;
   Move(EO.Name[1],RR.rid,slen);

   //calc size/offset
   if EO.Image > 0  then
   begin
     RR.size:=Size;
     RR.offset:=OffsetCount;
     RR.rt:=EO.Lan*100+EO.Image; //language id * 100 + Image Type to generate resource type

     inc(OffsetCount,Size);
     {$I-}
     Blockwrite(data.f,RR,sizeof(RR));

     //if there is a mask image we write the info also - size is the same, offset and name will be different
     if (EO.Image=1) and (EO.Mask = 1) then    //only create mask for putimage
     begin
       MaskName:=EO.Name+'Mask';
       slen:=Length(MaskName);
       if slen > 20 then slen:=20;
       Move(MaskName[1],RR.rid,slen);

       RR.offset:=OffsetCount;
       inc(OffsetCount,Size);
       Blockwrite(data.f,RR,sizeof(RR));
     end;


     {$I+}
     Error:=IORESULT;
     if Error<>0 then
     begin
       RESBinary:=Error;
       exit;
     end;
   end;
  end; //for count - finished wwriting all the image/pal header info

  // dump res header fields for Maps
  MapCount:=MapCoreBase.GetMapCount;
  for i:=0 to MapCount-1 do
  begin
      MapCoreBase.GetMapExportProps(i,MapExport);
      if MapExport.MapFormat > 0 then
      begin
        width:=MapCoreBase.GetExportWidth(i);
        height:=MapCoreBase.GetExportHeight(i);
        MapSize:=GetRESMapSize(width,height);

        fillchar(RR.rid,sizeof(RR.rid),32);
        MapName:=MapExport.Name;
        slen:=Length(MapName);
        if slen > 20 then slen:=20;
        Move(MapName[1],RR.rid,slen);

        RR.size:=MapSize;
        RR.offset:=OffsetCount;
        RR.rt:=MapExport.Lan*200+MapExport.MapFormat; //language id * 200 + Map format to generate resource type

        inc(OffsetCount,MapSize);
        {$I-}
        Blockwrite(data.f,RR,sizeof(RR));
        {$I+}
        Error:=IORESULT;
        if Error<>0 then
        begin
          RESBinary:=Error;
          exit;
        end;

      end;
  end;



 //convert and dump image
 for i:=0 to count-1 do
 begin
   width:=ImageThumbBase.GetExportWidth(i);
   height:=ImageThumbBase.GetExportHeight(i);
   ImageThumbBase.GetExportOptions(i,EO);
   SetThumbIndex(i);  //important - otherwise the GetMaxColor and GetPixel functions will not get the right data

   if EO.Palette > 0 then WritePalToBuffer(data,EO.Palette);

   Case EO.Lan of QCLan,QPLan,QBLan,GWLan,PBLan:
                                    begin
                                      if (EO.Image = 1) then WriteXgfToBuffer(0,0,width-1,height-1,EO.Lan,0,data);
                                      if (EO.Image = 1) and (EO.Mask=1) then WriteXgfToBuffer(0,0,width-1,height-1,EO.Lan,1,data);
                                    end;
                              QB64Lan:begin
                                        if (EO.Image > 0) and (EO.Image<4) then ResExportRayLibToBuffer(data.f,0,0,width-1,height-1,EO.Image);
                                      end;
                        TPLan,TCLan: begin
                                       if (EO.Image = 1) then WriteXgfToBuffer(0,0,width-1,height-1,EO.Lan,0,data);
                                       if (EO.Image = 1) and (EO.Mask=1) then WriteXgfToBuffer(0,0,width-1,height-1,EO.Lan,1,data);
                                       if (EO.Image = 2) then WriteLBMToBuffer(0,0,width-1,height-1,data);   //xlib lbm
                                       if (EO.Image = 3) then WritePBMToBuffer(0,0,width-1,height-1,data);   //xlib pbm
                                     end;
                              FPLan: begin
                                       if (EO.Image = 1) then WriteXGFToBufferFP(0,0,width-1,height-1,0,data);
                                       if (EO.Image = 1) and (EO.Mask=1) then WriteXGFToBufferFP(0,0,width-1,height-1,1,data);
                                       if (EO.Image > 1) and (EO.Image<5) then ResExportRayLibToBuffer(data.f,0,0,width-1,height-1,EO.Image-1);
                                     end;
                              FBinQBModeLan: begin
                                       if (EO.Image = 1) then WriteXGFToBufferFB(0,0,width-1,height-1,0,data);
                                       if (EO.Image = 1) and (EO.Mask=1) then WriteXGFToBufferFB(0,0,width-1,height-1,1,data);
                                     end;
                              FBLan:begin
                                       if (EO.Image > 0) and (EO.Image<4) then ResExportRayLibToBuffer(data.f,0,0,width-1,height-1,EO.Image);
                                    end;
                              ABLan:begin
                                      if (EO.Image = 1) then WriteAmigaBasicXGFBuffer(0,0,width-1,height-1,data);
                                      if (EO.Image = 2) then WriteAmigaBasicBobBuffer(0,0,width-1,height-1,data,false); //bob
                                      if (EO.Image = 3) then WriteAmigaBasicBobBuffer(0,0,width-1,height-1,data,true);  //sprite
                                    end;
                        ACLan,APLan:begin
                                      if (EO.Image = 1) then WriteAmigaBobBuffer(0,0,width-1,height-1,data,false);
                                      if (EO.Image = 2) then WriteAmigaBobBuffer(0,0,width-1,height-1,data,true);
                                    end;
                             gccLan:begin
                                      ResExportRayLibToBuffer(data.f,0,0,width-1,height-1,EO.Image);
                                    end;

   end;
 end;

 ResExportMaps(data.f); //export the maps

 {$I-}
 close(data.f);
 {$I+}
 RESBinary:=IOResult;
end;








begin
end.
