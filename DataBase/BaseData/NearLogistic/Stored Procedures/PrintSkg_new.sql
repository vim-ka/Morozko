CREATE PROCEDURE [NearLogistic].PrintSkg_new 
@mhid int
AS
BEGIN
declare @nd datetime
declare @marsh int

select @nd=nd, @marsh=marsh from dbo.marsh where mhid=@mhid

if object_id('tempdb..#tmp') is not null drop table #tmp
select * into #tmp from 
(   
      select v.sklad
      from dbo.nv v with (index(nv_datnom_idx)) 
      join nearlogistic.marshrequests mr on mr.reqid=v.datnom and mr.reqtype=0
      where mr.mhid=@mhid and v.kol>0
      union 
      select v.sklad
      from dbo.nv v with (index(nv_datnom_idx)) 
      join dbo.nc c on c.datnom=v.datnom
      join nearlogistic.marshrequests mr on mr.reqid=c.refdatnom and mr.reqtype=0
      where mr.mhid=@mhid and v.kol>0 
) x

select distinct 
    @mhid [mhid],
       sg.Skg,
    sg.SkgName,
       @ND [nd],
       @Marsh [marsh],
    cast('013'+format(@nd,'ddMMyy')+right('00'+cast(@marsh as varchar),3)+iif(len(cast(sg.skg as varchar))>2,'00',right('0'+cast(sg.skg as varchar),2)) as varchar(14)) [barcode],
       0 [ord]
from  #tmp v
/*[NearLogistic].MarshRequests mr 
join NC c on mr.ReqID=c.DatNom and mr.ReqType=0 
join NV v on c.datnom=v.datnom*/
join SkladList sl on v.Sklad=sl.SkladNo
join SkladGroups sg on sg.skg=sl.skg
--where mr.mhid=@mhid

union all

select distinct 
    @mhid [mhid],
       sg.Skg,
    sg.SkgName,
       @ND,
       @Marsh,
    cast('013'+format(@nd,'ddMMyy')+right('00'+cast(@marsh as varchar),3)+iif(len(cast(sg.skg as varchar))>2,'00',right('0'+cast(sg.skg as varchar),2)) as varchar(14)) [barcode],
       1 [ord]
from [NearLogistic].MarshRequests mr
join dbo.frizrequestinvnom i on mr.ReqID=i.frizreqid
join dbo.frizer z on z.nom=i.frizernom
join SkladList sl on z.SkladNo=sl.SkladNo
join SkladGroups sg on sg.skg=sl.skg
where mr.mhid=@mhid  
      and mr.ReqAction=1     
      and mr.ReqType=2

order by ord,Skg
if object_id('tempdb..#tmp') is not null drop table #tmp
END