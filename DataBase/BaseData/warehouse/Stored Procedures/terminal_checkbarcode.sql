CREATE procedure warehouse.terminal_checkbarcode
@barcode varchar(20),
@type int -- 0- группа, 1- пользователь, 2- старший смены, 3- склад, 4- маршрут, 5- накладная, 6- возврат
as
begin
	declare @id int
	declare @body varchar(18)
  declare @nd datetime
  declare @nom int
  declare @fio varchar(500)
  set @body=substring(@barcode,iif(@barcode like '0%',4,3),len(@barcode)-iif(@barcode like '0%',4,3))
	print @body
  if object_id('tempdb..#res') is not null drop table #res
  create table #res (allow bit, msg varchar(500), id int, nd datetime)
  --проверка пользователя
  if @type=1
  begin
  	select @id=sp.spk, @fio=sp.fio from dbo.skladpersonal sp
    where sp.spk=cast(@body as int) and sp.closed=0
    
    insert into #res
    select iif(@id is null,0,1), iif(@id is null,'Актуальный пользователь не найден',@fio), @id, @nd
  end
  --проверка старшего смены
  if @type=2
  begin
  	select @id=sp.spk, @fio=sp.fio from dbo.skladpersonal sp
    where sp.spk=cast(@body as int) and sp.closed=0 and sp.trid=38
    
    insert into #res
    select iif(@id is null,0,1), iif(@id is null,'Актуальный пользователь не найден', @fio), @id, @nd
  end
  --проверка складской группы
  if @type=3
  begin
  	select @id=skg
    from dbo.skladgroups 
    where skg=cast(@body as int)
    
    if isnull(@id,0)<>0
    set @fio= stuff((select N','+cast(skladno as varchar) 
             	       from dbo.skladlist where skg=12
                     for xml path(''), type).value('.','varchar(max)'),1,1,'')
    insert into #res
    select iif(@id is null,0,1), @fio, @id, @nd
  end
  --проверка возврата
  if @type=6
  begin
  	select top 1 @id=r.reqnum from dbo.reqreturn r join dbo.reqreturndet d on d.reqretid=r.reqnum join dbo.requests q on q.rk=r.reqnum
    where r.reqnum=cast(@body as int) and q.tip2=197 and d.done=0
    
    insert into #res
    select iif(@id is null,0,1), iif(@id is null,'Возврат не готов для обработки складом или обработан',''), @id, @nd
  end
  --проверка маршрута
  if @type=4
  begin
  	set @nd=cast(substring(@body,1,2)+'.'+substring(@body,3,2)+'.'+substring(@body,5,2) as datetime)
  	set @nom=cast(substring(@body,len(@body)-3,4) as int)
    print @nom
  	select @id=m.mhid from dbo.marsh m
    where m.nd=@nd and m.marsh=@nom and m.delivcancel=0 and m.listno=0
    
    if @id is null
    select top 1 @id=sr.sregionid from dbo.nc c join dbo.nvzakaz z on z.datnom=c.datnom join dbo.def d on d.pin=c.b_id join dbo.regions r on r.reg_id=d.reg_id join warehouse.skladreg sr on sr.sregionid=r.sregionid
    where sr.sregionid=@nom and c.nd=@nd and c.delivcancel=0 and z.done=0
    
    insert into #res
    select iif(@id is null,0,1), iif(@id is null,'Маршрут не готов для обработки складом или обработан',''), @id, @nd--iif(@id<1000,@nd,null)
  end
  --проверка накладной
  if @type=5
  begin
  	set @nd=cast(substring(@body,1,2)+'.'+substring(@body,3,2)+'.'+substring(@body,5,2) as datetime)
  	set @nom=cast(substring(@body,len(@body)-3,4) as int)
  	select top 1 @id=c.datnom from dbo.nc c --join dbo.nvzakaz z on z.datnom=c.datnom
    where c.nd=@nd and c.datnom % 10000=@nom and c.delivcancel=0
    
    insert into #res
    select iif(@id is null,0,1), iif(@id is null,'Накладная отменена',''), @id, null
  end
  
  --проверка прихода
  if @type=8
  begin
  	select @id=p.prihodrid
    from dbo.prihodreq p    
    where prihodrid=cast(@body as int) and prihodrdone=10 
    			and exists(select 1 from dbo.prihodreqdet a where a.prihodrid=p.prihodrid and a.sklad_done=0)
    insert into #res
    select iif(@id is null,0,1), iif(@id is null,'Приход не готов для обработки складом или обработан',''), @id, @nd
  end
  
  if not exists(select 1 from #res) 
  insert into #res
  select 0,'Тип штрихкода не опознан',null,null
  select * from #res
  if object_id('tempdb..#res') is not null drop table #res
end