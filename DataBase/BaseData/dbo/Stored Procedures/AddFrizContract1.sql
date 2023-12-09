CREATE procedure AddFrizContract1
  @B_ID int, @DCK int, @NDBeg DateTime, @Srok int, @Our_ID int, @OP int, @NeedNest int=0,
  @ContractID int OUTPUT, @ContractNo int=0 OUTPUT, @DopContractNo int OUTPUT, @NestNo int=0 OUTPUT
as
begin
  declare @ND DateTime,
          @tm varchar(8),
          @NDClose DateTime,
          @Master int,
          @CTip tinyint,
          @CTipIsh tinyint,
          @MorozNo int

  select @Master=master from Def where pin=@b_id
  
  set @ND = cast(floor(cast(getdate() as decimal(38,19))) as datetime)
  set @tm = Convert(varchar(8),GETDATE(),108)
  set @NDClose = @NDBeg + @Srok
  
  if @Master<>0 set @b_id=@Master
  
  if /*isnull(@ContractNo,0) = 0 and*/ @Srok<=0
  set @ContractNo = isnull((select max(ContractNo) from FrizContract where dck=@dck and AgrID<>5),0)
  else
  set @ContractNo = 0
  
  /*if @Srok=0 
  set @CTipIsh = isnull((select Ctip from FrizContract where ContractID=@ContractID),0)
  else
  set @CTipIsh = 0*/
  
  if @Our_ID = 7 and @Srok>0 set @CTip=4
  else if @Our_ID = 7 set @CTip=5
  else if @Srok=0 set @CTip=2
  else if @ContractNo = 0 set @CTip=0
  else set @CTip=1

  if (@CTip=1 or @CTip=4) and @Srok>0 set @CTip=0 --теперь договор БП вместо 1 и 4 
  
  if @ContractNo = 0
  begin
    set @ContractNo = (select max(ContractNo) from FrizContract) + 1
    set @DopContractNo = 0
  end
  else
  begin
    set @DopContractNo = isnull((select max(DopContrNo) from FrizContract where ContractNo=@ContractNo),-1) + 1
    if @NeedNest = 0 and @Srok<>0 and not exists(select * from FrizContract where ContractNo=@ContractNo and DopContrNo=0)
    set @DopContractNo=0
  end

  set @NestNo = 0
  set @MorozNo = 0
  
  if @NeedNest > 0
  begin
   set @NestNo=(select isnull(max(NestNo),0) from FrizContract) + 1                
   if @Srok>0 set @CTip=7 else
   begin
    set @CTip=8
    set @NestNo=@NeedNest
   end 
   if @DopContractNo=0 set @DopContractNo=1
  end 
  
  if @CTip = 4
  begin
    set @MorozNo=(select isnull(max(MorozNo),0) from FrizContract) + 1                
  end 
  
  insert into FrizContract (ContractNo,DopContrNo,ND,Tm,B_ID,Srok,Our_id,OP,NDBeg,NDClose,AgrID, CTip, NestNo, dck, MorozNo)
                    values (@ContractNo,@DopContractNo,@ND,@Tm,@B_ID,@Srok,@Our_id,@OP,@NDBeg,NULL,0, @CTip, @NestNo, @dck, @MorozNo)
  
  set @ContractId=@@IDENTITY
  select @ContractNo
  select @DopContractNo
  select @NestNo
end