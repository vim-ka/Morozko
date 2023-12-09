CREATE PROCEDURE NearLogistic.Marshs_del
@nd datetime
AS
BEGIN
set NOCOUNT on

if not exists(select * from NearLogistic.nlmarsh where nd=@nd and [marsh] in (0,99))
 insert into NearLogistic.nlmarsh([Marsh],nd,MStatus)
 select 0,@nd,0
 union 
 select 99,@nd,0

select  m.mhid,
    m.nd,
    m.Marsh,
    cast(m.Done as bit) Done,
    m.Away,
    case when exists(select j.mjid from MarshJob j where j.mhID=m.mhid) then cast(1 as bit) else cast(0 as bit) end [Jobs],
    m.VedNabPrinted,
    cast(isnull(m.Weight,0) as decimal(10,2)) [Weight],
    isnull(m.Direction,'') [Direction],
    (select count(distinct (case when isnull(d.vmaster,0)>0 
                   then d.vmaster 
                   else d.pin end
                )
           ) 
         from nc c 
     inner join def d on c.b_id=d.pin
         where c.nd=m.nd 
         and c.marsh=m.marsh) [Dots],
     m.MStatus,
     st.StatusName [Status],
     isnull(r.fio,'') [Sped],
     isnull(s.fio,'') [Driver],
     case when m.V_ID=0 then '' else v.[n]  end [Car],
     case when isnull(m.V_idTr,0)=0 then cast(0 as bit) else cast(1 as bit) end [Trailer],
     m.Marja - [NearLogistic].Marsh1CalcFact(m.mhid) - [NearLogistic].Marsh1OtherExpense(m.mhid) as Profit,
     m.TimePlan,
     m.AwayTime
from [NearLogistic].nlmarsh m 
left join (select drId,Fio from [dbo].Drivers) r on r.drId=m.SpedDrID
left join (select drId,Fio from [dbo].Drivers) s on s.drId=m.drId
left join (select v_id,isnull(Model,'')+' '+isnull(RegNom,'') [n] from [dbo].Vehicle) v on v.V_id=m.V_ID
inner join [NearLogistic].nlMarshStatus st on st.MStatus=m.MStatus
where m.nd=@nd
order by m.marsh
SET NOCOUNT off 
END