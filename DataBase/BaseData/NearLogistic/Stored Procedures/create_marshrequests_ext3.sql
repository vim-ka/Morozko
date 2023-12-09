CREATE procedure NearLogistic.create_marshrequests_ext3
 @delivdate DATETIME, @ext_pin_code varchar(50)
as
BEGIN
  declare  @docdate datetime, @docnom varchar(100), @extcode varchar(50), @mas decimal(15,2), @vol decimal(15,2), @box int, @pal decimal(15,4), @temp int, @cost money,
         @contact varchar(500), @remark varchar(500),
         @pinname varchar(100), 
         @ext_adress_code varchar(50), @adress varchar(500), @adress_name varchar(50), @tm varchar(5), @posx float, @posy float,
         @ext_sklad_code varchar(50), @sklad_adress varchar(500),@nal bit
  declare @ID INT 
  SET @ID=ISNULL((SELECT MIN(ID) FROM dbo.tempMarshRequestFree WHERE Del=0),-1)
  IF @ID >= 0 begin 

  SELECT 
         @extcode='Заявка№_'+FORMAT( @delivdate, 'dd.MM.yy', 'en-US' )+'_'+extcode, @mas=weight, @vol=0, @box=0, @pal=0, @temp=0,
         @cost=ISNULL(cost,0), @contact='', @remark=remark, @pinname=nAZS, 
         @ext_adress_code=extcode, @adress=AddrAZS, @adress_name=nAZS , @posx=posx, @posy=posy,
         @ext_sklad_code='mrz',/* @sklad_adress varchar(500)*/ @nal=0, @docdate=@delivdate, @docnom='№_'+FORMAT( @delivdate, 'dd.MM.yy', 'en-US' )+'_'+extcode
  FROM dbo.tempMarshRequestFree
  WHERE id=@id
 
	set nocount on
  
  declare @deliv_id int, @sklad_id int, @pin int, @reqid int
	
  IF not exists(select 1 from nearlogistic.marshrequests_points where extcode=@ext_adress_code)
  	/*update p set p.point_name = @adress_name, p.point_adress = @adress, p.tmDeliv = @tm,
                 p.posx = iif(isnull(@posx,0)>1,@posx,p.posx), p.posy = iif(isnull(@posy,0)>1,@posy,p.posy)
    from nearlogistic.marshrequests_points p
    where p.extcode=@ext_adress_code
  else*/
  	insert into nearlogistic.marshrequests_points(extcode, point_adress, point_name, tmdeliv, posx, posy)
    values(@ext_adress_code, @adress, @adress_name, @tm, @posx, @posy)
  
  select @deliv_id=point_id from nearlogistic.marshrequests_points where extcode=@ext_adress_code
  
  if NOT exists(select 1 from nearlogistic.marshrequests_points where extcode=@ext_sklad_code)
 /* 	update p set p.point_adress = @sklad_adress                 
    from nearlogistic.marshrequests_points p
    where p.extcode=@ext_sklad_code
  else*/
  	insert into nearlogistic.marshrequests_points(extcode, point_adress)
    values(@ext_sklad_code, @sklad_adress)
    
  select @sklad_id=point_id from nearlogistic.marshrequests_points where extcode=@ext_sklad_code
  
  /*
  if exists(select 1 from nearlogistic.marshrequests_cashers where extcode=@ext_pin_code)
  	update c set c.casher_name=@pinname
    from nearlogistic.marshrequests_cashers c
    where c.extcode=@ext_pin_code
  else 
  */
  if not exists(select 1 from nearlogistic.marshrequests_cashers where extcode=@ext_pin_code)
  	insert into nearlogistic.marshrequests_cashers(extcode, casher_name)
    values(@ext_pin_code, @pinname)
    
  select @pin=casher_id from nearlogistic.marshrequests_cashers where extcode=@ext_pin_code
  
  if exists(select 1 from nearlogistic.marshrequests_free where extcode=@extcode and pin=@pin and isdel=0)
  	update f set f.DocDate=@docdate, f.DocNumber=@docnom, f.cost=@cost, f.weight=@mas,
    						 f.volume=@vol, f.pal=@pal, f.kolbox=@box, f.temp=@temp, f.pin=@pin,
                 f.contact=@contact, f.remark=@remark, f.nd=@delivdate, f.nal = @nal                
    from nearlogistic.marshrequests_free f
    where f.extcode=@extcode
  else 
  	insert into nearlogistic.marshrequests_free(DocDate, DocNumber, cost, weight, volume, pal, kolbox, temp, pin, contact, remark, op, extcode, nd, nal)
    values(@docdate, @docnom, @cost, @mas, @vol, @pal, @box, @temp, @pin, @contact, @remark, 0, @extcode, @delivdate, @nal)
    
  select @reqid=mrfid from nearlogistic.marshrequests_free where extcode=@extcode
  
  if exists(select 1 from nearlogistic.marshrequestsdet where mrfid=@reqid and action_id=5)
  	update d set d.point_id=@sklad_id, d.nd=@docdate, d.place=0
    from nearlogistic.marshrequestsdet d
    where d.mrfid=@reqid and action_id=5
  else 
  	insert into nearlogistic.marshrequestsdet (mrfid, point_id, action_id, nd, place)
    values (@reqid, @sklad_id, 5, @docdate,0)
  
  if exists(select 1 from nearlogistic.marshrequestsdet where mrfid=@reqid and action_id=6)
  	update d set d.point_id=@deliv_id, d.nd=@delivdate, d.place=1
    from nearlogistic.marshrequestsdet d
    where d.mrfid=@reqid and action_id=6
  else 
  	insert into nearlogistic.marshrequestsdet (mrfid, point_id, action_id, nd, place)
    values (@reqid, @deliv_id, 6, @delivdate, 1)
  
	set nocount OFF
  END
 update dbo.tempMarshRequestFree SET Del=1 WHERE id=@id

end