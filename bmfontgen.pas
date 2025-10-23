unit bmfontgen;
{$mode objfpc}{$H+}

Interface
uses
  Classes, SysUtils, FPWritePNG, IntfGraphics, Graphics, Generics.Collections;


type
  TBmPadding = Record
    up, right, down, left : integer;
  end;

  TBmSpacing = Record
    horizontal, vertical : integer;
  end;

  TBmInfo = record
     face     : string;
     size     : integer;
     bold     : integer;
     italic   : integer;
     charset  : string;
     unicode  : integer;
     stretchH : integer;
     smooth   : integer;
     aa       : integer;
     padding  : TBmPadding;
     spacing  : TBmSpacing;
     outline  : integer;
  end;

  TBmCommon = record
    LineHeight : integer;
    Base       : integer;
    scaleW      : integer;
    scaleH     : integer;
    pages      : integer;
    ppacked    : integer;
    alphaChnl  : integer;
    redChnl    : integer;
    greenChnl  : integer;
    blueChnl   : integer;
  end;

  TBmPage = record
    id         : integer;
    filename   : string;
  end;

  TBmChar = record
    id               : integer;
    x, y             : integer;
    width, height    : integer;
    xoffset, yoffset : integer;
    xadvance         : integer;
    page             : integer;
    chnl             : integer;
  end;

  TBmKern = record
    first, second, amount: Integer;
  end;

  TBmFontGen = class
  private
    info   : TBmInfo;
    common : TBmCommon;
    Page   : TBmPage;
    FChars: specialize TList<TBmChar>;
    FKerns: specialize TList<TBmKern>;
  public
    constructor Create;
    destructor  Destroy; override;
    procedure AddCharacter(C: TBmChar);
    procedure AddKern(K: TBmKern);
    procedure SetInfo(I: TBmInfo);
    procedure SetCommon(C: TBmCommon);
    procedure SetPage(P: TBmPage);
    procedure SaveFont(const FileName: string);
  end;

Implementation

constructor TBmFontGen.Create;
begin
  FChars := specialize TList<TBmChar>.Create;
  FKerns := specialize TList<TBmKern>.Create;  //for future if we want to implement kerning
end;

destructor TBmFontGen.Destroy;
begin
  FChars.Free;
  FKerns.Free;
  inherited;
end;

procedure TBmFontGen.AddCharacter(C: TBmChar);
begin
  FChars.Add(C);
end;

procedure TBmFontGen.AddKern(K: TBmKern);
begin
  FKerns.Add(K);
end;

procedure TBmFontGen.SetInfo(I: TBmInfo);
begin
  Info:=I;
end;

procedure TBmFontGen.SetCommon(C: TBmCommon);
begin
  Common:=C;
end;

procedure TBmFontGen.SetPage(P: TBmPage);
begin
  Page:=P;
end;

procedure TBmFontGen.SaveFont(const FileName: string);
var
  SL : TStringList;
   C : TBmChar;
begin
  SL := TStringList.Create;
    try
      SL.Add('info face="' + info.face + '" size=' + IntToStr(info.size) +
             ' bold='+IntToStr(info.bold)+' italic='+IntToStr(info.italic)+
             ' charset="'+info.charset+'" unicode='+IntToStr(info.unicode)+
             ' stretchH='+IntToStr(info.stretchH)+' smooth='+IntToStr(info.smooth)+
             ' aa='+IntToStr(info.aa)+' padding='+IntToStr(info.padding.up)+','+IntToStr(info.padding.right)+
             ','+IntToStr(info.padding.down)+','+IntToStr(info.padding.left)+
             ' spacing='+IntToStr(info.spacing.horizontal)+','+IntToStr(info.spacing.vertical)+
             ' outline='+IntToStr(info.outline));

      SL.Add('common lineHeight=' + IntToStr(common.LineHeight) + ' base=' + IntToStr(common.Base) +
             ' scaleW=' + IntToStr(common.scaleW) + ' scaleH=' + IntToStr(common.scaleH) +
             ' pages=' + IntToStr(common.pages) + ' packed='+IntToStr(common.ppacked)+' alphaChnl='+IntToStr(common.alphaChnl)+
             ' redChnl='+ IntToStr(common.redChnl) + ' greenChnl=' + IntToStr(common.greenChnl) + ' blueChnl=' + IntToStr(common.blueChnl));

      SL.Add('page id=' + IntToStr(page.id) + ' file="' + page.filename + '"');
      SL.Add('chars count=' + IntToStr(FChars.Count));
      for C in FChars do
      begin
        SL.Add(Format('char id=%d x=%d y=%d width=%d height=%d xoffset=%d yoffset=%d xadvance=%d page=%d chnl=%d',
               [C.id, C.x, C.y, C.width, C.height, C.xoffset, C.yoffset, C.xadvance, C.page, C.chnl]));
      end;
      SL.Add('kernings count=0');
      SL.SaveToFile(FileName, TEncoding.UTF8);   // <--  only TStringList
    finally
      SL.Free;
    end;
end;


end.
