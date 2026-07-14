unit brusheffects;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  Spin, rmcore, uRetrobrush;

type

  { TBrushEffectsForm }

  TBrushEffectsForm = class(TForm)
    PreviewPaintBox: TPaintBox;
    OrigPaintBox: TPaintBox;
    lblOriginal: TLabel;
    lblPreview: TLabel;
    lblSize: TLabel;
    GroupBox1: TGroupBox;
    btn90CW: TButton;
    btn90CCW: TButton;
    btn180: TButton;
    btnCustomAngle: TButton;
    SpinAngle: TSpinEdit;
    GroupBox2: TGroupBox;
    btnFlipH: TButton;
    btnFlipV: TButton;
    GroupBox3: TGroupBox;
    btnScale50: TButton;
    btnScale200: TButton;
    btnScaleCustom: TButton;
    SpinScalePct: TSpinEdit;
    btnReset: TButton;
    btnClose: TButton;
    GroupBox4: TGroupBox;
    lblTransColor: TLabel;
    btnSetTransCurrent: TButton;

    GroupBox5: TGroupBox;
    btnToSingleColor: TButton;
    btnFillTransparent: TButton;
    GroupBox6: TGroupBox;
    btnShearH: TButton;
    SpinShearH: TSpinEdit;
    btnShearV: TButton;
    SpinShearV: TSpinEdit;
    GroupBox7: TGroupBox;
    btnGradH: TButton;
    btnGradV: TButton;
    btnGradC: TButton;
    lblGradCX: TLabel;
    SpinGradCX: TSpinEdit;
    lblGradCY: TLabel;
    SpinGradCY: TSpinEdit;
    lblGradInfo: TLabel;
    btnGradCenterBrush: TButton;
    procedure btn90CWClick(Sender: TObject);
    procedure btn90CCWClick(Sender: TObject);
    procedure btn180Click(Sender: TObject);
    procedure btnCustomAngleClick(Sender: TObject);
    procedure btnFlipHClick(Sender: TObject);
    procedure btnFlipVClick(Sender: TObject);
    procedure btnScale50Click(Sender: TObject);
    procedure btnScale200Click(Sender: TObject);
    procedure btnScaleCustomClick(Sender: TObject);
    procedure btnResetClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure btnSetTransCurrentClick(Sender: TObject);
    procedure btnToSingleColorClick(Sender: TObject);
    procedure btnFillTransparentClick(Sender: TObject);
    procedure btnShearHClick(Sender: TObject);
    procedure btnShearVClick(Sender: TObject);
    procedure btnGradHClick(Sender: TObject);
    procedure btnGradVClick(Sender: TObject);
    procedure btnGradCClick(Sender: TObject);
    procedure btnGradCenterBrushClick(Sender: TObject);
    procedure PreviewPaintBoxPaint(Sender: TObject);
    procedure OrigPaintBoxPaint(Sender: TObject);
  private
    procedure DrawPixelBuf(ACanvas : TCanvas; AWidth, AHeight : integer;
      var Pixels : TPixelBuf; BufW, BufH : integer);
    procedure UpdatePreview;
  end;

var
  BrushEffectsForm: TBrushEffectsForm;

implementation

{$R *.lfm}

{ === helpers === }

procedure TBrushEffectsForm.DrawPixelBuf(ACanvas : TCanvas;
  AWidth, AHeight : integer;
  var Pixels : TPixelBuf; BufW, BufH : integer);
var
  i, j, px, py, cellW, cellH : integer;
  ci, ri : byte;
  pal : TRMPaletteBuf;
