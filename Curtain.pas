unit Curtain;

interface

uses Utils, Windows, Resources;

Type TCurtain = class
  HDC: LongWord;
  BufferedImage:LongWord;
  PbyteArray:Pointer;
  mDC:LongWord;
  ScreenOver    :array of byte;
  maxLineBits:integer;
  Public
  Constructor Create(DC:Longword);overload;
  Destructor Destroy; override;
  Procedure Render;
  function Update(Frame:integer):boolean;
end;

implementation

{ TCurtain }

constructor TCurtain.Create(DC: Longword);
begin
  setLength(ScreenOver, 60);
  HDC:=DC;
  BufferedImage :=CreateDIB(hDC,8,8,PbyteArray);
  mdc           :=CreateCompatibleDC(hDC);
  SelectObject(mdc, BufferedImage);
  ChangePallete(mdc, 0,0);
  maxLineBits := Width div 2;
end;

destructor TCurtain.Destroy;
begin
  ReleaseDC(mDC,BufferedImage);
  DeleteDC(mDC);
  DeleteObject(BufferedImage);
  inherited;
end;

procedure TCurtain.Render;
var
i,j:integer;
begin
for i := low(ScreenOver) to high(ScreenOver) do
if ScreenOver[i] = $0 then
for j := 0 to 80 do Shtamps(HDC, mDC, PbyteArray,1,$11,3,2,j*8,i*8,True,False);
end;

function TCurtain.Update(Frame: integer):boolean;
var
i,s,m:integer;
begin
result:=true;
if frame mod 4 = 0 then begin
m:=high(ScreenOver);
s:=m div 2;
for I := s downto 0 do
if ScreenOver[i] = $0 then begin
ScreenOver[i] :=$1;
ScreenOver[m-i] :=$1;
exit;
end;
result:=false;
end;
  //
end;

end.
