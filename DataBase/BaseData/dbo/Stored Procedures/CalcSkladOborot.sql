CREATE PROCEDURE dbo.CalcSkladOborot @SkladNo int, @nd1 datetime, @nd2 datetime
AS declare @rash bit
BEGIN

  create table #TempTable (ND datetime,TIM varchar(8),Oper int,Fam varchar(30),Plata money,Remark varchar(100),
                           Bank INT, OP INT, SkladNo int)

  Declare @CURSOR Cursor 
  set @CURSOR  = Cursor scroll
  for select * from #TempTable

  Declare @saldo money

  create table #ResTable (ND datetime,TIM varchar(8),Oper int,Fam varchar(30), Rashod money, Dohod money,Remark varchar(100),
                         Bank INT, OP INT, saldo1 money, saldo2 money, SkladNo int)
                       
  Declare @ND datetime,@TIM varchar(8),@Oper int,@Fam varchar(30),@Rashod money,@Dohod money, @Plata money,@Remark varchar(100),
          @Bank INT, @OP INT, @saldo1 money,@saldo2 money, @SkladNoTek int;


  set @saldo=isnull((select sum(k.plata) from kassa1 k where k.SkladNo=@SkladNo and k.nd<@nd1 and k.oper in (select ks.oper from KsOper ks where ks.rashflag = 1)),0)-
             isnull((select sum(k.plata) from kassa1 k where k.SkladNo=@SkladNo and k.nd<@nd1 and k.oper in (select ks.oper from KsOper ks where ks.rashflag = 0)),0)  
           
                         
  insert into #TempTable (ND, TIM, Oper, Fam, Plata, Remark, Bank, OP, SkladNo)                        

  select k.nd Data, k.tm TIM, k.Oper,k.fam Fam,k.Plata Plata, k.Remark Remark,
         k.Bank_id Bank, k.op OP, k.SkladNo
  from kassa1 k
  where k.nd >= @nd1 and k.nd < @nd2 and k.SkladNo = @SkladNo 

  union

  select i.ND Data, i.tm TIM, 0, 'Склад '+CAST(@SkladNo as varchar(2)), (i.Kol-i.NewKol)*i.Cost Plata,i.Remark Remark,
         0 Bank,i.Op OP, i.Sklad 
  from izmen i
  where i.Nd >= @nd1 and i.Nd < @nd2 and i.Sklad = @SkladNo and i.Act='Испр'
      
  order by 1,2
  
  open @CURSOR
  fetch next from @CURSOR into @ND, @TIM, @Oper, @Fam, @Plata, @Remark,
                               @Bank, @OP, @SkladNoTek
  set @saldo1=@saldo                
  
  if @Oper=0 
  begin
    set @saldo2=@saldo1+@Plata 
    if @Plata>0 
    begin
      set @Rashod=@Plata
      set @Dohod=0
    end
    else
    begin
      set @Rashod=0
      set @Dohod=-@Plata
    end
  end
  else
  begin
    set @rash=(select ks.rashflag from KsOper ks where ks.oper=@Oper)
    if @rash = 1 
    begin
      set @saldo2=@saldo1+@Plata
      set @Rashod=@Plata
      set @Dohod=0  
    end  
    else
    begin
      set @saldo2=@saldo1-@Plata 
      set @Rashod=0
      set @Dohod=@Plata
    end  
  end  
  /*Выполняем в цикле перебор строк*/
  while @@FETCH_STATUS = 0
  begin
    insert into #ResTable (ND,TIM,Oper,Fam,Rashod,Dohod,Remark,
                           Bank, OP, saldo1, saldo2, SkladNo)
                   values (@ND, @TIM, @Oper, @Fam, @Rashod, @Dohod, @Remark,
                           @Bank, @OP, @saldo1, @saldo2,@SkladNoTek)
  
    fetch next from @CURSOR into @ND, @TIM, @Oper, @Fam, @Plata, @Remark,
                                 @Bank, @OP, @SkladNoTek
    set @saldo1=@saldo2                                 
                
    if @Oper=0 
  begin
    set @saldo2=@saldo1+@Plata 
    if @Plata>0 
    begin
      set @Rashod=@Plata
      set @Dohod=0
    end
    else
    begin
      set @Rashod=0
      set @Dohod=-@Plata
    end
  end
  else
  begin
    set @rash=(select ks.rashflag from KsOper ks where ks.oper=@Oper)
    if @rash = 1 
    begin
      set @saldo2=@saldo1+@Plata
      set @Rashod=@Plata
      set @Dohod=0  
    end  
    else
    begin
      set @saldo2=@saldo1-@Plata 
      set @Rashod=0
      set @Dohod=@Plata
    end  
  end  
 
  end
  
  close @CURSOR
  
  select * from #ResTable 
END