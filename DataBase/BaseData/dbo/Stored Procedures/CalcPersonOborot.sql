CREATE PROCEDURE dbo.CalcPersonOborot @p_id int, @StNom int, @nd1 datetime, @nd2 datetime, @StID int=0
AS declare @rash bit
BEGIN

create table #TempTable (ND datetime,TIM varchar(8),Oper int,Fam varchar(40),Plata money,Remark varchar(200),
                         Bank INT, OP INT, stNom int)

Declare @CURSOR Cursor 
set @CURSOR  = Cursor scroll
for select * from #TempTable order by Nd,TIM

Declare @saldo money

create table #ResTable (ND datetime,TIM varchar(8),Oper int,Fam varchar(40), Rashod money, Dohod money,Remark varchar(200),
                         Bank INT, OP INT, saldo1 money, saldo2 money, stID int)
                       
Declare @ND datetime,@TIM varchar(8),@Oper int,@Fam varchar(40),@Rashod money,@Dohod money, @Plata money,@Remark varchar(200),
                         @Bank INT, @OP INT, @saldo1 money,@saldo2 money, @stNomTek int;


if @StID <> 0  
begin

  set @saldo=isnull((select sum(round(k.plata/(1+k.nalog/100),2)) from kassa1 k where k.StNom-k.StNom/100*100=@StID and k.nd<@nd1 and k.oper=59),0)-
             isnull((select sum(round(k.plata/(1+k.nalog/100),2)) from kassa1 k where k.StNom-k.StNom/100*100=@StID and k.nd<@nd1 and k.oper=10),0)  
           
                         
  insert into #TempTable (ND, TIM, Oper, Fam, Plata, Remark, Bank, OP, stNom)                        

  select k.nd Data, k.tm TIM, k.Oper,left(k.fam,30) Fam, round(k.plata/(1+k.nalog/100),2) Plata, left(k.Remark,200) +isnull(' Дов. №'+ d.DovNom+' от '+ convert(char(10),d.NDBeg,104)+'г.','') as  Remark,
         k.Bank_id Bank, k.op OP, k.stNom
  from kassa1 k left join Dover d on k.OrigRecn=d.DovID
  where k.StNom-k.StNom/100*100=@StID and k.nd >= @nd1 and k.nd <= @nd2 and (k.oper=59 or k.oper=10)
  --and k.oper = -1
  --group by k.nd,k.bank_id,k.op
 
  /*union

  select i.ND Data, max(i.tm) TIM, null Plata, max(i.Remark) Remark,
  Null sumcost, Null izmen, null corr, sum(i.smi) remove,
  null bank, null My, null nomdok,i.op OP, null mid, 1 aid
  from izmen i
  where i.ncod = @ncod and i.Nd >= @date1 and i.Nd < @date2
      and i.Act='Снят' and i.smi<>0*/
  order by 1,2
  
  open @CURSOR
  fetch next from @CURSOR into @ND, @TIM, @Oper, @Fam, @Plata, @Remark,
                               @Bank, @OP, @stNomTek
  set @saldo1=@saldo                
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
  /*Выполняем в цикле перебор строк*/
  while @@FETCH_STATUS = 0
  begin
    insert into #ResTable (ND,TIM,Oper,Fam,Rashod,Dohod,Remark,
                           Bank, OP, saldo1, saldo2, stID)
                   values (@ND, @TIM, @Oper, @Fam, @Rashod, @Dohod, @Remark,
                           @Bank, @OP, @saldo1, @saldo2,@StNomTek-@p_id*100)
  
    fetch next from @CURSOR into @ND, @TIM, @Oper, @Fam, @Plata, @Remark,
                                 @Bank, @OP, @StNomTek
    set @saldo1=@saldo2                                 
                
    set @rash = (select ks.rashflag from KsOper ks where ks.oper=@Oper)
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
  
  close @CURSOR
  
  select * from #ResTable  order by ND, TIM
end
else

