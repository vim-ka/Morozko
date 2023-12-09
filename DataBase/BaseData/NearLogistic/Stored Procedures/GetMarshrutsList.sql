CREATE PROCEDURE NearLogistic.GetMarshrutsList
@nd datetime, @type int=0, @other bit =0, @trans bit =0
as
begin
	set nocount on	 
  if @nd is null set @nd=convert(varchar,getdate(),104) 
  if object_id('tempdb..#mh') is not null drop table #mh  
  create table #mh (mhID int, w decimal(15,2) not null default 0)  
  if @type=1  
  begin
    insert into #mh (mhID,w)
    select m.mhID, isnull(m.weight,0) from dbo.marsh m
    where not m.MStatus in (4,5) and m.nd>=dateadd(month,-3,getdate()) and m.VedNo=0 and m.ListNo=0
          and m.SelfShip=0 and not m.Marsh in (0,99) and m.DelivCancel=0
  end
  else
  begin
  	insert into #mh (mhID,w)
    select m.mhid,isnull(m.weight,0) from dbo.marsh m
    where m.nd=@nd and m.mstatus>=iif(@type=2,2,0)
          and m.mstatus<iif(@type=2,5,99) and not m.marsh in (0,99)
  end
    
  create nonclustered index idx_#mhID on #mh(mhID)
  
  alter table #mh add isDone bit not null default 0,
  										isVet bit not null default 0,
                      isNCCancel bit not null default 0,
                      isNVCancel bit not null default 0,
                      cost_1kg money not null default 0,
                      avg_1dot_kg decimal(15,2) not null default 0,
                      cost003 decimal(15,2) not null default 0;
	
  update a set a.isdone=isnull(b.isdone,0),
  						 a.isvet=isnull(b.isvet,0),
               a.isnccancel=isnull(b.isnccancel,0),
               a.isnvcancel=isnull(b.isnvcancel,0)
  from #mh a
  left join (  
  select x.[mhid], 
  			 max(x.[isDone]) [isDone],
         max(x.[isVet]) [isVet],
         max(x.[isNCCancel]) [isNCCancel],
         max(x.[isNVCancel]) [isNVCancel]
  from (
  select dbo.nc.mhid,
  			 dbo.nc.DatNom,
         cast(dbo.nc.done as int) [isDone],
         iif((dbo.nc.SertifDoc & 16 <>0),1,0) [isVet],
         cast(dbo.nc.DelivCancel as int) [isNCCancel],
         --cast(dbo.nv.DelivCancel as int) [isNVCancel]
         0 [isNVCancel]
  from dbo.nc 
  left join dbo.nv with (index(nv_datnom_idx)) on dbo.nc.datnom=dbo.nv.datnom
  join #mh on #mh.mhid=dbo.nc.mhid     ) x
  group by x.[mhid]) b on b.mhid=a.mhid
  
  --/*
  if @other=1
  update a set a.cost_1kg=iif(a.w=0,0,NearLogistic.Marsh1CalcFact(a.mhid, 1, 0.0) / a.w),
  						 a.avg_1dot_kg=b.[avg_w],
               a.cost003=b.[cost003]
  from #mh a
  join (
  	select x.mhid, avg(x.wei) [avg_w], sum(x.[cost003]) [cost003] from (
  	select r.mhid,r.pinto,sum(r.weight_) [wei],sum(r.Cost_) * 0.03 [cost003]
    from NearLogistic.MarshRequests r 
    join #mh on #mh.mhid=r.mhid
    where r.reqtype=0
    group by r.mhid,r.pinto) x
    group by x.mhid
  ) b on b.mhid=a.mhid
  --*/
 
  select m.mhid,m.direction [dir],m.drID,m.SpedDrID,m.v_id,m.v_idtr,m.calcdist,m.dopWeight,
  			 m.marsh,m.Peni,
         --ISNULL(m.VetPay,0) AS VetPay, ISNULL(m.WayPay,0) AS WayPay, 
         m.VetPay, m.WayPay,
         m.Km0,m.Km1,m.Dist,m.PriorityFlag,
         isnull(m.direction,'')+iif(@type<>1,char(13)+char(10)+rs.RegName,'') [direction],
         m.mstatus,n.msName [statusname],
         isnull(v.model,'--')+' '+isnull(v.regnom,'--') [vehname],
         isnull(c.crname,'--')+': '+isnull(c.phone,'--') [carname],
         isnull(d.fio,'--')+': '+isnull(d.phone,'--') [drname],
         isnull(d1.fio,'--')+': '+isnull(d1.phone,'--') [spedname],
         v.limitweight,
         cast(isnull(m.weight,0) as decimal(15,1)) [mweight],
         isnull(cast(isnull(v.limitweight,0)-isnull(m.weight,0) as decimal(10,2)),0) [leftweight],
         isnull(cast(isnull(v.Volum,0)-isnull(m.Volume,0) as decimal(10,2)),0) [leftvolume],
         isnull(m.dots,0) [dots],
         iif(exists(select 1 from dbo.marshjob j where j.mhid=m.mhid),cast(1 as bit),cast(0 as bit)) [isjob],
         m.SelfShip,v.crid,m.DelivCancel,m.nlTariffParamsIDDrv,m.nlTariffParamsIDSpd,m.nd,
         m.VedNo,m.ListNo,m.ScanND,m.Earnings,isnull(t.TariffName,'<..>') [TariffName],m.TimePlan,
         #mh.isVet,#mh.isDone,#mh.isNCCancel,#mh.isNVCancel,m.plid,#mh.cost_1kg,#mh.avg_1dot_kg,#mh.cost003,
         m.parent_mhid,
         --список плательщиков с весом
         (SELECT DISTINCT STUFF((select DISTINCT ' ' + CHAR(10) --', ' 
                                + IIF(mr.ReqType=-2, ISNULL(mc.ShortName,''), 
                                IIF(nc.STip = 4, d.shortfam, fc.OurName)) + ' ' 
                                + IIF(mr.ReqType=-2,                                       
                                      CAST(CAST(ROUND(SUM(ISNULL(mrf.weight,0)),1) AS DECIMAL(15,1)) AS VARCHAR),                                      
                                      CAST(CAST(ROUND(SUM(ISNULL(mr.Weight_,0)),1) AS DECIMAL(15,1)) AS VARCHAR))
            FROM NearLogistic.MarshRequests mr 
            LEFT JOIN NearLogistic.MarshRequests_free mrf ON mr.mhID = mrf.mhID AND mr.ReqID = mrf.mrfID                                                       
            LEFT JOIN NearLogistic.marshrequests_cashers mc ON mc.casher_id = mrf.pin
            LEFT JOIN nc ON mr.ReqID = nc.DatNom AND mr.ReqType <> -2
            LEFT JOIN FirmsConfig fc ON nc.OurID = fc.Our_id
            LEFT JOIN DefContract dc ON dc.DCK = IIF(nc.stip<>4, NC.DCK, nc.gpOur_ID)   --IIF(nc.stip<>4, NC.DCK = dc.DCK, nc.gpOur_ID = dc.DCK)
            LEFT JOIN def d ON dc.pin = d.pin
           WHERE mr.mrID IN(SELECT DISTINCT mr1.mrID
                              FROM NearLogistic.MarshRequests mr1
                             WHERE mr1.mhID = m.mhid) 
           GROUP BY --ISNULL(mc.casher_name,'')
                    mr.ReqType, mc.ShortName,
                    IIF(mr.ReqType=-2, ISNULL(mc.ShortName,''), 
                        IIF(nc.STip = 4, d.shortfam, fc.OurName))
                    --IIF(mr.ReqType=-2, ISNULL(mc.ShortName,''), fc.OurName), 
                    --IIF(nc.STip = 4, d.brName, fc.OurName)
                    --nc.STip, nc.dck, nc.gpOur_ID, d.brName
               for xml path(''))
              ,1,2,'')
         ) AS cashers              
  from dbo.marsh m
  inner join #mh on m.mhid=#mh.mhID
  left join dbo.drivers d on d.drid=m.drid
  left join dbo.vehicle v on v.v_id=m.v_id
  left join dbo.drivers d1 on d1.drid=m.speddrid
  left join dbo.carriers c on c.crid=v.crid
  left join nearlogistic.marshstatus n on n.msID=m.mstatus 
  left join NearLogistic.GetRegsString(@nd) rs on rs.mhid=m.mhid
  left join NearLogistic.nlTariffsDet td on td.nlTariffParamsID=m.nlTariffParamsIDDrv
  left join NearLogistic.nlTariffs t on t.nlTariffsID=td.nlTariffsID
  where ((m.parent_mhid>0 and @trans=1)or(m.parent_mhid=0 and @trans=0))
  order by iif(@trans=0,0,m.parent_mhid),m.[marsh] 

  drop table #mh
	set nocount off
end