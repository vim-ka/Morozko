CREATE PROCEDURE dbo.CalcVendOborot @pin int, @date1 datetime, @date2 datetime, @DCK int=0
AS 
BEGIN
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED; 
Declare @saldo money
create table #TempTable (ND datetime,TIM varchar(8),Plata money,Remark varchar(100),SumCost money,Izmen money,
                         Corr money, Remove money, Bank INT, My int,nomdok varchar(30),
                         OP INT, mid int, aid smallint)
                         
create table #ResTable (ND datetime,TIM varchar(8),Plata money,Remark varchar(100),SumCost money,Izmen money,
                         Corr money, Remove money, Bank INT, My int,nomdok varchar(30),
                         OP INT, mid int, aid smallint,saldo1 money,saldo2 money)
                         
Declare @ND datetime,@TIM varchar(8),@Plata money,@Remark varchar(100),@SumCost money,@Izmen money,
        @Corr money, @Remove money, @Bank INT, @My int,@nomdok varchar(10),
        @OP INT, @mid int, @aid smallint,@saldo1 money,@saldo2 money;
       
                         

if @DCK=0 
begin

set @saldo=isnull((select sum(c2.summacost) from comman c2 where c2.pin=@pin and c2.date<@date1),0) 
           +isnull((select sum(cc2.corr) from commancorr cc2, comman c2 where cc2.ncom=c2.ncom and c2.pin=@pin and cc2.nd<@date1),0) 
           -isnull((select sum(k2.plata) from kassa1 k2 where k2.pin=@pin and oper=-1 and k2.nd<@date1),0)
           +isnull((select sum(i2.smi) from izmen i2 where i2.pin=@pin and (i2.Act='Снят' or i2.Act='ИзмЦ') and i2.nd<@date1),0)


insert into #TempTable (ND,TIM,Plata,Remark,SumCost,Izmen,Corr,Remove,Bank,My,nomdok,
                        OP,mid,aid)                        

select k.nd Data, max(k.tm) TIM, sum(k.Plata) Plata, k.Remark Remark,
null sumcost, null izmen, null corr, null remove,
k.Bank_id bank, null My, null nomdok,k.op OP, max(k.kassid) mid, 3 aid
from kassa1 k
where k.pin = @pin and k.nd >= @date1 and k.nd < @date2
      and k.oper = -1
group by k.nd,k.bank_id,k.op,k.Remark

union

select c.date Data, c.time TIM, null Plata, 'Приход - срок конс. '+convert(varchar(4),srok)+' дней' Remark,
c.summacost sumcost, null izmen, null corr, null remove,
null bank, our_id My, c.doc_nom nomdok,c.op OP, c.ncom mid, 4 aid
from comman c
where c.pin = @pin and c.date >= @date1 and c.date < @date2

union

select cast(floor(cast(cc.nd as decimal(38,19))) as datetime) Data, convert(varchar(8),cc.nd,108) TIM, null Plata,cc.Remark,
Null sumcost, null izmen, cc.corr corr, null remove,
null bank, null My, null nomdok,cc.op OP, cc.ncom mid, 2 aid
from commancorr cc,comman cm
where cc.ncom=cm.ncom and cm.pin = @pin and cc.Nd >= @date1 and cc.Nd < @date2

union

select i.ND Data, max(i.tm) TIM, null Plata, i.Remark Remark,
Null sumcost, Null izmen, null corr, sum(i.smi) remove,
null bank, null My, null nomdok,i.op OP, null mid, 1 aid
from izmen i
where i.pin = @pin and i.Nd >= @date1 and i.Nd < @date2
      and i.Act='Снят' and i.smi<>0
group by i.ND,i.OP,i.Remark

union

select i.ND Data, max(i.tm) TIM, null Plata, i.Remark Remark,
Null sumcost, sum(i.smi) izmen, null corr, null remove,
null bank, null My, null nomdok,i.op OP, null mid, 0 aid
from izmen i
where i.pin = @pin and i.Nd >= @date1 and i.Nd < @date2
      and i.Act='ИзмЦ' and i.smi<>0
group by i.ND,i.OP, i.Remark
order by 1,2,14

Declare @CURSOR Cursor 
set @CURSOR  = Cursor FORWARD_ONLY
for select * from #TempTable order by ND
 /*Открываем курсор*/
open @CURSOR
 /*Выбираем первую строку*/
fetch next from @CURSOR into @ND,@TIM,@Plata,@Remark,@SumCost,@Izmen,
                  @Corr, @Remove, @Bank, @My,@nomdok,@OP,@mid,@aid
set @saldo1=@saldo                
if (@SumCost is not null) set @saldo2=@saldo1+@SumCost
else if (@Plata is not null) set @saldo2=@saldo1-@Plata 
else if (@Remove is not null) set @saldo2=@saldo1+@Remove            
else if (@Izmen is not null) set @saldo2=@saldo1+@Izmen            
else if (@Corr is not null) set @saldo2=@saldo1+@Corr                       

 /*Выполняем в цикле перебор строк*/
while @@FETCH_STATUS = 0
begin
  insert into #ResTable (ND,TIM,Plata,Remark,SumCost,Izmen,
                         Corr, Remove, Bank, My,nomdok,
                         OP, mid, aid,saldo1,saldo2)
                 values (@ND,@TIM,@Plata,@Remark,@SumCost,@Izmen,
                         @Corr, @Remove, @Bank, @My,@nomdok,
                         @OP, @mid, @aid,@saldo1,@saldo2)
  
  fetch next from @CURSOR into @ND,@TIM,@Plata,@Remark,@SumCost,@Izmen,
                                  @Corr, @Remove, @Bank, @My,@nomdok,@OP,@mid,@aid
  set @saldo1=@saldo2                                 
                  
  if (@SumCost is not null) set @saldo2=@saldo1+@SumCost
  else if (@Plata is not null) set @saldo2=@saldo1-@Plata 
  else if (@Remove is not null) set @saldo2=@saldo1+@Remove            
  else if (@Izmen is not null) set @saldo2=@saldo1+@Izmen            
  else if (@Corr is not null) set @saldo2=@saldo1+@Corr
