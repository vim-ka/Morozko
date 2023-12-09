CREATE PROCEDURE ELoadMenager.Eload_DotsWithoutPos
AS
BEGIN
  select sp.fio [Супервайзер], 
         p.fio [Агент], 
         d.pin [Код точки],
         d.gpName [Наименование], 
         case when isnull(d.dstAddr,'')='' then d.gpAddr else d.dstAddr end [Адрес]
  from def d 
  join defcontract c on d.pin=c.pin and c.contrtip=2
  left join agentlist a on c.ag_id=a.ag_id
  left join person p on a.p_id=p.p_id
  left join agentlist sa on a.sv_ag_id=sa.ag_id
  left join person sp on sa.p_id=sp.p_id
  where (d.POSX=0 or d.POSX is null) 
        and d.actual=1 
        and d.worker=0 
        and sa.ag_id<>0 
        and sa.ag_id<>257
  order by sp.fio, p.fio
END