CREATE PROCEDURE dbo.CalcVendOborotSmall @pin int, @date1 datetime, @date2 datetime
AS 
BEGIN
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED; 
Declare @saldo money
set @saldo=isnull((select sum(c2.summacost + c2.izmen + c2.remove + c2.corr) from comman c2 where c2.pin=@pin and c2.date<@date1),0) -
isnull((select sum(k2.plata) from kassa1 k2 where k2.pin=@pin and oper=-1 and k2.nd<@date1),0) 

create table #TempTable (ND datetime,TIM varchar(8),Plata money,Remark varchar(100),SumCost money,Izmen money,
                         Corr money, Remove money, Bank INT, My int,nomdok varchar(10),
                         OP INT, mid int, aid smallint)
insert into #TempTable (ND,TIM,Plata,Remark,SumCost,Izmen,Corr,Remove,Bank,My,nomdok,
                        OP,mid,aid)                        

select k.nd Data, max(k.tm) TIM, sum(k.Plata) Plata, max(k.Remark) Remark,
       null sumcost, null izmen, null corr, null remove,
       k.Bank_id bank, null My, null nomdok,k.op OP, max(k.kassid) mid, 0 aid
from kassa1 k
where k.pin = @pin and k.nd >= @date1 and k.nd < @date2
      and k.oper = -1
group by k.nd,k.bank_id,k.op

union

select c.date Data, c.time TIM, null Plata, 'Приход - срок конс. '+convert(varchar(4),srok)+' дней' Remark,
       c.summacost sumcost, c.izmen izmen, c.corr corr, c.remove remove,
       null bank, our_id My, c.doc_nom nomdok, c.op OP, c.ncom mid, 1 aid
from comman c
where c.pin = @pin and c.date >= @date1 and c.date < @date2
order by 1,2,12

create table #ResTable (ND datetime,TIM varchar(8),Plata money,Remark varchar(100),SumCost money,Izmen money,
                         Corr money, Remove money, Bank INT, My int,nomdok varchar(10),
                         OP INT, mid int, aid smallint,saldo1 money,saldo2 money)
                         
Declare @ND datetime,@TIM varchar(8),@Plata money,@Remark varchar(100),@SumCost money,@Izmen money,
        @Corr money, @Remove money, @Bank INT, @My int,@nomdok varchar(10),
        @OP INT, @mid int, @aid smallint,@saldo1 money,@saldo2 money;
       
  /*Объявляем курсор*/
Declare @CURSOR cursor 
set @CURSOR  = cursor scroll
for select * from #TempTable
  /*Открываем курсор*/
open @CURSOR
  /*Выбираем первую строку*/
fetch next from @CURSOR into @ND,@TIM,@Plata,@Remark,@SumCost,@Izmen,
                @Corr, @Remove, @Bank, @My,@nomdok,@OP,@mid,@aid
set @saldo1=@saldo                
if (@SumCost is not null) set @saldo2=@saldo1+@SumCost+@Izmen+@Remove+@Corr
else if (@Plata is not null) set @saldo2=@saldo1-@Plata            
  
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
                  
  if (@SumCost is not null) set @saldo2=@saldo1+@SumCost+@Izmen+@Remove+@Corr
  else if (@Plata is not null) set @saldo2=@saldo1-@Plata            
     
end
  
close @CURSOR
  
select * from #ResTable                           

END