unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, ComCtrls, ToolWin, ImgList, XPMan;

type
  TForm1 = class(TForm)
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    GroupBox1: TGroupBox;
    Image1: TImage;
    ColorDialog1: TColorDialog;
    SaveDialog1: TSaveDialog;
    OpenDialog1: TOpenDialog;
    ImageList1: TImageList;
    ImageList2: TImageList;
    Label1: TLabel;
    Edit1: TEdit;
    UpDown1: TUpDown;
    Panel1: TPanel;
    ToolBar2: TToolBar;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ToolBar3: TToolBar;
    ToolButton7: TToolButton;
    ToolButton8: TToolButton;
    ToolButton9: TToolButton;
    ImageList3: TImageList;
    ToolButton10: TToolButton;
    ToolButton11: TToolButton;
    ToolButton15: TToolButton;
    ToolButton16: TToolButton;
    ToolBar4: TToolBar;
    ToolButton12: TToolButton;
    ToolButton13: TToolButton;
    ToolButton14: TToolButton;
    ToolButton17: TToolButton;
    ToolBar5: TToolBar;
    ToolButton18: TToolButton;
    ToolButton19: TToolButton;
    ToolButton20: TToolButton;
    ToolButton21: TToolButton;
    procedure FormCreate(Sender: TObject);
    procedure Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure ToolButton1Click(Sender: TObject);
    procedure Image1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Image1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure UpDown1ChangingEx(Sender: TObject; var AllowChange: Boolean;
      NewValue: Smallint; Direction: TUpDownDirection);
    procedure ToolButton3Click(Sender: TObject);
    procedure ToolButton2Click(Sender: TObject);
    procedure ToolButton7Click(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure CheckBox1Click(Sender: TObject);
    procedure ToolButton20Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }

    Procedure Initialized;
    Procedure ClearImage(Sender:TObject);
    Procedure Render32(Sender:TImage);
    Procedure Render16(Sender:TImage);
    Function DrawRect(g:TBitmap; x,y, size: Integer):word;
    Procedure DrawS(X,Y:word);
    Procedure ShowGrid;
  end;

var
  Form1: TForm1;
  select_patt:word = $00;
  select_pall:word = $00;
  setPal_row: word = $00;
  setPal_col: word = $00;
  Selected:byte;
  dr:boolean;
  Maps:Array [0..1072] of byte;
  Xp,Yp:integer;
implementation

{$R *.dfm}

procedure TForm1.CheckBox1Click(Sender: TObject);
begin
Draws(xp,yp);
Render16(Image1);
select_patt:=DrawRect(Image1.Picture.Bitmap, xp,yp,16);
end;

procedure TForm1.ClearImage(Sender: TObject);
Var
i:integer;
begin
(Sender as TImage).Picture.Bitmap.Width:=(Sender as TImage).Width;
(Sender as TImage).Picture.Bitmap.Height:=(Sender as TImage).Height;
(Sender as TImage).Picture.Bitmap.Canvas.Brush.Color:=$00;
(Sender as TImage).Picture.Bitmap.Canvas.FillRect(RECT(0,0,(Sender as TImage).Width, (Sender as TImage).Height));
For i:=0 to length(maps) do maps[i]:=$F;
end;



Function TForm1.DrawRect(g: TBitmap; x, y, size: Integer):word;
var
x1,y1,X2,Y2:Integer;
begin
g.Canvas.Brush.Color:=clRed;
x1:=(x div size);
y1:=(y div size);
X2:=x1*size;
Y2:=y1*size;
ImageList2.Draw(g.Canvas,x2,y2,Selected);
g.Canvas.FrameRect(RECT(x2,y2,x2+size,y2+size));
result:=(Y1 * (g.Width div size))+X1;
end;

procedure TForm1.DrawS(X, Y: word);
var
X1,Y1:word;
begin
if  (X<=592) and (y<=464)  then begin
if GetKeyState(VK_LBUTTON)<0 then begin
Y1:=Y div 16;
X1:=X div 16;
Maps[X1+Y1*37]:=selected;
end;
end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
Initialized;
end;

procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
//ShowMessage(Inttostr(key));
if key = VK_NUMPAD0 then Selected:=$F;
if key = VK_NUMPAD1 then Selected:=$4;
if key = VK_NUMPAD2 then Selected:=$9;
if key = VK_NUMPAD3 then Selected:=$A;
if key = VK_NUMPAD4 then Selected:=$B;
if key = VK_NUMPAD5 then Selected:=$C;
if key = VK_NUMPAD7 then Selected:=$D;
if key = VK_NUMPAD9 then Selected:=$E;

if key = VK_UP then begin
if Selected in [$0..$4] then Selected:=$3;
if Selected in [$5..$9] then Selected:=$8;
end;

if key = VK_DOWN then begin
if Selected in [$0..$4] then Selected:=$1;
if Selected in [$5..$9] then Selected:=$6;
end;

if key = VK_LEFT then begin
if Selected in [$0..$4] then Selected:=$2;
if Selected in [$5..$9] then Selected:=$7;
end;

if key = VK_RIGHT then begin
if Selected in [$0..$4] then Selected:=$0;
if Selected in [$5..$9] then Selected:=$5;
end;


ToolButton4.Down:=false;
ToolButton5.Down:=false;
ToolButton6.Down:=false;
ToolButton7.Down:=false;
ToolButton8.Down:=false;
ToolButton9.Down:=false;
ToolButton10.Down:=false;
ToolButton11.Down:=false;
ToolButton12.Down:=false;
ToolButton13.Down:=false;
ToolButton14.Down:=false;
ToolButton15.Down:=false;
ToolButton16.Down:=false;
ToolButton17.Down:=false;
ToolButton18.Down:=false;
ToolButton19.Down:=false;
case selected of
$0:ToolButton8.Down:=true;
$1:ToolButton9.Down:=true;
$2:ToolButton10.Down:=true;
$3:ToolButton11.Down:=true;
$4:ToolButton7.Down:=true;
$5:ToolButton5.Down:=true;
$6:ToolButton6.Down:=true;
$7:ToolButton15.Down:=true;
$8:ToolButton16.Down:=true;
$9:ToolButton4.Down:=true;
$A:ToolButton12.Down:=true;
$B:ToolButton13.Down:=true;
$C:ToolButton14.Down:=true;
$D:ToolButton19.Down:=true;
$E:ToolButton18.Down:=true;
$F:ToolButton17.Down:=true;
end;
Render16(Image1);
select_patt:=DrawRect(Image1.Picture.Bitmap, xp,yp,16);
end;

procedure TForm1.Image1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 If Button = MBLeft then Draws(X,Y);
end;

procedure TForm1.Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
Xp:=X;
Yp:=Y;
Draws(x,y);
Render16((Sender as TImage));
select_patt:=DrawRect((Sender as TImage).Picture.Bitmap, x,y,16);
end;

procedure TForm1.Image1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
If Button = MBRight then begin
inc(Selected);
if Selected > $F then Selected:=0;
ToolButton4.Down:=false;
ToolButton5.Down:=false;
ToolButton6.Down:=false;
ToolButton7.Down:=false;
ToolButton8.Down:=false;
ToolButton9.Down:=false;
ToolButton10.Down:=false;
ToolButton11.Down:=false;
ToolButton12.Down:=false;
ToolButton13.Down:=false;
ToolButton14.Down:=false;
ToolButton15.Down:=false;
ToolButton16.Down:=false;
ToolButton17.Down:=false;
ToolButton18.Down:=false;
ToolButton19.Down:=false;
case selected of
$0:ToolButton8.Down:=true;
$1:ToolButton9.Down:=true;
$2:ToolButton10.Down:=true;
$3:ToolButton11.Down:=true;
$4:ToolButton7.Down:=true;
$5:ToolButton5.Down:=true;
$6:ToolButton6.Down:=true;
$7:ToolButton15.Down:=true;
$8:ToolButton16.Down:=true;
$9:ToolButton4.Down:=true;
$A:ToolButton12.Down:=true;
$B:ToolButton13.Down:=true;
$C:ToolButton14.Down:=true;
$D:ToolButton19.Down:=true;
$E:ToolButton18.Down:=true;
$F:ToolButton15.Down:=true;
  
