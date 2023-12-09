create procedure restmon.NS_SaveNotSales
  @Hitag int, @Lim decimal(12,2), @unID tinyint, @perID tinyint
as
begin
  if @Lim=0 delete from RestMon.rm_NoSales where Hitag=@Hitag;
  else begin
    if exists(select * from RestMon.rm_NoSales where Hitag=@Hitag)
      update RestMon.rm_NoSales set Lim=@Lim, perID=@perID, unID=@unID where hitag=@Hitag;
    else 
      insert into RestMon.rm_NoSales(Hitag,Lim,perID,unID) values(@Hitag,@Lim,@perID,@unID);
  end;
end;