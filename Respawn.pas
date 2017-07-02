unit Respawn;

interface

  uses Windows, Utils, Enemy, Resources, RenderInform;

type
EnemyList = ^TEnemyList;
TEnemyList = array of TEnemy;

  type TRespawn = class
    private
        Respawn     : array of TRespawnPoint;
        MaxEnemy    : byte;
        CountEnemy  : byte;
        TotalEnemy  : Byte;
        DefRespIndex: byte;
        HDC: LongWord;
        BufferedImage:LongWord;
        PbyteArray:Pointer;
        mDC:LongWord;
        Level,PlayerCount:Byte;
        DestrFrame  : Integer;
        CompleteShow :Boolean;
        AllRespountEnemy:byte;
        RendersInfo:TRenderInform;
        TankNum:Byte;
        Function LoadEnemy(Level, num:byte):TPoint;
    public
    Procedure AddRespawnPoint(X,Y,Theam,Player:Byte);
    Procedure Update(Frame:Integer;Pl: Array of TEnemy);
    Procedure Render(Frame:Integer);
    Function RespawnFrame:Integer;
    Procedure SetDestroyFrame(Frame:Integer);
    Procedure SetRenderInform(RI:TRenderInform);
    constructor Create(DC:LongWord; Max, Count, PlayrsCounts,Levels:Byte); Overload;
    destructor Destroy;  Override;
  end;

implementation

{ TRespawn }

procedure TRespawn.AddRespawnPoint(X, Y, Theam, Player: Byte);
Var
i:integer;
begin
I:=High(Respawn)+1;
SetLength(Respawn,i+1);
Respawn[i].Coordinates.x:=X;
Respawn[i].Coordinates.y:=Y;
Respawn[i].Theams:=Theam;
Respawn[i].Player:=Player;
if Player=0 then AllRespountEnemy:=AllRespountEnemy+1;
Respawn[i].StatusPoint := $0C;
Respawn[i].Vector:=-4;
Respawn[i].CurrentCircle:=$00;
Respawn[i].Active := False;
DefRespIndex:=Random(i-3);
end;

constructor TRespawn.Create(DC:LongWord; Max, Count,PlayrsCounts,Levels:Byte);
begin
  HDC:=DC;
  BufferedImage :=CreateDIB(hDC,8,8,PbyteArray);
  mdc           :=CreateCompatibleDC(hDC);
  SelectObject(mdc, BufferedImage);
  PlayerCount:=PlayrsCounts;
  Level:=Levels;
  ChangePallete(mdc, 3,3);
  AllRespountEnemy:=0;
  MaxEnemy:=Max;
  TotalEnemy:=0;
  CountEnemy:=Count;
  SetLength(Respawn,0);
  CompleteShow:=True;
  TankNum:=0;
end;

destructor TRespawn.Destroy;
begin
  ReleaseDC(mDC,BufferedImage);
  DeleteDC(mDC);
  DeleteObject(BufferedImage);
  inherited;
end;

function TRespawn.LoadEnemy(Level, num: byte): TPoint;
Var
b:Byte;
begin
b:=EnemyRes[Level, num div 2 ];
if num mod 2 = 0 then begin
Result.x :=  (b shr 6) and $03;
Result.y := ((b shr 4) and $03) + 1;
end else begin
Result.x :=  (b shr 2) and $03;
Result.y :=   (b and $03) + 1;
end;
end;

procedure TRespawn.Render(Frame: Integer);
var
i:integer;
X,Y:integer;
begin
for I := low(Respawn) to high(Respawn) do begin
if Respawn[i].Active then begin
X:=Respawn[i].Coordinates.x*8;
y:=Respawn[i].Coordinates.y*8;
Shtamps(HDC, mDC, PbyteArray,1,$A0+Respawn[i].StatusPoint,3,3,x,y    ,True,False);
Shtamps(HDC, mDC, PbyteArray,1,$A1+Respawn[i].StatusPoint,3,3,x,y+8  ,True,False);
Shtamps(HDC, mDC, PbyteArray,1,$A2+Respawn[i].StatusPoint,3,3,x+8,y  ,True,False);
Shtamps(HDC, mDC, PbyteArray,1,$A3+Respawn[i].StatusPoint,3,3,x+8,y+8,True,False);
end;
end;


