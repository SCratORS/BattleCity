
unit Enemy;

interface
  uses Windows, Utils, Bulet, Resources, Maps, BoomAnim, CollisionMap, Bonus, Shores, mmsystem;

  type TEnemy = class
    private
      EnType:byte;
      X,Y: Integer;
      DC: LongWord;
      Heading: byte;
      Road:byte;
      FrameSkeep:byte;
      Bullet: Array [0..1] of TBulet;
      Reload: Boolean;
      Armor : byte;
      UpGrade:Byte;
      Teams:Byte;
      EnemType:Byte;
      Players:Byte;
      BufferedImage:LongWord;
      PbyteArray:Pointer;
      mDC:LongWord;
      BufferedImage_bonus:LongWord;
      PbyteArray_bonus:Pointer;
      mDC_bonus:LongWord;
      GlobalMaps: TMaps;
      GlobalBoomMaps:TBoom;
      GlobalCollisionMap:TCollisionMap;
      button_down:boolean;
      going: boolean;
      Power:byte;
      Button_UP,
      Button_Dwn,
      Button_Left,
      Button_Right,
      Button_Fire:Boolean;
      MyIndex:Integer;
      Alive:Boolean;
      IceFrame:Integer;
      Barrier:Boolean;
      RespawnPointPlayer:Byte;
      Locked:Boolean;
      Lives:Byte;
      palls,bonuspall:Byte;
      bonused:byte;
      GlobalBonus:TBonus;
      AliveBonus:Byte;
      FrameBonus:integer;
      ResultBonus:byte;
      ResultBonusFrame:Integer;
      ArmoreRender:Byte;
      DestroyFrames:Integer;
      AliveFrames:integer;
      ShoresMaps:TShores;
      RespawnFrame:Integer;
      AtackObject:Tpoint;
      hwo: HWAVEOUT;
      wh10 : TWAVEHDR;
      hres10:THandle;
      wh14 : TWAVEHDR;
      hres14:THandle;
      procedure change(frame:integer;PlayersObject: Array of ObjectPlayer);
    public
      function isGoing:Boolean;
      Function isAlive:Boolean;
      Function getBulet(i:byte):TBulet;
      Function GetPlayer:Byte;
      Procedure CreateEnemy(PosX,PosY:integer; UpGrades,Armors,Bonuse:byte);
      Procedure Destr(Frame:integer; granade:boolean);
      Procedure Lock(Locks:Boolean);
      Procedure SetAlive(B:Boolean);
      Procedure ChangeStatus(i:integer; Frames:integer);
      Procedure GetResults(Var R: Array of Results);
      Procedure CollisionMapChange;
      Procedure Input(Frame:Integer; PlayersObject: Array of ObjectPlayer);
      Procedure Render(Frame:Integer);
      Procedure BulletRender(Frame:Integer);
      Procedure SetMaps(m:TMaps);
      Procedure BoomMaps(bm:TBoom);
      Procedure ShoreMap(sm:TShores);
      Procedure SetCollisionMap(cm:TCollisionMap);
      constructor Create(HDC:LongWord; EnemyTeams, Player_num, UpGrades, Armors,Liveses: Byte; StartPositionX,StartPositionY:Integer); overload;
      destructor Destroy;Override;
      Procedure SetIndex(i:Integer);
      Function  GetIndex:Byte;
      Procedure ChangePlayer(Theam,Player:Byte);
      Procedure SetPespawnPoint(p:byte);
      Function GetRespawnPoint:byte;
      Function GetLives:Byte;
      Procedure DecLives;
      Function GetArmor:Byte;
      Function GetUpgrade:Byte;
      Procedure setBonus(BN:TBonus);
      Function GetResultBonus:byte;
      Function GetResultBonusFrame:integer;
      Procedure SetBonused(BN:Byte; IncFrame:Integer);
      Function DestroyFrame:Integer;
      Procedure SetDestroyFrames(Frame:integer);
      Function getPosition:Tpoint;
      Procedure setRespaunFrame(Frame:integer);
      Procedure SetAliveFrames(Frame:integer);
      Procedure Action(ListIndex: array of byte);
      Function GetLocked:Boolean;
  end;

implementation


{ TEnemy }


