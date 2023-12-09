CREATE PROCEDURE ELoadMenager.Eload_ZakupNDS
@dt1 datetime,
@dt2 datetime,
@our_ids varchar(200)
AS
BEGIN
set nocount on
declare @dt datetime
declare @dat1 int
declare @dat2 int

create table #firms (our_id int)

insert into #firms
select distinct number
from dbo.String_to_Int(@our_ids,',',1)

create nonclustered index idx_firmsOurID on #firms(our_id)
       
create table #res (id int identity(1,1) not null,
									 period varchar(20) not null,
                   pin int,
                   pinName varchar(100),
                   dck int,
                   dckName varchar(100),
                   NDS int,
                   nal bit,
                   our_id int,
                   dt datetime,
                   sCost decimal(12,2) not null default 0
                   )
                   
set @dt=@dt1
while @dt<=@dt2
begin
	if not exists(select 1 from #res where month(dt)=month(@dt) and year(dt)=year(@dt))
  begin
    
    insert into #res(dt,
    				 period,
                     pin,
                     pinName,
                     NDS,
                     nal,
                     our_id)
    select @dt,
           datename(month,@dt)+' '+cast(year(@dt) as varchar),
           d.pin,
           d.brName, 
           n.nds,
           iif((dc.BnFlag=1 or dc.NeedCK=1),0,1),
           c.Our_ID
    from comman c
    inner join def d on d.pin=c.pin
    inner join (select 10 as nds union select 18) as n on 1=1
    inner join #firms f on f.our_id=c.Our_ID
    inner join defcontract dc on dc.dck=c.dck
    where c.date=@dt and dc.contrtip = 1
    group by d.pin,d.brName,n.nds, iif((dc.BnFlag=1 or dc.NeedCK=1),0,1),c.Our_ID
   end 
   set @dt=dateadd(day,1,@dt)
end

create nonclustered index idx_resNDS on #res(NDS)
create nonclustered index idx_respin on #res(pin)
create nonclustered index idx_resOurID on #res(our_id)

select c.ncom,
       c.pin,
       n.nds,
       sum(v.summacost) [sc],
       c.Our_ID,
       iif((dc.BnFlag=1 or dc.NeedCK=1),0,1) nal      
into #tmpNCNV 
from comman c
inner join inpdet v on c.ncom=v.ncom
inner join nomen n on n.hitag=v.hitag
inner join #firms f on f.our_id=c.Our_ID
inner join defcontract dc on dc.dck=c.dck
where dc.contrtip = 1 
      and n.nds in (10,18)
      and c.date between @dt1 and @dt2
      --and gr.AgInvis=0
group by c.ncom,c.pin,n.nds,c.Our_ID,iif((dc.BnFlag=1 or dc.NeedCK=1),0,1)      
      
create nonclustered index idx_tmpNCNVpin on #tmpNCNV(pin)
create nonclustered index idx_tmpNCNVNDS on #tmpNCNV(nds)

update #res set  sCost=isnull(
                			( select sum(isnull(c.sc,0))
											  from #tmpNCNV c 
                        			where c.NDS=iif(#res.NDS=-1,c.nds,#res.NDS)
                              and c.pin=iif(#res.pin=-1,c.pin,#res.pin)
                              and #res.nal=c.nal),0)

select n1.period [Период],
       n1.our_id [Код фирмы],
       n1.OurName [Наименование фирмы],
       n1.pin [Код],
       n1.pinName [Наименование],
       n1.nal [Наличный],
       n1.sCost [Стоимость закупки, НДС10%],
       n2.sCost [Стоимость закупки, НДС18%]
from
(select period ,
   	  #res.our_id,
       ff.OurName,
       #res.pin,
       #res.pinName,
       #res.NDS,
	   nal,
       sum(sCost) as sCost
from #res
inner join FirmsConfig ff on ff.Our_id=#res.our_id
where #res.NDS=10
group by period,#res.our_id,ff.OurName,#res.NDS,nal,dt, #res.pin, #res.pinName
) n1

inner join          
         
(select period,
        #res.our_id,
        ff.OurName,
        #res.pin,
        #res.pinName,
        #res.NDS,
	    nal,
        sum(sCost) as sCost
from #res
inner join FirmsConfig ff on ff.Our_id=#res.our_id
where #res.NDS=18
group by period,#res.our_id,ff.OurName,#res.NDS,nal,dt, #res.pin, #res.pinName
 ) n2 on n1.period=n2.period and n1.pin=n2.pin and n1.nal=n2.nal
 order by 1,2,4
    	 

         
         
         
         
drop table #firms
drop table #res
drop table #tmpNCNV
set nocount off
END