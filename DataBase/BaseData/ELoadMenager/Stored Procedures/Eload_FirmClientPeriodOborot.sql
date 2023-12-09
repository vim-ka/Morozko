CREATE PROCEDURE ELoadMenager.Eload_FirmClientPeriodOborot
@dt1 datetime,
@dt2 datetime,
@our_ids varchar(200),
@provod bit
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
                     NDS,
                     nal,
                     our_id)
    select @dt,
           datename(month,@dt)+' '+cast(year(@dt) as varchar),
           @dat1,
           @dat2,
           iif(dnet.pin>0,dnet.pin, d.pin),
           iif(dnet.pin>0,dnet.brName, d.brName), 
           n.nds,
           iif((dc.BnFlag=1 or dc.NeedCK=1),1,0),
           dc.Our_ID
    from  def d left join def dnet on d.master=dnet.pin
                join (select 10 as nds union select 18) as n on 1=1
                join defcontract dc on dc.pin=d.pin and dc.ContrTip=2
                join #firms f on f.our_id=dc.Our_ID
                left join nc c on dc.dck=c.dck and c.datnom between @dat1 and @dat2 and c.stip <> 4
     group by iif(dnet.pin>0,dnet.pin, d.pin),iif(dnet.pin>0,dnet.brName, d.brName),n.nds, iif((dc.BnFlag=1 or dc.NeedCK=1),1,0),dc.Our_ID
   end 
   set @dt=dateadd(day,1,@dt)
end


create nonclustered index idx_resdatnom1 on #res(datnom1)
create nonclustered index idx_resdatnom2 on #res(datnom2)
create nonclustered index idx_resdatnom1datnom2 on #res(datnom1,datnom2)
create nonclustered index idx_resNDS on #res(NDS)
create nonclustered index idx_respin on #res(pin)
create nonclustered index idx_resOurID on #res(our_id)

select c.datnom,
       iif(dnet.pin>0,dnet.pin, d.pin) pin,
       n.nds,
       sum((v.kol*v.price)*(1.0+c.Extra/100.0)) [sp],
       sum(v.kol*v.cost) [sc],
       c.OurID,
       iif((dc.BnFlag=1 or dc.NeedCK=1),1,0) nal      
into #tmpNCNV 
from nc c
left join def d on d.pin=c.b_id
left join def dnet on d.master=dnet.pin
inner join nv v on c.datnom=v.datnom 
inner join nomen n on n.hitag=v.hitag
inner join #firms f on f.our_id=c.OurID
inner join defcontract dc on dc.dck=c.dck
where c.stip <> 4
      and n.nds in (10,18)
      and c.nd<>'20160101'
      and c.datnom between dbo.indatnom(0,@dt1) and dbo.indatnom(9999,@dt2)
      --and gr.AgInvis=0
group by c.datnom,c.b_id,n.nds,c.OurID,iif((dc.BnFlag=1 or dc.NeedCK=1),1,0), d.pin, dnet.pin, dnet.master       
      
create nonclustered index idx_tmpNCNVdatnom on #tmpNCNV(datnom)
create nonclustered index idx_tmpNCNVpin on #tmpNCNV(pin)
create nonclustered index idx_tmpNCNVNDS on #tmpNCNV(nds)

update #res set sPrice=isnull(
											 (select sum(isnull(c.sp,0))
											  from #tmpNCNV c 
											  where c.datnom between #res.datnom1 and #res.datnom2
                        			and c.NDS=iif(#res.NDS=-1,c.nds,#res.NDS)
                              and c.pin=iif(#res.pin=-1,c.pin,#res.pin)
                              and #res.nal=c.nal),0),
			 					sCost=isnull(
                			( select sum(isnull(c.sc,0))
											  from #tmpNCNV c 
											  where c.datnom between #res.datnom1 and #res.datnom2
                        			and c.NDS=iif(#res.NDS=-1,c.nds,#res.NDS)
                              and c.pin=iif(#res.pin=-1,c.pin,#res.pin)
                              and #res.nal=c.nal),0),
       					sVal=isnull(
                		 (  select sum(c.sp-c.sc)
											  from #tmpNCNV c 
											  where c.datnom between #res.datnom1 and #res.datnom2
                        			and c.NDS=iif(#res.NDS=-1,c.nds,#res.NDS)
                              and c.pin=iif(#res.pin=-1,c.pin,#res.pin)
                              and #res.nal=c.nal),0)

select n1.period [Период],
       n1.our_id [Код фирмы],
       n1.OurName [Наименование фирмы],
       n1.pin [Код],
       n1.pinName [Наименование],
       n1.nal [Проводной],
       n1.sPrice [Продажа, руб.],
       n1.sCost [Стоимость закупки, руб.]
from
(select period ,
       #res.our_id,
       ff.OurName,
       #res.pin,
       #res.pinName,
	   nal,
       sum(sPrice) as sPrice,
       sum(sCost) as sCost,
       sum(sVal) as sVal,
       cast(iif(sum(sPrice)=0,0,(sum(sVal) * 100.0 / sum(sPrice))) as decimal(12,2)) as sNac
from #res
inner join FirmsConfig ff on ff.Our_id=#res.our_id
where #res.nal=@provod
group by period,#res.our_id,ff.OurName,nal,dt, #res.pin, #res.pinName
) n1
where n1.sPrice<>0 
 order by 1,2,4
        
drop table #firms
drop table #res
drop table #tmpNCNV
set nocount off
END