procedure TEnemy.Action(ListIndex: array of byte);
var
r:integer;
begin
{if high(ListIndex)=0 then AtackObject.x:=0 else begin
if random (5) = 0 then AtackObject.x:=0 else begin
r:=random(high(ListIndex)+1);
AtackObject.x:=ListIndex[r]+1;
end;
end; }
AtackObject.y:=Random(2) + 1;  
AtackObject.x:=0;
end;

procedure TEnemy.BoomMaps(bm: TBoom);
begin
GlobalBoomMaps:=bm;
Bullet[0].BoomMaps(bm);
Bullet[1].BoomMaps(bm);
end;

procedure TEnemy.BulletRender(Frame: Integer);
var
i:integer;
begin
for I := 0 to 1 do Bullet[i].Render(Frame);
end;

procedure TEnemy.change(frame:integer; PlayersObject: Array of ObjectPlayer);
var
ListIndex:Array of byte;
w,m:integer;

procedure RandomChange;
begin
Button_UP:=false;
Button_Dwn:=false;
Button_Left:=false;
Button_Right:=false;
case random(4) of
0:Button_UP:=true;
1:Button_Dwn:=true;
2:Button_Left:=true;
3:Button_Right:=true;
end;
end;

Procedure RotateLeft;
begin
if Button_UP then begin
Button_UP:=false;
Button_Left:=True;
end else
if Button_Left then begin
Button_Left:=false;
Button_Dwn:=True;
end else
if Button_Dwn then begin
Button_Dwn:=false;
Button_Right:=True;
end else
if Button_Right then begin
Button_Right:=false;
Button_Up:=True;
end;
end;

Procedure RotateRight;
begin
if Button_UP then begin
Button_UP:=false;
Button_Right:=True;
end else
if Button_Right then begin
Button_Right:=false;
Button_Dwn:=True;
end else
if Button_Dwn then begin
Button_Dwn:=false;
Button_Left:=True;
end else
if Button_Left then begin
Button_Left:=false;
Button_Up:=True;
end;
end;

Procedure InvertDirection;
begin
if Button_UP then begin
Button_UP:=False;
Button_Dwn:=True;
end else
if Button_Dwn then begin
Button_Dwn:=False;
Button_Up:=True;
end else
if Button_Left then begin
Button_Left:=False;
Button_Right:=True;
end else
if Button_Right then begin
Button_Right:=False;
Button_Left:=True;
end;
end;

Procedure GoToPlayer(b:byte);
var
sizeMap:TPoint;
br:byte;
i,j,xf,yf,xs,ys:integer;
mapbuf: array of array of word;
mov: TPoint;  // массив точек пути

procedure find(sposx, sposy, fposx, fposy: integer);
var
i,j,k,n : integer;
cellx,celly:integer;
not_found:boolean;
begin
k:=2;
cellx:=fposx;
celly:=fposy;
mapbuf[sposy,sposx]:=k;
repeat
not_found:=true;
for i:= 0 to high(mapbuf) do
 for j:= 0 to high(mapbuf[i]) do
   if mapbuf[i,j] = k then
     begin
      not_found:=false;
      if (mapbuf[i+1,j]=1) then mapbuf[i+1,j]:=k+1;
      if (mapbuf[i-1,j]=1) then mapbuf[i-1,j]:=k+1;
      if (mapbuf[i,j+1]=1) then mapbuf[i,j+1]:=k+1;
      if (mapbuf[i,j-1]=1) then mapbuf[i,j-1]:=k+1;
     end;
    inc(k);
until (mapbuf[fposy, fposx] > 1) or (k > 64) or not_found;
   if mapbuf[celly,cellx] = k then
     begin
        mov.X:=cellX;
        mov.Y:=cellY;
     if mapbuf[celly,cellx+1] = k-1 then mov.X:=cellx+1 else
     if mapbuf[celly,cellx-1] = k-1 then mov.X:=cellx-1 else
     if mapbuf[celly+1,cellx] = k-1 then mov.Y:=celly+1 else
     if mapbuf[celly-1,cellx] = k-1 then mov.Y:=celly-1;
     end else begin
        mov.X:=0;
        mov.Y:=0;
     end;
end;

begin

