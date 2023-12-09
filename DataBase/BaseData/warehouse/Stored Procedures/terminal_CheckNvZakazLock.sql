CREATE PROCEDURE warehouse.terminal_CheckNvZakazLock
@nzID int,
@terminal int=-1,
@op int
AS
BEGIN
declare @comp varchar(50)
declare @msg varchar(100)
declare @datnom int
declare @hitag int
select @datnom=datnom, @hitag=hitag from dbo.nvzakaz where nzid=@nzID
set @comp=host_name()  
set @msg=''
if not exists(select 1 from dbo.nvzakaz where nzID=@nzID and ISNULL(id,0)=0 and done=0)
	set @msg='Позиция '+cast(@nzID as varchar)+' обработана!'
else
begin
  if exists(select 1 from dbo.nvzakazlock where nzID=@nzID and abs(datediff(minute,getdate(),dt))<5 and (terminal<>@terminal or comp<>@comp))
  begin	  
     set @msg='Заблокировано '
              +cast((select iif(comp='', 'Терминалом №'+cast(terminal as varchar), comp) 
                     from dbo.nvzakazlock 
                     where nzID=@nzID) as varchar)
              +' в '
              +convert(varchar,(select dt 
                     from dbo.nvzakazlock 
                     where nzID=@nzID),120)            
  end
  else
  begin
    delete from dbo.nvzakazlock where nzID=@nzID
    insert into dbo.nvzakazlock(datnom,dt,terminal,op,hitag,comp)
    values(@datnom,getdate(),@terminal, @op, @hitag, @comp)
  end
end

if @msg<>''
	select cast(1 as bit) [res], @msg [msg]
else
	select cast(0 as bit) [res], @msg [msg]
END