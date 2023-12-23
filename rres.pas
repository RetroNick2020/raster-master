{$MODE TP}
{$PACKRECORDS 1}
Unit rres;

Interface
   uses rmcore,rmthumb,rmxgfcore,rwxgf,rmamigarwxgf,rwpal,wmodex,rwmap,gwbasic,mapcore,rmcodegen,
     wraylib,rwaqb,wmouse;

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


//Image Export Propertis Dialog box the image type changes depending on what compiler is selected
//we need a way to convert all the droplist combination to a simple format

function ImageIndexToFormat(Compiler,ImageIndex : integer) : integer;
var
  format : integer;
begin
  format:=0;
  case Compiler of TPLan:begin
                           case ImageIndex of 1:format:=PutImageExportFormat;
                                              2:format:=XLibLBMExportFormat;
                                              3:format:=XLibPBMExportFormat;
                                              4:format:=MouseImageExportFormat;
                           end;
                         end;
                  TMTLan:begin
                           case ImageIndex of 1:format:=PutImageExportFormat;
                           end;
                         end;
                   TCLan:begin
                           case ImageIndex of 1:format:=PutImageExportFormat;
                                              2:format:=XLibLBMExportFormat;
                                              3:format:=XLibPBMExportFormat;
                                              4:format:=MouseImageExportFormat;
                           end;
                         end;
                   QCLan:begin
                           case ImageIndex of 1:format:=PutImageExportFormat;
                                              2:format:=MouseImageExportFormat;
                           end;
                         end;
                   QBLan:begin
                           case ImageIndex of 1:format:=PutImageExportFormat;
                                              2:format:=MouseImageExportFormat;
                           end;
                         end;
                   BAMLan:begin
                           case ImageIndex of 1:format:=PutImageExportFormat;
                           end;
                         end;
                   QB64Lan:begin
                           case ImageIndex of 1:format:=RGBAFuchsiaExportFormat;
                                              2:format:=RGBAIndex0ExportFormat;
                                              3:format:=RGBExportFormat;
                                              4:format:=RayLibRGBAFuchsiaExportFormat;
                                              5:format:=RayLibRGBAIndex0ExportFormat;
                                              6:format:=RayLibRGBExportFormat;
                           end;
                         end;
                   PBLan:begin
                           case ImageIndex of 1:format:=PutImageExportFormat;
                                              2:format:=MouseImageExportFormat;
                           end;
                         end;
                   GWLan:begin
                           case ImageIndex of 1:format:=PutImageExportFormat;
                                              2:format:=MouseImageExportFormat;
                           end;
                         end;
                   FPLan:begin
                           case ImageIndex of 1:format:=PutImageExportFormat;
                                              2:format:=RGBAFuchsiaExportFormat;
                                              3:format:=RGBAIndex0ExportFormat;
                                              4:format:=RGBExportFormat;
                                              5:format:=MouseImageExportFormat;
                           end;
                         end;
                   FBinQBModeLan:begin
                         case ImageIndex of 1:format:=PutImageExportFormat;
                                            2:format:=MouseImageExportFormat;
                         end;
                       end;
                   FBLan:begin
                           case ImageIndex of 1:format:=RGBAFuchsiaExportFormat;
                                              2:format:=RGBAIndex0ExportFormat;
                                              3:format:=RGBExportFormat;
                           end;
                         end;
                   ABLan:begin
                           case ImageIndex of 1:format:=PutImageExportFormat;
                                              2:format:=AmigaBOBExportFormat;
                                              3:format:=AmigaVSpriteExportFormat;
                           end;
                         end;
                   APLan:begin
                           case ImageIndex of 1:format:=AmigaBOBExportFormat;
                                              2:format:=AmigaVSpriteExportFormat;
                           end;
                         end;
                   ACLan:begin
                           case ImageIndex of 1:format:=AmigaBOBExportFormat;
                                              2:format:=AmigaVSpriteExportFormat;
                           end;
                         end;
                   AQBLan:begin
                           case ImageIndex of 1:format:=PutImageExportFormat;
                                              2:format:=AmigaBOBExportFormat;
                                              3:format:=AmigaVSpriteExportFormat;
                           end;
                          end;
                   QPLan:begin
                           case ImageIndex of 1:format:=PutImageExportFormat;
                                              2:format:=MouseImageExportFormat;
                           end;
                         end;
                   gccLan:begin
                           case ImageIndex of 1:format:=RGBAFuchsiaExportFormat;
                                              2:format:=RGBAIndex0ExportFormat;
                                              3:format:=RGBExportFormat;
                           end;
                         end;
                   OWLan:begin
                           case ImageIndex of 1:format:=PutImageExportFormat;
                                              2:format:=MouseImageExportFormat;
                           end;
                         end;
   end;
   ImageIndexToFormat:=format;
end;

function GetRESImageSize(width,height,nColors,Lan,ImageType : integer) : longint;
var
 size : longint;
 ImageFormat : integer;
