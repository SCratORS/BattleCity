unit CollisionMap;

interface

uses Utils;

type TCollisionMap = class
private
ObjectList: Array of ObjectPack;
public
constructor Create(ItemCount:Integer);Overload;
destructor Destroy;Override;
Function GetObjectTheam(X,Y:Integer; var teams:byte):integer;
Function GetObjectTypes(i:Integer):Byte;
Procedure SetObject(ItemIndex,X,Y:Integer; Theam,Types:Byte);
Procedure SetLengthMap(NewLength:Integer);
Function GetObject(i:Integer):ObjectPack;
end;


implementation

{ TCollisionMap }

constructor TCollisionMap.Create(ItemCount: Integer);
begin
SetLengTh(ObjectList, ItemCount);
end;

destructor TCollisionMap.Destroy;
begin

  inherited;
end;

function TCollisionMap.GetObject(i: Integer): ObjectPack;
begin
Result:=ObjectList[i];
end;

function TCollisionMap.GetObjectTheam(X, Y: Integer; var teams:byte): integer;
var
i:integer;
begin
Result:=-1;
teams:=255;
for i:=low(ObjectList) to high(ObjectList) do begin
 if (X>=ObjectList[i].X) and (X<ObjectList[i].X+16) and
   (Y>=ObjectList[i].Y) and (Y<ObjectList[i].Y+16) then begin
    teams:=ObjectList[i].Theam;
    result:=i;
    exit;
   end;
end;
end;

function TCollisionMap.GetObjectTypes(i: Integer): Byte;
begin
Result:= ObjectList[i].types;
end;

procedure TCollisionMap.SetLengthMap(NewLength: Integer);
begin
SetLengTh(ObjectList, NewLength+1);
end;

procedure TCollisionMap.SetObject(ItemIndex, X, Y: Integer; Theam, Types: Byte);
begin
ObjectList[ItemIndex].X:=X;
ObjectList[ItemIndex].Y:=Y;
ObjectList[ItemIndex].Theam:=Theam;
ObjectList[ItemIndex].types:=Types;
end;

end.
