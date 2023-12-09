CREATE PROCEDURE dbo.KsRashod @nd1 datetime,@nd2 datetime
AS
BEGIN

  create table #TempTable (Oper int, OperName varchar(100), RashFlag bit, Sm Money);
   
  if @nd1 < '20101202' 
  begin 
    insert into #TempTable (Oper,OperName,Rashflag,Sm)
    select o.Oper,o.OperName,o.RashFlag,isnull(sum(k.plata),0)
    from ksOper_old o left join kassa1 k on o.Oper=k.Oper and k.nd>=@nd1 and k.nd<=@nd2
    group by o.oper,o.OperName,o.RashFlag
    order by o.Oper
  end
  else
  begin
    insert into #TempTable (Oper,OperName,Rashflag,Sm)
    select o.Oper,o.OperName,o.RashFlag,isnull(sum(k.plata),0)
    from ksOper o left join kassa1 k on o.Oper=k.Oper and k.BankDay>=@nd1 and k.BankDay<=@nd2
    group by o.oper,o.OperName,o.RashFlag
    order by o.Oper
  end;
   
  Declare @Oper int, @OperName varchar(100), @RashFlag bit, @Sm Money, @Rashod money, @Dohod money 
  
  create table #ResTable (Oper int, OperName varchar(100), RashFlag bit, Rashod money, Dohod money);
  
  Declare @CURSOR Cursor 
  set @CURSOR  = Cursor scroll
  for select * from #TempTable
  /*Открываем курсор*/  
  open @CURSOR
  /*Выбираем первую строку*/
  fetch next from @CURSOR into @Oper, @OperName, @RashFlag, @Sm
  set @Rashod=0
  set @Dohod=0
  if @RashFlag = 0 set @Dohod=@Sm else set @Rashod=@Sm
  /*Выполняем в цикле перебор строк*/  
  while @@FETCH_STATUS = 0
  begin
    insert into #ResTable (Oper, OperName, RashFlag, Rashod, Dohod)
                   values (@Oper, @OperName, @RashFlag, @Rashod, @Dohod)
  
    fetch next from @CURSOR into @Oper, @OperName, @RashFlag, @Sm
    set @Rashod=0
    set @Dohod=0
    if @RashFlag = 0 set @Dohod=@Sm else set @Rashod=@Sm
  end
  
close @CURSOR
  
select * from #ResTable  
  
END