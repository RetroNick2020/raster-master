unit rmapi;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,Dialogs,rmxgfcore,rmcodegen,rmcore,rmtools,gwbasic;

procedure rm_putpixel(x,y,color : integer);
function rm_getpixel(x,y : integer) : integer;

function rm_getwidth : integer;
function rm_getheight : integer;

procedure rm_showmessage(const aMsg : string);

function rm_cg_open(filename : string) : boolean;
procedure rm_cg_options(name, value : string);

procedure rm_cg_close;
procedure rm_cg_write(Line : string);
procedure rm_cg_writeln;
procedure rm_cg_write_byte(value : byte);
procedure rm_cg_write_integer(value : integer);

procedure rm_getselectarea(var active,x1,y1,x2,y2 : integer);

implementation

var
  cg     : CodeGenRec;
  cgfile : text;

procedure rm_putpixel(x,y,color : integer);
begin
  putpixel(x,y,color);
end;

function rm_getpixel(x,y : integer) : integer;
begin
  rm_getpixel:=getpixel(x,y);
end;

function rm_getwidth : integer;
begin
  rm_getwidth:=GetWidth;
end;

function rm_getheight : integer;
begin
  rm_getheight:=GetHeight;
end;

function  rm_getmaxcolor : integer;
begin
  rm_getmaxcolor:=GetMaxColor;
end;

procedure rm_getcolorrgb(index : integer;var r,g,b : byte);
var
  cr : TRMColorRec;
begin
  GetColor(index,cr);
  r:=cr.r;
  g:=cr.g;
  b:=cr.b;
end;

function rm_cg_open(filename : string) : boolean;
begin
  Assign(cgfile,filename);
{$I-}
  Rewrite(cgfile);
{$I+}
  if IORESULT = 0 then
  begin
     MWInit(cg,cgfile);
     rm_cg_open:=true;
  end
  else
  begin
    rm_cg_open:=false;
  end;
end;

procedure rm_cg_close;
begin
  close(cgfile);
end;

procedure rm_cg_options(name, value : string);
begin
  name:=UpperCase(name);
  value:=UpperCase(value);
  Case Name of 'LAN':begin
                       Case value of 'BASICLAN': MWSetLan(cg,BasicLan);
                                 'BASICLNLAN': MWSetLan(cg,BasicLnLan);

                                    'PASCALLAN': MWSetLan(cg,PascalLan);
                                         'CLAN': MWSetLan(cg,CLan);
                                            else MWSetLan(cg,StrToInt(value));
                       end;
                     end;
                'VALUESPERLINE': MWSetValuesPerLine(cg,StrToInt(value));
                  'VALUESTOTAL': MWSetValuesTotal(cg,StrToInt(value));
                  'VALUEFORMAT': begin
                                   Case value of 'HEX': MWSetValueFormat(cg,ValueFormatHex);
                                             'DECIMAL': MWSetValueFormat(cg,ValueFormatDecimal);
                                                   else MWSetValueFormat(cg,StrToInt(value));
                                   end;
                                 end;
                       'INDENT': MWSetIndent(cg,StrToInt(value));
            'INDENTONFIRSTLINE': MWSetIndentOnFirstLine(cg,Value='YES');
              'LINENUMBERSTART': SetGWStartLineNumber(StrToInt(value));
  end;
end;

procedure rm_cg_write(Line : string);
begin
  write(cgfile,line);
end;

procedure rm_cg_writeln;
begin
  writeln(cgfile);
end;

procedure rm_cg_write_byte(value : byte);
begin
  MWWriteByte(cg,value);
end;

procedure rm_cg_write_integer(value : integer);
begin
  MWWriteInteger(cg,value);
end;

procedure rm_getselectarea(var active,x1,y1,x2,y2 : integer);
var
  ca : TClipAreaRec;
begin
  active:=0;
  x1:=0;
  x2:=0;
  y1:=0;
  y2:=0;

  RMDrawTools.GetClipAreaCoords(ca);
  if (ca.sized=1) and (RMDrawTools.GetClipStatus=1) then
  begin
    active:=1;
    x1:=ca.x;
    x2:=ca.x2;
    y1:=ca.y;
    y2:=ca.y2;
  end;
end;

procedure rm_showmessage(const aMsg : string);
begin
  showmessage(aMsg);
end;


end.

