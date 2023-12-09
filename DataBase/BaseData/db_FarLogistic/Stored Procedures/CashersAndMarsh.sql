CREATE PROCEDURE [db_FarLogistic].CashersAndMarsh
@m varchar(max)
AS
declare @sql varchar(max) 

if not object_id('tempdb.dbo.#Cashers') is null
drop table #Cashers

create table #Cashers (id int not null identity(1,1), CasherID int not null, RecType int not null)

insert into #Cashers (CasherID, RecType) 
select b.CasherID, r.RecType 
from db_FarLogistic.dlGroupBill b 
join db_FarLogistic.dlMarsh m on m.dlMarshID=b.MarshID
join (select 1 RecType union all select 2) r on 1=1 
where month(m.dt_end_fact) in (select * from db_FarLogistic.String_to_Int(@m)) and m.IDdlMarshStatus=4 and year(m.dt_end_fact)=2014
group by b.CasherID, r.RecType

set @sql=''
set @sql='alter table #Cashers add 	[CashName] varchar(200) null, [RecName] varchar(20)'
exec(@sql)

declare @curM int
declare curM cursor for
select m.number from db_FarLogistic.String_to_Int(@m) m
open curM
fetch next from curM into @curM 
while @@fetch_status=0 
begin
  set @sql=''
  set @sql='alter table #Cashers add 	[Month'+'_'+cast(@curM as varchar(2))+'] money default 0 null'
  exec(@sql)
	
  set @sql=''
  set @sql=	'update #Cashers set [Month_'+cast(@curM as varchar(2))+']=(select isnull(count(m.dlMarshID),0) from db_FarLogistic.dlMarsh m '+
  					'join db_FarLogistic.dlGroupBill b on b.marshid=m.dlmarshid '+
  					'where month(m.dt_end_fact)='+cast(@curM as varchar(2))+' and m.IDdlMarshStatus=4 and year(m.dt_end_fact)=2014 and b.CasherID=#Cashers.CasherID), '+
            'CashName=(select brname from def where pin=#Cashers.CasherID), '+
            'RecName=''Кол-во маршрутов'' '+  
  					'where RecType=1'
  exec(@sql)
  
  set @sql=''
  set @sql=	'update #Cashers set [Month_'+cast(@curM as varchar(2))+']=(select isnull(sum(b.ForPay),0) from db_FarLogistic.dlMarsh m '+
  					'join db_FarLogistic.dlGroupBill b on b.marshid=m.dlmarshid '+
  					'where month(m.dt_end_fact)='+cast(@curM as varchar(2))+' and m.IDdlMarshStatus=4 and year(m.dt_end_fact)=2014 and b.CasherID=#Cashers.CasherID), '+
            'CashName=(select brname from def where pin=#Cashers.CasherID), '+
            'RecName=''Сумма'' '+    
  					'where RecType=2'
  exec(@sql)
  fetch next from curM into @curM
end

close curM
deallocate curM

select * from #Cashers
order by 2,3