create procedure SaveBigPriceList
  @B_ID int, @Comp varchar(16), @OP int, 
  @NewPrice decimal(12,2), @Hitag int,  @isWeight bit=0
as 
declare @OldPrice decimal(12,2)
begin
  if @NewPrice=-1 -- команда на удаление
    delete from BigPriceList where B_ID=@B_ID and Hitag=@Hitag;
  else begin
  
    set @OldPrice=(select Price from BigPriceList where B_ID=@B_ID and Hitag=@Hitag);
  
    if @OldPrice is NULL
      insert into BigPriceList(hitag,b_id,price,isWeight,COMP,Op,Saved)
      values(@hitag,@B_ID,@NewPrice,@isWeight,@Comp,@OP, getdate());
    else if abs(@OldPrice-@NewPrice)>=0.01
      update BigPriceList set Price=@NewPrice, Comp=@Comp, Op=@Op,
      Saved=getdate() where b_id=@B_ID and Hitag=@Hitag;
  end;
end