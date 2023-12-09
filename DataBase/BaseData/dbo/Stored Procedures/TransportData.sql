CREATE procedure dbo.TransportData
AS
DECLARE @ND DATETIME, @PrevND datetime, @Olddatnom INT, 
  @Nnak INT, @Nnak0 BIGINT, @OldPin INT, @NotUsedNom int
BEGIN

-- *****************************************************************
-- ** Корректируем правила ценообразования.                       **
-- *****************************************************************
TRUNCATE TABLE netspec2_who;
-- SET IDENTITY_INSERT netspec2_who ON; -- поле HTID, автоинкрементное, пусть само наращивается.
DISABLE trigger ALL ON dbo.netspec2_who;
-- Из старых правил выдергиваем то, что не относится к покупателям (codetip=1..6):
INSERT INTO netspec2_who(nmid,code,codetip,contrtip) 
  SELECT nmid,code,codetip,contrtip FROM morozdata..netspec2_who WHERE CodeTip<=6;
-- Теперь то, что относится к сетям и отдельным покупателям (codtip=7..8):
INSERT INTO netspec2_who(nmid,code,codetip,contrtip) 
  SELECT DISTINCT w.nmid, tc.new_pin, w.codetip, contrtip
  FROM 
    morozdata..netspec2_who w 
    INNER JOIN morozdata..transport_client tc ON tc.old_pin=w.code
  WHERE w.CodeTip in (7,8);
-- SET IDENTITY_INSERT netspec2_who OFF;
ENABLE trigger ALL ON dbo.netspec2_who;



--========================================================================================================
--=  Создаем и заполняем (однократно) таблицу перехода клиентов Transport_client (участвуют pin и dck)   =
--========================================================================================================
-- CREATE TABLE MOROZDATA..transport_client (old_pin INT, new_pin INT, old_dck INT, new_dck int);
-- TRUNCATE TABLE morozdata..transport_client;
-- INSERT INTO morozdata..transport_client(old_dck,new_dck, new_pin) SELECT old_dck, dck,pin FROM defcontract;
--
-- UPDATE morozdata..transport_client 
-- SET old_pin=def.old_pin 
--   FROM morozdata..transport_client INNER JOIN def def ON def.pin=transport_client.new_pin;
--
-- INSERT INTO morozdata..transport_client(old_pin, new_pin) SELECT old_pin, pin FROM def 
--   WHERE pin NOT IN (SELECT DISTINCT pin FROM defcontract);


--=============================================================================================
--=  ТАБЛИЦА перехода Transport_Person в основноц базе. Создается однократно                  =
--=============================================================================================
--  CREATE TABLE morozdata..transport_person(new_p_od INT NOT NULL IDENTITY, old_p_id INT);
--  INSERT INTO morozdata..transport_person(old_p_id)
--    SELECT Person.p_id
--      FROM morozdata..Person
--      JOIN HRmain.dbo.pers pers ON Person.HRPersID = pers.PersID
--     WHERE pers.PersState <> 5
--       AND Person.Closed = 0
--       AND ISNULL(pers.isdel,0) = 0
--    UNION
--    SELECT Person.p_id
--      FROM morozdata..Person
--      JOIN morozdata..AgentList a ON Person.P_ID = a.P_ID
--      JOIN morozdata..transport_agent ta ON ta.old_ag_id = a.AG_ID
--    ORDER BY person.P_ID



-- *******************************************************************************************************
-- ** Перегоняем таблицу AgentList                                                                      **
-- *******************************************************************************************************
  TRUNCATE TABLE AgentList;
  INSERT INTO AgentList (AG_ID, P_ID, Agent, OrdStick, DepID, 
    sv_ag_id, IsAgent, IsSupervis, Remark, SkipSver, TmrENAB, 
  	AgentPart, ServerName, FolderName, FolderNameBackup, WeekPercent, 
  	Merch, SkipDover)
  SELECT 
  	ta.new_AG_ID, a.P_ID, a.Agent, a.OrdStick, a.DepID, 
    a.sv_ag_id, a.IsAgent, a.IsSupervis, a.Remark, a.SkipSver, a.TmrENAB,
  	a.AgentPart, a.ServerName, a.FolderName, a.FolderNameBackup, a.WeekPercent, 
  	a.Merch, a.SkipDover
  FROM 
  	MorozData..AgentList a
    INNER JOIN Morozdata..transport_agent ta on ta.old_ag_id=a.AG_ID

  -- Проставляем супервайзеров:
  UPDATE Agentlist SET sv_ag_id=ISNULL(ta.new_ag_id, Ag_id)
    FROM Agentlist A LEFT JOIN morozdata..transport_agent ta ON ta.old_ag_id=a.sv_ag_id;

  -- В DefContract прописываем новые коды агентов:
  UPDATE defcomtract SET ag_id=ta.ag_id
    FROM defcontract dc 
    inner JOIN morozdata..transport_agent ta ON ta.old_ag_id=dc.ag_id



-- *******************************************************************************************************
-- ** Перегоняем таблицу Person                                                                         **
-- *******************************************************************************************************
TRUNCATE TABLE person;
SET IDENTITY_INSERT Person ON;
INSERT INTO Person (P_ID, Fio, trID, Invis, V_ID, Our_ID, 
  DepID, Closed, ag_id, sv_id, uin, DepDirector, Phone, 
  Email, login, pwd, NDBeg, NDEnd, OP, Agent, Supervis, 
  svP_ID, Remark, PersID, HRPersID, dubl)
SELECT tp.new_p_od, p.Fio, p.trID, p.Invis, p.V_ID, 2 AS Our_ID, 
  p.DepID, p.Closed, p.ag_id, p.sv_id, p.uin, p.DepDirector, p.Phone, 
  p.Email, p.login, p.pwd, p.NDBeg, p.NDEnd, p.OP, p.Agent, p.Supervis, 
  p.svP_ID, p.Remark, NULL AS PersID, p.HRPersID, p.dubl 
