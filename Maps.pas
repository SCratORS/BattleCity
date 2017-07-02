unit Maps;

interface
uses Resources, Windows, utils;
const
blocks: array[0..19] of byte = (
	$00, $01, $02, $03, $04, $05, $06, $07, $08, $09, $0A, $0B, $0C, $0D, $0E, $0F,
  $10, $12, $21, $22
);

Type Hero = Packed record
ObjectType:Byte;
X,Y:Integer;
end;

 Type TMaps = Class
 Private
  xMaps   : Array of Array of Byte;
  OldMaps : Array of Array of Byte;
  HDC: LongWord;
  MapsBufferBackgroundImage :LongWord;
  MapsBufferForegroundImage :LongWord;
  mbDC            :LongWord;
  mfDC            :LongWord;
  PbyteArrayBack  :Pointer;
  PbyteArrayFore  :Pointer;
  GlobalPalete:byte;
  maxLineBits:Integer;
 Public
  var
  Heros: array of Hero;
  Function  getMap(x,y:byte):byte;
  Procedure setMap(x,y, b:byte);
  Function  getCollisionMap(x,y:byte):byte;
  Procedure setCollisionMap(x,y, b:byte);
  procedure LoadMap(maps_num,w,h:byte);
  Constructor CreateMaps(DC:LongWord;level,w,h:byte);Overload;
  Destructor Destroy;Override;
  Procedure  Render(Background:boolean; frames:integer);
  Procedure  ArmorBases(X,Y:Integer; t:byte);
  Function getSize:TPoint;
 End;

implementation

{ TMaps }

procedure TMaps.ArmorBases(X, Y: Integer; t: byte);
var
i,j:integer;
begin
j:= y-1;
for I := X-1 to X+2 do If xMaps[i,j] <> $11 then begin
xMaps[i,j]:=t;
OldMaps[i,j]:=$01
end;
j:= y+2;
for I := X-1 to X+2 do If xMaps[i,j] <> $11 then begin
xMaps[i,j]:=t;
OldMaps[i,j]:=$01
end;
I:=X-1;
for J := Y to Y+1 do If xMaps[i,j] <> $11 then begin
xMaps[i,j]:=t;
OldMaps[i,j]:=$01
end;
I:=X+2;
for J := Y to Y+1 do If xMaps[i,j] <> $11 then begin
xMaps[i,j]:=t;
OldMaps[i,j]:=$01
end;
end;

constructor TMaps.CreateMaps(DC:LongWord;level, w, h: byte);
var
i,j,r:byte;
maxW,maxH:byte;
begin
randomize;
HDC:=DC;
maxW:=Width div 8;
maxH:=Height div 8;
SetLength(xMaps,maxW);
SetLength(OldMaps,maxW);
for i := 0 to High(xMaps) do begin SetLength(xMaps[i],maxH);
SetLength(OldMaps[i],maxH);
end;
for i := 0 to High(xMaps) do
for j := 0 to High(xMaps[i]) do xMaps[i,j]:=$11;
if (w>maxW-6) or (w = 0) then w:= maxW-6;
if (h>maxH-2) or (h = 0) then h:= maxH-2;
  LoadMap(Level,w,h);
  maxLineBits := Width div 2;
  GlobalPalete:=0;
  MapsBufferBackgroundImage  :=CreateDIB(hDC,Width,Height,PbyteArrayBack);
  mbdc                       :=CreateCompatibleDC(hDC);
  SelectObject(mbdc, MapsBufferBackgroundImage);
  ChangeScenePalette(mbdc, 0);
  MapsBufferForegroundImage  :=CreateDIB(hDC,Width,Height,PbyteArrayFore);
  mfdc                       :=CreateCompatibleDC(hDC);
  SelectObject(mfdc, MapsBufferForegroundImage);
  ChangeScenePalette(mfdc, 0);
end;

destructor TMaps.Destroy;
begin
  ReleaseDC(mbDC,MapsBufferBackgroundImage);
  DeleteDC(mbDC);
  DeleteObject(MapsBufferBackgroundImage);

  ReleaseDC(mfDC,MapsBufferForegroundImage);
  DeleteDC(mfDC);
  DeleteObject(MapsBufferForegroundImage);
  
  inherited;
end;

function TMaps.getMap(x, y: byte): byte;
begin
result:=xMaps[x,y];
end;

