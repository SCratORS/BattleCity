unit GameThread;

interface

uses Windows, Enemy, Utils, Maps, BoomAnim,CollisionMap, Bulet, Respawn,
     PlayerBase, Resources, Bonus, RenderInform, Shores, Curtain, mmsystem;

const
  UPDATE_RATE     = 240.0;
  UPDATE_INTERVAL	= SECOND / UPDATE_RATE;

type TGameThread = class
  private
    HWND          : THandle;
    Total_Frame,
    Total_FPS,
    Total_UPD,
    Total_UPDL    : Cardinal;
    TITLE         : String;
    HDC, DC       : LongWord;
    BufferedImage : LongWord;
    ClearBrush,Pen    : LongWord;
    ClientRect    : TRect;
    Player         : array of TEnemy;
    mMaps          : TMaps;
    mBooms         : TBoom;
    mShores        : TShores;
    RespownMaps    : TRespawn;
    ColMaps        : TCollisionMap;
    RenderInforms  : TRenderInform;
    Bases          : array of TBase;
    PlayersObject  : array of ObjectPlayer;
    BasesCount     : Integer;
    Player_num    :byte;
    Enemy_num     :Byte;
    Max_Enemy     :byte;
    level         :byte;
    Bonuse         :TBonus;
    ClockBonus    :Boolean;
    ClockFrame    :Cardinal;
    ArmorBaseBonus:Boolean;
    ArmorBaseFrame:Cardinal;
    Status:byte;
    mCurtain: TCurtain;

    hwo: HWAVEOUT;
    wh17 : TWAVEHDR;
    hres17:THandle;
    wh18 : TWAVEHDR;
    hres18:THandle;

    Procedure Update;
    Procedure Render;
    Procedure UpdateTitle;
    Procedure ClearBuffer;
    Procedure SwapBuffers;
  protected
    procedure Execute;
    procedure ThreadExit;
  public
    procedure StopThread;
    constructor Create(Handle:Thandle); overload;
end;

var
  running   : Boolean;
  ThreadID  : LongWord;
implementation

{ TGameThread }

procedure TGameThread.Execute;
  var
  fps,upd,updl,l,k      : integer;
  counter,
  lastTime, elapsedTime,
  nowTime             : Extended;
  rendered            : boolean;
  delta               : Extended;
  Player_Command      : Byte;
  PlayersOnMap:Byte;
  BaseOffset:Byte;
  Obj:ObjectPack;
  RespFrame:Integer;
  ResHandle : THandle;

  BufPlayLen:Cardinal;

