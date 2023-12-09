CREATE procedure AddFrizContract
  @B_ID int, @NDBeg DateTime, @Srok int, @Our_ID int, @OP int, @NeedNest tinyint=0,
  @ContractID int OUTPUT, @ContractNo int=0 OUTPUT, @DopContractNo int OUTPUT, @NestNo int=0 OUTPUT
as
begin
  Declare @ND DateTime,
          @tm varchar(8),
          @NDClose DateTime,
          @Master int,
          @CTip tinyint

  select @Master=master from Def where pin=@b_id and tip=1
  
  set @ND = cast(floor(cast(getdate() as decimal(38,19))) as datetime)
  set @tm = Convert(varchar(8),GETDATE(),108)
  set @NDClose = @NDBeg + @Srok
  
  if @Master<>0 set @b_id=@Master
  if @ContractNo = 0
  set @ContractNo = isnull((select max(ContractNo) from FrizContract where b_id=@b_id and AgrID<>5),0)
  
  if @Our_ID = 7 set @CTip=4
  else if @Srok=0 set @CTip=2
  else if @ContractNo = 0 set @CTip=0
  else set @CTip=1
  
  if @ContractNo = 0
  begin
    set @ContractNo = (select max(ContractNo) from FrizContract) + 1
    set @DopContractNo = 0
  end
  else
  begin
    set @DopContractNo =  (select max(DopContrNo) from FrizContract where ContractNo=@ContractNo) + 1
  end

  set @NestNo = 0
  
  if @NeedNest = 1
  begin
   set @NestNo=(select isnull(max(NestNo),0) from FrizContract) + 1                
   set @CTip=7
  end 
  
  insert into FrizContract (ContractNo,DopContrNo,ND,Tm,B_ID,Srok,Our_id,OP,NDBeg,NDClose,AgrID, CTip, NestNo)
                    values (@ContractNo,@DopContractNo,@ND,@Tm,@B_ID,@Srok,@Our_id,@OP,@NDBeg,NULL,0, @CTip, @NestNo)
  
  set @ContractId=@@IDENTITY
  select @ContractNo
  select @DopContractNo
  select @NestNo
end