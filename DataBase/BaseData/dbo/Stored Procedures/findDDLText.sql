CREATE PROCEDURE [dbo].[findDDLText]
@pattern varchar(100)
AS 
BEGIN
create table #result (xtype varchar(10), name varchar(100), dbname varchar(30)  )
declare @sqlstr varchar(1000)
set @sqlstr = '
insert #result
select so.xtype, so.name, ''?''
from ?..sysobjects so
where exists (select 1 
						  from ?..syscomments sc1
              left join ?..syscomments sc2 on sc1.id = sc2.id and sc1.colid + 1 = sc2.colid
              where sc1.id = so.id
                		and (right(sc1.text, 2000) + left(isnull(sc2.text, ''''), 2000) like  ''' +'%'+ @pattern +'%'+ '''
                    		 or sc1.text like  ''' +'%'+ @pattern +'%'+ ''')
             )
order by so.xtype, so.name'
exec sp_msforeachdb @sqlstr
select * from #result where dbname='MainData'
END