//Render
end;


function TRespawn.RespawnFrame: Integer;
begin
Result:= (190 - level * 4 - (PlayerCount - 1) * 20) * 4;
end;

Procedure TRespawn.SetDestroyFrame(Frame:Integer);
begin
DestrFrame:=Frame;
end;

procedure TRespawn.SetRenderInform(RI: TRenderInform);
begin
RendersInfo:=RI;
end;

procedure TRespawn.Update(Frame: Integer; Pl: Array of TEnemy);

Procedure CreatePlayer(RespIndex:Byte);
var
i:integer;
begin
for i := Low(pl) to High(pl) do begin
  if (pl[i].GetPlayer = respawn[RespIndex].Player) then begin
      pl[i].CreateEnemy(respawn[RespIndex].Coordinates.x*8, respawn[RespIndex].Coordinates.y*8, pl[i].GetUpgrade, pl[i].GetArmor,0);
      pl[i].SetBonused($01,Frame+720);
      Exit;
  end;
  
end;
end;



procedure CreateEnemy(PosX,PosY:Integer);
var
i:integer;
p:TPoint;
b:byte;
begin
for i := Low(pl) to High(pl) do begin
  if (pl[i].GetPlayer = 0) and (not pl[i].isAlive) then begin
   P:=LoadEnemy(Level,TankNum);


   if (TankNum - 3) mod 7 = 0 then b:=1 else b:=0;

   //if TankNum in [3,10,17,24,31,38,45,52,59,66,73,80,87,94,101] then b:=1 else b:=0;
   inc(TankNum);
   pl[i].CreateEnemy(PosX, PosY, p.x, p.y,b);
   pl[i].SetAliveFrames(Frame);
   Exit;
 end;
end;
end;


var
i:integer;
MaxCircle:byte;
begin
if frame mod 4 = 0 then begin
TotalEnemy:=0;
for I := low(pl) to high(pl) do begin
 if (pl[i].GetPlayer = 0) and pl[i].isAlive then TotalEnemy:=TotalEnemy+1;
 if (pl[i].GetPlayer = 0) and not pl[i].isAlive then
 if (Frame > pl[i].DestroyFrame + RespawnFrame) or (DestrFrame = 0) then
 if (Frame > DestrFrame + RespawnFrame) or (DestrFrame = 0) then DestrFrame:=0;
 If (pl[i].GetPlayer > 0) and not pl[i].isAlive and (pl[i].GetLives > 0) and not Respawn[pl[i].GetRespawnPoint].Active then begin
  Respawn[pl[i].GetRespawnPoint].Player:=pl[i].GetPlayer;
  Respawn[pl[i].GetRespawnPoint].Active:=true;
 end;
end;
for I := low(Respawn) to high(Respawn) do begin
 if (Respawn[i].Player = 0) and Respawn[i].Active then TotalEnemy:=TotalEnemy+1;
end;

if (TotalEnemy < MaxEnemy) and (TankNum < CountEnemy) then begin
if DestrFrame = 0 then begin
 DestrFrame:=Frame;
 Respawn[DefRespIndex].Active:=True;
 RendersInfo.DecTank;
 DefRespIndex:=DefRespIndex+1;
 If DefRespIndex = AllRespountEnemy then DefRespIndex:=0;
end;
end;

for I := low(Respawn) to high(Respawn) do begin

if Respawn[i].Active then begin

if (Respawn[i].Player = 0) then begin
  if Frame mod 16 <>  0 then continue;
end else begin
  if Frame mod 12 <>  0 then continue;
end;

Respawn[i].StatusPoint := Respawn[i].StatusPoint + Respawn[i].Vector;
if Respawn[i].StatusPoint = $00 then Respawn[i].Vector := 4;
if Respawn[i].StatusPoint = $0C then begin
Respawn[i].Vector := -4;
Respawn[i].CurrentCircle:=Respawn[i].CurrentCircle+1;
If Respawn[i].CurrentCircle = 2 then begin
Respawn[i].CurrentCircle:=0;
Respawn[i].Active:=false;
if Respawn[i].Player= 0 then CreateEnemy(Respawn[i].Coordinates.x*8,Respawn[i].Coordinates.y*8) else CreatePlayer(i);
end;
end;
end;
end;

end;
//Update
end;

end.
