CREATE PROCEDURE dbo.GetSertifLogWorkRep
@dt datetime
AS
BEGIN
	declare @yymm int
  declare @op int
	set @yymm=(year(@dt)-2000)*100+month(@dt)  
  declare @sql varchar(max)
  
  create table #cnt (op int, cnt int)
  
  declare cr cursor for
  select op,Comment 
  from SertifLogWork 
  where YYMM=@yymm        
        and TypeID=3
        
  open cr
  
  fetch next from cr into @op,@sql
  
  while @@fetch_status=0
  begin
  	set @sql='select '+replace(LEFT(@sql,len(@sql)-1),'$',' x union all select ')
   	set @sql='insert into #cnt select '+cast(@op as varchar(3))+', count(distinct z.x) from ('+@sql+') z '
   	exec(@sql)
  
  	fetch next from cr into @op,@sql  
  end
  
  close cr
  deallocate cr   
  
  select * from (
	select 	w.YYMM,
					u.fio,
					t.TypeName,
					w.Counter 
	from SertifLogWork w   
	join SertifLogWorkType t on w.TypeID=t.TypeID
	join usrpwd u on w.OP=u.uin
	where YYMM=@yymm
  union 
  select @yymm,
  			 u.fio,
         'Добавлено в сертификаты',
         c.cnt
  from #cnt c
  join usrpwd u on c.OP=u.uin) z  
	order by 1,2
  
  drop table #cnt
END