function TMaps.getSize: TPoint;
begin
Result.x:=High(xMaps);
Result.y:=High(xMaps[0]);
end;

function TMaps.getCollisionMap(x, y: byte): byte;
begin
result:=OldMaps[x,y];
end;

procedure TMaps.LoadMap(maps_num, w, h: byte);

procedure toBlock(B:byte;xp,yp:integer; Var result: array of byte);
var b1,b2:byte;
i:integer;
begin
b1:=b shr 4;
b2:=b and $F;
case b1 of
$0: begin result[0]:=$00;result[1]:=$0F;result[2]:=$00;result[3]:=$0F;end;
$1: begin result[0]:=$00;result[1]:=$00;result[2]:=$0F;result[3]:=$0F;end;
$2: begin result[0]:=$0F;result[1]:=$00;result[2]:=$0F;result[3]:=$00;end;
$3: begin result[0]:=$0F;result[1]:=$0F;result[2]:=$00;result[3]:=$00;end;
$4: begin result[0]:=$0F;result[1]:=$0F;result[2]:=$0F;result[3]:=$0F;end;
$5: begin result[0]:=$00;result[1]:=$10;result[2]:=$00;result[3]:=$10;end;
$6: begin result[0]:=$00;result[1]:=$00;result[2]:=$10;result[3]:=$10;end;
$7: begin result[0]:=$10;result[1]:=$00;result[2]:=$10;result[3]:=$00;end;
$8: begin result[0]:=$10;result[1]:=$10;result[2]:=$00;result[3]:=$00;end;
$9: begin result[0]:=$10;result[1]:=$10;result[2]:=$10;result[3]:=$10;end;
$A: begin result[0]:=$12;result[1]:=$12;result[2]:=$12;result[3]:=$12;end;
$B: begin result[0]:=$22;result[1]:=$22;result[2]:=$22;result[3]:=$22;end;
$C: begin result[0]:=$21;result[1]:=$21;result[2]:=$21;result[3]:=$21;end;
$D: begin I:=HIGH(Heros)+1;
          SetLength(Heros, I+1);
          Heros[I].ObjectType:=$0;
          Heros[I].X:=xp;
          Heros[I].Y:=yp;
          //showmessage('1 Object 0 in '+inttostr(Heros[I].X)+ ' '+ inttostr(Heros[I].Y));
          result[0]:=$00;result[1]:=$00;result[2]:=$00;result[3]:=$00;
          end;
$E: begin I:=HIGH(Heros)+1;
          SetLength(Heros, I+1);
          Heros[I].ObjectType:=$E;
          Heros[I].X:=xp;
          Heros[I].Y:=yp;
          //showmessage('2 Object E in '+inttostr(Heros[I].X)+ ' '+ inttostr(Heros[I].Y));
          result[0]:=$00;result[1]:=$00;result[2]:=$00;result[3]:=$00;
          end;
$F: begin result[0]:=$00;result[1]:=$00;result[2]:=$00;result[3]:=$00;end;
end;
case b2 of
$0: begin result[4]:=$00;result[5]:=$0F;result[6]:=$00;result[7]:=$0F;end;
$1: begin result[4]:=$00;result[5]:=$00;result[6]:=$0F;result[7]:=$0F;end;
$2: begin result[4]:=$0F;result[5]:=$00;result[6]:=$0F;result[7]:=$00;end;
$3: begin result[4]:=$0F;result[5]:=$0F;result[6]:=$00;result[7]:=$00;end;
$4: begin result[4]:=$0F;result[5]:=$0F;result[6]:=$0F;result[7]:=$0F;end;
$5: begin result[4]:=$00;result[5]:=$10;result[6]:=$00;result[7]:=$10;end;
$6: begin result[4]:=$00;result[5]:=$00;result[6]:=$10;result[7]:=$10;end;
$7: begin result[4]:=$10;result[5]:=$00;result[6]:=$10;result[7]:=$00;end;
$8: begin result[4]:=$10;result[5]:=$10;result[6]:=$00;result[7]:=$00;end;
$9: begin result[4]:=$10;result[5]:=$10;result[6]:=$10;result[7]:=$10;end;
$A: begin result[4]:=$12;result[5]:=$12;result[6]:=$12;result[7]:=$12;end;
$B: begin result[4]:=$22;result[5]:=$22;result[6]:=$22;result[7]:=$22;end;
$C: begin result[4]:=$21;result[5]:=$21;result[6]:=$21;result[7]:=$21;end;
$D: begin I:=HIGH(Heros)+1;
          SetLength(Heros, I+1);
          Heros[I].ObjectType:=$0;
          Heros[I].Y:=yp;
          Heros[I].X:=xp+2;
          if Heros[I].X > 74 then begin Heros[I].Y:=Heros[I].Y+2;Heros[I].X:=2; end;
          //showmessage('3 Object 0 in '+inttostr(Heros[I].X)+ ' '+ inttostr(Heros[I].Y));
          result[4]:=$00;result[5]:=$00;result[6]:=$00;result[7]:=$00;
          end;