begin
 size:=0;
 ImageFormat:=ImageIndexToFormat(Lan,ImageType);
 Case Lan of TPLan:begin
                      Case ImageFormat of PutImageExportFormat:size:=GetXImageSize(width,height,ncolors);
                                          XLibLBMExportFormat,
                                          XLibPBMExportFormat:size:=GetLBMPBMImageSize(width,height); // Xlib LBM/PBM
                                          MouseImageExportFormat:size:=GetMouseShapeSize;
                      end;
                   end;

            TMTLan:begin
                     Case ImageFormat of PutImageExportFormat:size:=GetXImageSizeTMT(width,height,ncolors);
                     end;
                   end;
             TCLan:begin
                      Case ImageFormat of PutImageExportFormat:size:=GetXImageSize(width,height,ncolors);
                                          XLibLBMExportFormat,
                                          XLibPBMExportFormat:size:=GetLBMPBMImageSize(width,height); // Xlib LBM/PBM
                                          MouseImageExportFormat:size:=GetMouseShapeSize;
                      end;
                   end;
             QCLan:begin
                     Case ImageFormat of PutImageExportFormat:size:=GetXImageSize(width,height,ncolors);
                                         MouseImageExportFormat:size:=GetMouseShapeSize;
                     end;
                   end;
             QPLan:begin
                     Case ImageFormat of PutImageExportFormat:size:=GetXImageSize(width,height,ncolors);
                                         MouseImageExportFormat:size:=GetMouseShapeSize;
                     end;
                   end;
             GWLan:begin
                     Case ImageFormat of PutImageExportFormat:size:=GetXImageSize(width,height,ncolors);
                                         MouseImageExportFormat:size:=GetMouseShapeSize;
                     end;
                   end;
             PBLan:begin
                     Case ImageFormat of PutImageExportFormat:size:=GetXImageSize(width,height,ncolors);
                                         MouseImageExportFormat:size:=GetMouseShapeSize;
                     end;
                   end;
             QBLan:begin
                     Case ImageFormat of PutImageExportFormat:size:=GetXImageSize(width,height,ncolors);
                                         MouseImageExportFormat:size:=GetMouseShapeSize;
                     end;
                    end;
             BAMLan:begin
                     Case ImageFormat of PutImageExportFormat:size:=GetXImageSizeBAM(width,height,ncolors);
                     end;
                    end;

             QB64Lan:begin
                       Case ImageFormat of RGBAFuchsiaExportFormat:size:=ResRayLibImageSize(width,height,1);
                                           RGBAIndex0ExportFormat:size:=ResRayLibImageSize(width,height,2);
                                           RGBExportFormat:size:=ResRayLibImageSize(width,height,3);
                                           RayLibRGBAFuchsiaExportFormat:size:=ResRayLibImageSize(width,height,1);
                                           RayLibRGBAIndex0ExportFormat:size:=ResRayLibImageSize(width,height,2);
                                           RayLibRGBExportFormat:size:=ResRayLibImageSize(width,height,3);
                       end;
                     end;
             FPLan:begin
                      //if ImageType = 1 then
                      //begin
                      //   size:=GetXImageSizeFP(width,height);
                      //end
                      //else if (ImageType >1)  and (ImageType < 5) then
                      //begin
                      //   size:=ResRayLibImageSize(width,height,ImageType-1);
                      //end;

                      Case ImageFormat of  PutImageExportFormat:size:=GetXImageSizeFP(width,height);
                                           RGBAFuchsiaExportFormat:size:=ResRayLibImageSize(width,height,1);
                                           RGBAIndex0ExportFormat:size:=ResRayLibImageSize(width,height,2);
                                           RGBExportFormat:size:=ResRayLibImageSize(width,height,3);
                                           MouseImageExportFormat:size:=GetMouseShapeSize;
                      end;
                   end;
             FBinQBModeLan:begin
                             //if ImageType = 1 then
                             //begin
                             //  size:=GetXImageSizeFB(width,height);
                             //end;
                             Case ImageFormat of PutImageExportFormat:size:=GetXImageSizeFB(width,height);
                                                       MouseImageExportFormat:size:=GetMouseShapeSize;
                             end;
                           end;
             FBLan:begin
                      //if (ImageType >0)  and (ImageType < 4) then
                      //begin
                      //   size:=ResRayLibImageSize(width,height,ImageType);
                      //end;
                      Case ImageFormat of  RGBAFuchsiaExportFormat:size:=ResRayLibImageSize(width,height,1);
                                           RGBAIndex0ExportFormat:size:=ResRayLibImageSize(width,height,2);
                                           RGBExportFormat:size:=ResRayLibImageSize(width,height,3);
                      end;
                    end;
             ABLan:begin
                     Case ImageFormat of PutImageExportFormat:size:=GetABXImageSize(width,height,nColors);
                                         AmigaBOBExportFormat:size:=GetBobDataSize(width,height,nColors,false); //bob
                                         AmigaVSpriteExportFormat:size:=GetBobDataSize(width,height,nColors,true);  //vsprite
                     end;
                   end;
             AQBLan:begin
                     Case ImageFormat of PutImageExportFormat,
                                         AmigaBOBExportFormat,
                                         AmigaVSpriteExportFormat:size:=width*height;
                     end;
                    end;
             APLan:begin
                      Case ImageFormat of AmigaBOBExportFormat,
                                          AmigaVSpriteExportFormat:size:=GetAmigaBitMapSize(width,height,ncolors);
                      end;
                   end;
             ACLan:begin
                      Case ImageFormat of AmigaBOBExportFormat,
                                          AmigaVSpriteExportFormat:size:=GetAmigaBitMapSize(width,height,ncolors);
                      end;
                   end;
             gccLan:begin
                      // size:=ResRayLibImageSize(width,height,ImageType);
                      Case ImageFormat of  RGBAFuchsiaExportFormat:size:=ResRayLibImageSize(width,height,1);
                                           RGBAIndex0ExportFormat:size:=ResRayLibImageSize(width,height,2);
                                           RGBExportFormat:size:=ResRayLibImageSize(width,height,3);
                      end;
                    end;
             OWLan:begin
                     Case ImageFormat of PutImageExportFormat:size:=GetXImageSizeOW(width,height,ncolors);
                                         MouseImageExportFormat:size:=GetMouseShapeSize;
                     end;
                   end;

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
  case Lan of BAMLan,ABLan,AQBLan,FBinQBModeLan,FBLan,QBLan,QB64Lan,PBLan:Writeln(data.fText,LabelName,'Label:');
  end;