begin
    SoundPreapare(hwo);
    ResHandle := FindResource( HInstance, 'FX17', 'RAW');
    hRes17 :=    LoadResource( HInstance, ResHandle);
    ZeroMemory(@wh17, sizeof(WAVEHDR));
    wh17.lpData   := LockResource(hRes17); wh17.  dwBufferLength := SizeOfResource(hInstance, ResHandle);
    waveOutPrepareHeader(hwo, @wh17, sizeof(TWAVEHDR));  // подготовка буферов драйверо
    ResHandle :=   FindResource( HInstance, 'FX18', 'RAW');
    hRes18 :=      LoadResource( HInstance, ResHandle);

    ZeroMemory(@wh18, sizeof(WAVEHDR));
    wh18.lpData   := LockResource(hRes18); wh18.  dwBufferLength := SizeOfResource(hInstance, ResHandle);
    waveOutPrepareHeader(hwo, @wh18, sizeof(TWAVEHDR));  // подготовка буферов драйверо

    waveOutSetVolume(hwo, $FFFF);

  Max_Enemy := (High(EnemyRes[level])+1) * 2;
  mCurtain:= TCurtain.Create(DC);
  RenderInforms:=TRenderInform.Create(DC);
  mBooms    := TBoom.Create(DC);
  mShores   := TShores.Create(DC);
  mMaps     := TMaps.CreateMaps(DC,level,0,0);
  ColMaps:=TCollisionMap.Create(0);
  Bonuse:=TBonus.Create(DC);
  Bonuse.SetShores(mShores);
  RenderInforms.SetLengthPlay(Player_num);
  RenderInforms.SetLevels(Level);
  RenderInforms.SetMaxTank(Max_Enemy);
  PlayersOnMap:=Enemy_num + Player_num;
  setLength(PlayersObject, Player_num);
  setLength(Player, PlayersOnMap);
  ColMaps.SetLengthMap(PlayersOnMap-1);

  For K:=0 to PlayersOnMap-1 do begin
  Player[k] := TEnemy.Create(DC,$02,0,3, 4,13,0,0);
  Player[k].SetAlive(False);
  Player[k].SetMaps(mMaps);
  Player[k].SetIndex(K);
  Player[k].SetCollisionMap(ColMaps);
  Player[k].BoomMaps(mBooms);
  Player[k].ShoreMap(mShores);
  Player[k].SetBonus(Bonuse);
  Player[k].CollisionMapChange;
  end;

  For K:=Enemy_num to PlayersOnMap-1 do Player[k].ChangePlayer($00,(K - Enemy_num)+1);

  BaseOffset:=0; //Костыль для смещения индексов респауна если орел между ними
  RespownMaps:=TRespawn.Create(DC, Enemy_num, Max_Enemy,Player_num,level);
  RespownMaps.SetRenderInform(RenderInforms);
  RespFrame:=RespownMaps.RespawnFrame;

  for k := low(Player) to high(Player) do Player[k].setRespaunFrame(RespFrame);


  k:=0;
  Player_Command:=0;
  for l := 0 to high(mMaps.Heros) do begin
  if mMaps.Heros[l].ObjectType < $A then begin
  if mMaps.Heros[l].ObjectType = 0 then begin
  if Player_Command < Player_num  then begin
  k:=Enemy_num + Player_Command;
  inc(Player_Command);
  Player[k].SetPespawnPoint(l-BaseOffset);
  end;
  end;
  RespownMaps.AddRespawnPoint(mMaps.Heros[l].X,mMaps.Heros[l].Y,mMaps.Heros[l].ObjectType,Player_Command);
  end else begin
  if mMaps.Heros[l].ObjectType = $E then  begin
  inc(BaseOffset);
  K:=PlayersOnMap+BaseOffset-1;
  ColMaps.SetLengthMap(K);
  SetLength(Bases, BaseOffset);
  Bases[BaseOffset-1]:=TBase.Create(DC, mMaps.Heros[l].X*8, mMaps.Heros[l].Y*8);
  Bases[BaseOffset-1].SetCollisionMap(ColMaps);
  Bases[BaseOffset-1].SetBoomMap(mBooms);
  Bases[BaseOffset-1].SetMyIndex(K);
  Bases[BaseOffset-1].CollisionMapChange;
  mMaps.setCollisionMap(mMaps.Heros[l].X,mMaps.Heros[l].Y,$01);
  mMaps.setCollisionMap(mMaps.Heros[l].X+1,mMaps.Heros[l].Y,$01);
  mMaps.setCollisionMap(mMaps.Heros[l].X,mMaps.Heros[l].Y+1,$01);
  mMaps.setCollisionMap(mMaps.Heros[l].X+1,mMaps.Heros[l].Y+1,$01);
  mMaps.ArmorBases(mMaps.Heros[l].X,mMaps.Heros[l].Y,$0F);
  end;
  end;
  end;


  BasesCount:=BaseOffset;
  setLength(PlayersObject, Player_num+BasesCount);

  fps       := 0;
	upd       := 0;
	updl      := 0;
	counter   := 0;
	delta     := 0;
	lastTime  := GetNanoTime;
  ClockBonus:=false;
  ClockFrame:=0;
  status:=0;


	while running do begin
    nowTime         := GetNanoTime;
		elapsedTime     := nowTime - lastTime;
		lastTime        := nowTime;
		counter         := counter + elapsedTime;
		rendered        := false;
		delta           := delta + elapsedTime / UPDATE_INTERVAL;
		while delta > 1 do begin
      Update;
      inc(upd);
      delta := delta - 1;
      if rendered then inc(updl) else rendered := true;
		end;

    if rendered{ and (Total_Frame mod 4 =0) }then begin
      Render;
		  inc(fps);
    end;

		if (counter >= SECOND) then begin
			Total_FPS  := fps;
			Total_UPD  := upd;
			Total_UPDL := updl;
			upd        := 0;
			fps        := 0;
			updl       := 0;
			counter    := counter - SECOND;
		end;
	end;
  ThreadExit;
  running        :=  false;
