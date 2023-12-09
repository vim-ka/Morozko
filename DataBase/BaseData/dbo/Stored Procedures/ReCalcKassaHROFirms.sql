CREATE PROCEDURE dbo.ReCalcKassaHROFirms
AS
BEGIN
  Declare @Prihod money, @Rashod money, @PredKassMorn money
  Declare @PredND datetime, @TekND datetime
  Declare @ND datetime, @Our_ID int, @Plata money, @Rec bit

 /*курсор по организациям*/         
  DECLARE @CURSOR CURSOR 
  SET @CURSOR  = CURSOR SCROLL
  FOR SELECT Our_ID FROM FirmsConfig ORDER BY Our_ID desc
  
  OPEN @CURSOR 

  set @PredND=(select MAX(nd) from KassaHROFirms)
  set @TekND = dateadd(day, 1, @PredND)
  set @Rec=0

  FETCH NEXT FROM @CURSOR INTO @Our_ID
  WHILE @@FETCH_STATUS = 0
  BEGIN   
  
    set @PredKassMorn=ISNULL((select KassMorn from KassaHROFirms where nd=@PredND and Our_ID=@Our_ID),0)
    
    set @Prihod=ISNULL((select sum(k.plata) from kassa1 k where k.nd>=@PredND and k.nd<=@PredND and k.bank_id=0 and k.oper in (select o.oper from KsOper o where o.rashflag=0) and k.Our_ID=@Our_ID),0)
    set @Rashod=ISNULL((select sum(k.plata) from kassa1 k where k.nd>=@PredND and k.nd<=@PredND and (k.bank_id=0 or (k.bank_id=k.FromBank_id and k.bank_id>0)) and k.oper in (select o.oper from KsOper o where o.rashflag=1) and k.Our_ID=@Our_ID),0)
  
    if (@Our_ID=0 and @Rec=0) or ((@PredKassMorn + @Prihod - @Rashod<>0) and (not exists (select * from KassaHROFirms where ND=@TekND and Our_ID=@Our_ID)))
    begin
      insert into KassaHROFirms (ND, Our_ID, KassMorn) values (@TekND, @Our_ID, @PredKassMorn + @Prihod - @Rashod)
      set @Rec=1
    end
    else    
    update KassaHROFirms set KassMorn=@PredKassMorn + @Prihod - @Rashod where ND=@TekND and Our_ID=@Our_ID 
    
        
    FETCH NEXT FROM @CURSOR INTO @Our_ID
  END

  CLOSE @CURSOR 

END