if @StNom = 0  
begin

  set @saldo=isnull((select sum(round(k.plata/(1+k.nalog/100),2)) from kassa1 k where k.p_id=@p_id and k.nd<@nd1 and k.oper=59 /*in (select ks.oper from KsOper ks where ks.rashflag = 1)*/),0)-
             isnull((select sum(round(k.plata/(1+k.nalog/100),2)) from kassa1 k where k.p_id=@p_id and k.nd<@nd1 and k.oper=10 /*in (select ks.oper from KsOper ks where ks.rashflag = 0)*/),0)  
           
                         
  insert into #TempTable (ND, TIM, Oper, Fam, Plata, Remark, Bank, OP, stNom)                        

  select k.nd Data, k.tm TIM, k.Oper,left(k.fam,30) Fam, round(k.plata/(1+k.nalog/100),2) Plata, left(k.Remark,200) Remark,
         k.Bank_id Bank, k.op OP, k.stNom
  from kassa1 k 
              -- join person p on k.p_id=p.p_id
  where k.p_id = @p_id and k.nd >= @nd1 and k.nd <= @nd2 and (k.oper=59 or k.oper=10)
--        and p.our_id in (select our_id from firmsconfig where firmgroup=10)
  --and k.oper = -1
  --group by k.nd,k.bank_id,k.op
 
  /*union

  select i.ND Data, max(i.tm) TIM, null Plata, max(i.Remark) Remark,
  Null sumcost, Null izmen, null corr, sum(i.smi) remove,
  null bank, null My, null nomdok,i.op OP, null mid, 1 aid
  from izmen i
  where i.ncod = @ncod and i.Nd >= @date1 and i.Nd < @date2
      and i.Act='Снят' and i.smi<>0*/
  order by 1,2
  
  open @CURSOR
  fetch next from @CURSOR into @ND, @TIM, @Oper, @Fam, @Plata, @Remark,
                               @Bank, @OP, @stNomTek
  set @saldo1=@saldo                
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
  /*Выполняем в цикле перебор строк*/
  while @@FETCH_STATUS = 0
  begin
    insert into #ResTable (ND,TIM,Oper,Fam,Rashod,Dohod,Remark,
                           Bank, OP, saldo1, saldo2, stID)
                   values (@ND, @TIM, @Oper, @Fam, @Rashod, @Dohod, @Remark,
                           @Bank, @OP, @saldo1, @saldo2,@StNomTek-@p_id*100)
  
    fetch next from @CURSOR into @ND, @TIM, @Oper, @Fam, @Plata, @Remark,
                                 @Bank, @OP, @StNomTek
    set @saldo1=@saldo2                                 
                
    set @rash = (select ks.rashflag from KsOper ks where ks.oper=@Oper)
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
  
  close @CURSOR
  
  select * from #ResTable  order by ND, TIM
end
else
begin
  
  set @saldo=isnull((select sum(round(k.plata/(1+k.nalog/100),2)) from kassa1 k where k.StNom=@StNom and k.nd<@nd1 and k.oper=59/* in (select ks.oper from KsOper ks where ks.rashflag = 1)*/),0)-
             isnull((select sum(round(k.plata/(1+k.nalog/100),2)) from kassa1 k where k.StNom=@StNom and k.nd<@nd1 and k.oper=10/* in (select ks.oper from KsOper ks where ks.rashflag = 0)*/),0)  
                    
  insert into #TempTable (ND, TIM, Oper, Fam, Plata, Remark, Bank, OP)                        

  select k.nd Data, k.tm TIM, k.Oper,k.fam Fam,round(k.plata/(1+k.nalog/100),2) Plata, left(k.Remark,200) +isnull(' Дов. №'+ d.DovNom+' от '+ convert(char(10),d.NDBeg,104)+'г.','') as Remark,
         k.Bank_id Bank, k.op OP
  from kassa1 k left join Dover d on k.OrigRecn=d.DovID
  where k.StNom = @StNom and k.nd >= @nd1 and k.nd <= @nd2 and (k.oper=59 or k.oper=10)
  order by 1,2
  
  open @CURSOR
 
  fetch next from @CURSOR into @ND, @TIM, @Oper, @Fam, @Plata, @Remark,
                               @Bank, @OP,@StNomTek
  set @saldo1=@saldo                
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
  while @@FETCH_STATUS = 0
  begin
    insert into #ResTable (ND,TIM,Oper,Fam,Rashod,Dohod,Remark,
                           Bank, OP, saldo1, saldo2,stID)
                   values (@ND, @TIM, @Oper, @Fam, @Rashod, @Dohod, @Remark,
                           @Bank, @OP, @saldo1, @saldo2,@StNom-@P_ID*100)
  
    fetch next from @CURSOR into @ND, @TIM, @Oper, @Fam, @Plata, @Remark,
                                 @Bank, @OP,@StNomTek
    set @saldo1=@saldo2                                 
                  
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
  
  close @CURSOR
  
  select * from #ResTable order by Nd,tim
end                          

END