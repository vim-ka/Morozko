CREATE PROCEDURE [ELoadMenager].Eload_SertifErrors
@nd1 datetime,
@nd2 datetime
AS
BEGIN
declare @dat1 int
declare @dat2 int

set @dat1=dbo.InDatNom(0, @nd1) 
set @dat2=dbo.InDatNom(9999, @nd2)

select 	n.Nd [Дата],
       	n.datnom%10000 [Номер накладной],
        n.marsh [Номер маршрута],
       	n.B_ID [Код покупателя],
       	d.gpName [Наименование покупателя],
       	n.Remark [Ремарка агента],
        n.RemarkOp [Ремарка оператора],
        iif(n.SertifDoc=0 or (n.SertifDoc & 288<>0 and n.SertifDoc & 223=0),cast(1 as bit),cast(0 as bit)) [Ошибка],
        cast(iif(exists(select 1 from dbo.defcontract dc inner join dbo.AgentList al on dc.ag_id=al.AG_ID where dc.pin=d.pin and al.DepID=3),1,0) as bit) [Сеть],
        stuff((select N''+sd.dName+';' 
        		   from dbo.SertifDoc sd 
               where n.SertifDoc & sd.dNo<>0 
               for xml path(''), type).value('.','varchar(max)'),1,0,'') [Отметки],
        stuff((select N''+me.Remark+';' 
        		   from MobAgents.Mess me 
               where me.data0=n.DatNom and me.MessType=2
               for xml path(''), type).value('.','varchar(max)'),1,0,'') [Сообщения]
        --MobAgents.Mess      
from dbo.nc n
inner join dbo.Def d on n.b_id = d.pin
where d.tip = 1
      and n.datnom >= @dat1
      and n.datnom <= @dat2 
      and n.sp > 0 
      and (n.Remark like '%вет%' or
      	   n.Remark like '%свид%' or
      		 n.Remark like '%общ%' or
      		 n.Remark like '%доку%' or
           n.RemarkOp like '%вет%' or
      	   n.RemarkOp like '%свид%' or
      		 n.RemarkOp like '%общ%' or
      		 n.RemarkOp like '%доку%' or
           exists(select 1 from dbo.defcontract dc inner join dbo.AgentList al on dc.ag_id=al.AG_ID where dc.pin=d.pin and al.DepID=3))
      and n.Marsh <> 99
      --and n.SertifDoc & 288=0
order by n.nd
END