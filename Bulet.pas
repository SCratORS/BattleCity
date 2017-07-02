unit Bulet;

interface

Uses Resources, Windows, Utils, Maps, BoomAnim, CollisionMap, mmsystem;

   type TBulet = class
    private
      Alive:boolean;
      BTheam:byte;
      X,Y: Integer;
      DC: LongWord;
      Heading: byte;
      FrameSkeep:byte;
      BufferedImage:LongWord;
      PbyteArray:Pointer;
      mDC:LongWord;
      GlobalMaps:TMaps;
      GlobalBoomMaps:TBoom;
      GlobalCollisionMap:TCollisionMap;
      Buletpower:byte;
      Destr_Frame:Integer;
      ResultsWork:Results;

      hwo: HWAVEOUT;
      wh15 : TWAVEHDR;
      hres15:THandle;

      wh12 : TWAVEHDR;
      hres12:THandle;

      wh13 : TWAVEHDR;
      hres13:THandle;
      
    public
      Function getPosition:TPoint;
      Function GetTeams:Byte;
      Procedure CollisionBullet(Frame:integer);
      function Fire(Head,Armor,power:byte; StartPositionX, StartPositionY, StartFrame: integer; Reload_Frame:Byte):boolean;
      Procedure Destr(head:byte; x,y,b:byte; BoomX,BoomY,frame:Integer);
      procedure ChengeTheams(Teams:byte);
      procedure setMaps(m:TMaps);
      procedure SetCollisionMap(CM:TCollisionMap);
      Procedure BoomMaps(bm:TBoom);
      Procedure Update(Frame:Integer);
      Procedure Render(Frame:Integer);
      constructor Create(HDC:LongWord; Theam: Byte); overload;
      destructor Destroy;Override;
      function getAlive:Boolean;
      Function GetResults:Results;
      Procedure ResetResults;
  end;

implementation

{ TBulet }


procedure TBulet.BoomMaps(bm: TBoom);
begin
GlobalBoomMaps:=bm;
end;

procedure TBulet.ChengeTheams(Teams: byte);
begin
BTheam:=Teams;
end;

procedure TBulet.CollisionBullet(Frame: integer);
begin
Destr_Frame:=Frame;
Alive:=false;
end;

constructor TBulet.Create(HDC: LongWord; Theam:byte);
var
  ResHandle : THandle;