end;
Xp:=X;
Yp:=Y;
select_patt:=DrawRect((Sender as TImage).Picture.Bitmap, x,y,16);
end;
end;

procedure TForm1.Initialized;
begin
ClearImage(Image1);
Selected:=$F;
end;

procedure TForm1.Render16(Sender: TImage);
var
i:integer;
X,Y:integer;
b:byte;
begin
for i := 0 to length(maps) do begin
X:= i mod 37;
Y:= i div 37;
b:= maps[i];
Imagelist2.Draw(Sender.Canvas,x*16,y*16,b);
end;
ShowGrid;
end;

procedure TForm1.Render32(Sender: TImage);
begin
end;

procedure TForm1.ShowGrid;
var
i:integer;
begin
If not ToolButton20.Down then exit; 
Image1.Canvas.pen.Color:=ClGray;
Image1.Canvas.brush.Color:=ClBlack;
Image1.Canvas.brush.Style:=bsClear;
Image1.Canvas.pen.Style:=psDot;
for I := 1 to 37 do begin
Image1.Canvas.MoveTo(i*16-1,0);
Image1.Canvas.LineTo(i*16-1,464);
end;

for I := 1 to 29 do begin
Image1.Canvas.MoveTo(0,i*16-1);
Image1.Canvas.LineTo(592,i*16-1);
end;
end;

procedure TForm1.ToolButton1Click(Sender: TObject);
begin
Initialized;
end;

procedure TForm1.ToolButton20Click(Sender: TObject);
begin
Draws(xp,yp);
Render16(Image1);
select_patt:=DrawRect(Image1.Picture.Bitmap, xp,yp,16);
end;

procedure TForm1.ToolButton2Click(Sender: TObject);
var
Stream:TMemoryStream;
i:Integer;
b1,b2,bo:byte;
begin
If OpenDialog1.Execute then begin
Stream:=TMemoryStream.Create;
Stream.LoadFromFile(OpenDialog1.FileName);
Stream.Position:=0;
Stream.Seek(0,soFromBeginning);
i:=0;
while (i < Stream.size) do begin
Stream.Read(Bo,1);
b1:=BO shr 4;
b2:=BO and $F;
Maps[i*2]:=B1;
if (i*2+1) > High(Maps) then Edit1.Text:=Inttostr(B2) else Maps[I*2+1]:=B2;
inc(i);
end;
Stream.Free;
Render16(Image1);
end;
end;

procedure TForm1.ToolButton3Click(Sender: TObject);
Var
Stream:TMemoryStream;
i:Integer;
b1,b2,bo:byte;
begin
If saveDialog1.Execute then begin
Stream:=TMemoryStream.Create;
Stream.Position:=0;
for I := Low(Maps) to (High(Maps) div 2) do begin
b1:=Maps[i*2];
if (i*2+1) > High(Maps) then B2:=StrToInt(Edit1.text) else b2:=Maps[i*2+1];
BO:=b1 shl 4 or b2;
Stream.Write(BO,1);
end;
Stream.SaveToFile(SaveDialog1.FileName);
Stream.Free;
end;
end;

procedure TForm1.ToolButton7Click(Sender: TObject);
begin
selected:=(Sender as TToolButton).ImageIndex;
ToolButton4.Down:=false;
ToolButton5.Down:=false;
ToolButton6.Down:=false;
ToolButton7.Down:=false;
ToolButton8.Down:=false;
ToolButton9.Down:=false;
ToolButton10.Down:=false;
ToolButton11.Down:=false;
ToolButton12.Down:=false;
ToolButton13.Down:=false;
ToolButton14.Down:=false;
ToolButton15.Down:=false;
ToolButton16.Down:=false;
ToolButton17.Down:=false;
ToolButton18.Down:=false;
ToolButton19.Down:=false;
(Sender as TToolButton).Down:=True;
end;

procedure TForm1.UpDown1ChangingEx(Sender: TObject; var AllowChange: Boolean;
  NewValue: Smallint; Direction: TUpDownDirection);
begin
 Edit1.Text:=InttoStr(NewValue);
end;

end.
