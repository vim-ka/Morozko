-- Подготовка данных для печати пакета накладных:
CREATE procedure dbo.PrepareNakPrint @NaklList varchar(5000)='18051400005,18051400006'
-- @NaklList - список из одной основной накладной и нескольких (возможно, 0) дополнительных.

AS

declare @Nom0 bigint, @Datnom bigint, @RefDatnom bigint, @tekid int, @Cnt int, @reftekid int, 
   @SumKol decimal(10,3), @SourKol decimal(10,3), @NewKol decimal(10,3), @OrigNom bigint,
   @tekid0 int, @hitag int, @price money, @cost money, @kol decimal(10,3), @sklad smallint,
   @recn int, @K DECIMAL(18,10), @Unid smallint

BEGIN
  declare @flgDebug bit; -- вывод промежуточных результатов?
  set @flgDebug=0;
  SET @K=1;
  SET @Unid=0;
 
  -- Список номеров накладных:
  create table #nom(datnom bigint);
  insert into #nom select k from dbo.Str2intarray(@NaklList);
  create index nom_tmp_idx on #nom(datnom);

  -- Считаю, что из этого списка ровно одна накладная - исходная. Это продажа с минимальным номером:

  set @OrigNom=(select min(nc.datnom) from nc inner join #nom on #nom.datnom=nc.datnom where nc.sp>=0 and nc.sc>=0);
  
  -- Может, исходной и вообще нет, но не беда. Набьем чем есть.
  create table #v(recn int not null identity(1,1) primary key,datnom bigint, 
    tekid int, hitag int,price money,cost money, kol DECIMAL(10,3) default 0, sklad smallint, 
    K DECIMAL(18,10) DEFAULT 1, Unid SMALLINT DEFAULT 0, Orig bit default 0);
  create table #v1(recn int, datnom bigint,
    tekid int, hitag int,price money,cost money, kol DECIMAL(10,3) default 0, sklad smallint, 
    K DECIMAL(18,10) DEFAULT 1, Unid SMALLINT DEFAULT 0, Orig bit default 0);
  
  insert into #v(datnom,tekid,hitag,price,cost,kol,sklad, K, Unid) 
    select nv.datnom,tekid,hitag,price,cost,kol,sklad, K, Unid 
    from nv inner join #nom on #nom.datnom=nv.datnom ; -- where datnom=@OrigNom;
  IF @flgDebug=1 begin
    SELECT '#nom' AS TabName, * FROM #nom;
    SELECT 'NV' AS TabName, * FROM nv WHERE datnom=@OrigNom;
    SELECT '#v' AS TabName, * FROM #v;
  END;

  

  set @Nom0=dbo.fnDatNom(dbo.today(),0);

  update #v set Orig=1 where datnom=@OrigNom;
  
  if @flgDebug=1 select 'Всё в куче' as Remark,* from #v;

  insert into #v1 select * from #v where Orig=1;

  if @flgDebug=1 select 'Исходная NV' as Remark,* from #v1;
  -- Проезжаем по добавке:
  if @flgDebug=1 select 'Добавка' as Remark, * from #v where Orig=0;

  -- create table #v(datnom bigint,tekid int, hitag int,price money,cost money, kol int default 0, sklad smallint, 
  --  flgWeight bit default 0, Weight1 decimal(10,3) default 0,Orig bit default 0);


    
  if @flgDebug=1 SELECT 'Курсор добивки' as remark, isnull(nj.reftekid,#v.tekid) as tekid, #v.hitag, #v.price, #v.cost, #v.kol, #v.sklad, 
    #v.unid, #v.K
  FROM 
    #v
    left join nv_join nj on nj.datnom=#v.datnom and nj.tekid=#v.tekid
  where #v.Orig=0;
      
        
          
  DECLARE cur CURSOR FAST_FORWARD READ_ONLY LOCAL FOR
  SELECT isnull(nj.reftekid,#v.tekid) as tekid, #v.hitag, #v.price, #v.cost, #v.kol, #v.sklad, 
    #v.K, #v.Unid
  FROM 
    #v
    left join nv_join nj on nj.datnom=#v.datnom and nj.tekid=#v.tekid
  where #v.Orig=0;

  OPEN cur;  
  FETCH NEXT FROM cur INTO @tekid, @hitag, @Price,@Cost,@Kol,@Sklad,@K,@Unid;  
  WHILE @@FETCH_STATUS = 0 BEGIN
    -- для текущей возвратной или добивочной строки ищем исходную такую же:
    set @recn=isnull((select min(recn) from #v1 where tekid=@tekid),0);
    if @recn=0 BEGIN -- если не найдена, то просто втыкаем ее в результирующую таблицу #v1:
      print('Втыкаю tekid='+cast(@tekid as varchar));
      insert into #v1(tekid, hitag, Price,Cost,Kol,Sklad,K,Unid)
      values(@tekid, @hitag, @Price,@Cost,@Kol,@Sklad,@K,@Unid)
    end;
    else BEGIN -- Исходная строка найдена. Тут были сложные вычисления, но сейчас мы игнорируем разницу между штучным и весовым товаром:
        update #v1 set kol=kol+@kol where recn=@recn;
    end;
    FETCH NEXT FROM cur INTO @tekid, @hitag, @Price,@Cost,@Kol,@Sklad,@K,@Unid;  
  end;
  CLOSE cur;
  DEALLOCATE cur;

  delete from #v1 where kol=0;
  if @flgDebug=1 select 'Результат' as remark, * from #v1;
  if @flgDebug=1 select sum(kol) SW, sum(kol*cost) SC,sum(kol*price) sp from #v
      union ALL
    select sum(kol) SW, sum(kol*cost) SC,sum(kol*price) sp from #v1;
  
  -- Теперь нужно пристегнуть данные из заголовка главной накладной.
  if @OrigNom is null set @OrigNom=(select min(datnom) from #nom);

  -- Это уже финальная таблица, здесь будет храниться свернутая по товарам информация:
  create table #Rez2(datnom bigint, b_id int, dck int, srok int, OurID int, 
    ContrTip smallint, Fam varchar(255), BrINN varchar(12), BrKPP varchar(9), 
    Extra decimal(6,2), TekId int, Hitag int, Name varchar(90), FName varchar(100), 
    LongName varchar(90), Price decimal(15,5), Cost decimal(15,5), Sklad smallint,
    SkladGroup smallint, MinP int, Mpu int, Nds smallint, Fabriq varchar(50), 
    DatePost datetime, DateR datetime, SrokH datetime, Sert_ID int, Kol decimal(10,3), 
    Kol_B decimal(10,3), Ngrp int, LicNo varchar(50), LicWho varchar(10), LicDate datetime,
    BrAddr varchar(255), GpAddr varchar(255), StfDate datetime, Stfnom varchar(17), 
    OrgName varchar(80), NSert varchar(40), NBlank varchar(15), BegDate datetime, 
    EndDate datetime, NVet varchar(15), DateVet datetime, Printed smallint, 
    GpName varchar(255), Okpo varchar(10), Okpo2 varchar(10), Reg_ID varchar(5), 
    BnFlag bit, Fmt smallint, Actn tinyint, brAg_ID int, VisCountry varchar(50),
    Country varchar(50), NeedNDS bit,  RemarkOp varchar(50), 
    gpKpp varchar(9), Marsh2 int, Netto decimal(12,3), Brutto decimal(12,3), 
    Gtd varchar(100), Ncountry int, [Master] int, Unid smallint, K DECIMAL(18,10), Factoring bit, 
    NeedDover bit, BrName varchar(255),gpOur_ID int,ExtTag varchar(20),
    b_id2 int, Stip smallint, OrderDocNumber varchar(20), DocNom varchar(20), 
    Refdatnom bigint, refTekId int, 
    SumWeight decimal(10,3) default 0, Nabor varchar(10) default '');


  
  insert into #rez2(datnom,tekid,hitag,name,fname,longname,price,cost,sklad,
    skladGroup,Kol,Kol_B,K,Unid,Nds,Ngrp, Netto, Brutto)
  select @OrigNom, #v1.tekid, #v1.hitag, nm.name, nm.fname, nm3.Name longname, #v1.price,#v1.cost,#v1.sklad,
    sl.SkG, #v1.kol,0,#v1.K, #v1.Unid, nm.nds, nm.Ngrp, Netto, nm.Brutto
  from
    #v1
    left join SkladList SL on SL.SkladNo=#v1.Sklad
    inner join Nomen nm on nm.hitag=#v1.hitag
    left join Nomen3 nm3 on nm3.Hitag=#v1.hitag;
  
  
  
  update #rez2 set b_id=iif(nc.b_id2=0,nc.b_id,nc.b_id2), dck=nc.dck, srok=nc.srok, OurID=nc.OurID, ContrTip=dc.ContrTip,
    Fam=iif(nc.b_id2=0, nc.fam, def.gpName), brINN=def.brInn, BrKPP=def.brKpp, Extra=nc.extra, BrAddr=def.brAddr,  GpAddr=def.gpAddr,
    StfDate=nc.StfDate, stfNom=nc.StfNom,Printed=nc.Printed, GpName=def.gpName, Okpo=def.OKPO, Okpo2=def.okpo2,
    Reg_ID=def.Reg_ID, [Master]=def.Master, Factoring=dc.Factoring, NeedDover=nc.NeedDover, BrName=def.brName,
    gpOur_ID=nc.gpOur_ID, b_id2=nc.B_Id2, Stip=nc.STip, OrderDocNumber=nc.DocNom, DocNom=nc.DocNom,
    LicNo=dc.ContrNum,licwho='', LicDate=DC.ContrDate, bnFlag=dc.bnFlag, Fmt=Def.fmt, brAg_ID=dc.ag_id,
    RemarkOP=nc.Remarkop,Actn=iif(nc.gpOur_id>100, 0, nc.Actn), NeedNds=iif(nc.gpOur_id>100, dc2.NDS, F.Nds), -- Actn=nc.Actn, NeedNds=F.Nds,
    gpKpp=def.gpKpp,Marsh2=nc.Marsh2
  from 
    nc 
    inner join DefContract dc on dc.dck=nc.dck
    left join DefContract dc2 on dc2.dck=nc.gpOur_ID
    inner join def on def.pin=iif(nc.b_id2=0,nc.b_id,nc.b_id2)
    left join FirmsConfig F on F.Our_ID=nC.Ourid
  where nc.datnom=@OrigNom;

  update #rez2 set MinP=v.minp, mpu=v.mpu,Fabriq=pr.ProducerName, DatePost=v.DatePost,
    DateR=V.DateR, Srokh=V.Srokh, SERT_ID=v.SERT_ID, orgName=sr.orgName,
    NSert=sr.nSert,nBlank=sr.nBlank, BegDate=sr.begDate, EndDate=sr.endDate, NVet=sr.nVet, DateVet=sr.dateVet,
    VisCountry=v.COUNTRY, Country=c.CName, Gtd=v.Gtd, Ncountry=v.CountryID, ExtTag=n2.ExtTag
  from 
    #rez2 
    inner join tdvi v on v.id=#rez2.tekid 
    left join Producer pr on pr.ProducerID=v.ProducerID
    left join Sertif sr on sr.sert_id=v.sert_id 
    left join NomenVend N2 on N2.Pin=#Rez2.b_id and N2.hitag=#rez2.Hitag
    left join Country c on c.Ncnt=v.CountryID


  update #rez2 set MinP=v.minp, mpu=v.mpu,Fabriq=pr.ProducerName, DatePost=v.DatePost,
    DateR=V.DateR, Srokh=V.Srokh, SERT_ID=v.SERT_ID, orgName=sr.orgName,
    NSert=sr.nSert,nBlank=sr.nBlank, BegDate=sr.begDate, EndDate=sr.endDate, NVet=sr.nVet, DateVet=sr.dateVet,
    VisCountry=v.COUNTRY, Country=c.CName, Gtd=v.Gtd, Ncountry=v.CountryID, ExtTag=n2.ExtTag
  from 
    #rez2 
    inner join visual v on v.id=#rez2.tekid 
    left join Producer pr on pr.ProducerID=v.ProducerID
    left join Sertif sr on sr.sert_id=v.sert_id 
    left join NomenVend N2 on N2.Pin=#rez2.b_id and N2.hitag=#rez2.Hitag
    left join Country c on c.Ncnt=v.CountryID
  where #rez2.MinP is null;

  update #rez2 set Nabor=iif(z.spk>0, cast(z.spk as varchar), 'u'+cast(z.OP as varchar)) 
    from #rez2 inner join nvzakaz Z on Z.datnom=#rez2.datnom and Z.ID=#rez2.TekId and (z.spk>0 or z.op>0)
  
  UPDATE #Rez2 SET SumWeight=kol*K*IIF(unid=1,1,netto);

  select * from #rez2 order by sklad,name;
  -- SELECT hitag,name,netto,brutto,kol, sumweight, k, unid FROM #rez2;

  END;