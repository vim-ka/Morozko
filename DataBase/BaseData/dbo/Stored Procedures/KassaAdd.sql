CREATE PROCEDURE dbo.KassaAdd
  @Oper int, @Act varchar(4), @SourDate datetime,
  @Nnak int, @Plata money, @Fam varchar(30), 
  @P_ID int, @B_ID int, @V_ID int, @Ncod int,
  @remark varchar(60), @RashFlag tinyint, @LostFlag tinyint,
  @LastFlag tinyint, @Op int, @Bank_ID int,
  @Our_ID int, @BankDay datetime, @Actn tinyint, @Ck tinyint,
  @Thr int, @ThrFam varchar(40), @DocNom int, 
  @ForPrint tinyint, @OrigRecN int, @SourDatNom int, @StNom int,
  @FromBank_ID smallint, @SkladNo int, @DepID int=0, @Nalog float=0, @RemarkPlat varchar(150)='',
  @pin int=0, @KassaNo int=0, @RealOper bit=0, @DCK int = 0, 
  @NDInp datetime , @InBank bit = 0, @ksid int = 0 out
AS
BEGIN
  
  if isnull(@ksid,0) = 0 --Добавление операции
  begin
    if (@SourDate<'19500101') set @SourDate=null; 
    if (@BankDay<'19500101') set @BankDay=null;   
    if (@NDInp<'19500101') set @NDInp=null;      
    if (@Oper = -2) and (@SourDate is not null) set @SourDatNom = dbo.InDatNom(@Nnak,@SourDate)
    if (@Oper = -1) and (isnull(@pin,0)=0) set @pin=isnull((select min(pin) from Def where Ncod=@Ncod),0)
    
    --if (@Oper = 59) and (@Op>1000) and (@StNom=0) set @StNom=@P_ID*100+1 else set @StNom=0 
  
    set @Bank_ID=isNull(@Bank_id,0)
    
        
    if @DepID>0 and isnull((select our_id from Deps where DepID=@DepID),0)<>0 set @Our_ID=(select our_id from Deps where DepID=@DepID) else
    if isnull(@Our_ID,0)=0 and @P_ID>0 set @Our_ID=(select our_id from person where p_id=@p_id) else
    if isnull(@Our_ID,0)=0 set @Our_id=8
  
    if @Our_id=0 set @Our_ID=(select our_id from Deps where DepID=@DepID)
  
    insert into Kassa1(Nd,TM,Oper,Act,SourDate,Nnak,Plata,Fam, P_ID,B_ID,V_ID,Ncod,
                       remark, RashFlag,LostFlag,LastFlag,Op,Bank_ID,Our_ID,BankDay,Actn,Ck,
                       Thr,ThrFam,DocNom, ForPrint, OrigRecN, SourDatNom, StNom, FromBank_ID,
                       SkladNo, DepID, Nalog, RemarkPlat,pin,KassaNo, RealOper, DCK, NDInp, InBank)
    values (convert(char(10), getdate(),104), convert(char(8), getdate(),108),
                       @Oper,@Act,@SourDate,@Nnak,@Plata,@Fam, @P_ID,@B_ID,@V_ID,@Ncod,
                       @remark, @RashFlag,@LostFlag,@LastFlag, @Op,@Bank_ID,@Our_ID,@BankDay,@Actn,@Ck,
                       @Thr,@ThrFam,@DocNom, @ForPrint, @OrigRecN, @SourDatNom, @StNom,
                       @FromBank_ID, @SkladNo, @DepID, @Nalog, @RemarkPlat,@pin,@KassaNo, @RealOper, @DCK, @NDInp, @InBank);
     
    set @ksid=SCOPE_IDENTITY()    
  end
  else -- Редактирование операции
  begin
    declare @ND datetime,@MaxDepthEdit int
    set @ND=(select nd from kassa1 where kassid=@ksid)
    set @MaxDepthEdit=(select cast(val as int) from config where param='MaxDepthEditKassa')
    
    if @ND>=dbo.today()-@MaxDepthEdit
    begin
    
    
      if (@SourDate<'19500101') set @SourDate=null; 
      if (@BankDay<'19500101') set @BankDay=null;   
      if (@NDInp<'19500101') set @NDInp=null;      
      
      declare @Oper_OLD int, @P_ID_OLD int
      select @Oper_OLD=Oper, @P_ID_OLD=p_id from kassa1 where KassID=@ksid
      
      update dbo.Kassa1  
      set 
      Oper = @Oper,
      Act = @Act,
      SourDate = @SourDate,
      Nnak = @Nnak,
      Plata = @Plata,
      Fam = @Fam,
      P_ID = @P_ID,
      B_ID = @B_ID,
      V_ID = @V_ID,
      Ncod = @Ncod,
      Remark = @Remark,
      RashFlag = @RashFlag,
      LostFlag = @LostFlag,
      LastFlag = @LastFlag,
      Op = @Op,
       Bank_ID = @Bank_ID,
      Our_ID = @Our_ID,
      BankDay = @BankDay,
      Actn = @Actn,
      Ck = @Ck,
      Thr = @Thr,
      ThrFam = @ThrFam,
      DocNom = @DocNom,
      OrigRecn = @OrigRecn,
      ForPrint = @ForPrint,
      SourDatNom = @SourDatNom,
      StNom = @StNom,
      FromBank_ID = @FromBank_ID,
      SkladNo = @SkladNo,
      DepID = @DepID,
      --OperOld = @OperOld,
      NDInp = @NDInp,
      InBank = @InBank,
      Nalog = @Nalog,
      RemarkPlat = @RemarkPlat,
      pin = @pin,
      --platarez = @platarez,
      --B_IDPlat = @B_IDPlat,
      DCK = @DCK,
      KassaNo = @KassaNo,
      RealOper = @RealOper
 
      where KassID = @ksid
    
      if (@Oper = 10 or @Oper = 59  or @Oper_OLD = 10  or @Oper_OLD = 59)
      begin
        execute CheckPerson @P_ID_OLD;  
        if @P_ID_OLD<>@P_ID execute CheckPerson @P_ID;
      end  
    end else set @ksid=-2
  end  
  
  select @ksid
  
END