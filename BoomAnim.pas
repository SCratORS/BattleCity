unit BoomAnim;
interface
  Uses Windows, Utils, Resources, mmsystem;
type
booms = packed record
x,y:integer;
tek,max:byte;
end;
  Type TBoom = Class
    private
     HDC: LongWord;
     BufferedImage:LongWord;
     PbyteArray:Pointer;
     mDC:LongWord;
     alive:boolean;

     mapsboom: array of Booms;
    public
    procedure booms(x,y:Integer; max:byte);
    function getAlive:Boolean;
    Constructor Create(DC:LongWord);Overload;
    destructor Destroy;override;
    Procedure Update(Frame:integer);
    Procedure Render(Frame:integer);
  End;

implementation

{ TBoom }

procedure TBoom.booms(x, y: Integer; max:byte);
var
l,i:integer;
begin
l:=high(mapsboom);
for I := 0 to l do begin
if mapsboom[i].max = 0 then begin
mapsboom[i].x:=X;
mapsboom[i].y:=Y;
mapsboom[i].tek:=0;
mapsboom[i].max:=max;
exit;
end;
end;

setlength(mapsboom,l+2);
mapsboom[l+1].x:=X;
mapsboom[l+1].y:=Y;
mapsboom[l+1].tek:=0;
mapsboom[l+1].max:=max;
end;

constructor TBoom.Create(DC: LongWord);
begin
HDC:=DC;
  BufferedImage :=CreateDIB(hDC,8,8,PbyteArray);
  mdc           :=CreateCompatibleDC(hDC);
  SelectObject(mdc, BufferedImage);
  ChangePallete(mdc, 3,3);

end;

destructor TBoom.Destroy;
begin
  ReleaseDC(mDC,BufferedImage);
  DeleteDC(mDC);
  DeleteObject(BufferedImage);
  inherited;
end;

function TBoom.getAlive: Boolean;
begin
result:=alive;
end;

procedure TBoom.Render;
var
offset:byte;
i:integer;
x,y:integer;
begin

for I := 0 to high(mapsboom) do
if mapsboom[i].max>0 then begin
if mapsboom[i].tek<3 then begin
offset:=mapsboom[i].tek * 4;
X:=mapsboom[i].x-4;
Y:=mapsboom[i].y;
Shtamps(HDC, mDC, PbyteArray,1,$F0+offset,3,3,x,y,True,False);
Shtamps(HDC, mDC, PbyteArray,1,$F1+offset,3,3,x,y+8,True,False);
Shtamps(HDC, mDC, PbyteArray,1,$F2+offset,3,3,x+8,y,True,False);
Shtamps(HDC, mDC, PbyteArray,1,$F3+offset,3,3,x+8,y+8,True,False);
end else begin

X:=mapsboom[i].x+4;
Y:=mapsboom[i].y+8;

offset:=(mapsboom[i].tek-3) * $10;

Shtamps(HDC, mDC, PbyteArray,1,$D0+offset,3,3,x-16,y-16,True,False);
Shtamps(HDC, mDC, PbyteArray,1,$D1+offset,3,3,x-16,y-8,True,False);
Shtamps(HDC, mDC, PbyteArray,1,$D2+offset,3,3,x-8,y-16,True,False);
Shtamps(HDC, mDC, PbyteArray,1,$D3+offset,3,3,x-8,y-8,True,False);

Shtamps(HDC, mDC, PbyteArray,1,$D4+offset,3,3,x,y-16,True,False);
Shtamps(HDC, mDC, PbyteArray,1,$D5+offset,3,3,x,y-8,True,False);
Shtamps(HDC, mDC, PbyteArray,1,$D6+offset,3,3,x+8,y-16,True,False);
Shtamps(HDC, mDC, PbyteArray,1,$D7+offset,3,3,x+8,y-8,True,False);

Shtamps(HDC, mDC, PbyteArray,1,$D8+offset,3,3,x-16,y,True,False);
Shtamps(HDC, mDC, PbyteArray,1,$D9+offset,3,3,x-16,y+8,True,False);
Shtamps(HDC, mDC, PbyteArray,1,$DA+offset,3,3,x-8,y,True,False);
Shtamps(HDC, mDC, PbyteArray,1,$DB+offset,3,3,x-8,y+8,True,False);

Shtamps(HDC, mDC, PbyteArray,1,$DC+offset,3,3,x,y,True,False);
Shtamps(HDC, mDC, PbyteArray,1,$DD+offset,3,3,x,y+8,True,False);
Shtamps(HDC, mDC, PbyteArray,1,$DE+offset,3,3,x+8,y,True,False);
Shtamps(HDC, mDC, PbyteArray,1,$DF+offset,3,3,x+8,y+8,True,False);
end;
end;
end;

procedure TBoom.Update(Frame: integer);
var
i:integer;
begin
if frame mod 18 = 0 then begin
for I := 0 to high(mapsboom) do begin
if mapsboom[i].max=0 then continue else begin
 inc(mapsboom[i].tek);
 if mapsboom[i].tek>mapsboom[i].max then mapsboom[i].max:=0;
end;
end;
end;


end;

end.