if (frame mod 8) <> 0 then exit;
sizeMap:=GlobalMaps.getSize;
setlength(mapbuf, sizeMap.Y+1, sizeMap.X+1);
if PlayersObject[b].objectType=$00 then br:=$0F else br:=$00;
for i:=0 to high(mapbuf) do
for j:=0 to high(mapbuf[i]) do
if (GlobalMaps.getMap(j,i)     in [$00..br,$21,$22]) and
   (GlobalMaps.getMap(j+1,i)   in [$00..br,$21,$22]) and
   (GlobalMaps.getMap(j,i+1)   in [$00..br,$21,$22]) and
   (GlobalMaps.getMap(j+1,i+1) in [$00..br,$21,$22]) then mapbuf[i,j]:=$01 else mapbuf[i,j]:=$00;
xf:=(X+4) div 8;
yf:=(Y+4) div 8;

xs:=(PlayersObject[b].X+4) div 8;
ys:=(PlayersObject[b].Y+4) div 8;
find(xs,ys,xf,yf);
xs:=mov.x;
ys:=mov.y;

if (x mod 8 = 0) or (y mod 8 = 0) then begin
Button_UP:=false;
Button_Dwn:=false;
Button_Left:=false;
Button_Right:=false;
if (XS=0) and (ys = 0) then AtackObject.X:=0;
if yf < ys then Button_dwn:=true else
if yf > ys then Button_up:=true else
if xf < xs then Button_Right:=true else
if xf > xs then Button_Left:=true;
end;

end;

begin

if palls = 0 then palls := 1 else palls := 0;
case armor of
4: if palls = 0 then ChangePallete(mdc, 3, 2) else ChangePallete(mdc, 3, 1);
3: if palls = 0 then ChangePallete(mdc, 3, 2) else ChangePallete(mdc, 3, 0);
2: if palls = 0 then ChangePallete(mdc, 3, 0) else ChangePallete(mdc, 3, 1);
1: ChangePallete(mdc, 3, 2);
end;

if bonused>0 then begin
if frame mod 32 = 0 then begin if bonuspall = 0 then bonuspall := 1 else bonuspall := 0 end;
if bonuspall = 1 then ChangePallete(mdc, 3, 3);
end;


if Locked then exit;

randomize;
if AliveFrames + (AtackObject.y * RespawnFrame) > Frame then begin
case AtackObject.X of
0: if (X mod 8 = 0) and (Y mod 8 = 0) and (random(16) = 0) then begin
   if (random(2)= 0) then RandomChange else if (random(2)= 0) then RotateLeft else RotateRight;
    end else begin
    if Barrier and (random(4) = 0) then if ((X mod 8) <> 0) or ((Y mod 8) <> 0) then InvertDirection else RandomChange;
    end;
else if PlayersObject[AtackObject.X-1].Alive and not PlayersObject[AtackObject.X-1].Lock then GoToPlayer(AtackObject.X-1) else AtackObject.X:=0;
end;

end else begin
  SetAliveFrames(Frame);
  w:=0;
  setLength(ListIndex, w);
  for m := 0 to high(PlayersObject) do begin
  if PlayersObject[m].Alive then begin
  setLength(ListIndex, w+1);
  ListIndex[w]:=m;
  inc(w);
  end;
  end;
  Action(ListIndex);
end;




if random(32)=0 then Button_Fire:=True;
end;


procedure TEnemy.CollisionMapChange;
begin
if Alive then
GlobalCollisionMap.SetObject(MyIndex,X,Y,Teams,$01) else
GlobalCollisionMap.SetObject(MyIndex,X,Y,$FF,$01);
ResultBonus:=$00;
end;

constructor TEnemy.Create(HDC:LongWord; EnemyTeams, Player_num, UpGrades, Armors,Liveses: Byte; StartPositionX,
  StartPositionY: Integer);