FROM MorozData..Person p INNER JOIN morozdata..transport_person tp ON tp.old_p_id=p.p_id;
SET IDENTITY_INSERT Person OFF;




  truncate TABLE dbo.nomen;

  -- следующий кусок не работает из=за ограничений на GR и пока отключен:
  --  truncate TABLE dbo.gr;
  --
  --  INSERT INTO dbo.GR(Ngrp,GrpName,Vet,Parent,Category,MainParent,Levl,
  --    [Prior],Cost1kgStor,Cost1kgDeliv,nlMt,AgInvis,IsDel,OP,nlmt_new)
  --  SELECT Ngrp,GrpName,Vet,Parent,Category,MainParent,Levl,
  --    [Prior],Cost1kgStor,Cost1kgDeliv,nlMt,AgInvis,IsDel,OP,nlmt_new
  --  FROM morozdata..gr ORDER BY ngrp;

  -- **************************************************************
  -- *      Наши фирмы (там счет с 0, поэтому два запроса):      **
  -- **************************************************************
  TRUNCATE TABLE dbo.FirmsConfig;
  -- Втыкаем строку с с Our_ID=0:
	INSERT INTO dbo.FirmsConfig(our_id, OurName,OurADDR,OurINN,OurBIK,OurBANK,OurLICNO,
		OurLICWHO,OurLICSROK,OurADDRFIZ,OurRSCHET,OurCSCHET,Direktor,Glavbuh,Phone,Kpp,
		Inpoffset,Nds,OKPO,OurFullName,CompRegName,Actual,OurAbbreviature,OKPO2,OKDP,OGRN,
		OGRNDate,OurAddr_City,OurAddr_Street,OurAddr_House,OurAddr_Room,OurAddrFiz_City,
		OurAddrFiz_Street,OurAddrFiz_House,OurAddrFiz_Room,ouraddr_index,ouraddrFiz_index,
		GlavbuhDov,PosX,PosY,pin_,FirmGroup,GlavbuhUIN,KassaVal,pin,VetCode,OurLastDocNum,Old_OurID) 
	select our_id, OurName,OurADDR,OurINN,OurBIK,OurBANK,OurLICNO,
		OurLICWHO,OurLICSROK,OurADDRFIZ,OurRSCHET,OurCSCHET,Direktor,Glavbuh,Phone,Kpp,
		Inpoffset,Nds,OKPO,OurFullName,CompRegName,Actual,OurAbbreviature,OKPO2,OKDP,OGRN,
		OGRNDate,OurAddr_City,OurAddr_Street,OurAddr_House,OurAddr_Room,OurAddrFiz_City,
		OurAddrFiz_Street,OurAddrFiz_House,OurAddrFiz_Room,ouraddr_index,ouraddrFiz_index,
		GlavbuhDov,PosX,PosY,pin_,Our_id,GlavbuhUIN,KassaVal,pin,VetCode,OurLastDocNum,Our_id
	from Morozdata..FirmsConfig 
  where Our_id=0;

  -- **************************************************************
  -- **      вторая часть списка фирм, начиная с Our_ID=22      **
  -- **************************************************************
	INSERT INTO dbo.FirmsConfig(our_id, OurName,OurADDR,OurINN,OurBIK,OurBANK,OurLICNO,
		OurLICWHO,OurLICSROK,OurADDRFIZ,OurRSCHET,OurCSCHET,Direktor,Glavbuh,Phone,Kpp,
		Inpoffset,Nds,OKPO,OurFullName,CompRegName,Actual,OurAbbreviature,OKPO2,OKDP,OGRN,
		OGRNDate,OurAddr_City,OurAddr_Street,OurAddr_House,OurAddr_Room,OurAddrFiz_City,
		OurAddrFiz_Street,OurAddrFiz_House,OurAddrFiz_Room,ouraddr_index,ouraddrFiz_index,
		GlavbuhDov,PosX,PosY,pin_,FirmGroup,GlavbuhUIN,KassaVal,pin,VetCode,OurLastDocNum,Old_OurID) 
	select row_number() OVER (ORDER BY our_id), OurName,OurADDR,OurINN,OurBIK,OurBANK,OurLICNO,
		OurLICWHO,OurLICSROK,OurADDRFIZ,OurRSCHET,OurCSCHET,Direktor,Glavbuh,Phone,Kpp,
		Inpoffset,Nds,OKPO,OurFullName,CompRegName,Actual,OurAbbreviature,OKPO2,OKDP,OGRN,
		OGRNDate,OurAddr_City,OurAddr_Street,OurAddr_House,OurAddr_Room,OurAddrFiz_City,
		OurAddrFiz_Street,OurAddrFiz_House,OurAddrFiz_Room,ouraddr_index,ouraddrFiz_index,
		GlavbuhDov,PosX,PosY,pin_,fc.Our_id,GlavbuhUIN,KassaVal,pin,VetCode,OurLastDocNum,Our_id
	from Morozdata..FirmsConfig fc
    where Our_id>=22
    order by fc.Our_id;
  UPDATE FirmsConfig SET FirmGroup=Our_id;

