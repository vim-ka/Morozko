CREATE PROCEDURE NearLogistic.SetMarshRequestFree
@id int output, @nd datetime, @pin int, @remark varchar(500), @cost decimal(15,2),
@weight decimal(15,2), @volume decimal(15,4), @kolbox decimal(15,2), @op int, @isDel bit =0,
@contact varchar(500) ='', @pallet int =0, @point_id int =0, @action int =5
AS
BEGIN
  if @id=-1
  begin
   insert into NearLogistic.MarshRequests_free(nd,pin,remark,cost,weight,volume,kolbox,op,contact,pallet_count,point_id,point_action)
    values(@nd,@pin,@remark,@cost,@weight,@volume,@kolbox,@op,@contact,@pallet,@point_id,@action)
    set @id=@@identity
  end
  else
  begin
   if @isDel=0
    begin
      update mf set nd=@nd, pin=@pin, remark=@remark, cost=@cost, weight=@weight, volume=@volume,
                    kolbox=@kolbox, op=@op, contact=@contact, pallet_count=@pallet, point_id=@point_id,
                    point_action=@action
      from NearLogistic.MarshRequests_free mf
      where mrfID=@id
    end
    else
    begin
      update mf set isdel=@isDel, op=@op
      from NearLogistic.MarshRequests_free mf
      where mrfID=@id    
    end
  end
END