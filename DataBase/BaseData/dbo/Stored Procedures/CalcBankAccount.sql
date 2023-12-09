CREATE PROCEDURE dbo.CalcBankAccount
AS
BEGIN
  Declare @Prihod money, @Rashod money, @InitPlata money
  Declare @PredND datetime, @TekND datetime
  

  --select @PredND = max(NDFact) from BankAccount 
  select @PredND = val from Config where Param='LastCalcDay'
  set @PredND = FORMAT( @PredND, 'd', 'de-de' )
  
  set @TekND = dateadd(day,1,@PredND)
  set @TekND = FORMAT( @TekND, 'd', 'de-de' )
  
  --insert into BankAccount (ND,Bank_ID,SumAC)
  --select @TekND,Bank_ID,SumAC from BankAccount where ND=@PredND
  
  create table #TempTable (BankDay datetime, Bank_ID int, Plata money);

  INSERT into #TempTable (BankDay, Bank_ID, Plata)
  SELECT k.BankDay, k.Bank_ID, sum(case when ko.rashflag = 1 and k.FromBank_ID<>k.bank_id then -k.plata else k.plata end) as Plata
  FROM Kassa1 k left join KsOper ko on k.Oper=ko.Oper 
  WHERE k.ND = @PredND and k.Bank_ID>0 and k.BankDay>='20110901'
  GROUP BY k.BankDay, k.Bank_ID
  ORDER BY k.Bank_ID, k.BankDay
      
  DECLARE @BankDay datetime, @Bank_ID int, @Plata money

 /*курсор по расчетным счетам*/         
  DECLARE @CURSOR CURSOR 
  SET @CURSOR  = CURSOR SCROLL
  FOR SELECT BankDay, Bank_ID, Plata FROM #TempTable ORDER BY Bank_ID, BankDay
  
  OPEN @CURSOR 

  FETCH NEXT FROM @CURSOR INTO @BankDay, @Bank_ID, @Plata
  WHILE @@FETCH_STATUS = 0
  BEGIN   
    if not exists (select * from BankAccount where ND=@BankDay  and Bank_ID=@Bank_ID)
    begin
      set @InitPlata=isnull((select SumAc from BankAccount where BID=
          (select max(BID) from BankAccount where ND<@BankDay and Bank_ID=@Bank_ID)),0)
      insert into BankAccount(ND, Bank_ID, SumAc) values (@BankDay, @Bank_ID, @InitPlata)      
    end  
    
    update BankAccount set SumAc=SumAc + @Plata where ND>=@BankDay and Bank_ID=@Bank_ID 
    
    update Banks set RschetMoney = RschetMoney + @Plata where Bank_ID=@Bank_ID       
    
    FETCH NEXT FROM @CURSOR INTO @BankDay, @Bank_ID, @Plata
  END

  CLOSE @CURSOR 
  
  update config set val=FORMAT( @TekND, 'd', 'de-de' ) where Param='LastCalcDay'
 
END