CREATE PROCEDURE [NearLogistic].Export2BM_test 
@nd datetime, @plid int =1
as
begin
set nocount on
if object_id('tempdb..#dck') is not null drop table #dck
create table #dck(dck int, nst bit default 0)
create nonclustered index dck_idx on #dck(dck)

insert into #dck --рестория
select distinct dck,0 from dbo.defcontract where actual=1 and our_id in (select our_id from dbo.firmsconfig where firmgroup=10)

insert into #dck --Красное и белое
select distinct dck,1 from dbo.defcontract where actual=1 and pin in (
select pin from dbo.def where master in (45247,43363,41782,37008))
except select dck,1 from #dck

insert into #dck --логистика
select dck,0 from dbo.defcontract where dck in (32757,32772,35856,47958,45004,59136,67333,36896)
except select dck,0 from #dck

select c.datnom [nom], left(f.ouraddrfiz,50)[getaddr], f.posx [getxcoord], f.posy [getycoord], isnull(left(DefTo.gpname,50),'???') [putdescr], 
    isnull(left(DefTo.gpaddr,80),'???') [putaddr], DefTo.posx [putxcoord], DefTo.posy [putycoord],
       iif(try_convert(datetime,defto.tmpost) is null,'00:01',
       iif(convert(varchar,DefTo.tmPost,108)='24:00','00:01',convert(varchar,DefTo.tmPost,108))) [putend],       
       'База'[getdescr], 1 [priority], '' [doc], '1' [cartype], 'Авто' [carn], '' [getbeg], '' [getend], convert(varchar,'',108) [putbeg], 
       sum(v.cost*v.kol) [cost],
       sum(iif(n.flgweight=0,n.brutto*v.kol,s.weight)) [weight], 
       sum(iif(n.flgweight=0,(v.kol/iif(n.minp=0,1,n.minp))*n.volminp,(s.weight/iif(n.netto=0,1,n.netto))*n.volminp)) [volume]
from dbo.nc c 
join dbo.Def DefTo on DefTo.pin=iif(c.b_id2<>0 ,c.b_id2, c.b_id) 
join dbo.nv v with(index(nv_datnom_idx)) on c.datnom=v.datnom
join dbo.visual s on s.id=v.tekid
join dbo.nomen n on n.hitag=s.hitag
join dbo.inpdet i on i.id=s.startid
join dbo.comman co on co.ncom=i.ncom
join dbo.vendors ve on ve.ncod=co.ncod
join dbo.skladplace f on f.plid=@plid
where c.nd=@nd and c.sp>0 and c.marsh<200 and v.kol>0 
   and (exists(select 1 from #dck where dck=c.dck and nst=iif(ve.ncod=1665,1,nst)) or (ve.ncod=551) or (c.gpour_id=74402) or (c.gpour_id in (32757,32772,35856,47958,45004,59136,67333,36896))) --фильтры по договорам и Тарновскому и БА и Логистика     
group by c.datnom, left(f.ouraddrfiz,50), f.posx, f.posy, isnull(left(DefTo.gpname,50),'???'), isnull(left(DefTo.gpaddr,80),'???'),DefTo.posx, DefTo.posy,
         iif(try_convert(datetime,defto.tmpost) is null,'00:01',iif(convert(varchar,DefTo.tmPost,108)='24:00','00:01',convert(varchar,DefTo.tmPost,108)))       
       
if object_id('tempdb..#dck') is not null drop table #dck
set nocount off
end