end;

procedure WriteBasicVariable(var data : BufferRec;Lan : integer;vname,vsubname : string;value : longint);
var
 DotOrUnderScore : String;
begin
  DotOrUnderScore:='.';

  if (Lan=BAMLan) or (Lan=AQBLan) or (Lan = FBinQBModeLan) or (Lan = FBLan) then
  begin
    DotOrUnderScore:='_';
  end;
  if (Lan=AQBLan) or (Lan = FBLan) then
  begin
    writeln(data.fText,LineCountToStr(Lan),'Dim ',vname,DotOrUnderScore,vsubname,' As Integer = ',value);
  end
  else if (Lan=QB64Lan) then
  begin
    writeln(data.fText,LineCountToStr(Lan),'Const ',vname,DotOrUnderScore,vsubname,' = ',value);
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

procedure WriteQB64ReadStub(var data : BufferRec;Lan : integer; name : string;size : longint);
begin
  writeln(data.fText,LineCountToStr(Lan),'Restore ',name,'Label');
  writeln(data.fText,LineCountToStr(Lan),'Dim ',name,'&');
  writeln(data.fText,LineCountToStr(Lan),name,'& = _NewImage(',name,'.Width,',name,'.Height,32)');
  writeln(data.fText,LineCountToStr(Lan),'rmprevdest = _Dest');
  writeln(data.fText,LineCountToStr(Lan),'_Dest ',name,'&');
  writeln(data.fText,LineCountToStr(Lan),'For rmy=0 to ',name,'.Height-1');
  writeln(data.fText,LineCountToStr(Lan),'  For rmx=0 to ',name,'.Width-1');
  writeln(data.fText,LineCountToStr(Lan),'   Read rmr,rmg,rmb');
  writeln(data.fText,LineCountToStr(Lan),'   if ',name,'.Format = 7 Then');
  writeln(data.fText,LineCountToStr(Lan),'      Read rma');
  writeln(data.fText,LineCountToStr(Lan),'      PSet(rmx,rmy),_RGBA(rmr,rmg,rmb,rma)');
  writeln(data.fText,LineCountToStr(Lan),'   else');
  writeln(data.fText,LineCountToStr(Lan),'      PSet(rmx,rmy),_RGB(rmr,rmg,rmb)');
  writeln(data.fText,LineCountToStr(Lan),'   end if');
  writeln(data.fText,LineCountToStr(Lan),'  Next rmx');
  writeln(data.fText,LineCountToStr(Lan),'Next rmy');
  writeln(data.fText,LineCountToStr(Lan),'_Dest rmprevdest');
end;