-- SELECT 'FirmsConfig' AS TablName, * FROM FirmsConfig;

  -- ****************************************************************************************
  -- **  Понадобится список кодов контрагентов, которые что-то поставляли на фирмы 22-25   **
  -- **  или что-то покупали у них. Сейчас там 680 строк.                                  **
  -- ****************************************************************************************
  IF OBJECT_ID('tempdb..#t') IS NOT NULL DROP TABLE #t;
  CREATE TABLE #t(NewPin INT NOT NULL PRIMARY key, OldPin INT);
  insert INTO #t(NewPin,OldPin) SELECT New_Pin, Pin FROM Morozdata..def WHERE New_Pin>0;
  
  DECLARE c0 CURSOR FAST_FORWARD for
    SELECT DISTINCT d.pin 
      FROM morozdata..defcontract c 
      inner join morozdata..def d on iif(c.contrtip=1,d.ncod,d.pin)=c.pin
      WHERE c.Our_id>=22 AND d.pin NOT IN (SELECT oldpin FROM #t)
    UNION
    SELECT DISTINCT pin FROM morozdata..Comman WHERE Our_id>=22 AND pin NOT IN (SELECT oldpin FROM #t)
    UNION -- добавлено 15.01.2019:
    SELECT DISTINCT nc.pin FROM morozdata..nc INNER JOIN morozdata..defcontract dc ON dc.dck=nc.dck
      WHERE nc.nd>='01.10.2018' AND dc.ContrTip=7  AND dc.pin NOT IN (SELECT oldpin FROM #t)
    ORDER BY pin

  OPEN c0;
  FETCH NEXT FROM c0 INTO @OldPin;
  WHILE @@fetch_status=0 BEGIN
    SET @NotUsedNom=(SELECT TOP 1 newpin+1 FROM #t WHERE newpin+1 NOT IN (SELECT newpin FROM #t)); 
    INSERT INTO #t(NewPin,OldPin) VALUES (@NotUsedNom, @OldPin)
    FETCH NEXT FROM c0 INTO @OldPin;
  END;
  CLOSE c0;
  DEALLOCATE c0;

  IF OBJECT_ID('transport_t') IS NOT NULL DROP TABLE transport_t;
  SELECT * INTO transport_t FROM #t;
  SELECT 'Таблица перехода' AS remark, * FROM #t;

  -- **********************************
  -- *     Продавцы и покупатели:     *
  -- **********************************
  TRUNCATE TABLE dbo.def;
  SET IDENTITY_INSERT def ON;
  INSERT INTO dbo.def(pin,tip,gpName,gpIndex,gpAddr,gpRs,gpCs,
  	gpBank,gpBik,gpInn,gpKpp,brName,brIndex,brAddr,brRs,brCs,brBank,
  	brBik,brInn,brKpp,brAg_ID,Fam,gpPhone,brPhone,Remark,RemarkDate,[Limit],PosX,
  	PosY,FullDocs,Srok,Actual,Disab,Extra,LicNo,LicWho,LicSrok,LicDate,
  	Raz,BeginDate,Contact,Oborot,[Master],Our_ID,Buh_ID,Reg_ID,Rn_ID,
  	Obl_ID,Sver,NeedSver,[Prior],LastSver,PeriodSver,ShortFam,Torg12,TovChk,NetType,
  	GrOt,Fmt,PrevAgID,OKPO,OKPO2,NDSFlg,Ag_GRP,Debit,OGRN,tmDin,tmWork,
  	OGRNDate,SlAll,DisMinEXTRA,Tov,BNFlg,Worker,TmPost,SkipIce,SkipPf,Zarp,
  	LastFrizSver,Bonus,IceNorm,PfNorm,Op,dstAddr,wostamp,SumFriz,SverTara,
  	OborotIce,Part,Bank_ID,LimitOver,Priority,NaklCopy,brFullName,C1Code,gln,
  	LicScan,tradeArea,brag_id2,Vmaster,NDPret,NDPretBack,Email,Ncod,NDCoord,
  	dfID,upin,MainMaster,OKDP,gpRegCode,gpAddr_city,gpAddr_NasPunct,gpAddr_Street,
  	gpAddr_House,gpAddr_Corp,gpAddr_Room,p_id,OborotPf,point_ID,OLD_Pin) 
  select #t.newpin, D.tip, D.gpName, D.gpIndex, D.gpAddr, D.gpRs, D.gpCs, 
  	D.gpBank, D.gpBik, D.gpInn, D.gpKpp, D.brName, D.brIndex, D.brAddr, D.brRs, D.brCs, D.brBank, D.brBik, 
  	D.brInn, D.brKpp, D.brAg_ID, D.Fam, D.gpPhone, D.brPhone, D.Remark, D.RemarkDate, D.[Limit], D.PosX, 
  	D.PosY, D.FullDocs, D.Srok, D.Actual, D.Disab, D.Extra, D.LicNo, D.LicWho, D.LicSrok, D.LicDate, 
  	D.Raz, D.BeginDate, D.Contact, D.Oborot, D.[Master], -1, D.Buh_ID, D.Reg_ID, D.Rn_ID, D.Obl_ID, 
  	D.Sver, D.NeedSver, D.[Prior], D.LastSver, D.PeriodSver, D.ShortFam, D.Torg12, D.TovChk, D.NetType, 
  	D.GrOt, D.Fmt, D.PrevAgID, D.OKPO, D.OKPO2, D.NDSFlg, D.Ag_GRP, D.Debit, D.OGRN, D.tmDin, D.tmWork, 
  	D.OGRNDate, D.SlAll, D.DisMinEXTRA, D.Tov, D.BNFlg, D.Worker, D.TmPost, D.SkipIce, D.SkipPf, D.Zarp, 
  	D.LastFrizSver, D.Bonus, D.IceNorm, D.PfNorm, D.Op, D.dstAddr, D.wostamp, D.SumFriz, D.SverTara, 
  	D.OborotIce, D.Part, D.Bank_ID, D.LimitOver, D.Priority, D.NaklCopy, D.brFullName, D.C1Code, D.gln, 
  	D.LicScan, D.tradeArea, D.brag_id2, D.Vmaster, D.NDPret, D.NDPretBack, D.Email, D.Ncod, D.NDCoord, 
  	D.dfID, D.upin, D.MainMaster, D.OKDP, D.gpRegCode, D.gpAddr_city, D.gpAddr_NasPunct, D.gpAddr_Street, 
  	D.gpAddr_House, D.gpAddr_Corp, D.gpAddr_Room, D.p_id, D.OborotPf, D.point_ID, #t.oldPin
  from 
  	morozdata..Def D
    INNER JOIN #t ON #t.oldpin=D.Pin
  ORDER BY #t.OldPin;
  -- Прописываем правильное поле Master:
  UPDATE DEF SET Master=#t.NewPin FROM Def INNER JOIN #t ON #t.oldpin=def.Master;
  -- В тех случаях, когда это не удалось (примерно 15 строк), вычисляем другим способом:
  UPDATE def SET master=E.MinPin FROM def INNER JOIN (SELECT master, MIN(pin) AS MinPin 
    FROM def WHERE master>500 GROUP BY master) E ON E.master=def.master

  SET IDENTITY_INSERT def Off;

  -- SELECT 'DEF' AS TabName, * FROM Def;

  -- ****************************************************************************************
  -- **               ПОНАДОБИТСЯ ТАКЖЕ СПИСОК ДОГОВОРОВ С ЭТИМИ КОНТРАГЕНТАМИ:            **
  -- ****************************************************************************************
PRINT('Контрольная точка 0 пройдена')
  IF OBJECT_ID('tempdb..#c') IS NOT NULL DROP TABLE #c;
  CREATE TABLE #c(NewDCK INT NOT NULL IDENTITY, OldDCK INT, OldPin INT, NewPin int);
  -- Во избежание потери данных вытаскиваем уже существующие пары DCK — Olв_DCK из новой DefContract:
  SET IDENTITY_INSERT #c On;
  insert INTO #c(NewDCK,OldDck) SELECT dck,old_dck FROM Defcontract WHERE dck IS NOT NULL AND old_dck IS NOT NULL;
  SET IDENTITY_INSERT #c Off;

DECLARE @cnt INT;
SET @cnt=(SELECT COUNT(*) FROM #c);
PRINT('Контрольная точка 1a пройдена, в табл. #c исходно '+CAST(@cnt AS varchar)+' строк.');

  INSERT INTO #c(oldDCK) SELECT dck 
  FROM morozdata..defcontract 
  WHERE 
    Our_id>=22
    AND dck NOT IN (SELECT olddck FROM #c) ORDER BY dck;

SET @cnt=(SELECT COUNT(*) FROM #c);
PRINT('Контрольная точка 1b пройдена, в табл. #c сейчас '+CAST(@cnt AS varchar)+' строк.');

  INSERT INTO #c(oldDCK) SELECT DISTINCT dc.dck 
  FROM
    morozdata..nc 
    INNER JOIN morozdata..defcontract dc ON dc.dck=nc.dck
  WHERE 
    nc.nd>='01.10.2018' AND dc.contrtip=7
    AND dc.dck NOT IN (SELECT olddck FROM #c) 
  ORDER BY dck;

SET @cnt=(SELECT COUNT(*) FROM #c);
PRINT('Контрольная точка 2 пройдена, в табл. #c сейчас '+CAST(@cnt AS varchar)+' строк.');
  
  UPDATE #c SET OldPin=dc.pin FROM #c INNER JOIN morozdata..defcontract dc ON dc.dck=#c.olddck WHERE dc.ContrTip<>1;

PRINT('Контрольная точка 3 пройдена')

  UPDATE #c SET OldPin=def.pin 
  FROM 
    #c 
    INNER JOIN morozdata..defcontract dc ON dc.dck=#c.olddck 
    INNER join morozdata..def ON def.ncod=dc.pin 
  WHERE dc.ContrTip=1;
PRINT('Контрольная точка 4 пройдена')

  UPDATE #c SET NewPin=#t.newpin FROM #c INNER JOIN #t ON #t.oldpin=#c.oldpin;
PRINT('Контрольная точка 5 пройдена')

  -- SELECT 'Контракты' AS TabName, * FROM #c;
  IF OBJECT_ID('transport_c') IS NOT NULL DROP TABLE transport_c;
  SELECT * INTO transport_c FROM #c;
PRINT('Контрольная точка 6 пройдена')

  -- Связанный с контрагентами список договоров:

  TRUNCATE TABLE dbo.DefContract;
  SET IDENTITY_INSERT dbo.DefContract ON;
  INSERT INTO dbo.DefContract(DCK,ND,OP,Actual,Our_id,ContrTip,pin,ContrName,
  	ContrMain,ContrNum,ContrDate,ContrEvalDate,Srok,BnFlag,NDS,minOrder,maxDaysOrder,
  	LastSver,Remark,gpOur_ID,Bank_ID,p_id,[limit],Extra,wostamp,DCKOld,PrevP_id,
  	AccountID,ag_id,PrevAg_ID,NeedFrizSver,LastFrizSver,Degust,dcnID,DckMaster,NeedCK,
  	Factoring,PrintStandartPhrase,Ncod,ExpressSver,Disab,Debit,gpBank_ID,FMonDisab,
  	TaxMID,PricePrecision,GPAccountID, Old_DCK) 
  select #c.NewDck,DC.ND,DC.OP,DC.Actual,ISNULL(f.Our_id,0),DC.ContrTip,#c.newpin,DC.ContrName,
  	DC.ContrMain,DC.ContrNum,DC.ContrDate,DC.ContrEvalDate,DC.Srok,DC.BnFlag,DC.NDS,DC.minOrder,DC.maxDaysOrder,
  	DC.LastSver,DC.Remark,DC.gpOur_ID,DC.Bank_ID,DC.p_id,DC.[limit],DC.Extra,DC.wostamp,DC.DCKOld,DC.PrevP_id,
  	DC.AccountID,DC.ag_id,DC.PrevAg_ID,DC.NeedFrizSver,DC.LastFrizSver,DC.Degust,DC.dcnID,DC.DckMaster,DC.NeedCK,
  	DC.Factoring,DC.PrintStandartPhrase,DC.Ncod,DC.ExpressSver,DC.Disab,DC.Debit,DC.gpBank_ID,DC.FMonDisab,
  	DC.TaxMID,DC.PricePrecision,0,DC.DCK -- Поле DC.GPAccountID новое!
  from 
  	morozdata..Defcontract DC
    INNER JOIN #c ON #c.olddck=dc.dck
  	left join FirmsConfig f on f.old_ourID=DC.our_ID
  ORDER BY #c.NewDck;

  SET IDENTITY_INSERT dbo.DefContract Off;
  --  SELECT 'Контракты' AS TabName, * FROM Defcontract;

  -- Какие именно товары приходили от поставщиков из списка?

  TRUNCATE TABLE Comman;
  TRUNCATE TABLE Inpdet;
  TRUNCATE TABLE VISUAL;
  TRUNCATE TABLE TDVI;
  TRUNCATE TABLE NC;
  TRUNCATE TABLE NV;
  TRUNCATE TABLE NVzakaz;
  TRUNCATE TABLE IZMEN;
  TRUNCATE TABLE tdiz;
  TRUNCATE TABLE NCEdit;
  TRUNCATE TABLE NVEdit;

  -- Поступления товаров, COMMAN. Пока что код нашей фирмы старый:
  INSERT INTO dbo.Comman(Ncom,Ncod,[date],[Time],summaprice,summacost,izmen,isprav,
  	[remove],ostat,realiz,corr,plata,closdate,srok,op,our_id,doc_nom,doc_date,comp,
  	izmensc,errflag,copyexists,origdate,skman,grman,DCK,TN_nom,TN_date,OrdersID,
  	safeCust,PrihodDate,PrihodOp,PinOwner,DCKOwner,pin,dlMarshID,dlMarshCost,PrihodRID, Old_NCOM) 
  select ROW_NUMBER() over(order by c.ncom), 0 AS Ncod, C.[date],C.[Time],C.summaprice,C.summacost,C.izmen,C.isprav,
  	C.[remove],C.ostat,C.realiz,C.corr,C.plata,C.closdate,C.srok,C.op, c.Our_ID, C.doc_nom,C.doc_date,C.comp,
  	C.izmensc,C.errflag,C.copyexists,C.origdate,C.skman,C.grman,#c.newDCK,C.TN_nom,C.TN_date,C.OrdersID,
  	C.safeCust,C.PrihodDate,C.PrihodOp,C.PinOwner,C.DCKOwner,C.pin,C.dlMarshID,C.dlMarshCost,C.PrihodRID, C.NCOM
  from morozdata..comman C
  inner join #c on #c.olddck=c.dck
  WHERE c.date>='10.05.2018' -- приходится так ограничить, поскольку идиоты-пользователи переписали старые договоры под новые фирмы.

  UPDATE comman SET pin=#c.newpin FROM comman c INNER JOIN #c ON #c.OldPin=c.pin;

  -- Таблица переходов идентификаторов товаров:
  IF OBJECT_ID('tempdb..#I') IS NOT NULL DROP TABLE #I;
  CREATE TABLE #I(NewID INT NOT NULL IDENTITY, OldID INT, OldNcom INT, NewNcom int);
  insert into #i(oldid, OldNcom) 
  select i.id, i.Ncom
  from 
    morozdata..inpdet i 
    INNER JOIN morozdata..comman cm ON cm.ncom=i.ncom
    INNER JOIN comman nc ON nc.old_ncom=cm.ncom    
    -- INNER JOIN #c ON #c.olddck=cm.dck
    -- inner join defcontract dc on dc.dck=#c.newdck
  -- where -- dc.contrtip=1 AND 
    -- i.kol>0
  order by i.ncom, i.id;

  -- Подготовка к перенумерации поставок:
  IF OBJECT_ID('tempdb..#o') IS NOT NULL DROP TABLE #o;
  CREATE TABLE #o(newNcom INT NOT NULL IDENTITY, OldNcom int);
  INSERT INTO #o(OldNcom) SELECT DISTINCT oldncom FROM #i ORDER BY oldNcom;
  UPDATE #i SET NewNcom=#o.NewNcom FROM #i INNER JOIN #o ON #o.oldNcom=#i.oldncom;
  DROP TABLE #o;

  IF OBJECT_ID('transport_I') IS NOT NULL DROP TABLE transport_I;
  SELECT * INTO transport_I FROM #i;


  -- SELECT '#i' AS TabName, * FROM #i;

  TRUNCATE TABLE dbo.Inpdet;
  SET IDENTITY_INSERT inpdet ON;

  INSERT INTO dbo.Inpdet(nd,ncom,id,hitag,price,cost,kol,sert_id,minp,mpu,dater,srokh,
  	nalog5,op,country,sklad,kol_b,summacost,BasePrice,inId,CountryID,ProducerID,[weight],
  	Id_vet_svid,cost_delivery_1kg,QTY,unid) 
  select
  	i.nd,#i.newncom, #i.newid,i.hitag,i.price,i.cost,i.kol,i.sert_id,i.minp,i.mpu,i.dater,i.srokh,
  	i.nalog5,i.op,i.country,i.sklad,i.kol_b,i.summacost,i.BasePrice,i.inId,i.CountryID,i.ProducerID,i.[weight],
  	i.Id_vet_svid,i.cost_delivery_1kg,i.kol,CAST(nm.flgweight AS INT)
  from 
    morozdata..inpdet i
    inner join #i on #i.oldid=i.id
    INNER JOIN morozdata..nomen nm ON nm.hitag=i.hitag
  -- WHERE i.kol<>0;

  SET IDENTITY_INSERT inpdet Off;  
  UPDATE inpdet SET price=price/weight, cost=cost/weight, QTY=QTY*weight, Kol=Kol*weight, weight=1 WHERE unid=1 AND weight<>0;
  -- SELECT 'inpdet' AS TabName, * FROM INPDET;

  truncate table dbo.Nomen
  INSERT INTO dbo.Nomen(hitag,[name],inactive,nds,price,cost,minp,mpu,
  	ngrp,fname,emk,egrp,sert_id,[prior],barcode,barcodeMinP,MinW,Netto,Brutto,
  	MinEXTRA,Closed,OnlyMinP,MeasID,Weight_b,flgWeight,disab,NCID,VolMinp,AddTag,
  	KZarp,STM,krep,LastSkladID,LastProducerID,LastCountryID,SafeCust,NgrpOld,ShelfLifeAdd,ShelfLife,
  	Op,[date],DateCreate,price_old,NbID,UnID,flgFract) 
  select hitag,[name],inactive,nds,price,cost,minp,mpu,
  	ngrp,fname,emk,egrp,sert_id,[prior],barcode,barcodeMinP,MinW,Netto,Brutto,
  	MinEXTRA,Closed,OnlyMinP,MeasID,Weight_b,flgWeight,disab,NCID,VolMinp,AddTag,
  	KZarp,STM,krep,LastSkladID,LastProducerID,LastCountryID,SafeCust,NgrpOld,ShelfLifeAdd,ShelfLife,
  	Op,[date],DateCreate,price_old,NbID,iif(flgweight=1,1,0),iif(flgWeight=1,1,0)
  from morozdata..nomen nm
  where 
    hitag in (select distinct hitag from inpdet);

  UPDATE inpdet SET unid=nm.unid FROM inpdet i INNER JOIN nomen nm ON nm.hitag=i.hitag;

  DELETE FROM comman WHERE ncom NOT IN (SELECT newncom FROM #i);

  -- SELECT 'Nomen' AS TabName, * FROM Nomen;

  PRINT 'Подготовка VISUAL';

  INSERT INTO dbo.Visual(id,startid,ncom,ncod,datepost,Price,start,startthis,
    hitag,sklad,cost,nalog5,minp,mpu,sert_id,rang,now,isprav,remov,bad,dater,srokh,
    country,rezerv,units,locked,ncountry,gtd,vitr,our_id,weight,baseprice,LastDate,
    morn,sell,MeasId,ncnt,DCK,wsid,CountryID,ProducerID,pin,UnID,Unid2,KU)
  select 
    i.id, i.id, i.ncom, cm.ncod, cm.date, i.price, i.kol, i.kol,
    i.hitag, i.sklad, i.cost, 0, i.minp, i.mpu, i.sert_id, '5', i.kol, 0,0,0, i.dater,i.srokh,
    i.country, 0, NULL, 0, 0, 0, 0, cm.our_id, 0, price, NULL,
    i.kol, 0, 0, 0, cm.dck, 0, 0, i.ProducerID, cm.pin, i.unid, i.unid, 1
  from 
    inpdet i 
    left JOIN comman cm ON cm.ncom=i.ncom
    left JOIN defcontract dc ON dc.dck=cm.dck

  IF OBJECT_ID('transport_cm') IS NOT NULL DROP TABLE transport_cm;
  SELECT DISTINCT oldncom, newncom INTO transport_cm FROM #i;

  -- select 'visual' AS TabName,* from visual v 


  -- Переброс расходных/возвратных накладных.
  -- Таблица соответствия номеров:
  IF OBJECT_ID('tempdb..#nc') IS NOT NULL DROP TABLE #nc;
  CREATE TABLE #nc(OldDatnom INT, NewDatnom BIGINT);
  DECLARE c1 CURSOR FAST_FORWARD for 
    SELECT nd,datnom FROM morozdata..nc WHERE dck IN (SELECT old_dck FROM defcontract) order BY nd, datnom;
  OPEN c1;
  FETCH NEXT FROM c1 INTO @ND, @OldDatnom;
  SET @PrevND='01.01.2000'
  WHILE @@fetch_status=0 BEGIN
    IF @PrevND<>@ND SET @Nnak=0;
    SET @Nnak=@Nnak+1;
    INSERT INTO #nc(olddatnom, Newdatnom) VALUES(@olddatnom, dbo.fndatnom(@nd, @Nnak))
    SET @PrevND=@ND;
    FETCH NEXT FROM c1 INTO @ND, @OldDatnom;
  END;
  CLOSE c1;
  DEALLOCATE c1;
  IF OBJECT_ID('transport_nc') IS NOT NULL DROP TABLE transport_nc;
  SELECT * INTO transport_nc FROM #nc ORDER BY olddatnom;
  -- select '#nc' AS TabName,* from #nc ORDER BY olddatnom;


  INSERT INTO dbo.nc(nd, datnom, b_id, b_id2,dck, Fam, Remark,RemarkOP, tm,op,sc,sp,extra,srok,fact,
    frizer, ag_id,stfnom,stfdate, printed, boxqty,weight,actn,ck,tara,
    refdatnom,startdatnom, marsh2,ready,delivcancel, SertifDoc, TimeArrival,
    BruttoWeight, TranspRashod,comp,NeedDover,State,DocNom,DocDate,SertNo,SertND,
    stip,gpOur_ID,mhid,doverm2, nom
    )
  select 
  	c.nd, #nc.NewDatNom,0,0,c.dck, C.Fam, C.Remark, C.RemarkOP, c.tm,c.op,c.sc,c.sp,c.extra,c.srok,c.fact,
    c.frizer, c.ag_id,c.stfnom,c.stfdate, c.printed, c.boxqty,c.weight,c.actn,c.ck,c.tara,
    c.refdatnom, c.startdatnom, c.marsh2,c.ready,c.delivcancel, c.SertifDoc, c.TimeArrival,
    c.BruttoWeight, c.TranspRashod,c.comp,c.NeedDover,c.State,c.DocNom,c.DocDate,c.SertNo,c.SertND,
    c.stip,c.gpOur_ID,c.mhid,c.doverm2, null
  FROM 
  	morozdata..nc c
  	inner join #nc on #nc.olddatnom=c.datnom
  
  
  UPDATE nc SET refdatnom=#nc.newdatnom FROM nc INNER JOIN #nc ON #nc.Olddatnom=nc.refdatnom;
  UPDATE nc SET startdatnom=#nc.newdatnom FROM nc INNER JOIN #nc ON #nc.Olddatnom=nc.startdatnom;
  UPDATE nc SET b_id=#c.newpin,dck=#c.NewDCK FROM nc INNER JOIN #c ON #c.OldDCK=nc.dck;
  UPDATE nc SET OurID=dc.Our_id FROM nc INNER JOIN defcontract dc ON dc.dck=nc.dck;
  UPDATE nc SET gpOur_ID=dc.Our_id FROM nc INNER JOIN defcontract dc ON dc.dck=nc.dck;
  -- SELECT 'nc' AS tabName, * FROM nc;

  INSERT INTO dbo.NV(DatNom,TekID,Hitag,Price,Cost,Kol,Kol_B,Sklad,OrigPrice,ag_id,UnID,OrigUnid,K)
  SELECT
    #nc.newdatnom, -nv.TekID, nv.hitag, nv.Price, nv.Cost, nv.Kol,nv.Kol,    
    nv.Sklad,nv.OrigPrice, nv.ag_id,99,99,1
  FROM 
    #nc
    INNER JOIN morozdata..nv ON nv.datnom=#nc.OldDatnom
  ORDER BY #nc.newdatnom
  PRINT 'Простановка цен...';
SELECT 'Первый этап' AS TabName,* FROM nv WHERE ABS(tekid)=86862443 OR tekid=868
  -- Пока что все поля tekid отрицательные, признак того, что они еще не обработаны.

  SELECT 'Подозрительные товары' AS tabname, nm.* 
  FROM nv 
    INNER JOIN morozdata..visual v ON v.id=-nv.tekid 
    INNER JOIN morozdata..nomen nm ON nm.hitag=nv.hitag
  where nv.tekid<0 AND nm.flgWeight=1  AND v.weight=0


  -- Вместо TekID записываю соответствующие StartID:
  UPDATE nv SET tekid=v.startid, 
    kol=nv.Kol*IIF(nm.flgWeight=1, v.weight, 1),
    kol_b=nv.Kol_b*IIF(nm.flgWeight=1, IIF(v.weight>0,v.weight,nm.netto), 1),
    price=nv.Price/IIF(nm.flgWeight=1, IIF(v.weight>0,v.weight,nm.netto), 1),
    cost=nv.cost/IIF(nm.flgWeight=1, IIF(v.weight>0,v.weight,nm.netto), 1)
  FROM 
    nv 
    INNER JOIN morozdata..visual v ON v.id=-nv.tekid 
    INNER JOIN morozdata..nomen nm ON nm.hitag=nv.hitag
  where nv.tekid<0; -- В большинстве строк tekid стали положительные.
  PRINT 'Цены проставлены';
SELECT 'Второй этап' AS TabName,* FROM nv WHERE (ABS(tekid)=86862443 OR tekid=868)

  UPDATE nv SET tekid=v.startid, 
    kol=nv.Kol*IIF(nm.flgWeight=1, IIF(v.weight>0,v.weight,nm.netto), 1),
    kol_b=nv.Kol_b*IIF(nm.flgWeight=1, IIF(v.weight>0,v.weight,nm.netto), 1),
    price=nv.Price/IIF(nm.flgWeight=1, IIF(v.weight>0,v.weight,nm.netto), 1),
    cost=nv.cost/IIF(nm.flgWeight=1, IIF(v.weight>0,v.weight,nm.netto), 1)
  FROM 
    nv 
    INNER JOIN morozdata..tdvi v ON v.id=-nv.tekid 
    INNER JOIN morozdata..nomen nm ON nm.hitag=nv.hitag
  where nv.tekid<0 -- Во всех строках tekid стали положительные.
SELECT 'Третий этап' AS TabName,* FROM nv WHERE (ABS(tekid)=86862443 OR tekid=868)

  -- Следующий этап обработки.
  -- Для начала все tekid снова делаем отрицательными:
  UPDATE nv SET tekid=-tekid;
  -- Подставляем актуальные значения tekid, опираясь на таблицу преобразования приходов #i 
  UPDATE nv SET tekid=#i.newid FROM nv INNER JOIN #i ON #i.OldID=-nv.TekID;
SELECT 'Четвертый этап' AS TabName,* FROM nv WHERE hitag=27327 AND datnom=18072500041


  -- К этому шагу удалось прописать почти все ID, кроме 306 записей. Однако же для 304 из них
  -- все-таки можно подобрать правдоподобные ID, что показывает следующий запрос:
  --  SELECT 
  --    'Доп.подбор' AS TabName,
  --    nv.tekid, nv.hitag, nv.kol,vi.startid, vi.Ncod, vi.Ncom AS OldNcom, cm.newncom,
  --    nv.cost AS nvCost, i.cost, ti.newid, E.MinId
  --  FROM 
  --    nv 
  --    LEFT JOIN morozdata..visual vi ON vi.id=-nv.tekid
  --    LEFT JOIN transport_i TI ON TI.oldid=-nv.tekid
  --    LEFT JOIN transport_cm cm ON cm.oldncom=vi.ncom
  --    LEFT JOIN morozdata..inpdet i ON i.id=-nv.tekid 
  --    LEFT JOIN (SELECT ncom, hitag, MIN(id) AS MinID FROM inpdet GROUP BY ncom,hitag) E ON E.hitag=nv.hitag AND E.Ncom=cm.NewNcom
  --  WHERE nv.tekid<0
  --  -- Делаем это:
  --  UPDATE nv SET tekid=E.MinID FROM nv 
  --    LEFT JOIN morozdata..visual vi ON vi.id=-nv.tekid
  --    LEFT JOIN transport_i TI ON TI.oldid=-nv.tekid
  --    LEFT JOIN transport_cm cm ON cm.oldncom=vi.ncom
  --    LEFT JOIN morozdata..inpdet i ON i.id=-nv.tekid 
  --    LEFT JOIN (SELECT ncom, hitag, MIN(id) AS MinID FROM inpdet GROUP BY ncom,hitag) E ON E.hitag=nv.hitag AND E.Ncom=cm.NewNcom
  --    WHERE nv.tekid<0 AND e.MinID IS NOT NULL

  -- После этого остается всего две строки (проверено!), у обоих tekid=-86845797 и 24638.
  -- Черт с ними, эти данныне вобьем методом грубой силы:
  UPDATE nv SET tekid=(SELECT MIN(startid) FROM visual WHERE hitag=nv.hitag AND start>0) WHERE tekid<0;

SELECT 'Пятый этап' AS TabName,* FROM nv WHERE (ABS(tekid)=86862443 OR tekid=868) AND datnom IN (18072500041,1807250509)
  
  
  -- Осталось проставить единицы измерения в трех таблицах:
  UPDATE nv SET Unid=IIF(nm.flgWeight=0,0,1),k=1 FROM nv INNER JOIN nomen nm ON nm.hitag=nv.hitag;
  UPDATE nv SET origunid=unid;
  UPDATE visual SET Unid=IIF(nm.flgWeight=0,0,1),ku=1 FROM visual INNER JOIN nomen nm ON nm.hitag=visual.hitag;
  UPDATE visual SET unid2=unid;
  UPDATE inpdet SET Unid=IIF(nm.flgWeight=0,0,1) FROM inpdet INNER JOIN nomen nm ON nm.hitag=inpdet.hitag;
  
  -- Записываем продажи в таблицу склада:
  UPDATE visual SET sell=ISNULL(E.Kol,0) 
    FROM visual v LEFT join (SELECT tekid, SUM(kol) AS KOL FROM nv group BY tekid) E ON E.Tekid=v.id

  -- Переписываем данные в текущий склад, пока что оставляя поле SELL нулевое:
  INSERT INTO dbo.tdVi(ND,STARTID,NCOM,NCOD,DATEPOST,PRICE,START,STARTTHIS,HITAG
    ,SKLAD,COST,NALOG5,MINP,MPU,SERT_ID,RANG,MORN,SELL,ISPRAV,REMOV,BAD,DATER,SROKH
    ,COUNTRY,REZERV,UNITS,LOCKED,NCOUNTRY,GTD,VITR,OUR_ID,WEIGHT,SaveDate,MeasId
    ,OnlyMinP,AddrID,DCK,ProducerID,CountryID,wsID,safeCust,Price_old,LockID,PinOwner
    ,DCKOwner,pin,AutoID,Id_Old,ProducerCodeId,UnID,Unid2,KU)
  SELECT DatePost,STARTID,NCOM,NCOD,DATEPOST,PRICE,START,STARTTHIS,HITAG
    ,SKLAD,COST,NALOG5,MINP,MPU,SERT_ID,RANG,MORN,0,ISPRAV,REMOV,BAD,DATER,SROKH
    ,COUNTRY,REZERV,UNITS,LOCKED,NCOUNTRY,GTD,VITR,OUR_ID,WEIGHT,DatePost,MeasId
    ,0,0,DCK,ProducerID,CountryID,wsID,0,Price,0,0
    ,0,pin,0,0,0,UnID,Unid2,KU
  FROM visual;

  -- Поле Morn уменьшаем на все продажи, сделанные до сегодняшнего утра:
  SET @Nnak0=dbo.fndatnom(dbo.today(),0); -- номер нулевой накладной за сегодня.
  UPDATE tdvi SET Morn=Morn-E.Kol 
    FROM tdvi v INNER JOIN (SELECT tekid, SUM(kol) AS Kol FROM nv WHERE datnom<@Nnak0 GROUP BY tekid) E
    ON E.tekid=v.id;
  -- В поле SELL записываем продажи за сегодня:
  UPDATE tdvi SET Sell=E.Kol 
    FROM tdvi v INNER JOIN (SELECT tekid, SUM(kol) AS Kol FROM nv WHERE datnom>@Nnak0 GROUP BY tekid) E
    ON E.tekid=v.id;

  -- Соответственно в таблице Visual в поле Sell не должны учитываться сегодняшние продажи:
  UPDATE Visual SET Sell=Visual.Sell-tdvi.sell FROM visual INNER JOIN tdvi ON tdvi.id=visual.id;

  -- SELECT 'tdvi' AS tabName, * FROM tdvi;

  UPDATE comman SET Our_ID=dc.Our_ID FROM comman c INNER JOIN DefContract dc ON dc.dck=c.dck;
  UPDATE visual SET Our_ID=dc.Our_ID FROM visual c INNER JOIN DefContract dc ON dc.dck=c.dck;
  UPDATE tdvi SET Our_ID=dc.Our_ID FROM tdvi c INNER JOIN DefContract dc ON dc.dck=c.dck;
--SELECT 'Comman' AS TabName, * FROM Comman;



  -- ************************************************************************************
  -- **   Перегоняем таблицу кассовых операций, корректируя информациюу о накладных    **
  -- ************************************************************************************
  TRUNCATE TABLE Kassa1;
  TRUNCATE TABLE Kassa1Log;
  DISABLE trigger ALL ON dbo.Kassa1;
  -- начнем с выплат покупателей:
  INSERT INTO dbo.Kassa1(nd,tm,Oper,Act
    ,SourDate,Nnak
    ,Plata,Fam,P_ID,B_ID
    ,V_ID,Ncod,Remark,RashFlag,LostFlag,LastFlag,Op,Bank_ID,Our_ID,BankDay,Actn
    ,Ck,Thr,ThrFam,DocNom,OrigRecn,ForPrint,SourDatNom,StNom,FromBank_ID,SkladNo
    ,DepID,B_idPlat,OperOld,NDInp,InBank,Nalog,RemarkPlat,pin,platarez,DCK,KassaNo,RealOper, OldKassID)
  SELECT
    k.nd,k.tm,k.Oper,k.Act
    ,dbo.datnomindate(#nc.NewDatnom), #nc.NewDatnom % 100000
    ,k.Plata,k.Fam,k.P_ID,k.B_ID
    ,k.V_ID,k.Ncod,k.Remark,k.RashFlag,k.LostFlag,k.LastFlag,k.Op,k.Bank_ID,k.Our_ID,k.BankDay,k.Actn
    ,k.Ck,k.Thr,k.ThrFam,k.DocNom,k.OrigRecn,k.ForPrint, #nc.NewDatnom, k.StNom,k.FromBank_ID,k.SkladNo
    ,1 AS DepID, k.B_idPlat,k.OperOld,k.NDInp,k.InBank,k.Nalog,k.RemarkPlat,k.pin,k.platarez,k.DCK,k.KassaNo,k.RealOper,k. KassID
  FROM 
    morozdata..kassa1 k
    INNER JOIN #nc ON #nc.olddatnom=k.SourDatnom
  WHERE k.oper=-2;
  -- Правим данные покупателя (код и контракт):
  UPDATE Kassa1 SET Dck=#c.NewDCK, Pin=#c.NewPin FROM Kassa1 k INNER JOIN #C ON #c.OldDCK=K.dck WHERE Oper=-2;

  -- Добавляем выплаты поставщикам, и сразу корректируем Nnak, Ncod=0, Pin, Our_ID, Dck
  INSERT INTO dbo.Kassa1(nd,tm,Oper,Act
    ,SourDate,Nnak
    ,Plata,Fam,P_ID,B_ID
    ,V_ID,Ncod,Remark,RashFlag,LostFlag,LastFlag,Op,Bank_ID,Our_ID,BankDay,Actn
    ,Ck,Thr,ThrFam,DocNom,OrigRecn,ForPrint,SourDatNom,StNom,FromBank_ID,SkladNo
    ,DepID,B_idPlat,OperOld,NDInp,InBank,Nalog,RemarkPlat,pin,platarez,DCK,KassaNo,RealOper, OldKassID)
  SELECT
    k.nd,k.tm,k.Oper,k.Act
    ,k.sourdate, cm.ncom
    ,k.Plata,k.Fam,k.P_ID,k.B_ID
    ,k.V_ID,0 AS Ncod,k.Remark,k.RashFlag,k.LostFlag,k.LastFlag,k.Op,k.Bank_ID,cm.Our_ID,k.BankDay,k.Actn
    ,k.Ck,k.Thr,k.ThrFam,k.DocNom,k.OrigRecn,k.ForPrint, 0 AS SourDatnom, k.StNom,k.FromBank_ID,k.SkladNo
    ,1 AS DepID,k.B_idPlat,k.OperOld,k.NDInp,k.InBank,k.Nalog,k.RemarkPlat,cm.pin,k.platarez,cm.DCK,k.KassaNo,k.RealOper,k. KassID
  FROM 
    morozdata..kassa1 k
    INNER JOIN Comman cm ON cm.OLD_Ncom=k.nnak
  WHERE k.oper=-1;
  

  ENABLE trigger ALL ON dbo.Kassa1;

--SELECT 'Kassa1' AS tabName,* FROM Kassa1;

  TRUNCATE TABLE skladlist;
  INSERT INTO dbo.SkladList(SkladNo,SkladName,skg,Must,OnlyMinP,Locked,AgInvis,DisMinExtra
    ,Discard,SafeCust,Equipment,UpWeight,SkladOperLock,Discount,srid)
  SELECT SkladNo,SkladName,skg,Must,OnlyMinP,Locked,AgInvis,DisMinExtra
    ,Discard,SafeCust,Equipment,UpWeight,SkladOperLock,Discount,srid
  FROM morozdata..skladlist


  TRUNCATE TABLE skladgroups;
  INSERT INTO dbo.SkladGroups(skg,skgName,SkladList,Build,NumSklad,PLID,Our_ID,srid)
    SELECT skg,skgName,SkladList,Build,NumSklad,PLID,Our_ID,srid 
    FROM morozdata..skladgroups;
  UPDATE SkladGroups SET Our_ID=fc.Our_id FROM SkladGroups s INNER JOIN FirmsConfig fc ON fc.Old_OurID=s.Our_ID;

  
  -- ************************************************************************************
  -- **      Проверка движения остатков, исходных и конвертированных                   **
  -- ************************************************************************************
  IF OBJECT_ID('tempdb..#mv') IS NOT NULL DROP TABLE #mv;
  CREATE TABLE #mv(startid INT, StartIdOld INT, Hitag INT, TotalSellOld decimal(10,3), 
    TotalSellNew DECIMAL(10,3), Unid tinyint)
  insert INTO #mv(startid,startidOld,hitag, Unid)
    SELECT i.newid, i.oldid, v.hitag, v.unid
    FROM transport_i i INNER JOIN visual v ON v.startid=i.newid;

  SET @Nnak0=Morozdata.dbo.fndatnom(dbo.today(),0); -- номер нулевой накладной за сегодня в БД Морозко
  
  IF OBJECT_ID('tempdb..#sl') IS NOT NULL DROP TABLE #sl;
  CREATE TABLE #sl(IdMrz INT, StartIdMrz INT, SellMrz DECIMAL(10,3));
  INSERT INTO #sl(IdMrz,StartIdMrz,SellMrz) 
    SELECT nv.tekid, v.Startid, SUM(nv.kol*iif(nm.flgWeight=0, 1, v.Weight))
    FROM morozdata..nv INNER JOIN morozdata..visual v ON v.id=nv.tekid
    INNER  JOIN morozdata..nomen nm ON nm.hitag=nv.hitag
    WHERE nv.datnom>=1805010001 AND nv.datnom<@Nnak0 AND v.startid IN (SELECT oldid FROM transport_i)
    GROUP BY nv.tekid, v.Startid
  UNION all
    SELECT nv.tekid, v.Startid, SUM(nv.kol*iif(nm.flgWeight=0, 1, v.Weight))
    FROM morozdata..nv INNER JOIN morozdata..tdvi v ON v.id=nv.tekid
    INNER  JOIN morozdata..nomen nm ON nm.hitag=nv.hitag
    WHERE nv.datnom>@Nnak0 AND v.startid IN (SELECT oldid FROM transport_i)
    GROUP BY nv.tekid, v.Startid

  UPDATE #mv SET TotalSellOld=E.Kol FROM #mv 
    INNER JOIN (SELECT StartIdMrz, SUM(SellMrz) Kol FROM #sl GROUP BY StartIdMrz) E ON E.StartIdMrz=#mv.StartIdOld
   
  UPDATE #mv SET TotalSellNew=ISNULL(E.Kol,0) FROM #mv
    left JOIN (SELECT TekID, SUM(Kol) Kol FROM nv GROUP BY tekid) E ON E.TekID=#mv.startid

  SELECT '#mv' AS TabName, *, ISNULL(TotalSellOld,0)-TotalSellNew AS Err FROM #mv;


  -- Перегоняем координаты наших фирм, отбрасывая по дороге лишнее:
  TRUNCATE TABLE FirmsPlace;
  INSERT INTO FirmsPlace(Our_ID,PlID,OurAddrFiz,PosX,PosY)
    SELECT Our_ID-21,PlID,OurAddrFiz,PosX,PosY
    FROM morozdata..FirmsPlace
    WHERE Our_ID>=22
    ORDER BY Our_ID;


  -- Перегоняем таблицу настроек печати. Сначала самые общие данные, для наших фирм (2 строки):
  TRUNCATE TABLE printoptions;
  INSERT INTO dbo.PrintOptions(OurID,Pin,Dck,QtyNakl,QtyStf,QtyTorg12,QtyTtn,QtyBill,
    QtyDover,StfBase,Remark,QtyUPD,DCKVend,Op,QtyDover2,Torg12weight,Actual,QtyMh3)
  SELECT OurID-21,Pin,Dck,QtyNakl,QtyStf,QtyTorg12,QtyTtn,QtyBill,
    QtyDover,StfBase,Remark,QtyUPD,DCKVend,Op,QtyDover2,Torg12weight,Actual,QtyMh3
  FROM morozdata..PrintOptions
  WHERE OurID>=22 AND ISNULL(pin,0)=0 AND ISNULL(pin,0)=0

  -- Теперь данные по конкретным покупателям, без DCK (из 1000 строк отфильтровано 30):
  INSERT INTO dbo.PrintOptions(OurID,Pin,Dck,QtyNakl,QtyStf,QtyTorg12,QtyTtn,QtyBill,
    QtyDover,StfBase,Remark,QtyUPD,DCKVend,Op,QtyDover2,Torg12weight,Actual,QtyMh3)
  SELECT 0, def.pin,0 AS DCK,o.QtyNakl,o.QtyStf,o.QtyTorg12,o.QtyTtn,o.QtyBill,
    o.QtyDover,o.StfBase,o.Remark,o.QtyUPD,o.DCKVend,o.Op,o.QtyDover2,o.Torg12weight,o.Actual,o.QtyMh3
  FROM 
    morozdata..PrintOptions o
    INNER JOIN def ON def.OLD_pin=o.pin
  WHERE o.pin>0 AND o.OurID=0 AND o.dck=0

  -- Теперь данные по покупателям, у которых договора указаны (218 записей):
  INSERT INTO dbo.PrintOptions(OurID,Pin,Dck,QtyNakl,QtyStf,QtyTorg12,QtyTtn,QtyBill,
    QtyDover,StfBase,Remark,QtyUPD,DCKVend,Op,QtyDover2,Torg12weight,Actual,QtyMh3)
  SELECT dc.Our_id,dc.pin,dc.Dck,o.QtyNakl,o.QtyStf,o.QtyTorg12,o.QtyTtn,o.QtyBill,
    o.QtyDover,o.StfBase,o.Remark,o.QtyUPD,o.DCKVend,o.Op,o.QtyDover2,o.Torg12weight,o.Actual,o.QtyMh3
  FROM 
    morozdata..PrintOptions o 
    INNER JOIN defcontract dc ON dc.Old_DCK=o.dck
  WHERE o.dck>0


END