CREATE PROCEDURE users.SavePrgToAll
@prg int,
@uin varchar(2500),
@act bit --0 удаление, 1 добавление
AS
BEGIN
	if @uin=''
  	select distinct uin
  	into ##usr
  	from dbo.permisscurrent pc
  	where pc.Permiss>0
  else
  begin
  	declare @sql varchar(max)
    set @sql='select distinct uin into ##usr from dbo.PermissCurrent pc where pc.permiss>0 and pc.uin in ('+@uin+')'
    exec(@sql)
  end
  	  
	if @act=1
  begin
    delete from ##usr where exists(select 1 from dbo.PermissCurrent pc where pc.uin=##usr.uin and pc.prg=@prg)
    
    insert into dbo.PermissCurrent(prg,uin,permiss)
    select @prg,uin,1
    from ##usr
  end
  else
  	delete dbo.PermissCurrent where prg=@prg and exists(select 1 from ##usr where dbo.PermissCurrent.uin=##usr.uin)
    
  drop table ##usr
END