begin
  BTheam:=Theam;
  DC:=HDC;
  Alive:=False;
  BufferedImage :=CreateDIB(hDC,8,8,PbyteArray);
  mdc           :=CreateCompatibleDC(hDC);
  SelectObject(mdc, BufferedImage);
  ChangePallete(mdc, 0,3);

    SoundPreapare(hwo);
    ResHandle := FindResource( HInstance, 'FX15', 'RAW');
    hRes15 :=      LoadResource( HInstance, ResHandle);
    FillChar(wh15,sizeof(TWAVEHDR),#0);
    wh15.lpData := LockResource(hRes15);
    wh15.dwBufferLength := SizeOfResource(hInstance, ResHandle);  // длина буфера
    waveOutPrepareHeader(hwo, @wh15, sizeof(TWAVEHDR));  // подготовка буферов драйверо

    ResHandle := FindResource( HInstance, 'FX12', 'RAW');
    hRes12 :=      LoadResource( HInstance, ResHandle);
    FillChar(wh12,sizeof(TWAVEHDR),#0);
    wh12.lpData := LockResource(hRes12);
    wh12.dwBufferLength := SizeOfResource(hInstance, ResHandle);  // длина буфера
    waveOutPrepareHeader(hwo, @wh12, sizeof(TWAVEHDR));  // подготовка буферов драйверо

    ResHandle := FindResource( HInstance, 'FX13', 'RAW');
    hRes13 :=      LoadResource( HInstance, ResHandle);
    FillChar(wh13,sizeof(TWAVEHDR),#0);
    wh13.lpData := LockResource(hRes13);
    wh13.dwBufferLength := SizeOfResource(hInstance, ResHandle);  // длина буфера
    waveOutPrepareHeader(hwo, @wh13, sizeof(TWAVEHDR));  // подготовка буферов драйверо
end;

procedure TBulet.Destr(head:byte; x,y,b:byte; BoomX,BoomY,Frame:Integer);
var
NewX,NewY:integer;
Th:byte;
begin
NewX:=BoomX;
NewY:=BoomY;
case head of
0: begin
   if Buletpower = 1 then begin
   if B in [$01..$03] then b:=$00;
   if B in [$04..$0F] then b:= b and $03;
   if B in [$01..$0F] then NewY:=NewY-4;
   end else if B in [$01..$10] then b:=$00;
   if B = 0 then NewY:=NewY-8;
   end;
2: begin
   if Buletpower = 1 then begin
   if b in [$01..$05] then if B=$03 then B:=$01 else B:=$00;
   if b in [$06..$0F] then b:= b and $05;
   if B in [$01..$0F] then NewX:=NewX-4;
   end else if B in [$01..$10] then  b:=$00;
   if B = 0 then NewX:=NewX-8;
   end;
4: begin
   if Buletpower = 1 then begin
   if b in [$04,$08,$0C] then b:= $00 else
   if b in [$01..$0F] then b := b and $0C;
   if B in [$01..$0F] then NewY:=NewY+4;
   end else if B in [$01..$10] then  b:=$00;
   if B = 0 then NewY:=NewY+8;
   end;
6: begin
   if Buletpower = 1 then begin
   if b in [$02,$08,$0A] then b:= $00 else
   if b in [$01..$0F] then b := b and $0A;
   if B in [$01..$0F] then NewX:=NewX+4;
   end else if B in [$01..$10] then  b:=$00;
   if B = 0 then NewX:=NewX+8;
   end;
end;

GlobalMaps.SetMap(x,y,b);
if b = $00 then GlobalMaps.setCollisionMap(x,y,b);

if alive then GlobalBoomMaps.booms(NewX,NewY, 2);
Destr_Frame:=Frame;
Alive:=false;
end;

destructor TBulet.Destroy;
begin
  ReleaseDC(mDC,BufferedImage);
  DeleteDC(mDC);
  DeleteObject(BufferedImage);
  waveOutReset(hwo);
  waveOutUnprepareHeader(hwo, @wh15, sizeof(WAVEHDR));
  waveOutUnprepareHeader(hwo, @wh12, sizeof(WAVEHDR));
  waveOutUnprepareHeader(hwo, @wh13, sizeof(WAVEHDR));
  WaveOutClose(hwo);
  FreeResource(hRes15);
  FreeResource(hRes12);
  FreeResource(hRes13);

  inherited;
end;

function TBulet.Fire(Head,Armor,power:byte; StartPositionX, StartPositionY, StartFrame: integer; Reload_Frame:Byte):boolean;
begin
if StartFrame > Destr_Frame + Reload_Frame then begin
Destr_Frame:=0;
case Head of
0..7: Heading:=0;
8..15: Heading:=2;
16..23: Heading:=4;
24..31: Heading:=6;
end;
ResetResults;
X:=StartPositionX;
Y:=StartPositionY;
Buletpower:=Power;
Alive:=true;

if BTheam = 0 then begin
if Armor > 1 then FrameSkeep:=0 else FrameSkeep:=2;
waveOutReset(hwo);
waveOutWrite(hwo, @wh15, sizeof(WAVEHDR));
end else begin
FrameSkeep:=2;
end;

Result:=true;
end else Result:=false;
end;

function TBulet.getAlive: Boolean;
begin
  result:=Alive;
end;

function TBulet.getPosition: TPoint;
begin
Result.x:=X;
Result.y:=Y;
end;

function TBulet.GetResults: Results;
begin
result:=ResultsWork;
end;


function TBulet.GetTeams: Byte;
begin
 Result:=bTheam;
end;

procedure TBulet.Render(Frame: Integer);
begin
if Alive then begin
Shtamps(DC, mDC, PbyteArray,1,$B0+Heading,0,3,x,y,True,False);
Shtamps(DC, mDC, PbyteArray,1,$B0+Heading+1,0,3,x,y+8,True,False);
end;
end;

procedure TBulet.ResetResults;
begin
ResultsWork.ResultCode:=$00;
ResultsWork.Attributes:=0;
end;

procedure TBulet.SetCollisionMap(CM: TCollisionMap);
begin
GlobalCollisionMap:=CM;
end;

procedure TBulet.setMaps(m: TMaps);
begin
GlobalMaps:=m;
end;

procedure TBulet.Update(Frame: Integer);
var
NewX,NewY,index:Integer;
NextW,NextH:byte;
NextW1,NextH1:byte;
b1,b2,th:Byte;
begin
if FrameSkeep > 0 then
if Frame mod FrameSkeep > 0 then exit;

NewX:=X;
NewY:=Y;
case Heading of
0: dec(NewY);
2: dec(NewX);
4: inc(NewY);
6: inc(NewX);
end;

case Heading of
0: begin
   NextW :=  (NewX + 2) div 8;
   NextH :=  (NewY + 6) div 8;
   NextW1 :=  (NewX + 6) div 8;
   NextH1 :=  (NewY + 6) div 8;
   end;
2: begin
   NextW :=  (NewX + 2) div 8;
   NextH :=  (NewY + 5) div 8;
   NextW1 :=  (NewX + 2) div 8;
   NextH1 :=  (NewY + 9) div 8;
   end;
4: begin
   NextW :=  (NewX + 2) div 8;
   NextH :=  (NewY + 9) div 8;
   NextW1 :=  (NewX + 6) div 8;
   NextH1 :=  (NewY + 9) div 8;
   end;
6: begin
   NextW :=  (NewX + 5) div 8;
   NextH :=  (NewY + 5) div 8;
   NextW1 :=  (NewX + 5) div 8;
   NextH1 :=  (NewY + 9) div 8;
   end;
else begin
  NextW:=0;
  NextH:=0;
  NextW1:=0;
  NextH1:=0;
end;
end;
b1:=GlobalMaps.getMap(NextW,NextH);
b2:=GlobalMaps.getMap(NextW1,NextH1);

if B1 in [$01..$11] then Destr(Heading,NextW,NextH,B1,NewX,NewY,Frame);
if B2 in [$01..$11] then Destr(Heading,NextW1,NextH1,B2,NewX,NewY,Frame);

if (B1 in [$01..$0F]) or (B2 in [$01..$0F]) then 
if BTheam = 0 then begin
waveOutReset(hwo);
waveOutWrite(hwo, @wh12, sizeof(WAVEHDR));
end;

if (B1 in [$10]) or (B2 in [$10]) then 
if BTheam = 0 then begin
waveOutReset(hwo);
if BuletPower < 2 then waveOutWrite(hwo, @wh13, sizeof(WAVEHDR)) else
                       waveOutWrite(hwo, @wh12, sizeof(WAVEHDR));
end;

                       
if (B1 in [$11]) or (B2 in [$11]) then
if BTheam = 0 then begin
waveOutReset(hwo);
waveOutWrite(hwo, @wh13, sizeof(WAVEHDR));
end;

X:=NewX;
Y:=NewY;

if alive then begin

if (frame mod 4) = 0 then begin
Index:=GlobalCollisionMap.GetObjectTheam(X, Y, th);
if (Th < 255) and (TH <> BTheam) then begin
case Heading of
0,4:NewY:=NewY-8;
2,6:NewX:=NewX-4;
end;
Destr_Frame:=Frame;
alive:=false;
GlobalBoomMaps.booms(NewX,NewY,2);
ResultsWork.ResultCode:=GlobalCollisionMap.GetObjectTypes(Index);
ResultsWork.Attributes:=Index;
ResultsWork.Power:=BuletPower;
//enemy destroy
end;
end;
end;

end;

end.
