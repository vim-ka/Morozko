CREATE procedure ReadOurData @datnom int
as
declare @B_ID int, @B_ID2 int, @gpOurID int, @OurID int, @Dck int, @Bank_ID INT,
  @gpOurName varchar(60), @gpOurInn varchar(15), @Actn bit,
  @gpOurKpp varchar(10),@OurKpp varchar(10),
  @OurAddrJ varchar(70),@OurAddrF varchar(70), @OurINN varchar(20), 
  @OurName varchar(60), @OurFullName varchar(101),  
  @CompRegName varchar(20), @Actual bit, 
  @okpo varchar(10), @okpo2 varchar(10), 
  @ourOkpo varchar(10), @ourOkpo2 varchar(10), 
  @okdp varchar(20),
  @OurLicNo varchar(70), @OurLICWHO varchar(70), 
  @OurLICSROK datetime, @GlavBuhDov varchar(40),
  @OurC_SCHET varchar(20),@OurR_SCHET varchar(20), 
  @OurInpOffset int, @OurNds smallint,
  @gpOurAddr_j varchar(70), @gpOurAddr_F varchar(70), 
  @ourBank varchar(80), @OurBik varchar(20), @OurPhone varchar(60), 
  @ourDirektor varchar(20), @gpDirektor varchar(20), 
  @gpGlavbuh varchar(20),@ourGlavbuh varchar(20),
  @Osn varchar(100), @RemarkOp varchar(100),  @BonusMess varchar(30),
  @Extra decimal(6,2), @ContrTip smallint, @brmaster int,
  @gpAddr varchar(200),
  @gpName varchar(100),
  @gpIndex varchar(6),
  @gpInn varchar(12),
  @gpBank varchar(60),
  @gpBank_ID int,
  @gpBik varchar(9),
  @gpRS varchar(20),
  @gpCS varchar(20),
  @gpPhone varchar(50),
  @gpOkpo varchar(10),
  @gpOkpo2 varchar(10),
  @contrNum varchar(50),
  @contrDate datetime,
  @AgentFam varchar(100),
  @AgentPhone varchar(50),
  @SuperPhone varchar(50),
  @Bank_Name varchar(80),
  @Bank_Address varchar(50),
  @Bank_BIK varchar(15),
  @Bank_CShet varchar(100),
  @Bank_RShet varchar(100),
  @Bank_INN varchar(10),
  @Bank_OKPO varchar(15),
  @Bank_KPP varchar(15),
  @Bank_OGRN varchar(20),
  @PrintStandartPhrase bit,
  @Printed bit,
  @Dblmess varchar(20)
  
  
