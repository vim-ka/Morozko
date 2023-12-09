
create procedure AddTaraInput @ND datetime, @Ncom int, @Ncod int,
  @TarID tinyint, @Kol INT
as
declare @SavedQty int
begin
  set @SavedQty=(select Kol from TaraMove where Act=1 and ND=@ND and Ncom=@Ncom and TarId=@TarID);
  if (@SavedQty is null)
    insert into TaraMove(Act, ND,Ncom,Ncod,TarID,Kol) values(1, @ND,@Ncom,@Ncod,@TarID,@Kol);
  else if (@SavedQty<>@Kol)
    update TaraMove set Kol=@Kol where Act=1 and ND=@ND and Ncom=@Ncom and TarId=@TarID;
end;