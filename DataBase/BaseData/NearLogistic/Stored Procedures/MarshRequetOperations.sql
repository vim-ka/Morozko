CREATE PROCEDURE NearLogistic.MarshRequetOperations
@ids varchar(max), --строка заявок {кодзаявки1};{кодтипазаявки1};{коднаправлениязаявки1}#{кодзаявки2};{кодтипазаявки2};{коднаправлениязаявки2}...
@mhid int output, --код маршрута, если -1 то создается новый, если 0 выбрасываем из маршрута
@op int,
@operationType int=-1, --0 -добавление, 1 -удаление, 2 -перемещение
@ermsg varchar(1000)='' out,
@PLID int=1,
@Remark varchar(100)=''
AS
BEGIN
	set nocount on
  /*
  print '*********************************************'
  print 'proc [NearLogistic.MarshRequetOperations] params:'
  print '@ids='+cast(@ids as varchar)
  print '@mhid='+cast(@mhid as varchar)
  print '@op='+cast(@op as varchar)
  print '@operationtype='+cast(@operationType as varchar)
  print '@ermsg='+cast(@ermsg as varchar)
  print '@plid='+cast(@PLID as varchar)
  print '*********************************************'
  */
	declare @tranname varchar(50)
  declare @erReg int
  declare @msg varchar(1000)
  set @msg=''
  set @erReg=0  
  set @tranname='MarshRequetOperations'
  begin tran @tranname  
	declare @nd datetime 
  declare @marsh int
  declare @mhid_old int
  declare @mhIDs varchar(500)
  declare @ids_ varchar(max) 
  DECLARE @reqDate DATE 
  DECLARE @marshDate DATE 
  DECLARE @updateError VARCHAR(200) = ''

  
  set @nd=[dbo].today()
	--заполняем структуры под выделенные заявки
  --print 'структуры'
	if object_id('tempdb..#reqlist') is not null drop table #reqlist
  create table #reqlist (id int, type int, act int)
  declare @ttable varchar(50) 
  set @ttable='##'+host_name()+'_reqlist'
  declare @sql varchar(max)
  set @sql=''
  set @sql='if object_id(''tempdb..'+@ttable+''') is not null drop table '+@ttable+' '
  set @sql=@sql+' exec nearlogistic.gettablefromstrings '''+@ids+''',''id;type;act'','';'',''#'','''+@ttable+''''
  set @sql=@sql+' insert into #reqlist select cast(id as int),cast(type as int),cast(act as int) from '+@ttable+' '
  set @sql=@sql+' drop table '+@ttable+' '  
  --print @sql
  exec(@sql) 

  --создание нового маршрута
  if @operationType<>1
  if @mhid=-1
  begin
    if object_id('tempdbb..#tmp_new_marhs') is not null drop table #tmp_new_marhs
    create table #tmp_new_marhs (id int) 
    insert into #tmp_new_marhs
    select r.num from nearLogistic.get_range(1,199) r
		where not exists(select 1 from dbo.marsh m where m.marsh=r.num and m.nd=@nd) and r.num<>99
    /*select 
    case when row_number() over(order by [marsh]) in (select [marsh] from dbo.marsh where nd=@nd union select 99) then 0
         else row_number() over(order by [marsh]) end [id]
    from [dbo].marsh
    where nd=@nd*/
    SET @marsh = ISNULL((select min(id) from #tmp_new_marhs where id>0), 1)

    if object_id('tempdbb..#tmp_new_marhs') is not null drop table #tmp_new_marhs
    insert into [dbo].marsh(nd,marsh,plid) values(@nd,@marsh,@plid)
    set @mhid=scope_identity()
    
    insert into NearLogistic.MarshRequestsOperationsLog(op,mhid,mhid_old,ids,ids_,operationType) 
    values(@op,@mhid,0,'','',4)
  end
  
  --ключ старого маршрута для обновления    
  set @mhid_old=(select top 1 mhid from NearLogistic.MarshRequests mr inner join #reqlist r on mr.reqid=r.id and mr.reqtype=r.type)
  --добавление связанных возвратов
  if (exists(select 1 from dbo.marsh z where z.mhid=@mhid and z.selfship=0) and @operationType=0) or
  	 (exists(select 1 from dbo.marsh z where z.mhid=@mhid_old and z.selfship=0) and @operationType<>0)
  insert into #reqlist
  select r.reqnum,1,2
  from dbo.reqreturn r
  inner join dbo.requests q on q.ParentRk=r.reqnum
  where (r.pin in (select b_id from dbo.nc c inner join #reqlist l on l.id=c.datnom and l.type=0) 
  			 or r.pin in (select f.vmaster from dbo.nc c join dbo.def f on c.b_id=f.pin inner join #reqlist l on l.id=c.datnom and l.type=0)
         or r.pin in (select f.pin from dbo.nc c join dbo.def f on c.b_id=f.vmaster inner join #reqlist l on l.id=c.datnom and l.type=0))
  			and r.mhid=iif(@operationType=0,0,@mhid_old)
        and q.rs in (2,5,6) and q.Tip2=197
        and not r.reqnum in (select id from #reqlist l where l.type=1)
  
  --операция добавления заявок
  if @operationType=0
  begin
  	if not exists(select 1 from dbo.marsh where mhid=@mhid)
    begin
    	set @erReg=@erReg+16
      set @msg=@msg+';'+char(10)+char(13)+'Маршрут не существует!'
    end
  	
    --------------проверка дат-------------------
    --дата маршрута
  	select @marsh=marsh, @marshDate = nd 
      from [dbo].marsh where mhid=@mhid 

    --дата заявок
    SET @reqDate = (SELECT TOP 1 t.nd FROM
    (select TOP 1 c.nd
      from dbo.nc c 
      inner join #reqlist r on r.id=c.datnom
      where r.type=0 and c.DayShift=0	   
      union 
      --возвраты
      select TOP 1 r.ret_nd nd 
      from dbo.reqreturn r
      inner join dbo.requests q on q.ParentRk=r.reqnum
      inner join #reqlist r1 on r.reqnum = r1.id
      where r1.type=1
      			and q.rs in (2,5,6)
            and q.tip2=197
      group by r1.[id],r1.[type],r1.[act],r.pin,r.pin_from,q.ag_id,r.ret_nd,q.Remark
      union 
      --холодильники
      select TOP 1 f.rdt
      from dbo.frizrequest f
      inner join #reqlist r on f.rcmplxid=r.id
      where r.type=2  
      union 
      --деньги
      select TOP 1 mbr.nd
      from nearlogistic.moneybackrequest mbr 
      inner join #reqlist r on mbr.mbrid=r.id
      where r.type=3 
      union 
      --закупка
      select TOP 1 o.nd
      from dbo.orders o 
      inner join #reqlist r on o.ordid=r.id
      where r.type=5
      union
      --свободная    
      select TOP 1 ISNULL(mf.nd, cast(convert(varchar, mf.dt_create, 104) as datetime))
      from nearlogistic.MarshRequests_free mf 
      inner join #reqlist r on mf.mrfID=r.id
      where r.type=-2
    ) T)
    ---------------------------------------------
    --IF @reqDate <= @marshDate
    BEGIN 
      --накладные
      insert into nearlogistic.marshrequests (mhid, reqid, reqtype, reqaction, op,pinto,pinfrom,cost_,ag_id,ReqND, ReqRemark)
      select @mhid,r.[id],r.[type],r.[act],@op,c.b_id,isnull(c.b_id2,0),c.sp,c.ag_id,c.nd,c.Remark
      from dbo.nc c 
      inner join #reqlist r on r.id=c.datnom
      where r.type=0 and c.DayShift=0	    
      if @@error<>0
      begin
      	set @erReg=@erReg+1
        set @msg=@msg+';'+char(10)+char(13)+'Ошибка вставки накладных [вставка]'
      end
      --union all
      --возвраты
      insert into nearlogistic.marshrequests (mhid, reqid, reqtype, reqaction, op,pinto,pinfrom,cost_,ag_id,ReqND, ReqRemark)
      select @mhid,r1.[id],r1.[type],r1.[act],@op,r.pin,r.pin_from,0,q.ag_id,r.ret_nd,q.Remark
      from dbo.reqreturn r
      inner join dbo.requests q on q.ParentRk=r.reqnum
      inner join #reqlist r1 on r.reqnum = r1.id
      where r1.type=1
      			and q.rs in (2,5,6)
            and q.tip2=197
      group by r1.[id],r1.[type],r1.[act],r.pin,r.pin_from,q.ag_id,r.ret_nd,q.Remark
      if @@error<>0
      begin
      	set @erReg=@erReg+1
        set @msg=@msg+';'+char(10)+char(13)+'Ошибка вставки возвратов [вставка]'
      end
      --union all
      --холодильники
      insert into nearlogistic.marshrequests (mhid, reqid, reqtype, reqaction, op,pinto,pinfrom,cost_,ag_id,ReqND, ReqRemark)
      select @mhid,r.[id],r.[type],r.[act],@op,iif(r.act=3,isnull(f.rtpcode2,0),f.rtpcode),iif(r.act=3,f.rtpcode,isnull(f.rtpcode2,0)),
             0,f.rtpag_id,f.ractdate,f.rprim
      from dbo.frizrequest f
      inner join #reqlist r on f.rcmplxid=r.id
      where r.type=2
      if @@error<>0
      begin
      	set @erReg=@erReg+1
        set @msg=@msg+';'+char(10)+char(13)+'Ошибка вставки оборудования [вставка]'
      end
      --union all
      --деньги
      insert into nearlogistic.marshrequests (mhid, reqid, reqtype, reqaction, op,pinto,pinfrom,cost_,ag_id,ReqND, ReqRemark)
      select @mhid,r.[id],r.[type],r.[act],@op,mbr.pin,0,mbr.sumpay,mbr.ag_id,mbr.nd,mbr.remark
      from nearlogistic.moneybackrequest mbr 
      inner join #reqlist r on mbr.mbrid=r.id
      where r.type=3
      if @@error<>0
      begin
      	set @erReg=@erReg+1
        set @msg=@msg+';'+char(10)+char(13)+'Ошибка вставки денег [вставка]'
      end
      --union all
      --закупка
      insert into nearlogistic.marshrequests (mhid, reqid, reqtype, reqaction, op,pinto,pinfrom,cost_,ag_id,ReqND, ReqRemark)
      select @mhid,r.[id],r.[type],r.[act],@op,o.pin,0,o.summacost,0,o.DateComm,''
      from dbo.orders o 
      inner join #reqlist r on o.ordid=r.id
      where r.type=5
      if @@error<>0
      begin
      	set @erReg=@erReg+1
        set @msg=@msg+';'+char(10)+char(13)+'Ошибка вставки закупки [вставка]'
      end
      --свободная    
      insert into nearlogistic.marshrequests (mhid, reqid, reqtype, reqaction, op,pinto,pinfrom,cost_,ag_id,ReqND, ReqRemark)
      select @mhid,r.[id],r.[type],r.[act],@op,mf.pin,0,mf.cost,0,mf.nd,mf.remark
      from nearlogistic.MarshRequests_free mf 
      inner join #reqlist r on mf.mrfID=r.id
      where r.type=-2
      if @@error<>0
      begin
      	set @erReg=@erReg+1
        set @msg=@msg+';'+char(10)+char(13)+'Ошибка вставки свободной [вставка]'
      end      
      SET @updateError = '[вставка]'   
    END
    /*ELSE 
    BEGIN
      	set @erReg=@erReg+64
        set @msg=@msg+';'+char(10)+char(13)+'Ошибка вставки - дата рейса не может быть раньше даты заявки [вставка]'
    END*/
  end
  
  --операция удаление заявок
  if @operationType=1 
  begin
  	--set @mhid_old=(select top 1 mhid from NearLogistic.MarshRequests mr inner join #reqlist r on mr.reqid=r.id and mr.reqtype=r.type)
  	--удаление заявок    
    --select * from #reqlist
    delete mr
    from NearLogistic.MarshRequests mr
    inner join #reqlist r on mr.reqid=r.id and mr.reqtype=r.type    
    if @@error<>0
    begin
    	set @erReg=@erReg+4
      set @msg=@msg+';'+char(10)+char(13)+'Ошибка обновления удаления заявок [удаление]'
    end
    --обновление маршрута
    set @mhIDs=cast(@mhid_old as varchar)
    exec NearLogistic.UpdateMarshRequestParams @mhIDs=@mhIDs,
    																					 @nd=null
    SET @updateError = '[удаление]'  
    SET @mhid = 0
    SET @marsh = 0
  end
  
  --операция перемещения
  if @operationType=2
  begin
  	--ключ старого маршрута для обновления
    set @mhid_old=(select top 1 mhid from NearLogistic.MarshRequests mr inner join #reqlist r on mr.reqid=r.id and mr.reqtype=r.type)
		
    select @marsh=marsh from [dbo].marsh where mhid=@mhid
        
    --перемещение заявок
    update mr set mr.mhid=@mhid, mr.liter_id=0
    from NearLogistic.MarshRequests mr
    inner join #reqlist r on mr.reqid=r.id and mr.reqtype=r.type   	
    if @@error<>0
    begin
    	set @erReg=@erReg+8
      set @msg=@msg+';'+char(10)+char(13)+'Ошибка обновления заявок [перемещение]'
    end
    SET @updateError = '[перемещение]' 
  end
  
  ---------------------------------------------------------------------------------------------------------------------
   	--обновление источников
    --накладные
    update c set c.mhID=@mhid
               --c.Marsh=@marsh
    from dbo.nc c 
    inner join #reqlist r on r.id=c.DatNom 
    where r.type=0
    if @@error<>0
    begin
    	set @erReg=@erReg+32
      set @msg=@msg+';'+char(10)+char(13)+'Ошибка обновления источников накладных ' + @updateError
    end    
    --возвраты
    update rr set rr.mhID=@mhid
    from dbo.ReqReturn rr
    inner join NearLogistic.MarshRequests r on r.reqid=rr.reqnum
    where r.reqtype=1
          and r.mhid=@mhid
    if @@error<>0
    begin
    	set @erReg=@erReg+32
      set @msg=@msg+';'+char(10)+char(13)+'Ошибка обновления источников возвратов ' + @updateError
    end
    --холодильники
    update f set f.mhid=@mhid
    from dbo.frizrequest f
    inner join #reqlist r on r.id=f.rcmplxid 
    where r.type=2
    if @@error<>0
    begin
    	set @erReg=@erReg+32
      set @msg=@msg+';'+char(10)+char(13)+'Ошибка обновления источников оборудования ' + @updateError
    end    
    --деньги
    update mbr set mbr.mhid=@mhid
    from nearlogistic.moneybackrequest mbr
    inner join #reqlist r on r.id=mbr.mbrid 
    where r.type=3
    if @@error<>0
    begin
    	set @erReg=@erReg+32
      set @msg=@msg+';'+char(10)+char(13)+'Ошибка обновления источников денег ' + @updateError
    end
    --закупка
    update o set o.mhID=@mhID
    from dbo.orders o 
    inner join #reqlist r on r.id=o.OrdID 
    where r.type=5
    if @@error<>0
    begin
    	set @erReg=@erReg+32
      set @msg=@msg+';'+char(10)+char(13)+'Ошибка обновления источников закупки ' + @updateError
    end 
    --свободная
    update mf set mf.mhID=@mhID
    from nearlogistic.MarshRequests_free mf 
    inner join #reqlist r on r.id=mf.mrfID 
    where r.type=-2
    if @@error<>0
    begin
    	set @erReg=@erReg+32
      set @msg=@msg+';'+char(10)+char(13)+'Ошибка обновления источников свободная ' + @updateError
    end
    --обновление маршрута
    set @mhIDs=cast(@mhid as varchar)
    IF @mhid <> 0
    BEGIN 
      exec NearLogistic.UpdateMarshRequestParams @mhIDs=@mhIDs,
      																					 @nd=null
      --пересчет букв для набора                                           
  		exec nearlogistic.recalculate_liter_id @mhid 
    END
-----------------------------------------------------------------------------------------------------------------------


  set @ermsg=@msg
  
  set @ids_=
  STUFF((select N'#'+cast(id as varchar)+';'+cast(type as varchar)+';'+cast(act as varchar)
	from #reqlist 
	for xml path(''), type).value('.','varchar(max)'),1,1,'')
  
  if @erReg=0 
  begin
  	commit tran @tranname 
    insert into NearLogistic.MarshRequestsOperationsLog(op,mhid,mhid_old,ids,ids_,operationType, Remark) 
    values(@op,@mhid,@mhid_old,@ids,@ids_,@operationType, @Remark)
  end
  else rollback tran @tranname
 	set nocount on
END