procedure WriteQB64RayLibReadStub(var data : BufferRec;Lan : integer; name : string;size : longint);
begin
  writeln(data.fText,LineCountToStr(Lan),'Restore ',name,'Label');
  writeln(data.fText,LineCountToStr(Lan),'Dim ',name,'Data AS _MEM');
  writeln(data.fText,LineCountToStr(Lan),'Dim ',name,'Image AS Image');
  writeln(data.fText,LineCountToStr(Lan),'Dim ',name,'Texture AS Texture');

  writeln(data.fText,LineCountToStr(Lan),name,'Data = _MemNew(',name,'.Size)');
  writeln(data.fText,LineCountToStr(Lan),'rmc = 0');
  writeln(data.fText,LineCountToStr(Lan),'For rmy=0 to ',name,'.Height-1');
  writeln(data.fText,LineCountToStr(Lan),'  For rmx=0 to ',name,'.Width-1');
  writeln(data.fText,LineCountToStr(Lan),'   Read rmr,rmg,rmb');
  writeln(data.fText,LineCountToStr(Lan),'   _MemPut ',name,'Data, ',name,'Data.OFFSET + rmc, rmr As _UNSIGNED _BYTE ');
  writeln(data.fText,LineCountToStr(Lan),'   _MemPut ',name,'Data, ',name,'Data.OFFSET + rmc + 1, rmg As _UNSIGNED _BYTE ');
  writeln(data.fText,LineCountToStr(Lan),'   _MemPut ',name,'Data, ',name,'Data.OFFSET + rmc + 2, rmb As _UNSIGNED _BYTE ');
  writeln(data.fText,LineCountToStr(Lan),'   if ',name,'.Format = 7 Then');
  writeln(data.fText,LineCountToStr(Lan),'      Read rma');
  writeln(data.fText,LineCountToStr(Lan),'      _MemPut ',name,'Data, ',name,'Data.OFFSET + rmc + 3, rma As _UNSIGNED _BYTE ');
  writeln(data.fText,LineCountToStr(Lan),'      rmc = rmc + 4 ');
  writeln(data.fText,LineCountToStr(Lan),'   else');
  writeln(data.fText,LineCountToStr(Lan),'      rmc = rmc + 3 ');
  writeln(data.fText,LineCountToStr(Lan),'   end if');
  writeln(data.fText,LineCountToStr(Lan),'  Next rmx');
  writeln(data.fText,LineCountToStr(Lan),'Next rmy');

  writeln(data.fText,LineCountToStr(Lan),name,'Image.dat =  ',name,'Data.OFFSET');
  writeln(data.fText,LineCountToStr(Lan),name,'Image.W = ',name,'.Width');
  writeln(data.fText,LineCountToStr(Lan),name,'Image.H = ',name,'.Height');
  writeln(data.fText,LineCountToStr(Lan),name,'Image.mipmaps = 1');
  writeln(data.fText,LineCountToStr(Lan),name,'Image.format = ',name,'.Format');
  writeln(data.fText,LineCountToStr(Lan),'LoadTextureFromImage ',name,'Image, ',name,'Texture');
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
 ImageExportFormat : integer;
begin
  DefIntFlag:=True;
  count:=ImageThumbBase.GetCount;
  for i:=0 to count-1 do
  begin
     width:=ImageThumbBase.GetExportWidth(i);
     height:=ImageThumbBase.GetExportHeight(i);
     ImageThumbBase.GetExportOptions(i,EO);
     //start using ImageExportFormat instead of EO.Image because it give us more correct information without addtional condistions to check
     ImageExportFormat:=ImageIndexToFormat(EO.Lan,EO.Image);

     nColors:=ImageThumbBase.GetMaxColor(i)+1;
     size:=GetRESImageSize(width,height,nColors,EO.Lan,EO.Image);

     if (EO.LAN in [QB64Lan,FBLan]) then         //GetRESImageSize works most of the time but not for this - we need to use RayLibImageSize here
     begin
        Case ImageExportFormat of RGBAFuchsiaExportFormat:size:=RayLibImageSize(width,height,1);
                                   RGBAIndex0ExportFormat:size:=RayLibImageSize(width,height,2);
                                          RGBExportFormat:size:=RayLibImageSize(width,height,3);
                                  RayLibRGBAFuchsiaExportFormat:size:=RayLibImageSize(width,height,1);
                                   RayLibRGBAIndex0ExportFormat:size:=RayLibImageSize(width,height,2);
                                          RayLibRGBExportFormat:size:=RayLibImageSize(width,height,3);
        end;
    //    if (EO.Image > 0) and (EO.Image < 4) then
    //    begin
    //       size:=RayLibImageSize(width,height,EO.Image);
    //    end;
     end;


     if (EO.LAN in [BAMLan,ABLan,AQBLan,GWLan,QBLan,QB64Lan,FBinQBModeLan,FBLan,PBLan]) then
     begin
       if DefIntFlag then
       begin
          if (EO.Lan in [AQBLan,FBLan]) then
          begin
            writeln(data.fText,LineCountToStr(EO.Lan),'Dim As Integer _rmx,_rmy,_rmr,_rmg,_rmb,_rma,_rmi,_rmj');
          end
          else if (EO.Lan = QB64Lan) then
          begin
            if ImageExportFormat in [RayLibRGBAFuchsiaExportFormat,RayLibRGBAIndex0ExportFormat,RayLibRGBExportFormat] then
            begin
              writeln(data.fText,LineCountToStr(EO.Lan),'Dim rmx,rmy,rmi,rmj,rmc AS Integer');
              writeln(data.fText,LineCountToStr(EO.Lan),'Dim rmr, rmg, rmb, rma As _Unsigned _Byte');
            end
            else
            begin
              writeln(data.fText,LineCountToStr(EO.Lan),'Dim rmx,rmy,rmi,rmj,rmc,rmprevdest AS Integer');
              writeln(data.fText,LineCountToStr(EO.Lan),'Dim rmr, rmg, rmb, rma As _Unsigned _Byte');
            end;
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

//       if (EO.Image > 0) then  //we have an image
         if ImageExportFormat > 0 then
         begin
