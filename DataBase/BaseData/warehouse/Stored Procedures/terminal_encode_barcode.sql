CREATE procedure warehouse.terminal_encode_barcode --парсинг штрихкода, результат кодируется в строку, разделитиель $
@type int,
@barcode nvarchar(50)
as
begin
	set nocount on
	declare @result_string nvarchar(500) ='', @body varchar(18) ='', @separator nvarchar(1) ='$';
	
  set @barcode=ltrim(rtrim(@barcode));
  set @body=substring(@barcode,iif(@barcode like '0%' or @type > 99,4,3),len(@barcode)-iif(@barcode like '0%'  or @type > 99,4,3))
  print @body
  
  if @type in (83,84,838) --штрихкод сотрудника
  begin
  	if @type in (83,84)
    begin
    	select @result_string =cast(s.spk as nvarchar)+@separator+isnull(p.fio,'<..>')
      from dbo.skladpersonal s
      join dbo.person p on p.p_id=s.p_id
      where s.spk=cast(@body as int) and p.closed=0 and s.closed=0
    end
    
    if @type in (838)
    begin
    	select @result_string =cast(s.spk as nvarchar)+@separator+isnull(p.fio,'<..>')
      from dbo.skladpersonal s
      join dbo.person p on p.p_id=s.p_id
      join hrmain.dbo.pers hr on hr.persid=p.persid
      where hr.persid=cast(@body as int) and hr.persstaff>0 and p.closed=0 and s.closed=0
    end
  end  --штрихкод сотрудника
  
  if @type in (341) --штрихкод складской комнаты
  begin
  	select @result_string='['+r.room_code+'] '+r.room_name
    from dbo.skladrooms r
    where r.srID=cast(@body as int)
    
    select @result_string=@result_string+@separator+ 
    stuff((
		select N','+cast(sl.skladno as varchar)
    from dbo.skladlist sl
    join dbo.skladgroups g on sl.skg=g.skg
    where g.srid=cast(@body as int)
    for xml path(''), type).value('.','varchar(max)'),1,1,'')
  end --штрихкод складской комнаты
  
  select cast(iif(isnull(@result_string,'')='',0,1) as bit) [res], @separator+@result_string [msg]
  set nocount off 
end