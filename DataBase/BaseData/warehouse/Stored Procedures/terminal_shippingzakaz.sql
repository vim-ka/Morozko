CREATE procedure warehouse.terminal_shippingzakaz
@nzid int,
@QTY decimal(10,3), --в граммах
@op int, 
@spk int,
@mode int =-1,
@groupid int =-1,
@perentid int =0,
@comp varchar(64)=''
with recompile
as
begin
  set nocount on
  declare @done bit, @erreg int, @tranname varchar(50), @msg varchar(2000)
  set @tranname='terminal_shippingzakaz'
  set @erreg=0
  begin tran @tranname
  declare @work int, @type int/*0 -точный,1 -кратный,2 - любой*/, 
  @sklad int, @hitag int, @firmgroup int, @id int, @origid int, @RoundDec int,
  @price money, @cost money,  
  @origqty decimal(10,3), @q decimal(10,3), @junk int, @newid int,
  @procerror int, @datnom int, @mhid int,
  @zakaz int, @flgw bit, @cnt decimal(10,3), @newdatnom int, @kol int, @b_id int, @ag_id int, @dck int, 
  @stfnom varchar(17),@stfdate datetime, @docnom varchar(20), @docdate datetime, @srok int,
  @our_id int, @pko bit, @man_id int, @tovchk bit, @actn int, @ck int, @b_id2 int, @stip int,
  @needdover2 bit, @fam varchar(35), @savedzakaz float, @rem varchar(255), @remOP varchar(50)
  ,@price_row money, @cost_row money, @nc_op int, @mode_name varchar(10), @EmptyNC bit, @msg_sklad_lock varchar(100)


	declare @rest decimal(10,3), @unid INT
  SET @unid = (SELECT z.unID FROM nvZakaz z WHERE nzID=@nzID)

  
  if @comp is null
  	set @comp=host_name()
  set @work=-1  
  set @type=-1
  
  select @msg_sklad_lock=val from dbo.config 
	where param='msgonskladblock' and exists(select 1 from dbo.config where param='skladblock' and cast(val as int)<>0) 
  
  select @work=case when @msg_sklad_lock is not null then -3 --пересчет склада
  									when @QTY<=0 then -2 --попытка отгрузить 0
  									when z.done=1 then 0 --нет необходимости обрабатывать
                    /*
  									when n.flgweight=1 and datediff(day,z.nd,dbo.today())=0 and z.zakaz>0 then 1 --сегодня весовуха
                    when n.flgweight=0 and datediff(day,z.nd,dbo.today())=0 and z.zakaz>0 then 2 --сегодня штуки
                    when n.flgweight=1 and datediff(day,z.nd,dbo.today())=1 and z.zakaz>0 then 3 --вчера весовуха
                    when n.flgweight=0 and datediff(day,z.nd,dbo.today())=1 and z.zakaz>0 then 4 --вчера штуки
                    */
                    when datediff(day,z.nd,dbo.today())=0 and z.zakaz>0 then 2 --сегодня 
                    when datediff(day,z.nd,dbo.today())=1 and z.zakaz>0 then 4 --вчера 
                    --when z.zakaz<0 then 5 --разбор                    
                    else -1 end,--все невошедшее в ошибку 
         @datnom=z.datnom, @sklad=z.skladno, @hitag=z.hitag, @firmgroup=isnull(fc.firmgroup, 2),
         @mhid=c.mhid, @zakaz=z.zakaz, @flgw=n.flgweight, @cnt=@QTY, /*@cnt=round(@QTY,0),*/ @dck=c.dck, 
         @b_id=c.b_id, @our_id=c.ourid, @ag_id=c.ag_id, @stfnom=c.stfnom, @stfdate=c.stfdate,
         @docnom=c.docnom, @docdate=c.docdate, @srok=c.srok, /*@pko=c.pko, @man_id=c.man_id, */
         /*@tovchk=c.tovchk,*/ @actn=c.actn, @ck=c.ck, @b_id2=c.b_id2, @stip=c.stip, @needdover2=c.needdover,
         @fam=c.fam,@nc_op=c.op,@rem=c.remark,@remOp=c.remarkOP+' привязка', @price=z.price--, @cost=z.cost
  from dbo.nvzakaz z
  join dbo.nomen n on n.hitag=z.hitag
  inner join dbo.nc c on c.datnom=z.datnom 
	left join dbo.firmsconfig fc on fc.our_id=c.ourid
  where z.nzid=@nzid


  select @RoundDec=isnull(d.PricePrecision,2)
  from DefContract d 
  where d.dck=@DCK