begin
  ACanvas.Brush.Color:=clBlack;
  ACanvas.FillRect(0, 0, AWidth, AHeight);

  if (BufW <= 0) or (BufH <= 0) then exit;

  //fit the buffer into the paintbox with uniform scaling
  cellW:=AWidth div BufW;
  cellH:=AHeight div BufH;
  if cellW < 1 then cellW:=1;
  if cellH < 1 then cellH:=1;
  if cellW > cellH then cellW:=cellH else cellH:=cellW;

  //use the current sprite palette with remapping so the preview
  //matches what the stamp will actually look like
  RMCoreBase.Palette.GetPalette(pal);
  RetroBrush.InvalidateRemap;
  RetroBrush.BuildRemapTable(pal,
    RMCoreBase.Palette.GetPaletteMode,
    RMCoreBase.Palette.GetColorCount);

  for i:=0 to BufW-1 do
  begin
    for j:=0 to BufH-1 do
    begin
      ci:=Pixels[i][j];
      px:=i * cellW;
      py:=j * cellH;
      if ci = RetroBrush.TransColor then
      begin
        //draw checkerboard for transparent pixels
        if ((i + j) mod 2) = 0 then
          ACanvas.Brush.Color:=clSilver
        else
          ACanvas.Brush.Color:=clWhite;
      end
      else
      begin
        ri:=RetroBrush.RemapIndex(ci);
        ACanvas.Brush.Color:=
          RGBToColor(pal[ri].r, pal[ri].g, pal[ri].b);
      end;
      ACanvas.FillRect(px, py, px + cellW, py + cellH);
    end;
  end;
end;

procedure TBrushEffectsForm.UpdatePreview;
begin
  lblSize.Caption:=IntToStr(RetroBrush.WorkWidth) + 'x' + IntToStr(RetroBrush.WorkHeight);
  lblTransColor.Caption:='Color Index: ' + IntToStr(RetroBrush.TransColor);
  PreviewPaintBox.Invalidate;
  OrigPaintBox.Invalidate;
end;

{ === paint === }

procedure TBrushEffectsForm.PreviewPaintBoxPaint(Sender: TObject);
begin
  if not RetroBrush.HasBrush then
  begin
    PreviewPaintBox.Canvas.Brush.Color:=clBlack;
    PreviewPaintBox.Canvas.FillRect(0, 0, PreviewPaintBox.Width, PreviewPaintBox.Height);
    PreviewPaintBox.Canvas.Font.Color:=clWhite;
    PreviewPaintBox.Canvas.TextOut(8, 8, 'No brush captured');
    exit;
  end;
  DrawPixelBuf(PreviewPaintBox.Canvas, PreviewPaintBox.Width, PreviewPaintBox.Height,
    RetroBrush.WorkPixels, RetroBrush.WorkWidth, RetroBrush.WorkHeight);
end;

procedure TBrushEffectsForm.OrigPaintBoxPaint(Sender: TObject);
begin
  if not RetroBrush.HasBrush then
  begin
    OrigPaintBox.Canvas.Brush.Color:=clBlack;
    OrigPaintBox.Canvas.FillRect(0, 0, OrigPaintBox.Width, OrigPaintBox.Height);
    exit;
  end;
  DrawPixelBuf(OrigPaintBox.Canvas, OrigPaintBox.Width, OrigPaintBox.Height,
    RetroBrush.OrigPixels, RetroBrush.OrigWidth, RetroBrush.OrigHeight);
end;

{ === rotate === }

procedure TBrushEffectsForm.btn90CWClick(Sender: TObject);
begin
  if not RetroBrush.HasBrush then exit;
  RetroBrush.Rotate90CW;
  UpdatePreview;
end;

procedure TBrushEffectsForm.btn90CCWClick(Sender: TObject);
begin
  if not RetroBrush.HasBrush then exit;
  RetroBrush.Rotate90CCW;
  UpdatePreview;
end;

procedure TBrushEffectsForm.btn180Click(Sender: TObject);
begin
  if not RetroBrush.HasBrush then exit;
  RetroBrush.Rotate180;
  UpdatePreview;
end;

procedure TBrushEffectsForm.btnCustomAngleClick(Sender: TObject);
begin
  if not RetroBrush.HasBrush then exit;
  RetroBrush.RotateAngle(SpinAngle.Value);
  UpdatePreview;
end;

{ === flip === }

procedure TBrushEffectsForm.btnFlipHClick(Sender: TObject);
begin
  if not RetroBrush.HasBrush then exit;
  RetroBrush.FlipHorizontal;
  UpdatePreview;
end;

procedure TBrushEffectsForm.btnFlipVClick(Sender: TObject);
begin
  if not RetroBrush.HasBrush then exit;
  RetroBrush.FlipVertical;
  UpdatePreview;
end;

{ === scale === }