//        if (EO.Image = 1) and ((EO.Lan = FBinQBModeLan) or (EO.Lan = ABLan) or (EO.Lan = QBLan) or (EO.Lan = GWLan) or (EO.Lan = PBLan)) then size := size div 2;  //we writing basic integers for Image format 1
          if (ImageExportFormat = PutImageExportFormat) and (EO.Lan in [BAMLan,FBinQBModeLan,ABLan,QBLan,GWLan,PBLan]) then size := size div 2;  //we writing basic integers for Image format 1

          if (ImageExportFormat = MouseImageExportFormat) and (EO.Lan in [FBinQBModeLan,QBLan,GWLan,PBLan]) then size := size div 2;  //we writing basic integers for Image format 1


          WriteBasicVariable(data,EO.Lan,EO.Name,'Size',size);
//        if ((EO.Lan = QB64Lan) or (EO.Lan = FBLan)) and ((EO.Image > 0) and (EO.Image < 4)) then
          if ((EO.Lan = QB64Lan) or (EO.Lan = FBLan)) then
          begin
            if  ImageExportFormat in [RGBAFuchsiaExportFormat,RGBAIndex0ExportFormat,RGBExportFormat,RayLibRGBAFuchsiaExportFormat,RayLibRGBAIndex0ExportFormat,RayLibRGBExportFormat] then
            begin
               Format:=7;
               if ImageExportFormat in [RGBExportFormat,rayLibRGBExportFormat] then Format:=4;
               WriteBasicVariable(data,EO.Lan,EO.Name,'Format',Format);   // for QB64/Freebasic RayLib formats
            end;
          end;
          WriteBasicVariable(data,EO.Lan,EO.Name,'Width',width);
          WriteBasicVariable(data,EO.Lan,EO.Name,'Height',height);
          WriteBasicVariable(data,EO.Lan,EO.Name,'Colors',nColors);
          WriteBasicVariable(data,EO.Lan,EO.Name,'Id',i);

          //write loader code
//          if (EO.Lan=ABLan) and ((EO.Image=2) or (EO.Image=3)) then   //these are stored in strings so we need a diffent way
          if (EO.Lan=ABLan) and (ImageExportFormat in [AmigaBOBExportFormat,AmigaVSpriteExportFormat]) then   //these are stored in strings so we need a diffent way
          begin
            WriteAmigaBasicBobVSprite(data,EO.Lan,EO.Name,size);
          end
          else if (EO.Lan=AQBLan) then
          begin
            WriteBasicVariable(data,EO.Lan,EO.Name,'Depth',nColorsToBitPlanes(nColors));
            WriteAQBImageStub(data,EO.Lan,EO.Image,EO.Mask,EO.Name,size);
          end
//        else if (EO.Lan=FBLan) and ((EO.Image>0) and (EO.Image<4)) then
          else if (EO.Lan=FBLan) then
          begin
           if  (ImageExportFormat in [RGBAFuchsiaExportFormat,RGBAIndex0ExportFormat,RGBExportFormat]) then
           begin
             WriteFBBasicReadStub(data,EO.Lan,EO.Name,size);   //FreeBASIC - not QB mode - RGB/RGBA Load code
           end;
          end
//        else if (EO.Lan=QB64Lan) and ((EO.Image>0) and (EO.Image<4)) then
          else if (EO.Lan=QB64Lan) then
          begin
            if  (ImageExportFormat in [RGBAFuchsiaExportFormat,RGBAIndex0ExportFormat,RGBExportFormat]) then
            begin
              WriteQB64ReadStub(data,EO.Lan,EO.Name,size);   //QB64 - Use Internal Graphics
            end
            else if  (ImageExportFormat in [RayLibRGBAFuchsiaExportFormat,RayLibRGBAIndex0ExportFormat,RayLibRGBExportFormat]) then
            begin
              WriteQB64RayLibReadStub(data,EO.Lan,EO.Name,size);  //QB64 - Use RayLib Graphics
            end;

          end
          else
          begin
            if (ImageExportFormat in[PutImageExportFormat,MouseImageExportFormat]) then WriteBasicDimReadStub(data,EO.Lan,EO.Name,size);   //loading stub for putimage code.
          end;
       end;

//    if (EO.Image = 1) and (EO.Mask > 0)  then    //we have putimage mask - except for
      if (ImageExportFormat = PutImageExportFormat) and (EO.Mask > 0)  then    //we have putimage mask - except for
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

   if ((MPE.Lan=BasicLan) or (MPE.Lan=BAMBasicLan) or (MPE.Lan=AQBBasicLan) or  (MPE.Lan=FBBasicLan) or (MPE.Lan=QB64BasicLan) or (MPE.Lan=BasicLnLan)) and (MPE.MapFormat=1) then   //hack alert - fix FBBasicLan
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
     end
     else if MPE.Lan = BAMBasicLan then
     begin
        Lan:=BAMLan;
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
 ImageExportFormat : integer;
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
   ImageExportFormat:=ImageIndexToFormat(EO.Lan,EO.Image);
   SetThumbIndex(i);  //important - otherwise the GetMaxColor and GetPixel functions will not get the right data

   if (EO.Lan>0) and (EO.Palette > 0) then
   begin
     WriteBasicLabel(data,EO.Lan,EO.Name+'Pal');
     WritePalToArrayBuffer(data,EO.Name+'Pal',EO.Lan,EO.Palette);
   end;

   case EO.Lan of TPLan,TMTLan,TCLan,FPLan,FBinQBModeLan,BAMLan,QBLan,GWLan,QCLan,QPLan,PBLan,OWLan:
        begin