end;

procedure TGameThread.Render;
var
i:integer;
begin
  ClearBuffer;
  if status = 0 then begin
  mMaps.Render(true, Total_Frame);
  for I := 0 to high(Bases) do Bases[i].Render(Total_Frame);
  mMaps.Render(false, Total_Frame);
  mCurtain.Render;
  end else
  if status = 2 then begin

  end else begin
  mMaps.Render(true, Total_Frame); //background
  for I := 0 to high(Player) do Player[i].Render(Total_Frame);
  for I := 0 to high(Bases)  do  Bases[i].Render(Total_Frame);
  for I := 0 to high(Player) do Player[i].BulletRender(Total_Frame);
  mMaps.Render(false, Total_Frame); //foreground
  mShores.Render(Total_Frame);
  RespownMaps.Render(Total_Frame);
  Bonuse.Render(Total_Frame);
  mBooms.Render(Total_Frame);
  RenderInforms.Render;
  end;
  UpdateTitle;
  SwapBuffers;
end;

procedure TGameThread.Update;
var
i,j,l,m:integer;
Bull,Bull2:TBulet;
r:Array [0..1] of results;
GetBasesCount:integer;
Pos:TPoint;
btn_pres:boolean;
begin
inc(Total_Frame);

if status = 0 then begin
if not mCurtain.Update(Total_frame) then begin
mCurtain.Destroy;
status:=1;
end;
exit;
end else
if status = 2 then begin
exit;
end;


if ClockBonus and (Total_Frame > ClockFrame) then ClockBonus:=false;
RespownMaps.Update(Total_Frame, Player);
mShores.Update(Total_Frame);
mBooms.Update(Total_Frame);
Bonuse.Update(Total_Frame);
j:=0;
for i := low(Bases) to High(Bases) do begin
Pos:=Bases[i].getPosition;
PlayersObject[j].X:=Pos.x;
PlayersObject[j].Y:=Pos.y;
PlayersObject[j].objectType:=$00;
PlayersObject[j].Alive:=Bases[i].isAlive;
PlayersObject[j].lock:=false;
inc(j);
end;
m:=j;
j:=0;
btn_pres:=false;
for I := 0 to high(Player) do begin
if Player[i].GetPlayer>0 then begin
Pos:=Player[i].getPosition;
PlayersObject[m].X:=Pos.x;
PlayersObject[m].Y:=Pos.y;
PlayersObject[m].objectType:=Player[i].GetPlayer;
PlayersObject[m].Alive:=Player[i].isAlive;
PlayersObject[m].Lock:=Player[i].GetLocked;
RenderInforms.SetLives(J,Player[i].GetLives);
inc(J);
inc(m);

if not btn_pres then begin
if Player[i].isAlive and Player[i].isGoing and not Player[i].GetLocked then btn_pres:=true;
end;

case Player[i].GetResultBonus of
$01: begin
        ClockBonus:=True;
        ClockFrame:=Player[i].GetResultBonusFrame;
     end;
$02: begin
        ArmorBaseBonus:=True;
        ArmorBaseFrame:=Player[i].GetResultBonusFrame;
        for l := low(Bases) to High(Bases) do mMaps.ArmorBases(Bases[l].X div 8,Bases[l].Y div 8,$10);
end;
$03: begin
     for l := 0 to high(Player) do begin
       if (Player[l].GetPlayer = 0) and Player[l].isAlive then Player[l].Destr(Total_Frame, true);
     end;
     end;
end;
end;

end;

if ArmorBaseBonus then begin
if Total_Frame > ArmorBaseFrame then
begin
ArmorBaseBonus:=false;
for j := low(Bases) to High(Bases) do mMaps.ArmorBases(Bases[j].X div 8,Bases[j].Y div 8,$0F);
end else begin
m := ArmorBaseFrame - Total_Frame;
case m of
240,480,720,960: for j := low(Bases) to High(Bases) do mMaps.ArmorBases(Bases[j].X div 8,Bases[j].Y div 8,$0F);
120,360,600,840: for j := low(Bases) to High(Bases) do mMaps.ArmorBases(Bases[j].X div 8,Bases[j].Y div 8,$10);   
end;
end;
end;



