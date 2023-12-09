CREATE procedure AddKassa4
  @Oper int, @Act varchar(4), @SourDate datetime,
  @Nnak int, @Plata money, @Fam varchar(30), 
  @P_ID int, @B_ID int, @V_ID int, @Ncod int,
  @remark varchar(60), @RashFlag tinyint, @LostFlag tinyint,
  @LastFlag tinyint, @Op int, @Bank_ID int,
  @Our_ID int, @BankDay datetime, @Actn tinyint, @Ck tinyint,
  @Thr int, @ThrFam varchar(40), @DocNom int, 
  @ForPrint tinyint, @OrigRecN int, @SourDatNom int, @StNom int=0, @FromBank_ID smallint, @SkladNo int, @DepID int=0,
  @NDInp datetime, @InBank bit
as
begin
  if (@SourDate<'19500101') set @SourDate=null; 
  if (@BankDay<'19500101') set @BankDay=null;   
  if (@SourDate<'19500101') set @SourDate=null;   
  if (@NDInp<'19500101') set @NDInp=null;   
  if (@Oper = -2) and (@SourDate is not null) set @SourDatNom = dbo.InDatNom(@Nnak,@SourDate)
  if (@Oper = 59) and (@Op>1000) and (@StNom=0) set @StNom=@P_ID*100+1;
  
insert into Kassa1(Nd,TM,
   Oper,Act,SourDate,Nnak,Plata,Fam, P_ID,B_ID,V_ID,Ncod,
   remark, RashFlag,LostFlag,LastFlag,
   Op,Bank_ID,Our_ID,BankDay,Actn,Ck,
   Thr,ThrFam,DocNom, ForPrint, OrigRecN, SourDatNom, StNom, FromBank_ID, SkladNo, DepID, NDInp, InBank)
values(
  convert(char(10), getdate(),104),
  convert(char(8), getdate(),108),
  @Oper,@Act,@SourDate,@Nnak,@Plata,@Fam, @P_ID,@B_ID,@V_ID,@Ncod,
     @remark, @RashFlag,@LostFlag,@LastFlag,
     @Op,@Bank_ID,@Our_ID,@BankDay,@Actn,@Ck,
     @Thr,@ThrFam,@DocNom, @ForPrint, @OrigRecN, @SourDatNom, @StNom, @FromBank_ID, @SkladNo, @DepID, @NDInp, @InBank);
end