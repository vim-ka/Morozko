CREATE PROCEDURE NearLogistic.PrintBackRequests_same
@reqnum int
AS
BEGIN
 set nocount on
  
  select r.reqnum,
      r.ret_nd,
         d.pin,
         d.brName,
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
         cast(r.reqnum as varchar)+'1' [ord],
         isnull(ot.printname,'') [printname]
         
  from dbo.ReqReturn r 
  inner join dbo.requests q on r.reqnum=q.ParentRk
  inner join dbo.ReqReturnDet rd on rd.reqretid=r.reqnum
  inner join dbo.ReasonToRtrn rtr on rtr.Reason_Id=rd.ret_reason
  inner join dbo.nomen n on rd.hitag=n.hitag
  left join dbo.Visual v on v.id=rd.reftekid
  inner join dbo.def d on d.pin=iif(r.pin_from>0,r.pin_from,r.pin)
  inner join dbo.nc c on c.DatNom=rd.sourcedatnom
  inner join dbo.FirmsConfig fc on fc.Our_id=c.OurID
  join dbo.agentlist a on a.ag_id=q.ag_id
  join dbo.person p on p.p_id=a.p_id
  left join [MobAgents].OrderTypes ot on ot.otk=q.meta
  where r.reqnum=@reqnum
        and rd.kol<>0
  group by  r.reqnum,
        r.ret_nd,
           d.pin,
           d.brName,
            d.gpAddr,
            fc.OurName,
            fc.OurADDR,
            n.name,
            iif(rd.fact_weight=0,'шт','кг'),
            iif(rd.fact_weight=0,rd.tovprice,rd.tovprice / rd.fact_weight),
            v.srokh,
            rtr.Reason,
            '271'+right('000000000'+cast(r.reqnum as varchar),9),
            p.fio,
            p.phone,
            r.comment,
        isnull(ot.printname,'') 
  set nocount off
END