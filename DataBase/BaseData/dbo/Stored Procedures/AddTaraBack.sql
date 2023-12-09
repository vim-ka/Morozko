create procedure AddTaraBack @ND datetime, @Ncod int, @TarID tinyint, @Kol INT
as
declare @SavedQty int
begin
  set @SavedQty=(select Kol from TaraMove where Act=2 and ND=@ND and TarId=@TarID);
  if (@SavedQty is null)
    insert into TaraMove(Act, ND,Ncod,TarID,Kol) values(2, @ND, @Ncod,@TarID,@Kol);
  else if (@SavedQty<>@Kol)
    update TaraMove set Kol=@Kol where Act=2 and ND=@ND and TarId=@TarID;
end;