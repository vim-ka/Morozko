CREATE procedure dbo.EditPrintOptions_copy
  @rec int out, -- rec=0-новый, rec>0-редактировать, rec<0-стереть
  @ourID int, @Pin int, @Dck int,   @DckVend int,
  @QtyNakl int,
  @QtyStf int, @QtyTorg12 int, @QtyBill INT,
  @QtyDover INt, @QtyTTN int,
  @QtyUpd int,
  @StfBase varchar(40),
  @Remark varchar(60),
  @op int=0,
  @QtyDover2 int=0,
  @DepID smallint=-1
as begin 

  if @rec=0 begin  
    INSERT INTO PrintOptions_Copy(OurID,  Pin,  Dck,  QtyNakl,  QtyStf,  QtyTorg12,
      QtyTtn,  QtyBill,  QtyDover,  StfBase,  Remark,  QtyUPD, DCKVend,op, QtyDover2, DepID) 
    VALUES (@OurID,  @Pin,  @Dck,  @QtyNakl,  @QtyStf,  @QtyTorg12,
      @QtyTtn,  @QtyBill,  @QtyDover,  @StfBase,  @Remark,  @QtyUPD, @DCKVend,@op, @QtyDover2, @DepId) ;
    set @rec=SCOPE_IDENTITY();
  end;

  else if @rec>0
    update PrintOptions_Copy
    set   
      OurID=@OurID,
      Pin=@Pin,
      dck=@dck,
      QtyNakl=@QtyNakl,
      QtyStf=@QtyStf,
      QtyTorg12=@QtyTorg12,
      QtyTtn=@QtyTtn,
      QtyBill=@QtyBill,
      QtyDover=@QtyDover,
      StfBase=@StfBase,
      Remark=@Remark,
      QtyUPD=@QtyUPD,
      dckVend=@dckVend,
      op=@op,
      QtyDover2=@QtyDover2,
      DepID=@DepId
    where rec=@rec;
  
  else if @rec<0 delete from PrintOptions_Copy where rec=abs(@rec);
end;