end
  
close @CURSOR
  
select * from #ResTable order by ND                          
end

else

begin


set @saldo=isnull((select sum(c2.summacost) from comman c2 where c2.pin=@pin and c2.dck=@dck and c2.date<@date1),0) 
           +isnull((select sum(cc2.corr) from commancorr cc2, comman c2 where cc2.ncom=c2.ncom and c2.pin=@pin and c2.dck=@dck and cc2.nd<@date1),0) 
           -isnull((select sum(k2.plata) from kassa1 k2 where k2.pin=@pin and k2.dck=@dck and oper=-1 and k2.nd<@date1),0)
           +isnull((select sum(i2.smi) from izmen i2 where i2.pin=@pin and i2.dck=@dck and (i2.Act='Снят' or i2.Act='ИзмЦ') and i2.nd<@date1),0)

insert into #TempTable (ND,TIM,Plata,Remark,SumCost,Izmen,Corr,Remove,Bank,My,nomdok,
                        OP,mid,aid)                        

select k.nd Data, max(k.tm) TIM, sum(k.Plata) Plata, max(k.Remark) Remark,
null sumcost, null izmen, null corr, null remove,
k.Bank_id bank, null My, null nomdok,k.op OP, max(k.kassid) mid, 3 aid
from kassa1 k
where k.pin = @pin and k.dck = @dck and k.nd >= @date1 and k.nd < @date2
      and k.oper = -1
group by k.nd,k.bank_id,k.op

union

select c.date Data, c.time TIM, null Plata, 'Приход - срок конс. '+convert(varchar(4),srok)+' дней' Remark,
c.summacost sumcost, null izmen, null corr, null remove,
null bank, our_id My, c.doc_nom nomdok,c.op OP, c.ncom mid, 4 aid
from comman c
where c.pin = @pin and c.dck = @dck and c.date >= @date1 and c.date < @date2

union

select cast(floor(cast(cc.nd as decimal(38,19))) as datetime) Data, convert(varchar(8),cc.nd,108) TIM, null Plata,cc.Remark,
Null sumcost, null izmen, cc.corr corr, null remove,
null bank, null My, null nomdok,cc.op OP, cc.ncom mid, 2 aid
from commancorr cc,comman cm
where cc.ncom=cm.ncom and cm.pin = @pin and cm.dck = @dck and cc.Nd >= @date1 and cc.Nd < @date2

union

select i.ND Data, max(i.tm) TIM, null Plata, i.Remark Remark,
Null sumcost, Null izmen, null corr, sum(i.smi) remove,
null bank, null My, null nomdok,i.op OP, null mid, 1 aid
from izmen i
where i.pin = @pin and i.dck = @dck and i.Nd >= @date1 and i.Nd < @date2
      and i.Act='Снят' and i.smi<>0
group by i.ND,i.OP, i.remark

union

select i.ND Data, max(i.tm) TIM, null Plata, i.Remark Remark,
Null sumcost, sum(i.smi) izmen, null corr, null remove,
null bank, null My, null nomdok,i.op OP, null mid, 0 aid
from izmen i
where i.pin = @pin and i.dck = @dck and i.Nd >= @date1 and i.Nd < @date2
      and i.Act='ИзмЦ' and i.smi<>0
group by i.ND,i.OP, i.Remark
order by 1,2,14

set @CURSOR  = Cursor scroll
for select * from #TempTable order by ND
 /*Открываем курсор*/
open @CURSOR
 /*Выбираем первую строку*/
fetch next from @CURSOR into @ND,@TIM,@Plata,@Remark,@SumCost,@Izmen,
                  @Corr, @Remove, @Bank, @My,@nomdok,@OP,@mid,@aid
set @saldo1=@saldo                
if (@SumCost is not null) set @saldo2=@saldo1+@SumCost
else if (@Plata is not null) set @saldo2=@saldo1-@Plata 
else if (@Remove is not null) set @saldo2=@saldo1+@Remove            
else if (@Izmen is not null) set @saldo2=@saldo1+@Izmen            
else if (@Corr is not null) set @saldo2=@saldo1+@Corr                       

 /*Выполняем в цикле перебор строк*/
while @@FETCH_STATUS = 0
begin
  insert into #ResTable (ND,TIM,Plata,Remark,SumCost,Izmen,
                         Corr, Remove, Bank, My,nomdok,
                         OP, mid, aid,saldo1,saldo2)
                 values (@ND,@TIM,@Plata,@Remark,@SumCost,@Izmen,
                         @Corr, @Remove, @Bank, @My,@nomdok,
                         @OP, @mid, @aid,@saldo1,@saldo2)
  
  fetch next from @CURSOR into @ND,@TIM,@Plata,@Remark,@SumCost,@Izmen,
                                  @Corr, @Remove, @Bank, @My,@nomdok,@OP,@mid,@aid
  set @saldo1=@saldo2                                 
                  
  if (@SumCost is not null) set @saldo2=@saldo1+@SumCost
  else if (@Plata is not null) set @saldo2=@saldo1-@Plata 
  else if (@Remove is not null) set @saldo2=@saldo1+@Remove            
  else if (@Izmen is not null) set @saldo2=@saldo1+@Izmen            
  else if (@Corr is not null) set @saldo2=@saldo1+@Corr
end
  
close @CURSOR
  
select * from #ResTable  order by ND 


end

END