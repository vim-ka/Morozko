CREATE PROCEDURE NearLogistic.FillReqInfo
@reqs varchar(max)
AS
BEGIN
  if object_id('tempdb..#reqlist') is not null drop table #reqlist
  create table #reqlist (id int, type int, act int)
  declare @ttable varchar(50) 
  set @ttable='##'+host_name()+'_reqlist'
  declare @sql varchar(max)
  set @sql=''
  set @sql='if object_id(''tempdb..'+@ttable+''') is not null drop table '+@ttable+' '
  set @sql=@sql+' exec nearlogistic.gettablefromstrings '''+@reqs+''',''reqid;reqtype;act'','';'',''#'','''+@ttable+''''
  set @sql=@sql+' insert into #reqlist select cast(id as int),cast(type as int),cast(act as int) from '+@ttable+' '
  set @sql=@sql+' drop table '+@ttable+' '
  exec(@sql)
  
 
 select * into #tmp 
  from (
  select r.reqid,
       r.ReqType,
         c.sp [cost],
         isnull(sum((n.volminp / n.minp)*v.kol),0) [volume],
         isnull(sum(iif(n.flgweight=0,n.netto,/*iif(c.datnom>=dbo.indatnom(0,getdate()),*/isnull(t.weight,s.weight))*v.kol),0) [weight],
         isnull(sum(ceiling(v.kol/iif(isnull(n.minp,0)=0,1,n.minp))),0) [kolbox]
  from dbo.nc c 
  inner join #reqlist r on r.reqid=c.datnom
  inner join dbo.nv v on c.datnom=v.datnom
  inner join dbo.nomen n on n.hitag=v.hitag
  left join dbo.tdvi t on t.id=v.tekid
  left join dbo.visual s on s.id=v.tekid 
  where r.reqtype=0
  group by r.ReqID,c.sp,r.ReqType
  
  union
  
  select r1.reqid,
       r1.ReqType,
         0,
         isnull(sum((n.volminp / n.minp)*d.kol),0),
         isnull(sum(d.fact_weight),0),
         isnull(count(distinct d.hitag),0)
  from dbo.reqreturn r  
  inner join dbo.requests q on q.rk=r.reqnum
  inner join dbo.reqreturndet d on r.reqnum=d.reqretid
  inner join dbo.nomen n on n.hitag=d.hitag
  inner join #reqlist r1 on r1.reqid=r.reqnum
  where r1.reqtype=1
 group by r1.ReqID,r1.ReqType
  
  union
  
  select r.reqid,
       r.ReqType,
         0,
         isnull(sum((z.ob / 1000)*1.2),0),
         isnull(sum(z.weight),0),
         isnull(count(distinct f.rcmplxid),0)
  from frizrequest f
  inner join #reqlist r on r.reqid=f.rcmplxid
  inner join frizrequestinvnom i on i.frizreqid=f.rcmplxid
  inner join frizer z on z.nom=i.frizernom  
  where r.ReqType=2
  group by r.ReqID,r.ReqType
  
  union
  
  select r.reqid,
       r.ReqType,
         mbr.sumpay,
         0.001,
         0.001,
         1
  from nearlogistic.moneybackrequest mbr 
  inner join #reqlist r on r.reqid=mbr.mbrid
  where r.reqtype=3
  
  union 
  
  select r.reqid,
       r.ReqType,
         mf.cost,
         mf.volume,
         mf.weight,
         mf.kolbox
  from NearLogistic.MarshRequests_free mf
  inner join #reqlist r on r.reqid=mf.mrfID
  where r.reqtype=-2
  ) x
END