for I := 0 to high(Player) do begin
if Player[i].GetPlayer = 0 then Player[i].Lock(ClockBonus);
Player[i].Input(Total_Frame, PlayersObject);
end;
for I := 0 to high(Player) do begin
Player[i].GetResults(R);
for J := 0 to 1 do begin
Case R[j].ResultCode of
$01: Player[R[j].Attributes].ChangeStatus(-1 * R[j].Power, Total_Frame);
$02: Bases[(R[j] .Attributes)- (Enemy_num+Player_num)].ChangeStatus;
end;
end;
  for j := 0 to 1 do begin
    Bull:=Player[i].getBulet(j);
    if bull.getAlive then
      for l := i to high(Player) do begin
        for m := 0 to 1 do begin
        bull2:=Player[l].getBulet(m);
        if bull2.getAlive then
          if (Bull.getPosition.X>=Bull2.getPosition.X) and
             (Bull.getPosition.X<=Bull2.getPosition.X+4) and
              (Bull.getPosition.Y>=Bull2.getPosition.Y) and
              (Bull.getPosition.Y<=Bull2.getPosition.Y+4) then
          if Bull.GetTeams <> Bull2.GetTeams then begin
            Bull.CollisionBullet(Total_Frame);
            Bull2.CollisionBullet(Total_Frame);
          end;
        end;
      end;
  end;
end;
GetBasesCount:=0;
for j := low(Bases) to High(Bases) do if Bases[j].isAlive then inc(GetBasesCount);
if (GetBasesCount = 0) and (BasesCount > 0) then begin
//GameOver from bases
for I := 0 to high(Player) do begin
if Player[i].GetPlayer>0 then Player[i].Lock(True);
end;

end else begin
//if Total_Frame mod  16 = 0 then begin
if btn_pres then begin
waveOutWrite(hwo, @wh17, sizeof(WAVEHDR));
end else begin
waveOutWrite(hwo, @wh18, sizeof(WAVEHDR));
end;
//end;
end;

end;

procedure TGameThread.UpdateTitle;
Var
text:string;
begin
text:='FPS ' + IntToStr(Total_FPS) +
'   UPD ' + IntToStr(Total_UPD) + '   UPDL ' + IntToStr(Total_UPDL) +
'   FRAME ' + IntToStr(Total_Frame);
TextOut(DC,text,0,0);
end;

procedure TGameThread.StopThread;
begin
 running := false;
end;

procedure TGameThread.SwapBuffers;
begin
BitBLT(hDC,ClientRect.Left,ClientRect.Top,ClientRect.Right,ClientRect.Bottom,
    DC,0,0,$00CC0020);
ReleaseDC(hDC,HWND);
end;

procedure TGameThread.ThreadExit;
begin
DeleteObject(BufferedImage);
DeleteDC(DC);
DeleteDC(hDC);
  waveOutReset(hwo);
  waveOutUnprepareHeader(hwo, @wh17, sizeof(WAVEHDR));
  waveOutUnprepareHeader(hwo, @wh18, sizeof(WAVEHDR));
  WaveOutClose(hwo);
  UnlockResource(hRes17);
  UnlockResource(hRes18);
  FreeResource(hRes17);
  FreeResource(hRes18);
end;

procedure TGameThread.ClearBuffer;
begin
    FillRect(DC,ClientRect,ClearBrush);
end;

constructor TGameThread.Create(Handle:Thandle);
var
  Nm:Array[0..255] of Char;
  ObjectProc: procedure of object;
  ThreadHendle:LongWord;
begin
   HWND     := Handle;
   GetWindowText(HWND,nm,255);
   TITLE    := String(Nm);

   GetClientRect(HWND,ClientRect);

   hDC           := GetDC(GetDlgItem(HWND,1));
   DC            := CreateCompatibleDC(hDC);
   BufferedImage := CreateCompatibleBitmap(hDC,Width,Height);

   SelectObject(DC, BufferedImage);
   Pen:= CreatePen(0,1,$000000);
   ClearBrush:=CreateSolidBrush($000000);
   Player_num:= 2;
   Enemy_num :=40;
   Randomize;
   level:=random(8)+1;
   ObjectProc := Execute;
   ThreadHendle:=BeginThread(nil,0,TMethod(ObjectProc).Code,TMethod(ObjectProc).Data,0,ThreadID);
   running  := ThreadHendle <> 0;
end;

end.
