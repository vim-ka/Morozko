CREATE PROCEDURE [ELoadMenager].Eload_FirmPeriodOborotNDS
@dt1 datetime,
@dt2 datetime,
@our_id int
AS
BEGIN
set nocount on
declare @dt datetime
declare @dat1 int
declare @dat2 int
       
create table #res (id int identity(1,1) not null,
									 period varchar(20) not null,
                   pin int,
                   pinName varchar(100),
                   NDS int,
                   dt datetime,
                   datnom1 int,
                   datnom2 int,
                   sPrice decimal(12,2) not null default 0,
                   sCost decimal(12,2) not null default 0,
                   sVal decimal(12,2) not null default 0)
                   
set @dt=@dt1
while @dt<=@dt2
begin
	if not exists(select 1 from #res where month(dt)=month(@dt) and year(dt)=year(@dt))
  begin
  	set @dat1=dbo.indatnom(0,@dt)
    set @dat2=dbo.indatnom(9999,iif(@dt2<eomonth(@dt),@dt2,eomonth(@dt)))
    
    insert into #res(dt,
    								 period,
                     datnom1,
                     datnom2,
                     pin,
                     pinName,
                     NDS) 
    select @dt,
    			 datename(month,@dt)+' '+cast(year(@dt) as varchar),
           @dat1,
           @dat2,
           d.pin,
           d.brName,
           n.nds
    from nc c
    inner join def d on d.pin=c.b_id
    inner join (select 10 as nds union select 18 union select -1) as n on 1=1
    where c.datnom between @dat1 and @dat2
    			and c.stip <> 4
      		and c.OurID=@our_id
          and c.nd<>'20160101'
     group by d.pin,d.brName,n.nds
   end 
   set @dt=dateadd(day,1,@dt)
end

insert into #res(dt,
                 period,
                 datnom1,
                 datnom2,
                 pin,
                 pinName,
                 NDS)
                 
select null,
			 'Итого за период',
       dbo.indatnom(0,@dt1),
       dbo.indatnom(9999,@dt2),
       pin,
       pinName,
       -1
from #res 
group by pin,pinName

insert into #res(dt,
                 period,
                 datnom1,
                 datnom2,
                 pin,
                 pinName,
                 NDS)
                 
select null,
			 'Итого за период',
       dbo.indatnom(0,@dt1),
       dbo.indatnom(9999,@dt2),
       -1,
       'Итого по фирме',
       n.nds
from (select 10 as nds union select 18 union select -1) n

create nonclustered index idx_resdatnom1 on #res(datnom1)
create nonclustered index idx_resdatnom2 on #res(datnom2)
create nonclustered index idx_resdatnom1datnom2 on #res(datnom1,datnom2)
create nonclustered index idx_resNDS on #res(NDS)
create nonclustered index idx_respin on #res(pin)

select c.datnom,
			 c.b_id pin,
       n.nds,
       sum((v.kol*v.price)*(1.0+c.Extra/100.0)) [sp],
       sum(v.kol*v.cost) [sc]       
into #tmpNCNV 
from nc c
inner join nv v on c.datnom=v.datnom 
inner join nomen n on n.hitag=v.hitag
--inner join gr on gr.ngrp=n.ngrp
where c.stip <> 4
      and c.OurID=@our_id
      and n.nds in (10,18)
      and c.nd<>'20160101'
      and c.datnom between dbo.indatnom(0,@dt1) and dbo.indatnom(9999,@dt2)
      --and gr.AgInvis=0
group by c.datnom,c.b_id,n.nds       
      
create nonclustered index idx_tmpNCNVdatnom on #tmpNCNV(datnom)
create nonclustered index idx_tmpNCNVpin on #tmpNCNV(pin)
create nonclustered index idx_tmpNCNVNDS on #tmpNCNV(nds)

update #res set sPrice=isnull(
											 (select sum(isnull(c.sp,0))
											  from #tmpNCNV c 
											  where c.datnom between #res.datnom1 and #res.datnom2
                        			and c.NDS=iif(#res.NDS=-1,c.nds,#res.NDS)
                              and c.pin=iif(#res.pin=-1,c.pin,#res.pin)),0),
			 					sCost=isnull(
                			( select sum(isnull(c.sc,0))
											  from #tmpNCNV c 
											  where c.datnom between #res.datnom1 and #res.datnom2
                        			and c.NDS=iif(#res.NDS=-1,c.nds,#res.NDS)
                              and c.pin=iif(#res.pin=-1,c.pin,#res.pin)),0),
       					sVal=isnull(
                		 (  select sum(c.sp-c.sc)
											  from #tmpNCNV c 
											  where c.datnom between #res.datnom1 and #res.datnom2
                        			and c.NDS=iif(#res.NDS=-1,c.nds,#res.NDS)
                              and c.pin=iif(#res.pin=-1,c.pin,#res.pin)),0)

select period [Период],
			 pin [Код клиента],
       pinName [Наименование клиента],
       NDS [Ставка НДС],
			 sPrice [Выручка],
       sCost [Стоимость закупки],
       sVal [Валовая прибыль],
       cast(iif(sPrice=0,0,(sVal * 100.0 / sPrice)) as decimal(12,2)) [Процент наценки]
from #res
order by iif(pin=-1,999999,pin),
				 iif(dt is null,getdate(),dt),
				 iif(NDS=-1,100,nds)
drop table #res
drop table #tmpNCNV
set nocount off
END