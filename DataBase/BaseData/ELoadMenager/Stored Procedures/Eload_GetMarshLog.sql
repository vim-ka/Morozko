CREATE PROCEDURE ELoadMenager.Eload_GetMarshLog
@nd datetime,
@nom int
AS
BEGIN
declare @mhid int
select @mhid=mhid from dbo.marsh where marsh=@nom and nd=@nd
print @mhid
select convert(varchar,l.nd,104) [Дата],
			 convert(varchar,l.nd,108) [Время],
       l.host_ [Компьютер],
       l.app [Приложение],
       t.TypeName [Операция],
       iif(t.TypeID=2,'№'+cast(m.marsh as varchar)+' от '+convert(varchar,m.nd,104),l.Remark) [Примечание],
       l.ids_ [Список заявок]
from NearLogistic.MarshRequestsOperationsLog l
left join NearLogistic.OperationTypes t on t.TypeID=l.operationType
left join dbo.marsh m on m.mhid=l.mhid_old
where l.mhid=@mhid 
			or l.mhid_old=@mhid
order by l.olID desc
END