CREATE PROCEDURE dbo.CheckNvZakazLock
@datnom BIGint,
@hitag int =0,
@terminal int=-1,
@op int,
@comp varchar(50)=''
WITH RECOMPILE
AS
BEGIN
set transaction isolation level read uncommitted
declare @msg varchar(100)
if @comp=''
	set @comp=host_name()
  
set @msg=''

IF not exists(select 1 
				  from nvzakaz 
          where datnom=@datnom 
          		  and hitag=@hitag 
                and ISNULL(id,0)=0
                and done=0)
begin
	set @msg='Позиция обработана'
end
else
begin
  if exists(select 1 
            from nvzakazlock 
            where datnom=@datnom 
                  and abs(datediff(minute,getdate(),dt))<5
                  and (terminal<>@terminal or comp<>@comp)
                  and hitag=@hitag)
  begin	  
     set @msg='Заблокировано '
              +cast((select iif(comp='', 'Терминалом №'+cast(terminal as varchar), comp) 
                     from nvzakazlock 
                     where datnom=@datnom
                  			 and hitag=@hitag) as varchar)
              +' в '
              +convert(varchar,(select dt 
                     from nvzakazlock 
                     where datnom=@datnom
                     			 and hitag=@hitag),120)            
  end
  else
  begin
    delete from nvzakazlock where datnom=@datnom and hitag=@hitag
    insert into nvzakazlock(datnom,dt,terminal,op,hitag,comp)
    values(@datnom,getdate(),@terminal, @op, @hitag, @comp)
  end
end

if @msg<>''
	select cast(1 as bit) [res], @msg [msg]
else
	select cast(0 as bit) [res], @msg [msg]
END