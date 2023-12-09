CREATE PROCEDURE dbo.[MainBuyersListTest] @Actual bit
AS
BEGIN
  SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED; 
  declare @today datetime, @Cnt int
  set @today=convert(char(10), getdate(),104)
  set @Cnt=30
  create table #TempTable (RecId int IDENTITY(1, 1) NOT NULL, 
    pin int,tip int,gpName varchar(255),gpIndex char(255),gpAddr varchar(255),
    gpRs varchar(255),gpCs varchar(255), gpBank varchar(255), gpBik varchar(255),gpInn varchar(255),
    gpKpp varchar(255),brName varchar(255), brIndex char(255),brAddr varchar(255),brRs varchar(255),
    brCs varchar(255),brBank varchar(255),brBik varchar(255), brInn varchar(255), brKpp varchar(255),
    brAg_ID int,Fam varchar(255), gpPhone varchar(255),brPhone varchar(255),Remark varchar(255),
    RemarkDate datetime,Limit money,PosX numeric(9, 6),PosY numeric(9, 6),FullDocs bit ,
    Srok smallint,Actual bit ,Disab bit,Extra numeric(6, 2),LicNo varchar(255),
    LicWho varchar(255),LicSrok datetime,LicDate datetime,Raz int,BeginDate datetime ,
    Contact varchar(255),Oborot money,Master int,Our_ID int,Buh_ID int,
    Reg_ID varchar(255),Rn_ID smallint,Obl_ID int,Sver bit,NeedSver bit,Prior bit,
    LastSver datetime,PeriodSver smallint,ShortFam varchar(255),Torg12 bit,TovChk bit,
    NetType int,GrOt int,Fmt int,PrevAgID smallint,OKPO varchar(255),
    OKPO2 varchar(255),NDSFlg bit,Ag_GRP int,Debit bit,OGRN varchar(255),tmDin varchar(255),
    tmWork varchar(255),OGRNDate datetime,SlAll bit,DisMinEXTRA bit,Tov tinyint,BNFlg bit ,
    Worker bit, TmPost varchar(255),OborotIce money,SverTara datetime,X1 int, Duty money, NDDolg int, Overdue money, 
    CountFriz int,CountOb int, SPrice money,TaraKol int);
    
if @Actual='true' /*грузим только актуальные*/
begin 
    insert into  #TempTable 
    select distinct d1.pin,
           tip,
           gpName,
           gpIndex,
           gpAddr,
           gpRs,
           gpCs,
           gpBank,
           gpBik, gpInn,
           gpKpp, brName, brIndex, brAddr, brRs,brCs, brBank, brBik, brInn, brKpp,
           brAg_ID,Fam, gpPhone, brPhone, d1.Remark ,RemarkDate ,d1.Limit,PosX ,PosY ,FullDocs ,
           d1.Srok, d1.Actual, d1.Disab, d1.Extra ,LicNo ,LicWho ,
           LicSrok ,LicDate ,Raz,BeginDate, Contact,
           (select Sum(ISNULL(Oborot,0)) from Def where  MASTER=D1.pin  and Actual=1 and tip=1)+(select ISNULL(Sum(Sp),0)as Sm from NC where ND=@today
           and B_id in (select pin from Def where MASTER=D1.Master  and Actual=1 and tip=1)) as oborot,
           Master,d1.Our_ID,Buh_ID, Reg_ID,Rn_ID,Obl_ID,Sver,NeedSver,
           Prior,d1.LastSver ,PeriodSver,ShortFam ,Torg12 ,TovChk, NetType,GrOt,Fmt,PrevAgID,
           OKPO,OKPO2 ,NDSFlg,Ag_GRP,Debit ,OGRN,tmDin,tmWork,OGRNDate ,SlAll,DisMinEXTRA,Tov,BNFlg , Worker, TmPost,
           (select Sum(ISNULL(OborotIce,0)) from Def where  MASTER=D1.pin  and Actual=1 and tip=1)as OborotIce,
           SverTara,
           (select count(*) from Def D2 where D2.Master=D1.pin) X1,
           0 as Duty,             
           0 as NDDolg,
           0 as Overdue,
           0 as CountFriz,
           0 as CountOb,
           0 as SPrice,
           0 as TaraKol
    from Def D1 join DefContract c on D1.pin=c.pin and c.ContrTip=2
    where D1.Ncod is null and D1.Master=D1.pin and EXISTS(select pin from def where Actual=1 and MASTER=D1.pin)
    order by pin
     
    insert into  #TempTable
    select D3.pin, tip, gpName, gpIndex, gpAddr, gpRs, gpCs, gpBank, gpBik, gpInn,
           gpKpp, brName, brIndex, brAddr, brRs,brCs, brBank, brBik, brInn, brKpp,
           brAg_ID,Fam, gpPhone, brPhone, D3.Remark ,RemarkDate ,D3.Limit,PosX ,PosY ,FullDocs ,
           D3.Srok, D3.Actual, D3.Disab, D3.Extra ,LicNo ,LicWho ,LicSrok ,LicDate ,Raz,BeginDate  ,
           D3.Contact,Oborot+
           (select ISNULL(Sum(Sp),0)as Sm from NC where ND=@today
           and B_id=D3.pin  ) as oborot,Master,D3.Our_ID,Buh_ID, Reg_ID,Rn_ID,Obl_ID,Sver,NeedSver,
           Prior,D3.LastSver ,PeriodSver,ShortFam ,Torg12 ,TovChk, NetType,GrOt,Fmt,PrevAgID,
           OKPO,OKPO2 ,NDSFlg,Ag_GRP,Debit ,OGRN,tmDin,tmWork,OGRNDate ,SlAll,DisMinEXTRA,Tov,BNFlg ,
           Worker, TmPost,Isnull(OborotIce,0),SverTara, 
       (select count(*) from Def D2 where D2.Master=D3.pin) X1, 
        0 as Duty,
        0 as NDDolg,
        0 as Overdue,
        0 as CountFriz,
        0 as CountOb,
        0 as SPrice,
        0 as TaraKol 
    from Def D3 join DefContract c1 on D3.pin=c1.pin and c1.ContrTip=2
    where D3.master=0 and D3.Actual=1
    order by pin