var
cols:byte;
ResHandle : THandle;
begin
  Lives:=Liveses;
  ArmoreRender:=0;
  Locked:=false;
  RespawnPointPlayer := 0;
  Reload    :=  true;
  X         :=  StartPositionX;
  Y         :=  StartPositionY;
  DC        :=  HDC;
  Road      :=  1;
  Teams     := EnemyTeams;
  Players   :=Player_num;
  UpGrade   :=Upgrades;
  Armor     :=Armors;
  Alive     :=true;
  Bullet[0]:=TBulet.Create(HDC,0);
  Bullet[0].ChengeTheams(EnemyTeams);
  Bullet[1]:=TBulet.Create(HDC,0);
  Bullet[1].ChengeTheams(EnemyTeams);
  if Teams = 2 then EnType:=$80 else EnType:=$00;
  EnType := EnType + (UpGrade * $20);

  Power:=1;
  If (Teams < 2) and (UpGrade = 3) then Power:=2;

  case EnType of
  $00..$7F : FrameSkeep := 6;
  $A0..$BF : FrameSkeep := 4;
  else       FrameSkeep := 8;
  end;

  BufferedImage :=CreateDIB(hDC,8,8,PbyteArray);
  mdc           :=CreateCompatibleDC(hDC);
  SelectObject (mdc, BufferedImage);

  BufferedImage_bonus :=CreateDIB(hDC,8,8,PbyteArray_bonus);
  mdc_bonus           :=CreateCompatibleDC(hDC);
  SelectObject (mdc_bonus, BufferedImage_bonus);
  ChangePallete(mdc_bonus, 0, 3);

