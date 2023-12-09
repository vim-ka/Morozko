CREATE procedure dbo.EloadIncomStatistics
@nd1 datetime,
@nd2 datetime
as
begin
set nocount on
select convert(varchar,x.date,104) [Дата],
			 x.op [КодОператора],
       x.fio [ФИО],
       x.firmsgroupname [ГруппаФирм],
       x.[_all] [Всего],
       x.[_ord] [ВЗаявке],
       x.[_all]-x.[_ord] [НеЗаявка],
       cast(x.[_ord]*100.0 / x.[_all]*1.0 as decimal(15,2)) [ПроцентАвто],
       x.[_rows] [ВсегоСтрок],
       x.[_rowsIN] [СтрокВЗаявке],
       x.[_rows]-x.[_rowsIN] [СтрокНеЗаявка],
       cast(x.[_rowsIN]*100.0 / x.[_rows]*1.0 as decimal(15,2)) [ПроцентСтрокАвто]
from (
select c.date,c.op,u.fio,f.firmsgroupname,count(distinct c.ncom) [_all],count(distinct o.ordid) [_ord], count(distinct i.inId) [_rows], sum(iif(o.ncom is null,0,1)) [_rowsIN] 
from MorozData.dbo.comman c
left join morozdata.dbo.usrpwd u on u.uin=c.op
left join morozdata.dbo.firmsconfig fc on fc.Our_id=c.our_id
left join morozdata.dbo.orders o on o.Ncom=c.ncom
left join morozdata.dbo.firmsgroup f on f.firmsgroupid=fc.firmgroup
left join morozdata.dbo.inpdet i on i.ncom=c.ncom
where c.date between @nd1 and @nd2
group by c.date,c.op,u.fio,f.firmsgroupname) x
order by x.date,x.op
set nocount off
end