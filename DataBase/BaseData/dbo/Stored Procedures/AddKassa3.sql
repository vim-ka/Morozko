CREATE procedure AddKassa3
  @Oper int, @Act varchar(4), @SourDate datetime,
  @Nnak int, @Plata money, @Fam varchar(30), 
  @P_ID int, @B_ID int, @V_ID int, @Ncod int,
  @remark varchar(60), @RashFlag tinyint, @LostFlag tinyint,
  @LastFlag tinyint, @Op int, @Bank_ID int,
  @Our_ID int, @BankDay datetime, @Actn tinyint, @Ck tinyint,
  @Thr int, @ThrFam varchar(40), @DocNom int, 
  @ForPrint tinyint, @OrigRecN int, @SourDatNom int, @StNom int,
  @FromBank_ID smallint, @SkladNo int, @DepID int=0, @Nalog float=0, @RemarkPlat varchar(150)='',
  @pin int=0, @KassaNo int=0, @RealOper bit=0, 
  @ksid int = 0 out, @NDInp datetime=null
as
begin
  if isnull(@Our_ID,0)=0 and @P_ID>0 set @Our_ID=(select our_id from person where p_id=@p_id)
  if isnull(@Our_ID,0)=0 set @Our_ID=6

  if (@SourDate<'19500101') set @SourDate=null; 
  if (@BankDay<'19500101') set @BankDay=null;   
  
  if (@Oper = -2) and (@SourDate is not null) set @SourDatNom = dbo.InDatNom(@Nnak,@SourDate)
insert into Kassa1(Nd,TM,
                   Oper,Act,SourDate,Nnak,Plata,Fam, P_ID,B_ID,V_ID,Ncod,
                   remark, RashFlag,LostFlag,LastFlag,
                   Op,Bank_ID,Our_ID,BankDay,Actn,Ck,
                   Thr,ThrFam,DocNom, ForPrint, OrigRecN, SourDatNom, StNom,
                   FromBank_ID, SkladNo, DepID, Nalog, RemarkPlat,pin,KassaNo, RealOper, NDInp)
values (convert(char(10), getdate(),104), convert(char(8), getdate(),108),
       @Oper,@Act,@SourDate,@Nnak,@Plata,@Fam, @P_ID,@B_ID,@V_ID,@Ncod,
       @remark, @RashFlag,@LostFlag,@LastFlag,
       @Op,@Bank_ID,@Our_ID,@BankDay,@Actn,@Ck,
       @Thr,@ThrFam,@DocNom, @ForPrint, @OrigRecN, @SourDatNom, @StNom,
       @FromBank_ID, @SkladNo, @DepID, @Nalog, @RemarkPlat,@pin,@KassaNo, @RealOper, @NDInp);
     
set @ksid=SCOPE_IDENTITY()    
select @ksid
end