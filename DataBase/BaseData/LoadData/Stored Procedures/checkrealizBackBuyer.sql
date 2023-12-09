﻿CREATE procedure LoadData.checkrealizBackBuyer
@nd1 datetime,
@nd2 datetime, 
@Our_ID int,
@pin int,
@dck int=0,
@flgGroup bit=0

with recompile
as
begin
  set nocount on
  if object_id('tempdb..#nc_list') is not null drop table #nc_list
  create table #nc_list (real_datnom int, datnom int, nd datetime, tm char(8), b_id int, stfnom varchar(17), stfdate datetime, extra decimal(6,2));
  create nonclustered index nc_list_idx on #nc_list(datnom)
  create nonclustered index nc_list_idx1 on #nc_list(real_datnom)

  declare @datnom1 int
  declare @datnom2 int
  set @datnom1=dbo.indatnom(0,@nd1)
  set @datnom2=dbo.indatnom(9999,@nd2)

  insert into #nc_list(real_datnom, datnom, nd, tm, b_id, stfnom, stfdate, extra)
  select nc.datnom, nc.datnom, nc.nd, nc.tm, iif(isnull(d.master,0)=0,d.upin,m.upin), nc.docnom, nc.docdate, nc.extra
  from 
    dbo.nc 
    inner join dbo.def d on d.pin=nc.b_id
	  left join dbo.def m on m.pin=d.master
  where 
    nc.datnom>=@datnom1 
    and nc.datnom<=@datnom2
    and nc.OurID=@Our_ID 
  	and nc.Actn<>1 
    and nc.b_id in (select pin from def where master=@pin or pin=@pin)
    and nc.Frizer=0 and nc.Tara=0 and nc.STip not in (2,3,4)
    and (nc.sp<0 and nc.remark<>'')
  
  --  insert into #nc_list
  --  select c.datnom,c.datnom,c.nd,c.tm,iif(isnull(d.master,0)=0,d.upin,m.upin),c.stfnom,c.stfdate,c.extra 
  --  from dbo.nc c
  --  join dbo.def d on d.pin=c.b_id
  --	left join dbo.def m on m.pin=d.master
  --  where c.datnom between @datnom1 and @datnom2
  --  			and c.ourid=@our_id and c.Sp>0 and c.Actn<>1 
  --       	and c.Frizer<>1 and c.Tara<>1 and c.STip not in (2,3,4)
  --        
  --	insert into #nc_list (real_datnom,datnom)        
  --  select datnom, refdatnom
  --  from dbo.nc 
  --  where refdatnom in (select datnom from #nc_list)
  --  			and sp>0



 --обновление данных по добивкам 
  update a set a.nd=b.nd,a.tm=b.tm,a.b_id=b.b_id,a.stfnom=b.stfnom,a.stfdate=b.stfdate,a.extra=b.extra 
  from #nc_list a join (select * from #nc_list where datnom=real_datnom) b on b.datnom=a.datnom
  where a.real_datnom<>a.datnom
  
  --группировка в одну накладную
  if @flgGroup = 0 
  select c.datnom [vk],
         c.stfnom,
         c.stfdate,
         sum(v.price*v.kol*(1+(c.extra/100.0))) [sm]
  from #nc_list c
  join dbo.nv v with(nolock, index(nv_datnom_idx)) on v.datnom=c.real_datnom
  join dbo.visual s on s.id=v.tekid
  join dbo.nomen n on n.hitag=v.hitag
  group by c.datnom,c.stfnom, c.stfdate
  order by vk
  else
  select c.datnom [vk],
         '' as stfnom,
         '' as stfdate,
         sum(v.price*v.kol*(1+(c.extra/100.0))) [sm]
  from #nc_list c
  join dbo.nv v with(nolock, index(nv_datnom_idx)) on v.datnom=c.real_datnom
  join dbo.visual s on s.id=v.tekid
  join dbo.nomen n on n.hitag=v.hitag
  group by c.datnom
  order by vk
  
  
  
  
  if object_id('tempdb..#nc_list') is not null drop table #nc_list
  set nocount off
end