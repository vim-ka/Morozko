CREATE PROCEDURE dbo.TransInUnit
@str varchar(1024),
@minp int,
@res int output
AS
declare @t table(id int identity, val int)
begin	
  set @str='select '''+'0'+replace(@str, '+', ''' as val union all select ''')+''''
	
  insert into @t
	exec (@str)

	update @t set val=val*@minp where id=1	
  
  set @res=(select sum(val) from @t)
  --select @res as [res]
end