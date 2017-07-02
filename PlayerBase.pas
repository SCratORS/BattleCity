unit PlayerBase;

interface

uses Windows, Resources, Utils, BoomAnim,CollisionMap;

  Type TBase = Class
    X,Y:integer;
    HDC: LongWord;
    BufferedImage:LongWord;
    PbyteArray:Pointer;
    mDC:LongWord;
    Alive:Boolean;
    GlobalBoomMaps:TBoom;
    GlobalCollisionMap:TCollisionMap;
    MyIndex:Integer;
  Public
  Function isAlive:Boolean;
  Constructor Create(DC:LongWord; PosX, PosY:Integer);OverLoad;
  Destructor Destroy;Override;
  Procedure  Update(Frame:integer);
  Procedure  Render(Frame:Integer);
  Procedure SetCollisionMap(CM:TCollisionMap);
  Procedure SetBoomMap(BM:TBoom);
  Procedure CollisionMapChange;
  Procedure SetMyIndex(i:Integer);
  Procedure ChangeStatus;
  Function GetPosition:TPoint;
  End;

implementation

{ TBase }

procedure TBase.ChangeStatus;
begin
if Alive then begin
Alive:=False;
GlobalBoomMaps.booms(X+4,Y,4);
GlobalCollisionMap.SetObject(MyIndex,X,Y,$FF,$02);
end;
end;

procedure TBase.CollisionMapChange;
begin
GlobalCollisionMap.SetObject(MyIndex,X,Y,$F0,$02);
end;

constructor TBase.Create(DC: LongWord; PosX, PosY: Integer);
begin
  HDC:=DC;
  BufferedImage :=CreateDIB(hDC,8,8,PbyteArray);
  mdc           :=CreateCompatibleDC(hDC);
  SelectObject(mdc, BufferedImage);
  ChangePallete(mdc, 0,0);
  Alive:=True;
  X:=PosX;
  Y:=PosY;
end;

destructor TBase.Destroy;
begin
  ReleaseDC(mDC,BufferedImage);
  DeleteDC(mDC);
  DeleteObject(BufferedImage);
  inherited;
end;

function TBase.GetPosition: TPoint;
begin
Result.x:=X;
Result.Y:=Y;
end;

function TBase.isAlive: Boolean;
begin
Result:=Alive;
end;

procedure TBase.Render(Frame: Integer);
var
Offset:byte;
begin
if Alive then Offset:=$C8 else Offset:=$CC;
Shtamps(HDC, mDC, PbyteArray,1,offset+$00,0,0,x,y,True,False);
Shtamps(HDC, mDC, PbyteArray,1,offset+$01,0,0,x,y+8,True,False);
Shtamps(HDC, mDC, PbyteArray,1,offset+$02,0,0,x+8,y,True,False);
Shtamps(HDC, mDC, PbyteArray,1,offset+$03,0,0,x+8,y+8,True,False);
end;

procedure TBase.SetBoomMap(BM: TBoom);
begin
GlobalBoomMaps:=bm;
end;

procedure TBase.SetCollisionMap(CM: TCollisionMap);
begin
GlobalCollisionMap:=CM;
end;

procedure TBase.SetMyIndex(i: Integer);
begin
MyIndex:=i;
end;

procedure TBase.Update(Frame: integer);
begin
  //ToDo
end;

end.
