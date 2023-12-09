CREATE procedure Guard.SaveKolbasPlan @ND datetime, @AG_ID int, @B_ID int, @Weight int=0
as
begin
  -- if @Weight=0 delete from Guard.kolbasplan where nd=@ND and ag_ID=@AG_ID and b_id=@B_ID;
  -- else 
  if exists(select * from Guard.kolbasplan where nd=@ND and ag_ID=@AG_ID and b_id=@B_ID) 
    update Guard.kolbasplan set KolbasWeight=@Weight where nd=@ND and ag_ID=@AG_ID and b_id=@B_ID;
  else insert into Guard.kolbasplan(nd,ag_id,b_id,KolbasWeight) values(@nd,@ag_id,@b_id,@weight);
end