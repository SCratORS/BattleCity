unit Bonus;

interface

uses windows, utils, resources, Shores, mmsystem;

  type TBonus = Class
  X,Y:integer;
  HDC: LongWord;
  BufferedImage:LongWord;
  PbyteArray:Pointer;
  mDC:LongWord;
  IndexBonus:byte;
  Showind:boolean;
  A_Show:boolean;
  Frams:Integer;
  ShoresMap:TShores;

  hwo: HWAVEOUT;

  wh9 : TWAVEHDR;
  hres9:THandle;

  wh6 : TWAVEHDR;
  hres6:THandle;

  wh5 : TWAVEHDR;
  hres5:THandle;

  Public
  Constructor Create(DC:Longword);overload;
  Destructor Destroy; override;
  Procedure CreateBonus(Frame:integer);
  Procedure Render(frame:integer);
  Procedure Update(Frame:integer);
  Function GetIndex:Byte;
  Function GetPosition:TPoint;
  Procedure SetShores(SM:TShores);
  Procedure Give(Frame:integer);
  End;

implementation

{ TBonus }

constructor TBonus.Create(DC: Longword);
var
  ResHandle : THandle;
begin
  HDC:=DC;
  BufferedImage :=CreateDIB(hDC,8,8,PbyteArray);
  mdc           :=CreateCompatibleDC(hDC);
  SelectObject(mdc, BufferedImage);
  ChangePallete(mdc, 3,2);
  Showind:=False;
  A_Show:=False;

    SoundPreapare(hwo);
    ResHandle := FindResource( HInstance, 'FX09', 'RAW');
    hRes9 :=      LoadResource( HInstance, ResHandle);
    FillChar(wh9,sizeof(TWAVEHDR),#0);
    wh9.lpData := LockResource(hRes9);
    wh9.dwBufferLength := SizeOfResource(hInstance, ResHandle);  // длина буфера
    waveOutPrepareHeader(hwo, @wh9, sizeof(TWAVEHDR));  // подготовка буферов драйверо

    ResHandle := FindResource( HInstance, 'FX06', 'RAW');
    hRes6 :=      LoadResource( HInstance, ResHandle);
    FillChar(wh6,sizeof(TWAVEHDR),#0);
    wh6.lpData := LockResource(hRes6);
    wh6.dwBufferLength := SizeOfResource(hInstance, ResHandle);  // длина буфера
    waveOutPrepareHeader(hwo, @wh6, sizeof(TWAVEHDR));  // подготовка буферов драйверо

    ResHandle := FindResource( HInstance, 'FX05', 'RAW');
    hRes5 :=      LoadResource( HInstance, ResHandle);
    FillChar(wh5,sizeof(TWAVEHDR),#0);
    wh5.lpData := LockResource(hRes5);
    wh5.dwBufferLength := SizeOfResource(hInstance, ResHandle);  // длина буфера
    waveOutPrepareHeader(hwo, @wh5, sizeof(TWAVEHDR));  // подготовка буферов драйверо


end;

procedure TBonus.CreateBonus(Frame:integer);
var
r:byte;
begin
waveOutWrite(hwo, @wh9, sizeof(WAVEHDR));
Frams:=Frame;
randomize;
R:=random(8);
Case R of
0: IndexBonus:=$00; // каска
1: IndexBonus:=$01; // часы
2: IndexBonus:=$02; // лопата
3: IndexBonus:=$03; // звезда
4: IndexBonus:=$04; // граната
5: IndexBonus:=$05; // жизнь
6: IndexBonus:=$03; // звезда/пистолет
7: IndexBonus:=$04; // граната / корабль?
End;

X:=(random(73)+2)*8;
Y:=(random(57)+1)*8;
Showind:=true;
end;

destructor TBonus.Destroy;
begin
  ReleaseDC(mDC,BufferedImage);
  DeleteDC(mDC);
  DeleteObject(BufferedImage);
  waveOutReset(hwo);
  waveOutUnprepareHeader(hwo, @wh9, sizeof(WAVEHDR));
  waveOutUnprepareHeader(hwo, @wh6, sizeof(WAVEHDR));
  waveOutUnprepareHeader(hwo, @wh5, sizeof(WAVEHDR));
  WaveOutClose(hwo);
  FreeResource(hRes9);
  FreeResource(hRes6);
  FreeResource(hRes5);
  inherited;
end;

function TBonus.GetIndex: Byte;
begin
Result:=IndexBonus;
end;

function TBonus.GetPosition: TPoint;
begin
if Showind then begin
Result.x:=X div 8;
Result.y:=Y div 8;
end else begin
Result.x:=-1;
Result.y:=-1;
end;
end;

procedure TBonus.Give(Frame:integer);
begin
Showind:=false;
ShoresMap.ShowShore(X,Y,Frame,4);
case IndexBonus of
0..4: waveOutWrite(hwo, @wh6, sizeof(WAVEHDR));
5: waveOutWrite(hwo, @wh5, sizeof(WAVEHDR));
end;

end;

procedure TBonus.Render(frame: integer);
var
offset:byte;
begin
if Showind then begin
if frame mod 32 = 0 then A_Show:=not A_Show;
if A_Show then begin
offset:=IndexBonus*4;
Shtamps(HDC, mDC, PbyteArray,1,$80+offset,3,2,x,y    ,True,False);
Shtamps(HDC, mDC, PbyteArray,1,$81+offset,3,2,x,y+8  ,True,False);
Shtamps(HDC, mDC, PbyteArray,1,$82+offset,3,2,x+8,y  ,True,False);
Shtamps(HDC, mDC, PbyteArray,1,$83+offset,3,2,x+8,y+8,True,False);
end;
end;
end;

procedure TBonus.SetShores(SM: TShores);
begin
ShoresMap:=SM;
end;

procedure TBonus.Update(Frame: integer);
begin
if Showind then
 if Frame > Frams+7200 then Showind:=false;
end;

end.
