CREATE PROCEDURE users.GetChooseList
@type varchar(6),
@choosed varchar(500),
@prg int
AS
BEGIN
	if @choosed='' set @choosed='-666'
	create table #res (x bit not null default 0,
  									 id int,
                     list varchar(500))
	create table ##choosed (id int)
  declare @sql varchar(max)
  set @sql=''
  set @sql='insert into ##choosed select '+replace(@choosed,',',' union all select ')
  exec(@sql)
  
  if @type='prg'
  begin
  	insert into #res
    select case when exists(select 1 from ##choosed where id=p.Prg) then cast(1 as bit) else cast(0 as bit) end,
    		   p.prg,
           p.PrgName
    from dbo.Programs p
  end
  
  if @type='perms'
  begin
  	insert into #res
  	select case when exists(select 1 from ##choosed where id=pe.pID) then cast(1 as bit) else cast(0 as bit) end,
    		   pe.pID,
           pe.PermisName
    from dbo.Permissions pe
    where pe.Prg=@prg
  end
  
  if @type='closed'
  begin
  	insert into #res
    select 0,0,'открыт'
    union all
    select 0,1,'закрыт'
  end
  
  if @type='uin'
  begin
  	insert into #res
    select case when exists(select 1 from ##choosed where id=uin) then cast(1 as bit) else cast(0 as bit) end,
    		   uin,
           fio
    from dbo.usrPwd
  end
  
  if @type='p_id'
  begin
  	insert into #res
    select case when exists(select 1 from ##choosed where id=p_id) then cast(1 as bit) else cast(0 as bit) end,
    		   p_id,
           fio
    from dbo.Person
  end
  
  select * from #res
  order by list
  
  drop table #res
  drop table ##choosed
END