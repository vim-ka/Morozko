create procedure dbo.FindDivideErr @nd datetime, @Hitag int, @Sklad int
as
declare @IzmID int, @StartIzmId int, @Act varchar(4), @ID int, @Kol int, @NewKol int, 
  @Weight0 decimal(10,3), @Weight1 decimal(10,3),
  @Weight decimal(10,3), @NewWeight decimal(10,3), @OrigWeight decimal(10,3)
begin
  set TRANSACTION ISOLATION LEVEL READ COMMITTED
  create table #t(izmid int, OrigWeight decimal(10,3), NewWeight decimal(10,3));

  declare c1 cursor fast_forward for 
    select izmid, act, id, kol, newkol, weight, NewWeight
    from izmen where nd=@nd and sklad=@sklad and Hitag=@Hitag and act like 'div%'
    order by izmid;
  open c1;
  FETCH from c1 into @IzmID,@Act,@ID, @Kol, @NewKol, @Weight0, @Weight1;
  while @@fetch_status=0 begin
    set @StartIzmId=@IzmId;
    set @OrigWeight=@kol*@Weight0;

    FETCH from c1 into @IzmID,@Act,@ID, @Kol, @NewKol, @Weight0, @Weight1;
    set @NewWeight=@NewKol*@Weight1;

    FETCH from c1 into @IzmID,@Act,@ID, @Kol, @NewKol, @Weight0, @Weight1;
    set @NewWeight=@NewWeight+@NewKol*@Weight1;

    insert into #t values(@StartIzmId, @OrigWeight, @NewWeight);
    FETCH from c1 into @IzmID,@Act,@ID, @Kol, @NewKol, @Weight0, @Weight1;
  END
  CLOSE c1;
  deallocate c1;
  select * from #t; -- where OrigWeight<>NewWeight;
  select sum(OrigWeight), sum(NewWeight) from #t;

end