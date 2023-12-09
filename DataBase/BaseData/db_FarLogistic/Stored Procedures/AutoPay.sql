CREATE PROCEDURE [db_FarLogistic].AutoPay
@CasherID int,
@OP int,
@PayType int,
@Acc int=1,
@Com varchar(max),
@Cost money,
@str varchar(max),
@auto bit
AS
declare @TranName varchar(8)
select @TranName = 'AutoPay'
BEGIN TRAN @TranName

declare @BillID int
declare @Paided money 
declare @ForPay money
declare @TmpCost money
declare @Advance money
declare @SumAdvance money
declare @AdvID int
declare @TmpBill int
declare @WorkCount int
declare @AdvCount int
declare @NewAdv money

set @WorkCount=0
set @AdvCount=0
set @NewAdv=0

declare cur_adv cursor for
	select p.AdvID, sum(p.SumPayment) SumPayment
	from db_FarLogistic.dlPayments p
	where (not p.AdvID is null) and p.CasherID=@CasherID
	group by p.CasherID, p.AdvID
  having sum(p.SumPayment)<>0
  
open cur_adv
--сначала пробежка по авансам
fetch next from cur_adv into 
@AdvID, @Advance

if @auto=1	
		declare cur_dbt scroll cursor for 
  	select b.dlGroupBillID, b.Paided, b.ForPay
  	from db_FarLogistic.dlGroupBill b
  	where b.CasherID=@CasherID and b.ForPay-b.Paided<>0
  else
  	declare cur_dbt scroll cursor for 
  	select b.dlGroupBillID, b.Paided, b.ForPay
  	from db_FarLogistic.dlGroupBill b
  	where b.CasherID=@CasherID and b.ForPay-b.Paided<>0 and b.dlGroupBillID in (select s.number from db_FarLogistic.String_to_Int(@str) s)
  
open cur_dbt

while @@fetch_status=0 
begin	
  fetch next from cur_dbt into 
  @BillID, @Paided, @ForPay
  
  set @SumAdvance=@Advance
  --пробежка по долгам
  while @@fetch_status=0
  begin  	
    if @ForPay-@Paided>@Advance
    begin
    --аванс меньше долга
    	update db_FarLogistic.dlGroupBill set
      Paided=@Paided+@Advance,
      PaymentDate=getdate()
      where dlGroupBillID=@BillID
      
      insert into db_FarLogistic.dlPayments(OP,PaymentDate,SumPayment,CasherID,Com,WorkID,Auto,PaymentType,IDAccount,AdvID) 
			values (@op,getdate(),-@SumAdvance,@CasherID,@Com,@BillID,@auto,@PayType,@Acc, @AdvID)
      
      set @AdvCount=@AdvCount+1
      
      break
    end
  	else
    begin
    --аванс больше долга
    	update db_FarLogistic.dlGroupBill set
      Paided=@ForPay,
      PaymentDate=getdate()
      where dlGroupBillID=@BillID
      
      set @SumAdvance=@SumAdvance-@ForPay+@Paided
      
      insert into db_FarLogistic.dlPayments(OP,PaymentDate,SumPayment,CasherID,Com,WorkID,Auto,PaymentType,IDAccount,AdvID) 
			values (@op,getdate(),-(@ForPay-@Paided),@CasherID,@Com,@BillID,@auto,@PayType,@Acc,@AdvID)
      
      set @WorkCount=@WorkCount+1
    end
    
    if @SumAdvance=0 
    break
    
  	fetch next from cur_dbt into 
  	@BillID, @Paided, @ForPay
  end  
  
  fetch first from cur_dbt into
  @BillID, @Paided, @ForPay
  
	fetch next from cur_adv into 
	@AdvID, @Advance
end  

close cur_adv
deallocate cur_adv

set @TmpCost=@Cost
if @TmpCost>0
begin
	close cur_dbt
  open cur_dbt
  
  fetch first from cur_dbt into
  @BillID, @Paided, @ForPay
     
	--пробежка по долгам
  while @@fetch_status=0
  begin
    if @ForPay-@Paided>@TmpCost
    begin
    --платеж меньше долга
      update db_FarLogistic.dlGroupBill set
      Paided=@Paided+@TmpCost,
      PaymentDate=getdate()
      where dlGroupBillID=@BillID
        
      insert into db_FarLogistic.dlPayments(OP,PaymentDate,SumPayment,CasherID,Com,WorkID,Auto,PaymentType,IDAccount) 
      values (@op,getdate(),@TmpCost,@CasherID,@Com,@BillID,@auto,@PayType,@Acc)
      
      set @TmpCost=0
    end 
    else
    begin
    --платеж больше долга
      update db_FarLogistic.dlGroupBill set
      Paided=@ForPay,
      PaymentDate=getdate()
      where dlGroupBillID=@BillID
        
      insert into db_FarLogistic.dlPayments(OP,PaymentDate,SumPayment,CasherID,Com,WorkID,Auto,PaymentType,IDAccount) 
      values (@op,getdate(),@ForPay-@Paided,@CasherID,@Com,@BillID,@auto,@PayType,@Acc)
      
      set @WorkCount=@WorkCount+1
      
      set @TmpCost=@TmpCost-@ForPay+@Paided
    end
  	
    --выход если нечего разносить
    if @TmpCost=0 
    break
    
    fetch next from cur_dbt into 
    @BillID, @Paided, @ForPay
  end
	
  --запись остатка платежа как аванс
  if @TmpCost<>0
  begin
    select @AdvID=min(isnull(p.AdvID,0))-1 from db_FarLogistic.dlPayments p where p.CasherID=@CasherID and (not p.AdvID is null)
  	
    set @NewAdv=@TmpCost
    
    insert into db_FarLogistic.dlPayments(OP,PaymentDate,SumPayment,CasherID,Com,Auto,PaymentType,IDAccount,AdvID) 
    values (@op,getdate(),@TmpCost,@CasherID,@Com,@auto,@PayType,@Acc,@AdvID)
  end
end

close cur_dbt
deallocate cur_dbt

if @@ERROR = 0 
begin
	COMMIT TRAN @TranName
	select 0 Res, @AdvCount AdvCount, @WorkCount WorkCount, @NewAdv NewAdv
end
ELSE 
begin
	ROLLBACK TRAN @TranName
  select -1 Res
end