begin

  select 
    @b_id=b_id, @b_id2=isnull(b_id2,0),  @gpOurID=nc.gpOur_ID, @OurID=nc.OurID, 
    @Dck=Dck, @Extra=Extra, @Actn=Actn, @RemarkOP=RemarkOP, @Printed=Printed
  from nc 
  where datnom=@datnom;
  if(@Extra=-100) or (@B_ID2>0) or (@Actn=1) set @BonusMess='Бонус. Без оплаты' else set @BonusMess='';
  if @Printed>0 set @DblMess='Дубликат' else set @Dblmess='';

  select 
    @gpOurName=FirmsConfig.OurName, 
    @gpOurInn=FirmsConfig.OurINN,
    @gpOurKpp=FirmsConfig.Kpp,
    @gpOurAddr_F=FirmsConfig.OurADDRFIZ,
    @gpOurAddr_J=FirmsConfig.OurADDR,
    @OurR_Schet=FirmsConfig.OurRSCHET,
    @OurC_Schet=FirmsConfig.OurCSCHET,
    @OurBik=FirmsConfig.OurBIK,
    @OurPhone=FirmsConfig.Phone,
    @gpDirektor=FirmsConfig.Direktor,
    @gpGlavbuh=FirmsConfig.Glavbuh
  from FirmsConfig 
  where FirmsConfig.Our_id=@gpOurID;


  SELECT 
    @gpAddr=d.gpAddr,
    @gpName=d.gpName,
    @gpIndex=d.gpIndex,
    @gpInn=d.gpInn,
    @gpBank=d.gpBank,
    @gpBank_ID=t.Bank_id,
    @gpBik=d.gpBik,
    @gpRS=d.gpRs,
    @gpCS=d.gpCS,
    @gpPhone=d.gpPhone,
    @gpOkpo=d.Okpo,
    @gpOkpo2=d.Okpo2,
    @contrNum=t.ContrNum, 
    @contrDate=t.ContrDate,
    @AgentFam=PA.Fio,
    @AgentPhone=PA.Phone, 
    @SuperPhone=PS.Phone,
    @Bank_Name=b.BName,
    @Bank_Address=b.Address,
    @Bank_BIK=b.Bik,
    @Bank_CShet=b.CShet,
    @Bank_RShet=b.RShet,
    @Bank_INN=b.INN,
    @Bank_OKPO=b.OKPO,
    @Bank_KPP=b.KPP,
    @Bank_OGRN=b.OGRN, 
    @PrintStandartPhrase=t.PrintStandartPhrase
  FROM 
    DEF d  
    left join DefContract t on t.pin=d.pin and t.DCK=@DCK and t.ContrTip=2
    left join AgentList A on a.ag_id=t.ag_id left join Person PA on PA.p_id=A.P_id
    left join Banks B on B.Bank_ID=t.Bank_ID
    left join Agentlist S on S.ag_id=a.sv_ag_id left join Person PS on PS.P_ID=S.P_ID
  WHERE d.PIN = @b_id AND d.TIP in (1,10);  

  if @OurID in (7,16) set @brmaster=isnull((select max(master) from def where pin=@b_id),0);
  else set @brmaster=0;  
  
  select @ContrTip=ContrTip from Defcontract where Dck=@Dck;

  if @ContrTip=7 begin -- это мы для поставщика стараемся.
    select top 1 @Ourid=fc.our_id, @Bank_ID=bs.BnK, 
      @OurName=fc.OurName, @ourAddrJ=fc.ourAddr, @OurInn=fc.OurINN, @OurBik=bl.Bik,
      @OurBank=bl.BName, @OurLicNo=fc.OurLICNO, @OurLICWHO=fc.OurLICWHO, @OurLICSROK=fc.OurLICSROK,
      @OurAddrF=fc.OurADDRFIZ, @OurR_SCHET=bs.RshetNo, @OurC_SCHET=bl.CShet,
      @OurDirektor=fc.Direktor, @OurGlavbuh=fc.Glavbuh, @OurPhone=fc.Phone, @OurKpp=fc.Kpp, 
      @OurInpOffset=fc.Inpoffset,
      @OurNds=fc.Nds, @OurOKPO=fc.OKPO, @OurFullName=fc.OurFullName, 
      @CompRegName=fc.CompRegName, @Actual=fc.Actual, @okpo2=fc.okpo2,
      @okdp=fc.okdp, @GlavBuhDov=fc.GlavBuhDov
    from 
      FirmsConfig fc left join BankSheet bs on bs.Our_ID=fc.Our_id
      left join BankList bl on bl.BnK=bs.BnK
    where fc.Our_id=@OurID and bs.DefaultFlag=1
    order by fc.Our_id;  
  end;

  -- Какой банк? Определяется по DCK. Нет, уже это узнали выше.
  -- select @Bank_ID=defcontract.Bank_ID from Defcontract where Dck=@Dck;
  -- select @gpBank=Banks.BName from Banks where banks.Bank_ID=@Bank_ID;

  select
	@Actn as Actn,
	@Actual as Actual,
	@AgentFam as AgentFam,
	@AgentPhone as AgentPhone,
	@Bank_Address as Bank_Address,
	@Bank_BIK as Bank_BIK,
	@Bank_CShet as Bank_CShet,
	@Bank_ID as Bank_ID,
	@Bank_INN as Bank_INN,
	@Bank_KPP as Bank_KPP,
	@Bank_Name as Bank_Name,
	@Bank_OGRN as Bank_OGRN,
	@Bank_OKPO as Bank_OKPO,
	@Bank_RShet as Bank_RShet,
	@BonusMess as BonusMess,
	@brmaster as brmaster,
	@B_ID as B_ID,
	@B_ID2 as B_ID2,
	@CompRegName as CompRegName,
	@contrDate as contrDate,
	@contrNum as contrNum,
	@ContrTip as ContrTip,
	@Dck as Dck,
	@Dblmess as Dblmess,
	@GlavBuhDov as GlavBuhDov,
	@gpAddr as gpAddr,
	@gpBank as gpBank,
	@gpBik as gpBik,
	@gpCS as gpCS,
	@gpDirektor as gpDirektor,
	@gpGlavbuh as gpGlavbuh,
	@gpIndex as gpIndex,
	@gpInn as gpInn,
	@gpName as gpName,
	@gpOkpo as gpOkpo,
	@gpOkpo2 as gpOkpo2,
	@gpOurAddr_F as gpOurAddr_F,
	@gpOurAddr_j as gpOurAddr_j,
	@gpOurID as gpOurID,
	@gpOurInn as gpOurInn,
	@gpOurKpp as gpOurKpp,
	@gpOurName as gpOurName,
	@gpPhone as gpPhone,
	@gpRS as gpRS,
	@okdp as okdp,
	@okpo as okpo,
	@okpo2 as okpo2,
	@Osn as Osn,
	@OurAddrF as OurAddrF,
	@OurAddrJ as OurAddrJ,
	@ourBank as ourBank,
	@OurBik as OurBik,
	@OurC_SCHET as OurC_SCHET,
	@ourDirektor as ourDirektor,
	@OurFullName as OurFullName,
	@ourGlavbuh as ourGlavbuh,
	@OurID as OurID,
	@OurINN as OurINN,
	@OurInpOffset as OurInpOffset,
	@OurKpp as OurKpp,
	@OurLicNo as OurLicNo,
	@OurLICSROK as OurLICSROK,
	@OurLICWHO as OurLICWHO,
	@OurName as OurName,
	@OurNds as OurNds,
	@ourOkpo as ourOkpo,
	@ourOkpo2 as ourOkpo2,
	@OurPhone as OurPhone,
	@OurR_SCHET as OurR_SCHET,
	@PrintStandartPhrase as PrintStandartPhrase,
	@RemarkOp as RemarkOp,
	@SuperPhone as SuperPhone;
    
  
END