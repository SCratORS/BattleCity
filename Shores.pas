unit Shores;

interface
  Uses Windows, Utils, Resources;
type
TShore = packed record
x,y:integer;
num:byte;
FrameShores:Integer;
end;
  Type TShores = Class
    private
     HDC: LongWord;
     BufferedImage:LongWord;
     PbyteArray:Pointer;
     mDC:LongWord;
     alive:boolean;
     mapsShores: array of TShore;
    public
    procedure ShowShore(x,y,frame:Integer; nums:byte);
    function getAlive:Boolean;
    Constructor Create(DC:LongWord);Overload;
    destructor Destroy;override;
    Procedure Update(Frame:integer);
    Procedure Render(Frame:integer);
  End;

implementation

{ TShores }

constructor TShores.Create(DC: LongWord);
begin
  HDC:=DC;
  BufferedImage :=CreateDIB(hDC,8,8,PbyteArray);
  mdc           :=CreateCompatibleDC(hDC);
  SelectObject(mdc, BufferedImage);
  ChangePallete(mdc, 0, 3);
end;

destructor TShores.Destroy;
begin
  ReleaseDC(mDC,BufferedImage);
  DeleteDC(mDC);
  DeleteObject(BufferedImage);
  inherited;
end;

function TShores.getAlive: Boolean;
begin
result:=alive;
end;

procedure TShores.Render(Frame: integer);
var
offset:byte;
i:integer;
x,y:integer;
num:byte;
begin
for I := 0 to high(mapsShores) do
if Frame < mapsShores[i].FrameShores then begin
num:=$B8;
offset:=$00;
if mapsShores[i].num = $04 then num:= $3A else
offset:=mapsShores[i].num * 4;

X:=mapsShores[i].x;
Y:=mapsShores[i].y;
Shtamps(HDC, mDC, PbyteArray,1,num+offset,3,3,x,y,True,False);
Shtamps(HDC, mDC, PbyteArray,1,num+1+offset,3,3,x,y+8,True,False);
Shtamps(HDC, mDC, PbyteArray,1,num+2+offset,3,3,x+8,y,True,False);
Shtamps(HDC, mDC, PbyteArray,1,num+3+offset,3,3,x+8,y+8,True,False);
end;

end;

procedure TShores.ShowShore(x, y, frame: Integer; nums: byte);
var
l,i:integer;
begin
l:=high(mapsShores);
for I := 0 to l do begin
if mapsShores[i].FrameShores = 0 then begin
mapsShores[i].x:=X;
mapsShores[i].y:=Y;
mapsShores[i].FrameShores:=frame+480;
mapsShores[i].num:=nums;
exit;
end;
end;

setlength(mapsShores,l+2);
mapsShores[l+1].x:=X;
mapsShores[l+1].y:=Y;
mapsShores[l+1].FrameShores:=frame+480;
mapsShores[l+1].num:=nums;
end;

procedure TShores.Update(Frame: integer);
Var
i:integer;
begin
for I := 0 to high(mapsShores) do
if Frame >= mapsShores[i].FrameShores then mapsShores[i].FrameShores := 0;
end;

end.