/*  
  select @tekweight=sum(iif(n.flgweight=1,v.weight,1)*(v.morn-v.sell+v.isprav-v.remov-v.rezerv)) 
  from dbo.tdvi v
  join dbo.firmsconfig fc on fc.our_id=v.our_id
  where v.sklad=@sklad and v.hitag=@hitag and fc.firmgroup=@firmgroup
  			and v.locked=0 and v.lockid=0 and v.morn-v.sell+v.isprav-v.remov-v.rezerv>0
*/

  set @rest = ISNULL((SELECT SUM(dbo.getQTY(v.HITAG, v.UnID, v.rest, @unid)) 
                 FROM tdvi v 
                 JOIN dbo.firmsconfig fc on fc.our_id=v.our_id
                WHERE v.sklad=@sklad and v.hitag=@hitag and fc.firmgroup=@firmgroup
  			          AND v.locked=0 and v.lockid=0 and v.morn-v.sell+v.isprav-v.remov-v.rezerv>0), 0)   



  if @work=-3 set @msg='['+cast(@work as varchar)+']'+'Блокировка работы со складом: '+@msg_sklad_lock
  
  if @work=-2 set @msg='['+cast(@work as varchar)+']'+'введите вес больший 0'

	if @work=-1 set @msg='['+cast(@work as varchar)+']'+'недопустимый режим работы'
  
  if @work=0 set @msg='['+cast(@work as varchar)+']'+'строка уже обработана'
  
  
  if @work=2 --сегодня штуки
  begin
    if not exists(select 1 from dbo.tdvi t
    						  join dbo.firmsconfig fc on fc.our_id=t.our_id
                  where t.hitag=@hitag and t.sklad=@sklad and t.locked=0 and t.lockid=0 
                  			and fc.firmgroup=@firmgroup and t.id>0
                        and t.morn-t.sell+t.isprav-t.remov-t.bad>0
                  group by t.hitag
                  having sum(t.morn-t.sell+t.isprav-t.remov-t.bad)>=@cnt) 
     set @erreg=@erreg+64  --нет требуемого остатка
     if @erreg=0
     begin
     	declare cr cursor fast_forward for
      select t.id, t.morn-t.sell+t.isprav-t.remov-t.bad [rest], t.cost    --,t.price
      from dbo.tdvi t
      join dbo.firmsconfig fc on fc.our_id=t.our_id
      where t.hitag=@hitag and t.sklad=@sklad and t.locked=0 and t.lockid=0 
            and t.cost>0 and t.price>0
            and fc.firmgroup=@firmgroup and t.id>0
            and t.morn-t.sell+t.isprav-t.remov-t.bad>0
      open cr
      fetch next from cr into @id, @q, @cost    --,@price	
      while @@fetch_status=0
      begin
        if @q>@cnt set @origqty=@cnt else set @origqty=@q
        
        if exists(select 1 from dbo.nv where datnom=@datnom and tekid=@id)
          update dbo.nv set kol=kol+@origqty where datnom=@datnom and tekid=@id
        else
          insert into dbo.nv (datnom, tekid, hitag, price, cost,  kol, sklad, /*baseprice,*/ origprice)
          values (@datnom, @id,  @hitag, round(@price, @RoundDec), @cost, @origqty, @sklad, /*@price,*/  @price);
        if @@error<>0 set @erreg=8
        
        update dbo.tdvi set sell=sell+@origqty where id=@id        
        set @cnt=@cnt-@origqty
        
        if @erreg=0 and @cnt>0 
        fetch next from cr into @id,@q,@cost--,@price	
        else break
      end
      close cr
      deallocate cr
      
      --закрытие заказа
      update z set z.done=1, z.tmend=convert(varchar(8),getdate(),108), z.dtend=convert(varchar(10),getdate(),104),
            			 --z.curweight=round(@QTY,0), z.tekweight=@tekweight, 
                   z.curweight=NULL, z.tekweight=NULL, 
                   z.confKol = @QTY, z.rest = @rest,                    
                   z.id=@id, z.comp=comp+'#'+@comp, z.op=@op, z.spk=@spk, group_id=@groupid
      from dbo.nvzakaz z        
      where nzid=@nzid
      if @@error<>0 set @erreg=@erreg+16
        
      --обновление данных маршрута
      if @mhid>0 and @erreg=0
      exec nearlogistic.updatemarshrequestparams @mhid, null
     end
  end
  
  
  if @work=4 --вчера штуки
  begin
  	
    if not exists(select 1 from dbo.tdvi t
    						  join dbo.firmsconfig fc on fc.our_id=t.our_id
                  where t.hitag=@hitag and t.sklad=@sklad and t.locked=0 and t.lockid=0 
                  			and fc.firmgroup=@firmgroup and t.id>0
                        and t.morn-t.sell+t.isprav-t.remov-t.bad>0
                  group by t.hitag
                  having sum(t.morn-t.sell+t.isprav-t.remov-t.bad)>=@cnt) set @erreg=@erreg+64  --нет требуемого остатка
     if @erreg=0
     begin
     	set @newdatnom=(select top 1 datnom from dbo.nc where nd=dbo.today() and refdatnom=@datnom and dck=@dck and b_id=@b_id and sp>=0);
        
      declare cr cursor fast_forward for
      select t.id,t.morn-t.sell+t.isprav-t.remov-t.bad [rest],t.cost--,t.price
      from dbo.tdvi t
      join dbo.firmsconfig fc on fc.our_id=t.our_id
      where t.hitag=@hitag and t.sklad=@sklad and t.locked=0 and t.lockid=0 
            and fc.firmgroup=@firmgroup and t.id>0
            and t.morn-t.sell+t.isprav-t.remov-t.bad>0
      open cr
      fetch next from cr into @id,@q,@cost--,@price	
      while @@fetch_status=0
      begin
        if isnull(@newdatnom,0)=0
        begin -- нет, придется завести:
          exec dbo.savezakaz @comp, @hitag, @id, @zakaz, @sklad, 0/*@savedzakaz*/, @price, null, null, null, 1,
            @dck, @stfnom, @stfdate, @docnom, @docdate, 0, 1, 1, @datnom;             
        end
        else -- уже есть накладная, впиливаем строки в нее:
        begin
        	if @q>@cnt set @origqty=@cnt else set @origqty=@q
            
          if exists(select 1 from dbo.nv where datnom=@newdatnom and tekid=@id)
            update dbo.nv set kol=kol+@origqty where datnom=@newdatnom and tekid=@id
          else
            insert into dbo.nv (datnom, tekid, hitag, price, cost,  kol, sklad, /*baseprice,*/ origprice)
            values (@newdatnom, @id,  @hitag, round(@price, @RoundDec), @cost, @origqty, @sklad, /*@price,*/  @price);
          if @@error<>0 set @erreg=8
            
          update dbo.tdvi set sell=sell+@origqty where id=@id        
          set @cnt=@cnt-@origqty
        end
      	if @erreg=0 and @cnt>0 
        fetch next from cr into @id,@q,@cost--,@price	
        else break
      end
      close cr
      deallocate cr
      
      if isnull(@newdatnom,0)=0
      begin
      exec dbo.savenakl @comp, @b_id, @fam, @our_id, @ag_id, @nc_op,  @srok,   
        @pko,  @man_id, @tovchk,  @remOP,  @actn, @ck, 0, @datnom, 0, @newdatnom output, 
        0,  '',  null, '', @dck, @b_id2, @needdover2,
        @stip,0, 0, @procerror output, @needdover2, 0                    
      	if @procerror<>0 set @erreg=@erreg+128
      end
      
      --закрытие заказа
      update z set z.done=1, z.tmend=convert(varchar(8),getdate(),108), z.dtend=convert(varchar(10),getdate(),104),
            			 --z.curweight=round(@QTY,0), z.tekweight=@tekweight, 
                   z.curweight=NULL, z.tekweight=NULL, 
                   z.confKol = @QTY, z.rest = @rest,                        
                   z.id=@id, z.comp=comp+'#'+@comp, z.op=@op, z.spk=@spk, group_id=@groupid
      from dbo.nvzakaz z        
      where z.nzid=@nzid
      if @@error<>0 set @erreg=@erreg+32
        
      --обновление данных маршрута
      if @mhid>0 and @erreg=0
      exec nearlogistic.updatemarshrequestparams @mhid, null
     end
  end
  
  
  /*завершение работы процедуры*/
  if @erreg=0
  begin
  	if @@trancount>0 commit tran @tranname
    --set @msg='@id = '+cast(@newid as varchar)
    if @work<>5
    update c set c.ready=0 from dbo.nc c 
    where c.datnom=iif(@newdatnom>0,@newdatnom,@datnom)    
    set @done=1
  end
  else
  begin
  	rollback tran @tranname
    set @done=0
    set @msg='['+cast(@work as varchar)+']'
    if (@erreg & 1)<>0 set @msg=@msg+'строка обработана;'+char(13)+char(10)
    if (@erreg & 2)<>0 set @msg=@msg+'на остатках нет куска весом равным или более чем '+cast(@QTY as varchar)+'кг;'+char(13)+char(10)
    if (@erreg & 4)<>0 set @msg=@msg+'ошибка при делении остатка @procerror = '+cast(@procerror as varchar)+'; @id = '+cast(@id as varchar)+';'+char(13)+char(10)
    if (@erreg & 8)<>0 set @msg=@msg+'ошибка записи в накладную;'+char(13)+char(10)
    if (@erreg & 16)<>0 set @msg=@msg+'ошибка закрытия заявки на набор;'+char(13)+char(10)
    if (@erreg & 32)<>0 set @msg=@msg+'ошибка закрытия заявки на разбор;'+char(13)+char(10)
    if (@erreg & 64)<>0 set @msg=@msg+'на остатках нет требуемого количества;'+char(13)+char(10)
    if (@erreg & 128)<>0 set @msg=@msg+'ошибка записи накладной @procerror = '+cast(@procerror as varchar)+char(13)+char(10)
  end
  
  set @mode_name = case when @mode=0 then 'Штрихкод'
  											when @mode=1 then 'Ручной'
                        when @mode=2 then 'Весы'
                        else 'Неизвестно' end
  
  insert into warehouse.terminal_shippingzakaz_log(nzid,ves,op,spk,msg,done)
	values (@nzid, @QTY, @op, @spk, iif(@done=1, '['+cast(@work as varchar)+']['
                                              +cast(isnull(@type,-1) as varchar)+']['+@mode_name+'] @id = '
                                              +cast(isnull(@newid,@id) as varchar),isnull(@msg,'')),
          @done)
  select cast(iif(@done=1,0,1) as bit) [res], @msg [msg]
  set nocount off
end