cols:=2;
case players of
0: cols:=2;
1: cols:=0;
2: cols:=1;
3: cols:=3;
end;
ChangePallete(mdc, 3, Cols);
    SoundPreapare(hwo);
    ResHandle := FindResource( HInstance, 'FX10', 'RAW');
    hRes10 :=      LoadResource( HInstance, ResHandle);
    FillChar(wh10,sizeof(TWAVEHDR),#0);
    wh10.lpData := LockResource(hRes10);
    wh10.dwBufferLength := SizeOfResource(hInstance, ResHandle);  // длина буфера
    waveOutPrepareHeader(hwo, @wh10, sizeof(TWAVEHDR));  // подготовка буферов драйверо

    ResHandle := FindResource( HInstance, 'FX14', 'RAW');
    hRes14 :=      LoadResource( HInstance, ResHandle);
    FillChar(wh14,sizeof(TWAVEHDR),#0);
    wh14.lpData := LockResource(hRes14);
    wh14.dwBufferLength := SizeOfResource(hInstance, ResHandle);  // длина буфера
    waveOutPrepareHeader(hwo, @wh14, sizeof(TWAVEHDR));  // подготовка буферов драйверо
end;

procedure TEnemy.DecLives;
begin
If Lives>0 then dec(Lives);
end;

procedure TEnemy.Destr(Frame:integer; granade:boolean);
Var
X1,Y1:integer;
begin
    waveOutReset(hwo);
    waveOutWrite(hwo, @wh10, sizeof(WAVEHDR));
    Alive:=false;
    X1:= ((X+4) div 8);
    Y1:= ((Y+4) div 8);
    GlobalMaps.setCollisionMap(X1, Y1, $00);
    GlobalMaps.setCollisionMap(X1+1, Y1, $00);
    GlobalMaps.setCollisionMap(X1, Y1+1, $00);
    GlobalMaps.setCollisionMap(X1+1, Y1+1, $00);
    GlobalBoomMaps.booms(X+4,Y,4);
    DecLives;
    SetDestroyFrames(Frame);
    if not granade then  
    if Players = 0 then ShoresMaps.ShowShore(X,Y,Frame,Upgrade);
end;

destructor TEnemy.Destroy;
begin
  inherited;
  ReleaseDC(mDC,BufferedImage);
  DeleteDC(mDC);
  DeleteObject(BufferedImage);

  ReleaseDC(mDC_bonus,BufferedImage_bonus);
  DeleteDC(mDC_bonus);
  DeleteObject(BufferedImage_bonus);

  waveOutReset(hwo);
  waveOutUnprepareHeader(hwo, @wh10, sizeof(WAVEHDR));
  waveOutUnprepareHeader(hwo, @wh14, sizeof(WAVEHDR));
  WaveOutClose(hwo);
  FreeResource(hRes10);
  FreeResource(hRes14);
end;

function TEnemy.DestroyFrame: Integer;
begin
Result:=DestroyFrames;
end;

function TEnemy.GetArmor: Byte;
begin
Result:=Armor;
end;

function TEnemy.getBulet(i: byte): TBulet;
begin
Result:=Bullet[i];
end;

procedure TEnemy.ChangePlayer(Theam, Player: Byte);
var
Cols,i:Byte;
begin
  Teams     := Theam;
  Players   := Player;

  for I := 0 to 1 do Bullet[i].ChengeTheams(Theam);


  if Teams = 2 then EnType:=$80 else EnType:=$00;
  EnType := EnType + (UpGrade * $20);

  Power:=1;
  If (Teams < 2) and (UpGrade = 3) then Power:=2;

  case EnType of
  $00..$7F : FrameSkeep := 6;
  $A0..$BF : FrameSkeep := 4;
  else       FrameSkeep := 8;
  end;
cols:=2;
case Player of
0: cols:=2;
1: cols:=0;
2: cols:=1;
3: cols:=3;
end;
ChangePallete(mdc, 3, Cols);
CollisionMapChange;
end;

procedure TEnemy.ChangeStatus(i: integer; Frames:integer);
begin
if I<0 then begin
if Bonused>0 then begin
Bonused:=Bonused-1;
GlobalBonus.CreateBonus(Frames);
end;
if AliveBonus = $01 then exit;
if Armor < ABS(I) then begin
Armor:=0;
end else begin
Armor:=Armor+i;
end;
end else begin
Armor:=Armor+i;
if Armor>4 then Armor:=4;
end;


If (Teams < 2) then begin
if I<0 then begin
if UpGrade<ABS(I) then UpGrade:=0 else UpGrade:=UpGrade+i;
end else begin
UpGrade:=UpGrade+i;
if UpGrade>3 then UpGrade:=3;
end;
end;



Power:=1;
If (Teams < 2) and (UpGrade = 3) then Power:=2;
if Teams = 2 then EnType:=$80 else EnType:=$00;
EnType := EnType + (UpGrade * $20);
if Armor=0 then Destr(Frames, false) else begin
    if i<1 then begin
    waveOutReset(hwo);
    waveOutWrite(hwo, @wh14, sizeof(WAVEHDR));
    end;

end;
end;

function TEnemy.GetIndex: Byte;
begin
Result:=MyIndex;
end;

function TEnemy.GetLives: Byte;
begin
Result:=Lives;
end;

function TEnemy.GetLocked: Boolean;
begin
Result:=Locked;
end;

function TEnemy.GetPlayer: Byte;
begin
Result:=Players;
end;

function TEnemy.getPosition: Tpoint;
begin
Result.x:=X;
Result.y:=Y;
end;

function TEnemy.GetRespawnPoint: byte;
begin
Result:=RespawnPointPlayer;
end;

function TEnemy.GetResultBonus: byte;
begin
result:=ResultBonus;
end;

function TEnemy.GetResultBonusFrame: integer;
begin
Result:=ResultBonusFrame;
end;

procedure TEnemy.GetResults(var R: array of Results);
Var
i:integer;
begin
for I := 0 to 1 do begin
r[i]:= Bullet[i].getResults;
Bullet[i].ResetResults;
end;
end;

function TEnemy.GetUpgrade: Byte;
begin
Result:=Upgrade;
end;

procedure TEnemy.Input(Frame:Integer; PlayersObject: Array of ObjectPlayer);

function TankTab(ValueOld:integer; Var Value:Integer):integer;
var
offer:integer;
begin
offer:=Value mod 8;
if offer>0 then begin
if offer > 3 then Value:=(Value div 8)+1 else Value:=Value div 8;
Value:=Value*8;
Result:=Value;
end else result:=ValueOld;
end;

Var
NewX,NewY,i,x1,y1:integer;
TotalBulet,b1,b2,bi1,bi2:Byte;
BonusPos:TPoint;
begin
CollisionMapChange;
if Players>0 then begin
if Upgrade > 1 then TotalBulet:=1 else TotalBulet:=0;
end else TotalBulet:=0;

for I := 0 to 1 do
if Bullet[i].getAlive then Bullet[i].Update(Frame);


if not alive then exit;


if (Players = 0) and (Frame mod 4 = 0) then change(frame, PlayersObject);

if (Players > 0) and (Frame > FrameBonus) then AliveBonus:=$00;


if Locked then exit;

case Players of
1: begin
     if (GetKeyState(VK_RCONTROL) < 0) then begin
     if Reload then begin
      Reload := False;
      for I := 0 to TotalBulet do
        if Not Bullet[i].getAlive then begin
          if Bullet[i].Fire(Heading,Armor,Power,X+3,Y,Frame,40) then break;
        end;
    end;
    end else Reload:=True;
   end;
2: begin
     if (GetKeyState(VK_LCONTROL) < 0) then begin
     if Reload then begin
      Reload := False;
      for I := 0 to TotalBulet do
        if Not Bullet[i].getAlive then begin
          if Bullet[i].Fire(Heading,Armor,Power,X+3,Y,Frame,40) then break;
        end;
    end;
    end else Reload:=True;
   end;
3: begin
     if (GetKeyState(VK_NUMPAD0) < 0) then begin
     if Reload then begin
      Reload := False;
      for I := 0 to TotalBulet do
        if Not Bullet[i].getAlive then begin
          if Bullet[i].Fire(Heading,Armor,Power,X+3,Y,Frame,40) then break;
        end;
    end;
    end else Reload:=True;
   end;
0: begin
     if Button_Fire then begin
     Button_Fire:=false;
     if Reload then begin
      Reload := False;
      for I := 0 to TotalBulet do
        if Not Bullet[i].getAlive then begin
          if Bullet[i].Fire(Heading,Armor,Power,X+3,Y,Frame,40) then break;
        end;
    end;
    end else Reload:=True;
   end;
end;



if frame mod FrameSkeep <> 0 then exit;

NewX:=X;
NewY:=Y;

  button_down:=false;


case Players of
1:begin
  If GetKeyState(VK_UP) < 0 then begin
      dec(NewY);
      X:=TankTab(X,NewX);
      Heading := 0;
      button_down:=true;
  end else
  If GetKeyState(VK_RIGHT) < 0 then begin
      inc(NewX);
      Y:=TankTab(Y,NewY);
      Heading := 24;
      button_down:=true;
  end else
  If GetKeyState(VK_DOWN) < 0 then begin
      inc(NewY);
      X:=TankTab(X,NewX);
      Heading := 16;
      button_down:=true;
  end else
  If GetKeyState(VK_LEFT) < 0 then begin
      dec(NewX);
      Y:=TankTab(Y,NewY);
      Heading := 8;
      button_down:=true;
  end;
end;
2:begin
  If GetKeyState($57) < 0 then begin
      dec(NewY);
      X:=TankTab(X,NewX);
      Heading := 0;
      button_down:=true;
  end else
  If GetKeyState($44) < 0 then begin
      inc(NewX);
      Y:=TankTab(Y,NewY);
      Heading := 24;
      button_down:=true;
  end else
  If GetKeyState($53) < 0 then begin
      inc(NewY);
      X:=TankTab(X,NewX);
      Heading := 16;
      button_down:=true;
  end else
  If GetKeyState($41) < 0 then begin
      dec(NewX);
      Y:=TankTab(Y,NewY);
      Heading := 8;
      button_down:=true;
  end;
end;
3:begin
  If GetKeyState(VK_NUMPAD8) < 0 then begin
      dec(NewY);
      X:=TankTab(X,NewX);
      Heading := 0;
      button_down:=true;
  end else
  If GetKeyState(VK_NUMPAD6) < 0 then begin
      inc(NewX);
      Y:=TankTab(Y,NewY);
      Heading := 24;
      button_down:=true;
  end else
  If GetKeyState(VK_NUMPAD5) < 0 then begin
      inc(NewY);
      X:=TankTab(X,NewX);
      Heading := 16;
      button_down:=true;
  end else
  If GetKeyState(VK_NUMPAD4) < 0 then begin
      dec(NewX);
      Y:=TankTab(Y,NewY);
      Heading := 8;
      button_down:=true;
  end;
end;
0:begin
    If Button_UP then begin
      dec(NewY);
      X:=TankTab(X,NewX);
      Heading := 0;
      button_down:=true;
  end else
  If Button_Right then begin
      inc(NewX);
      Y:=TankTab(Y,NewY);
      Heading := 24;
      button_down:=true;
  end else
  If Button_Dwn then begin
      inc(NewY);
      X:=TankTab(X,NewX);
      Heading := 16;
      button_down:=true;
  end else
  If Button_Left then begin
      dec(NewX);
      Y:=TankTab(Y,NewY);
      Heading := 8;
      button_down:=true;
  end;
end;  
end;

    X1:= ((X+4) div 8);
    Y1:= ((Y+4) div 8);
    GlobalMaps.setCollisionMap(X1, Y1, $00);
    GlobalMaps.setCollisionMap(X1+1, Y1, $00);
    GlobalMaps.setCollisionMap(X1, Y1+1, $00);
    GlobalMaps.setCollisionMap(X1+1, Y1+1, $00);


  if button_down=true then IceFrame:=-1 else begin
  case Heading of
    0,16: begin
    bi1:=GlobalMaps.getMap((NewX+4) div 8, (NewY+8) div 8);
    bi2:=GlobalMaps.getMap((NewX+12) div 8, (NewY+8) div 8);
    end;
    8,24: begin
    bi1:=GlobalMaps.getMap((NewX+8) div 8, (NewY+4) div 8);
    bi2:=GlobalMaps.getMap((NewX+8) div 8, (NewY+12) div 8);
    end;
    else begin
      bi1:=0;bi2:=0;
    end;
  end;
  if (bi1 = $21) and (bi2 = $21) and (IceFrame = -1) then IceFrame:=Frame;
  if IceFrame>0 then   
  if Frame < IceFrame + 112 then begin
  case Heading of
  0:  dec(NewY);
  8:  dec(NewX);
  16: inc(NewY);
  24: inc(NewX);
  end;
  end;
  end;

  case Heading of
    0: begin
    b1:=GlobalMaps.getCollisionMap((NewX+4) div 8, NewY div 8);
    b2:=GlobalMaps.getCollisionMap((NewX+12) div 8, NewY div 8);
    end;
    8: begin
    b1:=GlobalMaps.getCollisionMap(NewX div 8, (NewY+4) div 8);
    b2:=GlobalMaps.getCollisionMap(NewX div 8, (NewY+12) div 8);
    end;
    16: begin
    b1:=GlobalMaps.getCollisionMap((NewX+4) div 8, (NewY+16) div 8);
    b2:=GlobalMaps.getCollisionMap((NewX+12) div 8, (NewY+16) div 8);
    end;
    24: begin
    b1:=GlobalMaps.getCollisionMap((NewX+16) div 8, (NewY+4) div 8);
    b2:=GlobalMaps.getCollisionMap((NewX+16) div 8, (NewY+12) div 8);
    end;
    else begin
      b1:=0;b2:=0;
    end;
  end;
  going:=false;
  Barrier:=true;
  if b1+b2 = $00 then begin
    going:=true;
    X:=NewX;
    Y:=NewY;
    Barrier:=False;
  end else begin
    IceFrame:=-1;
  end;

    NewX:= ((X+4) div 8);
    NewY:= ((Y+4) div 8);

    GlobalMaps.setCollisionMap(NewX, NewY, $01);
    GlobalMaps.setCollisionMap(NewX+1, NewY, $01);
    GlobalMaps.setCollisionMap(NewX, NewY+1, $01);
    GlobalMaps.setCollisionMap(NewX+1, NewY+1, $01);

  if Players>0 then begin
  if GlobalBonus.Showind then begin
  BonusPos:=GlobalBonus.GetPosition;
   if BonusPos.x > 0 then begin
       if (NewX>=BonusPos.x-1) and (NewX <= BonusPos.x +1) and
          (NewY>=BonusPos.y-1) and (NewY <= BonusPos.Y +1)
       then begin

       AliveBonus:=$00;
      Case GlobalBonus.GetIndex of
      $00: begin
           AliveBonus:=$01; // armore
           FrameBonus:=Frame+2400;
           end;
      $01: begin
           ResultBonus:=$01;
           ResultBonusFrame:=Frame+2400;
           end;
      $02: begin
           ResultBonus:=$02;
           ResultBonusFrame:=Frame+4800;
           end;
      $03: begin
           ChangeStatus(1, Frame);
           end;
      $04: begin
           ResultBonus:=$03;
           ResultBonusFrame:=Frame;
           end;
      $05: begin
           inc(Lives);
           end;
      End;
      GlobalBonus.Give(Frame);
      end;
    end;
  end;
  end;
end;

function TEnemy.isAlive: Boolean;
begin
Result:=Alive;
end;

function TEnemy.isGoing: Boolean;
begin
result:=button_down;
end;

procedure TEnemy.Lock(Locks:Boolean);
begin
Locked:=Locks;
end;

procedure TEnemy.Render(Frame:Integer);
var
anim:byte;
begin
if alive then begin

anim:=Road*4;
if locked then anim:=0 else begin
if button_down then
if going then begin
if (Heading = 24) or (Heading = 8) then anim := anim * ModesOne(X) else
anim := anim * ModesOne(Y);
end else anim := anim * ModesOne(frame div FrameSkeep);
end;



anim:=anim + EnType + Heading;
Shtamps(DC, mDC, PbyteArray,0,anim + 0,3,0,x,y,True,False);
Shtamps(DC, mDC, PbyteArray,0,anim + 1,3,0,x,y+8,True,False);
Shtamps(DC, mDC, PbyteArray,0,anim + 2,3,0,x+8,y,True,False);
Shtamps(DC, mDC, PbyteArray,0,anim + 3,3,0,x+8,y+8,True,False);

if AliveBonus = $01 then begin
if Frame mod 12 = 0 then if ArmoreRender=0 then ArmoreRender:=1 else ArmoreRender:=0;
anim:=ArmoreRender*4;
Shtamps(DC, mDC_bonus, PbyteArray_bonus,1,$28+anim ,3,0,x,y,True,False);
Shtamps(DC, mDC_bonus, PbyteArray_bonus,1,$29+anim ,3,0,x,y+8,True,False);
Shtamps(DC, mDC_bonus, PbyteArray_bonus,1,$2A+anim ,3,0,x+8,y,True,False);
Shtamps(DC, mDC_bonus, PbyteArray_bonus,1,$2B+anim ,3,0,x+8,y+8,True,False);
end;

end;
end;

procedure TEnemy.SetAlive(B: Boolean);
begin
Alive:=B;
end;

procedure TEnemy.SetAliveFrames(Frame: integer);
begin
AliveFrames:=Frame;
end;

procedure TEnemy.SetBonused(BN: Byte; IncFrame: Integer);
begin
AliveBonus:=BN;
FrameBonus:=IncFrame;
end;

procedure TEnemy.setBonus(BN: TBonus);
begin
GlobalBonus:=BN;
end;

procedure TEnemy.SetCollisionMap(cm: TCollisionMap);
Var
i:integer;
begin
GlobalCollisionMap:=CM;
For I:=0 to 1 do Bullet[i].SetCollisionMap(CM);
end;

procedure TEnemy.SetDestroyFrames(Frame: integer);
begin
DestroyFrames:=Frame;
end;

procedure TEnemy.SetIndex(i: Integer);
begin
MyIndex:=I;
end;

procedure TEnemy.SetMaps(m: TMaps);
begin
GlobalMaps:=m;
Bullet[0].setMaps(m);
Bullet[1].setMaps(m);
end;

procedure TEnemy.SetPespawnPoint(p: byte);
begin
RespawnPointPlayer:=p;
end;

procedure TEnemy.setRespaunFrame(Frame: integer);
begin
RespawnFrame:=Frame;
end;

procedure TEnemy.ShoreMap(sm: TShores);
begin
ShoresMaps:=sm;
end;

procedure TEnemy.CreateEnemy(PosX, PosY: integer; UpGrades,Armors,Bonuse:byte);
begin
palls:=0;
X:=PosX;
Y:=PosY;
UpGrade:=Upgrades;
Bonused:=Bonuse;
if Armors = 0 then Armor:=1 else Armor :=Armors;
if Teams = 2 then EnType:=$80 else EnType:=$00;

EnType := EnType + (UpGrade * $20);

Power:=1;
If (Teams < 2) and (UpGrade = 3) then Power:=2;

case EnType of
  $00..$7F : FrameSkeep := 6;
  $A0..$BF : FrameSkeep := 4;
else       FrameSkeep := 8;
end;
Alive:=True;
end;

end.
