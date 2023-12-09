CREATE procedure NearLogistic.create_marshrequests_ext2
@extcode varchar(50), @docdate datetime, @docnom varchar(100), 
@mas decimal(15,2), @vol decimal(15,2), @box int, @pal decimal(15,4), 
@temp int, @cost money, @contact varchar(500), @remark varchar(500),
@ext_pin_code varchar(50), @ext_adress_code varchar(50),  @ext_sklad_code varchar(50), 
@delivdate datetime, @nal bit
as
begin
	set nocount on
  
  declare @deliv_id int, @sklad_id int, @pin int, @reqid int

  select @deliv_id=isnull(point_id,0) from nearlogistic.marshrequests_points where extcode=@ext_adress_code
  select @sklad_id=isnull(point_id,0) from nearlogistic.marshrequests_points where extcode=@ext_sklad_code
  select @pin=isnull(casher_id,0) from nearlogistic.marshrequests_cashers where extcode=@ext_pin_code
  
  if @deliv_id<>0 and @pin<>0
  begin
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
  
  end
  set nocount off
end