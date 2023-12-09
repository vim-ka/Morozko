
CREATE procedure dbo.UpdateExiteNomen 
  @Hitag int, @PLU varchar(80), @FName varchar(75),
  @ActionInPosition tinyint, @CLID smallint, @Units varchar(3)='PCE', @ND datetime
as 
declare @ID int,
   @MinP int,
   @NDS decimal(10,2),
   @Weight decimal(10,3),
   @LastTekID integer,
   @Price money,
   @BarCode varchar(20),
   @CLGroup int, @TekCLID int
  
begin
  select @Nds=Nds, @MinP=MinP, @Price=Price, @BarCode=BarCode, @Weight=Netto
  from Nomen where Hitag=@Hitag;
 
  set @CLGroup=(select CLGroup from exite_clients ec where ec.CLID=@CLID)
  
  declare c1 cursor fast_forward 
    for select CLID from exite_clients where CLGroup=@CLGroup
  
  open c1
  fetch next from c1 into @TekCLID
  
  while @@FETCH_STATUS=0 
  begin
      set @ID=(select ID from Exite_Nomen where PLU=@PLU and CLID=@TekCLID and Hitag=@Hitag);
  
      update exite_nomen set DateRemove=@ND-1 where PLU=@PLU and CLID=@TekCLID and (DateRemove is null or DateRemove>@ND-1) 
      
      if @ID is NULL 
      begin
        insert into Exite_Nomen(Hitag,dateAdd,DateRemove,PLU,FName,
          DelivQuantum, NDS, PriceWithNDS, PriceWithoutNDS,
          ActionInPosition, BarCode, WEIGHT, CLID, OrderUnit)
        values(@Hitag,@ND,NULL,@PLU,@FName,
          @MinP, @NDS, @Price, @Price*100.0/(100.0+@Nds),
          0, @BarCode, @WEIGHT, @TekCLID, @Units);
      end   
      else 
        update exite_nomen set 
         DelivQuantum=@MinP,
         NDS=@NDS,
         PriceWithNDS=@Price,
         PriceWithoutNDS=@Price*100.0/(100.0+@Nds),
         ActionInPosition=@ActionInPosition,
         BarCode=@BarCode,
         Weight=@Weight,
         OrderUnit=@Units,
         dateremove=NULL,
         dateadd=@ND
        where PLU=@PLU and CLID=@TekCLID and Hitag=@Hitag;
         
    update exite_orderDet  set supplierProductId=@Hitag where BuyerProductId=@Plu and supplierProductId is null;
    fetch next from c1 into @TekCLID
  end
  close c1
  deallocate c1
end