//          if EO.Image = 1 then   //put image format

          if ImageExportFormat = PutImageExportFormat then   //put image format
          begin
            WriteBasicLabel(data,EO.Lan,EO.Name);  //checks if it's basic lan then writes lable - ignoes other lan
            WriteXGFCodeToBuffer(data,0,0,width-1,height-1,EO.Lan,0,EO.Name);
          end;

//          if (EO.Image = 1) and (EO.Mask=1) and (EO.Lan<>AQBLan) then    //put image mask
          if (ImageExportFormat = PutImageExportFormat) and (EO.Mask=1) and (EO.Lan<>AQBLan) then    //put image mask
          begin
            WriteBasicLabel(data,EO.Lan,EO.Name+'Mask');
            WriteXGFCodeToBuffer(data,0,0,width-1,height-1,EO.Lan,1,EO.Name+'Mask');
          end;

          if (ImageExportFormat = MouseImageExportFormat) then
          begin
            WriteBasicLabel(data,EO.Lan,EO.Name);
            WriteMShapeCodeToBuffer(data,0,0,EO.Lan,i,EO.Name);
          end;
        end;
   end;

//   if (EO.LAN=TPLan) AND (EO.Image = 2) then  // XLib LBM
  if (EO.LAN=TPLan) AND (ImageExportFormat = XLibLBMExportFormat) then  // XLib LBM
  begin
     WriteTPLBMCodeToBuffer(data,0,0,width-1,height-1,i,EO.Name);
   end;

   if (EO.LAN=TPLan) AND (ImageExportFormat = XLibPBMExportFormat) then // XLib PBM
   begin
     WriteTPPBMCodeToBuffer(data,0,0,width-1,height-1,i,EO.Name);
   end;

   if (EO.LAN=TCLan) AND (ImageExportFormat = XLibLBMExportFormat) then  // XLib LBM
   begin
     WriteTCLBMCodeToBuffer(data,0,0,width-1,height-1,i,EO.Name);
   end;

   if (EO.LAN=TCLan) AND (ImageExportFormat = XLibPBMExportFormat) then // XLib PBM
   begin
     WriteTCPBMCodeToBuffer(data,0,0,width-1,height-1,i,EO.Name);
   end;

   if (EO.LAN=ABLan) and (ImageExportFormat = PutImageExportFormat) then
   begin
     WriteBasicLabel(data,EO.Lan,EO.Name);
     WriteAmigaBasicXGFDataBuffer(0,0,width-1,height-1,0,data,EO.Name);        // put
   end;
   if (EO.LAN=ABLan) and (ImageExportFormat = PutImageExportFormat) and (EO.Mask=1) then
   begin
     WriteBasicLabel(data,EO.Lan,EO.Name+'Mask');
     WriteAmigaBasicXGFDataBuffer(0,0,width-1,height-1,1,data,EO.Name+'Mask');        // mask
   end;

   if (EO.LAN=ABLan) and (ImageExportFormat = AmigaBOBExportFormat) then
   begin
     WriteBasicLabel(data,EO.Lan,EO.Name);
     WriteAmigaBasicBobDataBuffer(0,0,width-1,height-1,data,EO.Name,false); //bob
   end;
   if (EO.LAN=ABLan) and (ImageExportFormat = AmigaVSpriteExportFormat) then
   begin
     WriteBasicLabel(data,EO.Lan,EO.Name);
     WriteAmigaBasicBobDataBuffer(0,0,width-1,height-1,data,EO.Name,true); // vsprite
   end;

   if (EO.LAN=ACLan) and (ImageExportFormat = AmigaBOBExportFormat) then WriteAmigaCBobCodeToBuffer(0,0,width-1,height-1,EO.Name,data,false);        // bob
   if (EO.LAN=ACLan) and (ImageExportFormat = AmigaVSpriteExportFormat) then WriteAmigaCBobCodeToBuffer(0,0,width-1,height-1,EO.Name,data,true);  //vsprite

   if (EO.LAN=APLan) and (ImageExportFormat = AmigaBOBExportFormat) then WriteAmigaPascalBobCodeToBuffer(0,0,height-1,width-1,EO.Name,data,false);        // bob
   if (EO.LAN=APLan) and (ImageExportFormat = AmigaVSpriteExportFormat) then WriteAmigaPascalBobCodeToBuffer(0,0,height-1,width-1,EO.Name,data,true);  //vsprite

   if (EO.LAN=AQBLan) and (ImageExportFormat in [AmigaBOBExportFormat,AmigaVSpriteExportFormat,PutImageExportFormat]) then
   begin
     WriteBasicLabel(data,EO.Lan,EO.Name);
     WriteAQBBitMapCodeToBuffer(data.fText,0,0,height-1,width-1,EO.Name);
   end;

   //FP RayLib formats
   if (EO.Lan in [FPLan,QB64Lan,FBLan,gccLan]) and (ImageExportFormat in [RGBAFuchsiaExportFormat,RGBAIndex0ExportFormat,RGBExportFormat,RayLibRGBAFuchsiaExportFormat,RayLibRGBAIndex0ExportFormat,RayLibRGBExportFormat]) then
   begin
     if (EO.Lan in [QB64Lan,FBLan]) then WriteBasicLabel(data,EO.Lan,EO.Name);
     Case ImageExportFormat of RGBAFuchsiaExportFormat:WriteRayLibCodeToBuffer(data.fText,0,0,width-1,height-1, EO.Lan,1,EO.Name);
                                RGBAIndex0ExportFormat:WriteRayLibCodeToBuffer(data.fText,0,0,width-1,height-1, EO.Lan,2,EO.Name);
                                       RGBExportFormat:WriteRayLibCodeToBuffer(data.fText,0,0,width-1,height-1, EO.Lan,3,EO.Name);
                         RayLibRGBAFuchsiaExportFormat:WriteRayLibCodeToBuffer(data.fText,0,0,width-1,height-1, EO.Lan,1,EO.Name);
                          RayLibRGBAIndex0ExportFormat:WriteRayLibCodeToBuffer(data.fText,0,0,width-1,height-1, EO.Lan,2,EO.Name);
                                 RayLibRGBExportFormat:WriteRayLibCodeToBuffer(data.fText,0,0,width-1,height-1, EO.Lan,3,EO.Name);
     end;
   end;
