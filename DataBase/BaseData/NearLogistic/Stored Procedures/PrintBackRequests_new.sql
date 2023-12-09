CREATE PROCEDURE NearLogistic.PrintBackRequests_new
@mhID int
AS
BEGIN
 set nocount on
  if object_id('tempdb..#backs') is not null drop table #backs
  select r.reqnum,
      r.ret_nd,
         d.pin,
         d.gpName [brName],
         d.gpAddr,
         fc.OurName,
         fc.OurADDR,
         n.name,
         iif(rd.fact_weight=0,'шт','кг') [units],
         sum(cast(iif(rd.fact_weight=0,rd.kol,rd.fact_weight) as decimal(12,3))) [kol],
         iif(rd.fact_weight=0,rd.tovprice,rd.tovprice / rd.fact_weight) [Price],
         sum(rd.tovprice*iif(n.flgWeight=0,rd.kol,1)) [sumPrice],
         max(v.sklad) sklad,
         v.srokh,
         rtr.Reason,
         '271'+right('000000000'+cast(r.reqnum as varchar),9) [barcode],
         p.fio [AgentFIO],
         p.phone [AgentPhone],
         r.comment,
         isnull(ot.printname,'') [printname],
         iif(a.depid=3,'Запросите два экземпляра возвратной накладной и счет-фактуру в торговой точке.','') [additional_remark]
  into #backs
 from NearLogistic.MarshRequests mr
  inner join dbo.ReqReturn r on r.reqnum=mr.ReqID
  inner join dbo.requests q on q.rk=r.reqnum
  inner join dbo.ReqReturnDet rd on rd.reqretid=r.reqnum
  inner join dbo.ReasonToRtrn rtr on rtr.Reason_Id=rd.ret_reason
  inner join dbo.nomen n on rd.hitag=n.hitag
  left join dbo.Visual v on v.id=rd.reftekid
  inner join dbo.def d on d.pin=iif(r.pin_from>0,r.pin_from,r.pin)
  inner join dbo.nc c on c.DatNom=rd.sourcedatnom
  inner join dbo.FirmsConfig fc on fc.Our_id=c.OurID
  join dbo.agentlist a on a.ag_id=mr.ag_id
  left join dbo.person p on p.p_id=a.p_id
  left join [MobAgents].OrderTypes ot on ot.otk=q.meta
  where mr.mhid=@mhID
     and mr.ReqType=1
        and rd.kol<>0
  group by r.reqnum,r.ret_nd,d.pin,d.gpName,d.gpAddr,fc.OurName,fc.OurADDR,n.name,
         iif(rd.fact_weight=0,'шт','кг'),iif(rd.fact_weight=0,rd.tovprice,rd.tovprice / rd.fact_weight),
         v.srokh,rtr.Reason,'271'+right('000000000'+cast(r.reqnum as varchar),9),mr.ReqOrder,p.fio,
         p.phone,r.comment,ot.printname,iif(a.depid=3,'Запросите два экземпляра возвратной накладной и счет-фактуру в торговой точке.','')
  
  
  select reqnum,ret_nd,pin,brName,gpAddr,OurName,OurADDR,name,units,kol,Price,sumPrice,sklad,srokh,Reason,barcode,AgentFIO,AgentPhone,cast(reqnum as varchar)+'0' [ord],comment,printname,[additional_remark] from #backs
  union all
  select reqnum,ret_nd,pin,brName,gpAddr,OurName,OurADDR,name,units,kol,Price,sumPrice,sklad,srokh,Reason,barcode,AgentFIO,AgentPhone,cast(reqnum as varchar)+'1' [ord],comment,printname,[additional_remark] from #backs
  order by Ord,  name 
 if object_id('tempdb..#backs') is not null drop table #backs
  set nocount off
END