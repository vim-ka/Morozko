CREATE procedure NearLogistic.create_update_request 
@request_id int output, @cost money=0, @contact varchar(500)='', @remark varchar(500)='', @op int, @pin int,
@mas decimal(15,4), @vol decimal(15,4), @pal decimal(15,4), @box decimal(15,4), @nal bit, @docnd datetime, @docnum varchar(100)
as
begin
if @request_id=0
begin
 insert into nearlogistic.marshrequests_free(pin, cost, remark, contact, op, weight, volume, pallet_count, kolbox, nal, docdate, docnumber)
  values(@pin, @cost, @remark, @contact, @op, @mas, @vol, @pal, @box, @nal, @docnd, @docnum)
  set @request_id=@@identity
end
else
 update a set a.pin=@pin, a.cost=@cost, a.contact=@contact, a.remark=@remark, a.op=@op,
         a.weight=@mas, a.volume=@vol, a.pallet_count=@pal, a.kolbox=@box, a.nal=@nal, 
               a.docdate=@docnd, a.docnumber=@docnum
  from nearlogistic.marshrequests_free a where a.mrfID=@request_id
end;