(*
   //QB/FB RayLib formats
   if ((EO.Lan = QB64Lan) or (EO.Lan = FBLan)) and ((ImageExportFormat in [RGBAFuchsiaExportFormat,RGBAIndex0ExportFormat,RGBExportFormat]) then
   begin
     WriteBasicLabel(data,EO.Lan,EO.Name);
     //WriteRayLibCodeToBuffer(data.fText,0,0,width-1,height-1, EO.Lan,EO.Image,EO.Name);
     Case ImageExportFormat of RGBAFuchsiaExportFormat:WriteRayLibCodeToBuffer(data.fText,0,0,width-1,height-1, EO.Lan,1,EO.Name);
                                     RGBAIndex0ExportFormat:WriteRayLibCodeToBuffer(data.fText,0,0,width-1,height-1, EO.Lan,2,EO.Name);
                                            RGBExportFormat:WriteRayLibCodeToBuffer(data.fText,0,0,width-1,height-1, EO.Lan,3,EO.Name);
     end;
   end;

   //gcc RayLib Format
   if (EO.Lan = gccLan) and ((ImageExportFormat in [RGBAFuchsiaExportFormat,RGBAIndex0ExportFormat,RGBExportFormat]) then
   begin
//      WriteRayLibCodeToBuffer(data.fText,0,0,width-1,height-1, EO.Lan,EO.Image,EO.Name);
      Case ImageExportFormat of RGBAFuchsiaExportFormat:WriteRayLibCodeToBuffer(data.fText,0,0,width-1,height-1, EO.Lan,1,EO.Name);
                                     RGBAIndex0ExportFormat:WriteRayLibCodeToBuffer(data.fText,0,0,width-1,height-1, EO.Lan,2,EO.Name);
                                            RGBExportFormat:WriteRayLibCodeToBuffer(data.fText,0,0,width-1,height-1, EO.Lan,3,EO.Name);
     end;
   end;
 *)
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
 ImageExportFormat : integer;
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
   ImageExportFormat:=ImageIndexToFormat(EO.Lan,EO.Image);

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
     if (ImageExportFormat=PutImageExportFormat) and (EO.Mask = 1) and (EO.Lan<>AQBLan) then    //only create mask for putimage = but not for Amiga AQB
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


 InitBufferRec(data);
 //convert and dump image
 for i:=0 to count-1 do
 begin
   width:=ImageThumbBase.GetExportWidth(i);
   height:=ImageThumbBase.GetExportHeight(i);
   ImageThumbBase.GetExportOptions(i,EO);

   ImageExportFormat:=ImageIndexToFormat(EO.Lan,EO.Image);
   SetThumbIndex(i);  //important - otherwise the GetMaxColor and GetPixel functions will not get the right data

   if EO.Palette > 0 then WritePalToBuffer(data,EO.Palette);

   Case EO.Lan of QCLan,QPLan,QBLan,GWLan,PBLan:
                                    begin
                                      if (ImageExportFormat = PutImageExportFormat) then WriteXgfToBuffer(0,0,width-1,height-1,EO.Lan,0,data);
                                      if (ImageExportFormat = PutImageExportFormat) and (EO.Mask=1) then WriteXgfToBuffer(0,0,width-1,height-1,EO.Lan,1,data);
                                      if (ImageExportFormat = MouseImageExportFormat) then WriteMShapeToBuffer(0,0,data.f);
                                    end;
                              QB64Lan:begin
                                        //if (EO.Image > 0) and (EO.Image<4) then ResExportRayLibToBuffer(data.f,0,0,width-1,height-1,EO.Image);
                                        case ImageExportFormat of RGBAFuchsiaExportFormat:ResExportRayLibToBuffer(data.f,0,0,width-1,height-1,1);
                                                                   RGBAIndex0ExportFormat:ResExportRayLibToBuffer(data.f,0,0,width-1,height-1,2);
                                                                          RGBExportFormat:ResExportRayLibToBuffer(data.f,0,0,width-1,height-1,3);
                                        end;
                                      end;
                        TPLan,TCLan: begin
                                       if (ImageExportFormat = PutImageExportFormat) then WriteXgfToBuffer(0,0,width-1,height-1,EO.Lan,0,data);
                                       if (ImageExportFormat = PutImageExportFormat) and (EO.Mask=1) then WriteXgfToBuffer(0,0,width-1,height-1,EO.Lan,1,data);
                                       if (ImageExportFormat = XLibLBMExportFormat) then WriteLBMToBuffer(0,0,width-1,height-1,data);   //xlib lbm
                                       if (ImageExportFormat = XLibPBMExportFormat) then WritePBMToBuffer(0,0,width-1,height-1,data);   //xlib pbm
                                       if (ImageExportFormat = MouseImageExportFormat) then WriteMShapeToBuffer(0,0,data.f);

                                     end;
                              FPLan: begin
                                       if (ImageExportFormat = PutImageExportFormat) then WriteXGFToBufferFP(0,0,width-1,height-1,0,data);
                                       if (ImageExportFormat = PutImageExportFormat) and (EO.Mask=1) then WriteXGFToBufferFP(0,0,width-1,height-1,1,data);
                                       //if (EO.Image > 1) and (EO.Image<5) then ResExportRayLibToBuffer(data.f,0,0,width-1,height-1,EO.Image-1);
                                       case ImageExportFormat of RGBAFuchsiaExportFormat:ResExportRayLibToBuffer(data.f,0,0,width-1,height-1,1);
                                                                   RGBAIndex0ExportFormat:ResExportRayLibToBuffer(data.f,0,0,width-1,height-1,2);
                                                                          RGBExportFormat:ResExportRayLibToBuffer(data.f,0,0,width-1,height-1,3);
                                       end;
                                       if (ImageExportFormat = MouseImageExportFormat) then WriteMShapeToBuffer(0,0,data.f);
                                     end;
                              FBinQBModeLan: begin
                                       if (ImageExportFormat = PutImageExportFormat) then WriteXGFToBufferFB(0,0,width-1,height-1,0,data);
                                       if (ImageExportFormat = PutImageExportFormat) and (EO.Mask=1) then WriteXGFToBufferFB(0,0,width-1,height-1,1,data);
                                       if (ImageExportFormat = MouseImageExportFormat) then WriteMShapeToBuffer(0,0,data.f);
                                     end;
                              FBLan:begin
                                       //if (EO.Image > 0) and (EO.Image<4) then ResExportRayLibToBuffer(data.f,0,0,width-1,height-1,EO.Image);
                                       case ImageExportFormat of RGBAFuchsiaExportFormat:ResExportRayLibToBuffer(data.f,0,0,width-1,height-1,1);
                                                                   RGBAIndex0ExportFormat:ResExportRayLibToBuffer(data.f,0,0,width-1,height-1,2);
                                                                          RGBExportFormat:ResExportRayLibToBuffer(data.f,0,0,width-1,height-1,3);
                                       end;
                                    end;
                              ABLan:begin
                                      if (ImageExportFormat = PutImageExportFormat) then WriteAmigaBasicXGFBuffer(0,0,width-1,height-1,data);
                                      if (ImageExportFormat = AmigaBOBExportFormat) then WriteAmigaBasicBobBuffer(0,0,width-1,height-1,data,false); //bob
                                      if (ImageExportFormat = AmigaVSpriteExportFormat) then WriteAmigaBasicBobBuffer(0,0,width-1,height-1,data,true);  //sprite
                                    end;
                        ACLan,APLan:begin
                                      if (ImageExportFormat = AmigaBOBExportFormat) then WriteAmigaBobBuffer(0,0,width-1,height-1,data,false);
                                      if (ImageExportFormat = AmigaVSpriteExportFormat) then WriteAmigaBobBuffer(0,0,width-1,height-1,data,true);
                                    end;
                             gccLan:begin
                                      //ResExportRayLibToBuffer(data.f,0,0,width-1,height-1,EO.Image);
                                       case ImageExportFormat of RGBAFuchsiaExportFormat:ResExportRayLibToBuffer(data.f,0,0,width-1,height-1,1);
                                                                   RGBAIndex0ExportFormat:ResExportRayLibToBuffer(data.f,0,0,width-1,height-1,2);
                                                                          RGBExportFormat:ResExportRayLibToBuffer(data.f,0,0,width-1,height-1,3);
                                       end;
                                    end;

                             OWLan:
                                    begin
                                      if (ImageExportFormat = PutImageExportFormat) then WriteXgfToBufferOW(0,0,width-1,height-1,0,data);
                                      if (ImageExportFormat = PutImageExportFormat) and (EO.Mask=1) then WriteXgfToBufferOW(0,0,width-1,height-1,1,data);
                                      if (ImageExportFormat = MouseImageExportFormat) then WriteMShapeToBuffer(0,0,data.f);
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
