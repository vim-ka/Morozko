CREATE PROCEDURE ELoadMenager.Eload_DefList
AS
BEGIN
select distinct al.ag_id [код агента], p.fio [фио агента], d1.dname [отдел], fc.ourname [организация],
                d.pin [код точки], d.brname [наименование точки], d.gpaddr [адрес], d.brinn [инн],
                d.contact [контактное лицо], d.brphone [телефон 1], d.gpphone [телефон 2],
                d.email, d.PosX, d.posy
from dbo.def d
join dbo.defcontract dc on d.pin = dc.pin
join dbo.agentlist al on dc.ag_id = al.ag_id
join dbo.person p on al.p_id = p.p_id
join dbo.deps d1 on al.depid = d1.depid
join dbo.firmsconfig fc on dc.our_id = fc.our_id
where d.actual=1 and dc.actual=1 and d.worker=0
order by d1.dname, p.fio, d.brname
END