$E: begin I:=HIGH(Heros)+1;
          SetLength(Heros, I+1);
          Heros[I].ObjectType:=$E;
          Heros[I].Y:=yp;
          Heros[I].X:=xp+2;
          if Heros[I].X > 74 then begin Heros[I].Y:=Heros[I].Y+2;Heros[I].X:=2; end;
          //showmessage('4 Object E in '+inttostr(Heros[I].X)+ ' '+ inttostr(Heros[I].Y));
          result[4]:=$00;result[5]:=$00;result[6]:=$00;result[7]:=$00;
          end;
$F: begin result[4]:=$00;result[5]:=$00;result[6]:=$00;result[7]:=$00;end;
end;


end;

var
i,j,o:byte;
b,b1,b2:byte;
k:integer;
l,m,t:integer;
r:array[0..7] of byte;
begin
k:=0;
i:=2;
j:=1;
b:=0;
while (k<=HIGH(LevelRes[maps_num])) and (j<58) do begin
b:=LevelRes[maps_num,k];
toBlock(b,i,j,r);
xMaps[i,j]:=R[0];
xMaps[i+1,j]:=R[1];
xMaps[i,j+1]:=R[2];
xMaps[i+1,j+1]:=R[3];

if (i+2)>74 then begin
i:=2;
o:=0;
j:=j+2;
end else o:=2;

if j<58 then begin

xMaps[i+o,j]:=R[4];
xMaps[i+o+1,j]:=R[5];
xMaps[i+o,j+1]:=R[6];
xMaps[i+o+1,j+1]:=R[7];
end;

i:=i+o+2;
if i>74 then begin
i:=2;
j:=j+2;
end;
inc (k);
end;

l:=b and $F;
t:=0;
for m := 0 to high(HEROS) do begin
if heros[m].ObjectType = $0 then begin
heros[m].ObjectType:=$2;
inc(t);
if t=l then break;
end;
end;

for i := low(xMaps) to HIGH(xMaps) do
  for j := low(xMaps[i]) to high(xMaps[i]) do begin
  if xMaps[i,j] in [$01..$12] then OldMaps[i,j]:=$01 else OldMaps[i,j]:=$00;
  end;
end;

procedure TMaps.Render(Background:boolean; frames:integer);
var
i,j:byte;
index:byte;
begin
if background then begin
if frames mod 256 < 128 then begin
if GlobalPalete = 0 then begin
GlobalPalete:=1;
ChangeScenePalette(mbdc, GlobalPalete);
ChangeScenePalette(mfdc, GlobalPalete);
end;
end else
begin
if GlobalPalete = 1 then begin
GlobalPalete:=0;
ChangeScenePalette(mbdc, GlobalPalete);
ChangeScenePalette(mfdc, GlobalPalete);
end;
end;

for i := low(xMaps) to high(xMaps) do
for j := low(xMaps[i]) to high(xMaps[i]) do begin
case xMaps[i,j] of
$10,$21: index:=3;
$12: index:=1;
$22: index:=2;
else index:=0;
end;

if xMaps[i,j] = $22 then
CopyBackground(PbyteArrayFore,1, xMaps[i,j],index,i,j,maxLineBits) else
CopyBackground(PbyteArrayBack,1, xMaps[i,j],index,i,j,maxLineBits);
end;
BitBLT(hDC,0,0,width,height,mbdc,0,0,SRCCOPY);
end else TransparentBlt(hDC,0,0,width,height,mfdc,0,0,width,height,NesColor[palettes[GlobalPalete,2,0]]);

end;

procedure TMaps.setMap(x, y, b: byte);
begin
xMaps[x,y]:=b;
end;

procedure TMaps.setCollisionMap(x, y, b: byte);
begin
OldMaps[x,y]:=b;
end;

end.
