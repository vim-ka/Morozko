CREATE procedure dbo.AddTdNV2  @nd datetime, @Nnak INT, @tekid int,
  @price money, @cost money, @Kol decimal(12,3), @Sklad smallint, 
  @Kol_B decimal(12,3), @Hitag int=0
as
begin
  if @TekID = 0 and @hitag > 0
  begin
    select top 1 @tekid=v.id, @price=v.price, @cost=v.cost, @sklad=v.sklad
    from tdvi v join SkladList s on v.sklad=s.skladno
    where v.morn-v.sell+v.isprav-v.remov>=@Kol and v.hitag=@hitag
          and s.Discard=0 and s.Discount=0 and s.SafeCust=0
          and s.Locked=0 and v.Locked=0
   order by isnull(v.dater, '20010101')      
  end
  if isnull(@tekid,0) > 0
  begin
    if @hitag=0 set @Hitag=(select hitag from tdvi where id=@tekid);
    if isnull(@hitag,0)=0 set @Hitag=(select hitag from visual where id=@tekid);
  
    insert into NV(DatNom,TekId,Hitag,Price,Cost,Kol,Kol_B,Sklad)
    values(dbo.InDatNom(@nnak, @nd),@TekId,@Hitag,@Price,@Cost,@Kol,@Kol_B,@Sklad);
  
    update tdVi set sell=sell+(@kol)  where id=@tekid
  end  
end