end
else   /*грузим все*/
begin
   insert into  #TempTable 
    select distinct d1.pin, tip, gpName, gpIndex, gpAddr, gpRs, gpCs, gpBank, gpBik, gpInn,
           gpKpp, brName, brIndex, brAddr, brRs,brCs, brBank, brBik, brInn, brKpp,
           brAg_ID,Fam, gpPhone, brPhone, d1.Remark ,RemarkDate, d1.Limit,PosX, PosY, FullDocs,
           d1.Srok, d1.Actual, d1.Disab, d1.Extra ,LicNo ,LicWho ,LicSrok ,LicDate, Raz,BeginDate,
           Contact,
           (select Sum(ISNULL(Oborot,0)) from Def  where  MASTER=D1.pin  and tip=1) +
           (select ISNULL(Sum(Sp),0) as Sm from NC where ND=@today and B_id in (select pin from Def where MASTER=D1.Master and tip=1)) as oborot,
           Master,d1.Our_ID,Buh_ID, Reg_ID,Rn_ID,Obl_ID,Sver,NeedSver,
           Prior,d1.LastSver ,PeriodSver,ShortFam ,Torg12 ,TovChk, NetType,GrOt,Fmt,PrevAgID,
           OKPO,OKPO2 ,NDSFlg,Ag_GRP,Debit ,OGRN,tmDin,tmWork,OGRNDate ,SlAll,DisMinEXTRA,Tov,BNFlg ,
           Worker, TmPost,
           (select Sum(ISNULL(OborotIce,0)) from Def where  MASTER=D1.pin and tip=1)as OborotIce,
            SverTara, 
           (select count(*) from Def D2 where D2.Master=D1.pin) X1,
           (select  IsNull(Sum(Sp+Izmen)-Sum(Fact),0) from  NC where Tara!=1 and Frizer!=1 and Actn!=1 and 
                                                B_id in (select pin from Def where MASTER=D1.pin)) as Duty,             
           (select IsNull(cast((GETDATE()- min(ND+Srok) )as int),0)
           from  NC --nc
           where B_id in (select pin from Def where MASTER=D1.pin) and 
               Tara!=1 and Frizer!=1 and Actn!=1 and 
               (nc.SP+ISNULL(nc.izmen,0)-nc.Fact)>0.01 and ND+Srok+1<GETDATE())as NDDolg,
        (select IsNull(SUM(nc.SP+ISNULL(nc.izmen,0)-nc.Fact),0)
         from  NC --nc  
         where B_id in (select pin from Def where MASTER=D1.pin) and 
               Tara!=1 and Frizer!=1 and Actn!=1 and             
               (nc.SP+ISNULL(nc.izmen,0)-nc.Fact)!=0 and ND+Srok+1<GETDATE()
         )as Overdue, 
         (select IsNull(Count(B_id),0) from Frizer
          where B_id in (select pin from Def where MASTER=D1.pin) and tip=0
         )as CountFriz,
         (select IsNull(Count(B_id),0) from Frizer
          where B_id in (select pin from Def where MASTER=D1.pin  and Actual=1) and tip!=0
         ) as CountOb,
         (select  IsNull(sum(Price),0) from Frizer
          where B_id in (select pin from Def where MASTER=D1.pin)) as SPrice,
        /* (select Sum(Kol) from TaraDet td
           where B_id in (select pin from Def where MASTER=D1.pin) and 
                selldate<=@today-@Cnt)*/ 0 as TaraKol
    from Def D1 join DefContract c on D1.pin=c.pin and c.ContrTip=2
    where D1.Ncod is null and D1.Master=D1.pin and (D1.tip=1 or D1.tip=10) 
    order by pin
     
    insert into  #TempTable
    select D3.pin, tip, gpName, gpIndex, gpAddr, gpRs, gpCs, gpBank, gpBik, gpInn,
           gpKpp, brName, brIndex, brAddr, brRs,brCs, brBank, brBik, brInn, brKpp,
           brAg_ID,Fam, gpPhone, brPhone, D3.Remark ,RemarkDate ,D3.Limit,PosX ,PosY ,FullDocs ,
           D3.Srok, D3.Actual, D3.Disab, D3.Extra ,LicNo ,LicWho ,LicSrok ,LicDate ,Raz,BeginDate  ,
           D3.Contact,
           Oborot +
           (select ISNULL(Sum(Sp),0) as Sm from NC where ND=@today
           and B_id=D3.pin) as Oborot,Master,D3.Our_ID,Buh_ID, Reg_ID,Rn_ID,Obl_ID,Sver,NeedSver,
           Prior,D3.LastSver ,PeriodSver,ShortFam ,Torg12 ,TovChk, NetType,GrOt,Fmt,PrevAgID,
           OKPO,OKPO2 ,NDSFlg,Ag_GRP,Debit ,OGRN,tmDin,tmWork,OGRNDate ,SlAll,DisMinEXTRA,Tov,BNFlg ,
           Worker, TmPost,Isnull(OborotIce,0),SverTara, 
     (select count(*) from Def D2 where D2.Master=D3.pin) X1,
        IsNull(A.Duty,0) as Duty,IsNull(B.NDDolg,0) as NDDolg,
        IsNull(B.Overdue,0) as Overdue,IsNull(C.CountFriz,0) as CountFriz,
        IsNull(E.CountOb,0) as CountOb, IsNull(C.SPrice,0)+IsNull(E.SPrice,0) as SPrice, 
        ISNULL(D.TaraKol,0) as TaraKol
    from Def D3 join DefContract c1 on D3.pin=c1.pin and c1.ContrTip=2
    LEFT JOIN
      (select  Sum(Sp+Izmen)-Sum(Fact)as Duty,B_id
       from  NC --nc
       where Tara!=1 and Frizer!=1 and Actn!=1
       group by B_id)A on A.B_Id=D3.pin 
    LEFT JOIN
      (select cast((GETDATE()- min(ND+Srok) )as int) as NDDolg, B_Id,
              SUM(nc.SP+ISNULL(nc.izmen,0)-nc.Fact) as Overdue
       from  NC --nc
       where  ND+Srok+1<GETDATE() and 
             (nc.SP+ISNULL(nc.izmen,0)-nc.Fact)>0.01 and Tara!=1 and Frizer!=1 and Actn!=1  
       group by B_Id)B on B.B_id=D3.pin
    LEFT JOIN
      (select Count(B_id) as CountFriz, sum(Price) as SPrice,B_id 
       from Frizer
       where tip=0 
       group by B_id)C on C.B_id=D3.pin    
    LEFT JOIN
      (select Count(B_id) as CountOb, sum(Price) as SPrice,B_id 
       from Frizer
       where tip!=0 
       group by B_id)E on E.B_id=D3.pin
    LEFT JOIN
      (select case when Sum(Kol)<0 then 0 else Sum(kol) end as TaraKol,B_id from TaraDet
       where selldate<=@today-@Cnt and datnom is not null
       group by B_id)D on D.B_id=D3.pin
    where  D3.master=0 and (D3.tip=1 or D3.tip=10) 
    order by pin
end

select pin, brName, Oborot, Duty, Overdue, NDDolg,OborotIce, SPrice, CountOb,CountFriz,   
       Srok, brAddr, gpAddr, Extra, brInn, NDSFlg, Disab, brPhone, Contact,
       brAg_ID, Actual, Buh_ID, Master, brRs, Our_ID, brKpp, Sver, NeedSver,
       LastSver, PeriodSver, brBank, TovChk, ShortFam, gpName, Obl_ID,
       NetType, GrOt, Fmt, OKPO, OKPO2, LicDate, FullDocs, Remark, tip, gpIndex,
       gpRs, gpCs, gpBank, gpBik, gpKpp, brIndex, brCs, RecId, brBik, gpInn, 
       Fam, gpPhone, RemarkDate ,Limit,PosX, PosY, LicNo, LicWho, LicSrok, Raz,
       BeginDate, Reg_ID, Rn_ID, Prior, Torg12, PrevAgID, Ag_GRP, Debit, OGRN, 
       tmDin, tmWork, OGRNDate, SlAll, DisMinEXTRA, Tov, BNFlg, Worker, X1,TmPost,SverTara,
       TaraKol--,RecId 
     from #TempTable
order by RecId
 
END