procedure TBrushEffectsForm.btnScale50Click(Sender: TObject);
begin
  if not RetroBrush.HasBrush then exit;
  RetroBrush.ScalePercent(50);
  UpdatePreview;
end;

procedure TBrushEffectsForm.btnScale200Click(Sender: TObject);
begin
  if not RetroBrush.HasBrush then exit;
  RetroBrush.ScalePercent(200);
  UpdatePreview;
end;

procedure TBrushEffectsForm.btnScaleCustomClick(Sender: TObject);
begin
  if not RetroBrush.HasBrush then exit;
  RetroBrush.ScalePercent(SpinScalePct.Value);
  UpdatePreview;
end;

{ === reset / close / trans === }

procedure TBrushEffectsForm.btnResetClick(Sender: TObject);
begin
  if not RetroBrush.HasBrush then exit;
  RetroBrush.Reset;
  UpdatePreview;
end;

procedure TBrushEffectsForm.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TBrushEffectsForm.btnSetTransCurrentClick(Sender: TObject);
begin
  RetroBrush.TransColor:=RMCoreBase.GetCurColor1;
  UpdatePreview;
end;



procedure TBrushEffectsForm.btnShearHClick(Sender: TObject);
begin
  if not RetroBrush.HasBrush then exit;
  RetroBrush.ShearHorizontal(SpinShearH.Value);
  UpdatePreview;
end;

procedure TBrushEffectsForm.btnShearVClick(Sender: TObject);
begin
  if not RetroBrush.HasBrush then exit;
  RetroBrush.ShearVertical(SpinShearV.Value);
  UpdatePreview;
end;

procedure TBrushEffectsForm.btnGradHClick(Sender: TObject);
begin
  if not RetroBrush.HasBrush then exit;
  RetroBrush.GradientHorizontal(RMCoreBase.GetCurColor1, RMCoreBase.GetCurColor2);
  UpdatePreview;
end;

procedure TBrushEffectsForm.btnGradVClick(Sender: TObject);
begin
  if not RetroBrush.HasBrush then exit;
  RetroBrush.GradientVertical(RMCoreBase.GetCurColor1, RMCoreBase.GetCurColor2);
  UpdatePreview;
end;

procedure TBrushEffectsForm.btnGradCClick(Sender: TObject);
begin
  if not RetroBrush.HasBrush then exit;
  RetroBrush.GradientCircular(RMCoreBase.GetCurColor1, RMCoreBase.GetCurColor2,
    SpinGradCX.Value, SpinGradCY.Value);
  UpdatePreview;
end;

procedure TBrushEffectsForm.btnGradCenterBrushClick(Sender: TObject);
begin
  if not RetroBrush.HasBrush then exit;
  SpinGradCX.Value:=RetroBrush.WorkWidth div 2;
  SpinGradCY.Value:=RetroBrush.WorkHeight div 2;
end;

procedure TBrushEffectsForm.btnToSingleColorClick(Sender: TObject);
var
  i, j : integer;
  ci : byte;
begin
  if not RetroBrush.HasBrush then exit;

  ci:=RMCoreBase.GetCurColor1;

  //change all non-transparent pixels in Work buffer only
  for i:=0 to RetroBrush.WorkWidth-1 do
    for j:=0 to RetroBrush.WorkHeight-1 do
      if RetroBrush.WorkPixels[i][j] <> RetroBrush.TransColor then
        RetroBrush.WorkPixels[i][j]:=ci;

  RetroBrush.InvalidateRemap;
  UpdatePreview;
end;

procedure TBrushEffectsForm.btnFillTransparentClick(Sender: TObject);
var
  i, j : integer;
  ci : byte;
begin
  if not RetroBrush.HasBrush then exit;

  ci:=RMCoreBase.GetCurColor1;

  //change all transparent pixels in Work buffer only
  for i:=0 to RetroBrush.WorkWidth-1 do
    for j:=0 to RetroBrush.WorkHeight-1 do
      if RetroBrush.WorkPixels[i][j] = RetroBrush.TransColor then
        RetroBrush.WorkPixels[i][j]:=ci;

  RetroBrush.InvalidateRemap;
  UpdatePreview;
end;

end.
