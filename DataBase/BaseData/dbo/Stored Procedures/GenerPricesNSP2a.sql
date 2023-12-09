CREATE procedure GenerPricesNSP2a @DCK INT, @SkladList varchar(300)=NULL,
  @Datnom int=0, 
  @Action tinyint=null, -- null,0 -сформировать прайс-лист для покуп. DCK
  -- 1 - сформировать цены для накладной datnom
  -- 2 - применить цены для nv с заданным datnom
  -- 3 - исправить табл. Zakaz для заданного DCK
  -- 4 - сформировать таблицу цен для заданного списка товаров IdList и покупателя DCK
  @IdList varchar(300)=null -- список идов
as
declare @theNMID int, @theOblID int, @theRNID int, @theDepID int, @theSvID int, 
  @theAgID int,  @theB_ID int, @theMaster int, @theFmt int, @theContrTip smallint,
  @FixPrice decimal(10,2)
declare @ctVendor tinyint, @ctGroup tinyint, @ctWares tinyint, @ctAll tinyint,
  @mtAdCostPerc tinyint, @mtFixedPrice tinyint, @mtDisabled tinyint, @mtAdCostRub tinyint, 
  @mtAdPriceRub tinyint, @mtAdPricePerc tinyint


set @ctVendor=0 -- типы групп товаров: товары заданного поставщика
set @ctGroup=1	-- группа товаров
set @ctWares=2	-- код товара
set @ctAll=3	-- вообще все товары :)

set @mtAdCostPerc=0 -- тип наценки: добавочный % к цене прихода
set @mtFixedPrice=1 -- фиксированная цена
set @mtDisabled=2   -- запрет продажи
set @mtAdCostRub=3  -- наценка в рублях к цене прихода
set @mtAdPriceRub=4 -- наценка в рублях к цене продажи
set @mtAdPricePerc=5 -- наценка в % к цене продажи
  
begin


  -- ИЗ СПИСКА ЗАДАЧ ПО НАЦЕНКЕ ОТБИРАЮ ОТНОСЯЩИЕСЯ К ЗАДАННОМУ ПОКУПАТЕЛЮ:
  declare C1 cursor fast_forward  
  for 
    select distinct w.nmid
    from 
      NetSpec2_Who w 
      inner join netspec2_main m on m.nmid=w.nmid
    where
      ( (W.CodeTip=0)							-- Все покупатели
        or (w.CodeTip=1 and w.Code=@theOblID)	-- область
        or (w.CodeTip=2 and w.Code=@theRnID)	-- район
        or (w.CodeTip=3 and w.Code=@theDepID)	-- отдел
        or (w.CodeTip=4 and w.Code=@theFmt)		-- формат
        or (w.CodeTip=5 and w.Code=@theSvID)	-- супервайзер
        or (w.CodeTip=6 and w.Code=@theAgID)	-- агент
        or (w.CodeTip=7 and w.Code=@theMaster)	-- сетевой покупатель
        or (w.CodeTip=8 and w.Code=@theB_ID)	-- одиночный покупатель
      )
      and (w.code>0 or W.CodeTip=0) 
      and m.Activ=1 and dbo.today() between m.StartDate and m.FinishDate;

  if @Datnom>0 set @Dck=(select dck from nc where datnom = @DATNOM);

  --ГОТОВЛЮ ЛОКАЛЬНУЮ КОПИЮ СКЛАДА
  create table #t (id int, sklad tinyint, hitag int, Ncod int, ngrp int, [Parent] int, MainParent int, 
    weight decimal(10,3), Cost decimal(12,4), OrigPrice decimal(12,2), NewPrice decimal(10,2), 
    Nacen decimal(6,2), nmid int, Disab bit default 0, flgWeight bit default 0, 
    Locked bit default 0, MinP int, Mpu int, Rest int, flgMinPrice bit default 1); 
    -- flgMinPrice=1 если вычисленная цена NewPrice -минимально допустимая,
    -- flgMinPrice=0 если вычисленная цена NewPrice - в точности нужная.


  if @Action=4 -- задан список ID товаров:

    insert into #t (id,sklad,hitag,ncod,ngrp, [Parent], MainParent, WEIGHT,Origprice, flgWeight, Cost, Locked,Minp,Mpu, Rest)
    select 
      v.id, v.sklad, v.hitag, v.ncod, nm.ngrp, gr.Parent, gr.MainParent, v.weight, 
      v.price, nm.flgWeight,V.Cost, v.Locked, v.minp, v.mpu,
      cast(v.MORN-v.SELL+v.ISPRAV-v.REMOV-v.REZERV as integer) as Rest
    from 
      dbo.Str2intarray(@idlist) E
      inner join TDVI V on V.ID=E.K
      inner join Nomen nm on nm.hitag=v.HITAG
      inner join GR on GR.Ngrp=nm.ngrp
      inner join skladlist S on S.SkladNo=v.Sklad
    where 
      S.Locked=0
      and v.MORN-v.SELL+v.ISPRAV-v.REMOV-v.REZERV > 0;
  else if @Action=3
    insert into #t (id,sklad,hitag,ncod,ngrp, [Parent], MainParent, WEIGHT,Origprice, flgWeight, Cost, Locked,Minp,Mpu, Rest)
    select 
      z.tekid, z.sklad, z.hitag, v.ncod, nm.ngrp, gr.Parent, gr.MainParent, v.weight, 
      v.price, nm.flgWeight,V.Cost, v.Locked, v.minp, v.mpu,
      cast(v.MORN-v.SELL+v.ISPRAV-v.REMOV-v.REZERV as integer) as Rest
    from 
      zakaz z
      inner join TDVI V on v.id=z.tekid
      inner join Nomen nm on nm.hitag=v.HITAG
      inner join GR on GR.Ngrp=nm.ngrp
    where z.DCK= @DCK; 
  else if (@Datnom>0) and (@Action=1 or @Action=2) and (dbo.DatnomInDate(@datnom)=dbo.today()) -- накладная за сегодня
    insert into #t (id,sklad,hitag,ncod,ngrp, [Parent], MainParent, WEIGHT,Origprice, flgWeight, Cost, Locked,Minp,Mpu, Rest)
    select 
      nv.tekid, nv.sklad, nv.hitag, v.ncod, nm.ngrp, gr.Parent, gr.MainParent, v.weight, 
      v.price, nm.flgWeight,V.Cost, v.Locked, v.minp, v.mpu,
      cast(v.MORN-v.SELL+v.ISPRAV-v.REMOV-v.REZERV as integer) as Rest
    from 
      nv
      inner join TDVI V on v.id=nv.tekid
      inner join Nomen nm on nm.hitag=v.HITAG
      inner join GR on GR.Ngrp=nm.ngrp
    where nv.datnom=@Datnom;

  else if (@Datnom>0) and (@Action=1 or @Action=2)  and (dbo.DatnomInDate(@datnom)<>dbo.today()) -- накладная за вчера
    insert into #t (id,sklad,hitag,ncod,ngrp, [Parent], MainParent, WEIGHT,Origprice, flgWeight, Cost, Locked,Minp,Mpu, Rest)
    select 
      nv.tekid, nv.sklad, nv.hitag, v.ncod, nm.ngrp, gr.Parent, gr.MainParent, v.weight, 
      v.price, nm.flgWeight,V.Cost, v.Locked, v.minp, v.mpu,
      cast(v.MORN-v.SELL+v.ISPRAV-v.REMOV-v.REZERV as integer) as Rest
    from 
      nv
      inner join visual V on v.id=nv.tekid
      inner join Nomen nm on nm.hitag=v.HITAG
      inner join GR on GR.Ngrp=nm.ngrp
    where nv.datnom=@Datnom;
  else if @SkladList is null
    insert into #t (id,sklad,hitag,ncod,ngrp, [Parent], MainParent, WEIGHT,Origprice, flgWeight, Cost, Locked,Minp,Mpu, Rest)
    select 
      v.id, v.sklad, v.hitag, v.ncod, nm.ngrp, gr.Parent, gr.MainParent, v.weight, 
      v.price, nm.flgWeight,V.Cost, v.Locked, v.minp, v.mpu,
      cast(v.MORN-v.SELL+v.ISPRAV-v.REMOV-v.REZERV as integer) as Rest
    from 
      TDVI V 
      inner join Nomen nm on nm.hitag=v.HITAG
      inner join GR on GR.Ngrp=nm.ngrp
      inner join skladlist S on S.SkladNo=v.Sklad
    where 
      S.Locked=0
      and v.MORN-v.SELL+v.ISPRAV-v.REMOV-v.REZERV > 0;
  else
    insert into #t (id,sklad,hitag,ncod,ngrp, [Parent], MainParent, WEIGHT,Origprice, flgWeight, Cost, Locked,Minp,Mpu,Rest)
    select 
      v.id, v.sklad, v.hitag, v.ncod, nm.ngrp, gr.Parent, gr.MainParent, v.weight, 
      v.price, nm.flgWeight,V.Cost, v.Locked, v.minp, v.mpu,
      cast(v.MORN-v.SELL+v.ISPRAV-v.REMOV-v.REZERV as integer) as Rest
    from 
      TDVI V 
	  inner join (select K from dbo.Str2intarray(@SkladList)) E on E.K=v.SKLAD
      inner join Nomen nm on nm.hitag=v.HITAG
      inner join GR on GR.Ngrp=nm.ngrp
      inner join skladlist S on S.SkladNo=v.Sklad
    where 
      S.Locked=0
      and v.MORN-v.SELL+v.ISPRAV-v.REMOV-v.REZERV > 0;
  create index t_temp_idx on #t(id);

  -- Кто наш покупатель, какого роду-племени?
  select 
    @theAgID=DC.ag_id, @theB_ID=DC.Pin, @theDepID=SV.DepID, @theRnID=D.Rn_ID,  
    @theOblID=D.Obl_ID, @theMaster=d.[Master], @theFmt=d.dfID, 
    @theContrTip=DC.ContrTip
  from 
    DefContract DC 
    inner join Agentlist A on A.AG_ID=DC.ag_id
    inner join AgentList SV on SV.AG_ID=A.sv_ag_id
    inner join Def D on D.pin=dc.pin
  where 
    dc.DCK=@DCK; --  and Dc.ContrTip=2 - убираю это! Уж какой есть!


select distinct w.nmid
from 
  NetSpec2_Who w 
  inner join netspec2_main m on m.nmid=w.nmid
where
  ( (W.CodeTip=0)							-- Все покупатели
    or (w.CodeTip=1 and w.Code=@theOblID)	-- область
    or (w.CodeTip=2 and w.Code=@theRnID)	-- район
    or (w.CodeTip=3 and w.Code=@theDepID)	-- отдел
    or (w.CodeTip=4 and w.Code=@theFmt)		-- формат
    or (w.CodeTip=5 and w.Code=@theSvID)	-- супервайзер
    or (w.CodeTip=6 and w.Code=@theAgID)	-- агент
    or (w.CodeTip=7 and w.Code=@theMaster)	-- сетевой покупатель
    or (w.CodeTip=8 and w.Code=@theB_ID)	-- одиночный покупатель
  )
  and (w.code>0 or W.CodeTip=0) 
  and m.Activ=1 and dbo.today() between m.StartDate and m.FinishDate;

 

  -- ОК, получили список задач, которые относятся к нашему клиенту. Смотрим его:
  open C1; 
  fetch next from C1 into @theNMID;
  WHILE (@@FETCH_STATUS=0) BEGIN
    -- Теперь у нас есть номер задачи по наценке, которая точно относится к покупателю.
    -- Перво-наперво запрет продаж. Может быть, вообще всё запрещено?
    if EXISTS(select * from netspec2_what T where t.nmid=@theNMID and T.RezTip=@mtDisabled and T.CodeTip=@ctAll)
    update #t set #t.Disab=1, NmID=@TheNMID where nmid is null;
    else begin -- ну раз всё запрещено, то дальше и смотреть незачем. Иначе:
      --******************************************************
      --**     ЗАПРЕТЫ										**  
      --******************************************************

      -- Запрет для товаров с известным кодом:
      update #t set #t.Disab=1, #t.NmID=@TheNMID where nmid is null 
      and #t.hitag in (select Code from netspec2_what T 
        where t.nmid=@theNMID and T.RezTip=@mtDisabled and T.CodeTip=@ctWares);
      -- Запрет продаж товаров известной группы:
      update #t 
        set #t.Disab=1, #t.NmID=@TheNMID 
        where nmid is null 
        and ((#t.Ngrp in (select Code from netspec2_what T where t.nmid=@theNMID and T.RezTip=@mtDisabled and T.CodeTip=@ctGroup))
               or (#t.Parent in (select Code from netspec2_what T where t.nmid=@theNMID and T.RezTip=@mtDisabled and T.CodeTip=@ctGroup))
               or (#t.MainParent in (select Code from netspec2_what T where t.nmid=@theNMID and T.RezTip=@mtDisabled and T.CodeTip=@ctGroup))
            );
            
      -- Запрет продаж товаров известного поставщика:
      update #t 
        set #t.Disab=1, #t.NmID=@TheNMID
        where nmid is null 
        and #t.Ncod in (select Code from netspec2_what T where t.nmid=@theNMID and T.RezTip=@mtDisabled and T.CodeTip=@ctVendor);

      --******************************************************
      --**     ФИКСИРОВАННЫЕ ЦЕНЫ							**  
      --******************************************************

      -- Фиксированные цены по штучным товарам с известным кодом:
      update #t 
      set NewPrice=(select Rez from netspec2_what T 
        where t.nmid=@theNMID and T.RezTip=@mtFixedPrice and T.Code=#t.hitag and T.CodeTip=@ctWares and T.isWeightPrice=0)
        where nmid is null and #t.flgweight=0;
      update #t set flgMinPrice=0, NmID=@TheNMID where NmId is null and NewPrice is not null;
		-- То же по весовым:
      update #t 
      set NewPrice=dbo.Round5kop([WEIGHT]*(select Rez from netspec2_what T 
        where t.nmid=@theNMID and T.RezTip=@mtFixedPrice and T.Code=#t.hitag and T.CodeTip=@ctWares))
      where nmid is null and [WEIGHT]>0  and #t.flgweight=1;
      update #t set flgMinPrice=0, NmID=@TheNMID where NmId is null and NewPrice is not null;

      -- Фиксированная цена для всех штучных товаров заданного поставщика:
      update #t 
      set NewPrice=(select max(Rez) from netspec2_what T 
          where t.nmid=@theNMID and T.RezTip=@mtFixedPrice and T.Code=#t.Ncod and T.CodeTip=@ctVendor and T.isWeightPrice=0)
      where #t.nmid is null and #t.flgWeight=0;
      update #t set flgMinPrice=0, NmID=@TheNMID where NmId is null and NewPrice is not null;
	  -- То же для весовых товаров:
      update #t 
      set NewPrice=dbo.Round5kop([weight]*(select max(Rez) from netspec2_what T 
          where t.nmid=@theNMID and T.RezTip=@mtFixedPrice and T.Code=#t.Ncod and T.CodeTip=@ctVendor and T.isWeightPrice=1))
          where #t.nmid is null and #t.flgWeight=1;
      update #t set flgMinPrice=0, NmID=@TheNMID where NmId is null and NewPrice is not null;

      -- Фиксированная цена для всех штучных товаров в заданной группе:
      update #t 
      set NewPrice=(select max(Rez) from netspec2_what T 
          where t.nmid=@theNMID and T.RezTip=@mtFixedPrice and (T.Code=#t.ngrp or T.Code=#t.MainParent or T.Code=#t.Parent) 
          and T.CodeTip=@ctGroup and T.isWeightPrice=0)
      where #t.nmid is null and #t.flgWeight=0;
      update #t set flgMinPrice=0, NmID=@TheNMID where NmId is null and NewPrice is not null;
      -- То же для весовых товаров:
      update #t 
      set NewPrice=dbo.Round5kop([weight]*(select max(Rez) from netspec2_what T 
          where t.nmid=@theNMID and T.RezTip=@mtFixedPrice and (T.Code=#t.ngrp or T.Code=#t.MainParent or T.Code=#t.Parent) 
          and T.CodeTip=@ctGroup and T.isWeightPrice=1))
      where #t.nmid is null and #t.flgWeight=1;
      update #t set flgMinPrice=0, NmID=@TheNMID where NmId is null and NewPrice is not null;

      -- Фиксированная цена по всем вообще товарам, штучным :
      set @FixPrice=(select max(T.Rez) from netspec2_what T where t.nmid=@theNMID and T.RezTip=@mtFixedPrice and T.CodeTip=@ctAll and T.isWeightPrice=0);
      if @FixPrice is not null update #t  set flgMinPrice=0, NmID=@TheNMID, NewPrice=@FixPrice where #t.nmid is null and #t.flgWeight=0;
      -- То же по весовым товарам:
      set @FixPrice=(select max(T.Rez) from netspec2_what T where t.nmid=@theNMID and T.RezTip=@mtFixedPrice and T.CodeTip=@ctAll and T.isWeightPrice=1);
      if @FixPrice is not null update #t  set flgMinPrice=0,  NmID=@TheNMID, NewPrice=dbo.Round5kop([weight]*@FixPrice) where #t.nmid is null and #t.flgWeight=1;


      --******************************************************
      --**     НАЦЕНКА В ПРОЦЕНТАХ							**  
      --******************************************************

      -- Наценка в % по отношению к базовой цене (к витринной) для заданного кода товара
      -- Почти неважно, весовой товар или штучный:
      -- Для любого товара округление до 5 копеек вверх:
      update #t set Nacen=(select Rez from netspec2_what T 
        where T.nmid=@theNMID and T.RezTip=@mtAdPricePerc and T.Code=#t.hitag and T.CodeTip=@ctWares)
        where #t.nmid is null and #t.flgweight=0;
      update #t set flgMinPrice=1, NmID=@TheNMID, NewPrice=dbo.round5kop(OrigPrice*(1.0+Nacen/100.0)) where NmID is null and Nacen is not null;
      
      -- Наценка в % по отношению к приходной цене для заданного кода товара, аналогично:
      update #t set Nacen=(select Rez from netspec2_what T 
        where T.nmid=@theNMID and T.RezTip=@mtAdCostPerc and T.Code=#t.hitag and T.CodeTip=@ctWares)
        where #t.nmid is null;
      update #t set flgMinPrice=1, NmID=@TheNMID, NewPrice=dbo.round5kop(Cost*(1.0+Nacen/100.0)) where NmID is null and Nacen is not null;
      
      -- Наценка в % по отношению к базовой цене (к витринной) для заданной группы товаров
      update #t set Nacen=(select Rez from netspec2_what T 
        where T.nmid=@theNMID and T.RezTip=@mtAdPricePerc and (T.Code=#t.Ngrp or T.Code=#T.parent 
          or T.Code=#T.MainParent) and T.CodeTip=@ctGroup)
        where #t.nmid is null;
      update #t set flgMinPrice=1, NmID=@TheNMID, NewPrice=dbo.round5kop(OrigPrice*(1.0+Nacen/100.0)) where NmID is null and Nacen is not null;
      
      -- Наценка в % по отношению к приходной цене  для заданной группы товаров
      update #t set Nacen=(select Rez from netspec2_what T 
        where T.nmid=@theNMID and T.RezTip=@mtAdCostPerc and (T.Code=#t.Ngrp or T.Code=#T.parent 
          or T.Code=#T.MainParent) and T.CodeTip=@ctGroup)
        where #t.nmid is null;
      update #t set flgMinPrice=1, NmID=@TheNMID, NewPrice=dbo.round5kop(cost*(1.0+Nacen/100.0)) where NmID is null and Nacen is not null;
      
      -- Наценка в % по отношению к базовой цене (к витринной) для заданного поставщика:
      update #t set Nacen=(select Rez from netspec2_what T 
        where T.nmid=@theNMID and T.RezTip=@mtAdPricePerc and T.Code=#t.Ncod and T.CodeTip=@ctVendor)
        where #t.nmid is null;
      update #t set flgMinPrice=1, NmID=@TheNMID, NewPrice=dbo.round5kop(OrigPrice*(1.0+Nacen/100.0)) where NmID is null and Nacen is not null;

      		      
      -- Наценка в % по отношению к базовой цене (к витринной) для всех вообще товаров:
      set @FixPrice=(select max(T.Rez) from netspec2_what T 
        where t.nmid=@theNMID and T.RezTip=@mtAdPricePerc and T.CodeTip=@ctAll and T.isWeightPrice=0);
      if @FixPrice is not null 
        update #t set flgMinPrice=1, NmID=@TheNMID, NewPrice=dbo.round5kop(OrigPrice*(1.0+@FixPrice/100)) where nmid is null;

      --******************************************************
      --**     НАЦЕНКА В РУБЛЯХ								**  
      --******************************************************
      
      -- Наценка в рублях по отношению к базовой цене (к витринной) для штучного товара:
      update #t set Nacen=(select Rez from netspec2_what T 
        where T.nmid=@theNMID and T.RezTip=@mtAdPriceRub and T.Code=#t.hitag and T.CodeTip=@ctWares  and T.isWeightPrice=0)
        where #t.nmid is null and #t.flgweight=0;
      update #t set flgMinPrice=1, NmID=@TheNMID, NewPrice=dbo.round5kop(OrigPrice+Nacen),nacen=null where NmID is null and Nacen is not null;
      -- То же для весового товара:
      update #t set Nacen=(select Rez from netspec2_what T 
        where T.nmid=@theNMID and T.RezTip=@mtAdPriceRub and T.Code=#t.hitag and T.CodeTip=@ctWares  and T.isWeightPrice=1)
        where #t.nmid is null and #t.flgweight=1;
      update #t set flgMinPrice=1, NmID=@TheNMID, NewPrice=dbo.round5kop([weight]*(OrigPrice/[weight]+Nacen)),nacen=null 
        where NmID is null and Nacen is not null and [weight]>0;
      
      -- Наценка в рублях по отношению к приходной цене для штучного товара:
      update #t set Nacen=(select Rez from netspec2_what T 
        where T.nmid=@theNMID and T.RezTip=@mtAdCostRub and T.Code=#t.hitag and T.CodeTip=@ctWares  and T.isWeightPrice=0)
        where #t.nmid is null and #t.flgweight=0;
      update #t set flgMinPrice=1, NmID=@TheNMID, NewPrice=dbo.round5kop(Cost+Nacen),Nacen=null where NmID is null and Nacen is not null and #t.flgweight=0;
      -- То же для весового товара:
      update #t set Nacen=(select Rez from netspec2_what T 
        where T.nmid=@theNMID and T.RezTip=@mtAdCostRub and T.Code=#t.hitag and T.CodeTip=@ctWares  and T.isWeightPrice=1)
        where #t.nmid is null and #t.flgweight=1;
      update #t set flgMinPrice=1, NmID=@TheNMID, NewPrice=dbo.round5kop([weight]*(Cost/[Weight]+Nacen)), Nacen=null 
        where NmID is null and Nacen is not null and flgweight=1 and [weight]>0;

      -- Наценка в рублях по отношению к приходной цене для известной группы (только штучных) товаров:
      update #t set Nacen=(select Rez from netspec2_what T 
        where T.nmid=@theNMID and T.RezTip=@mtAdCostRub and (T.Code=#t.Ngrp or T.Code=#T.parent 
          or T.Code=#T.MainParent) and T.CodeTip=@ctGroup and T.isWeightPrice=0)
        where #t.nmid is null and #t.flgweight=0;
      update #t set flgMinPrice=1, NmID=@TheNMID, NewPrice=dbo.round5kop(Cost+Nacen),nacen=null 
        where NmID is null and Nacen is not null and flgWeight=0;
      -- То же для весового товара:
      update #t set Nacen=(select Rez from netspec2_what T 
        where T.nmid=@theNMID and T.RezTip=@mtAdCostRub and (T.Code=#t.Ngrp or T.Code=#T.parent 
          or T.Code=#T.MainParent) and T.CodeTip=@ctGroup and T.isWeightPrice=1)
        where #t.nmid is null and #t.flgweight=1;
      update #t set flgMinPrice=1, NmID=@TheNMID, NewPrice=dbo.round5kop([weight]*(Cost/[weight]+Nacen)),nacen=null 
        where NmID is null and Nacen is not null and flgWeight=1 and [weight]>0;
        
        
      -- Наценка в рублях по отношению к приходной цене для заданного поставщика (только штучных) товаров:
      update #t set Nacen=(select Rez from netspec2_what T 
        where T.nmid=@theNMID and T.RezTip=@mtAdCostRub and T.Code=#t.Ncod and T.CodeTip=@ctVendor and T.isWeightPrice=0)
        where #t.nmid is null and #t.flgweight=0;
      update #t set flgMinPrice=1, NmID=@TheNMID, NewPrice=dbo.round5kop(Cost+Nacen),nacen=null 
        where NmID is null and Nacen is not null and flgWeight=0;
      -- То же для весового товара:
      update #t set Nacen=(select Rez from netspec2_what T 
        where T.nmid=@theNMID and T.RezTip=@mtAdCostRub and T.Code=#t.Ncod and T.CodeTip=@ctVendor and T.isWeightPrice=1)
        where #t.nmid is null and #t.flgweight=1;
      update #t set flgMinPrice=1, NmID=@TheNMID, NewPrice=dbo.round5kop([weight]*(Cost/weight+Nacen)),nacen=null 
        where NmID is null and Nacen is not null and flgWeight=1 and [weight]>0;
        

      -- Наценка в рублях по отношению к приходной цене для всех вообще штучных товаров:
      set @FixPrice=(select max(T.Rez) from netspec2_what T 
        where t.nmid=@theNMID and T.RezTip=@mtAdCostRub and T.CodeTip=@ctAll and T.isWeightPrice=0);
      if @FixPrice is not null 
        update #t set flgMinPrice=1, NmID=@TheNMID, NewPrice=dbo.round5kop(Cost+@FixPrice),nacen=null 
        where nmid is null and flgWeight=0;

      -- То же для всех весовых товаров:
      set @FixPrice=(select max(T.Rez) from netspec2_what T 
        where t.nmid=@theNMID and T.RezTip=@mtAdCostRub and T.CodeTip=@ctAll and T.isWeightPrice=1);
      if @FixPrice is not null 
        update #t set flgMinPrice=1, NmID=@TheNMID, NewPrice=dbo.round5kop([WEIGHT]*(Cost/[weight]+@FixPrice)),nacen=null 
        where nmid is null and flgWeight=1 and [weight]>0;
    end; -- это если не всё вообще было запрещено.
    fetch next from C1 into @theNMID;
  end; -- WHILE, конец цикла
  close C1;
  deallocate C1;
  


  if @Action=2 and @Datnom>0 begin
    update nv set Price=(select NewPrice from #t where #t.id=nv.tekid)
      where nv.DatNom=@datnom and  nv.tekid not in (select id from #t where NewPrice is not null);
    update NC set sp=(1.0+NC.extra/100.0)*(select sum(nv.kol*nv.price) from nv where nv.DatNom=nc.datnom) where datnom=@datnom;
  end;
 
  else if @Action=3 begin
    delete from Zakaz where DCK=@DCK and tekid in (select id from #t where Disab=1);
    update Zakaz set Price=(select NewPrice from #t where #t.id=zakaz.tekid)
      where Zakaz.dck=@DCK  and  Zakaz.tekid in (select id from #t where NewPrice is not null and flgMinPrice=0);
    update Zakaz set Price=(select NewPrice from #t where #t.id=zakaz.tekid)
    where Zakaz.dck=@DCK  and  Zakaz.tekid in (select id from #t join Zakaz on  Zakaz.tekid=#t.id where Zakaz.dck=@dck and Zakaz.Price<isnull(#t.NewPrice,0) );
  end;

  else if isnull(@Action,0)<2
  select #t.*, nm.[name], nm.FName, s.OnlyMinP,nm.Nds
  from #t 
    inner join Nomen NM on nm.hitag=#t.Hitag
    inner join SkladList S on S.SkladNo=#t.Sklad
  order by nm.[name];
  
  else if @Action=4
    SELECT 
      #t.Ncod, Ve.Fam, T.DatePost, #t.Cost, i.Cost as SourceCost,
      #t.OrigPrice, #t.NewPrice, #t.nmid, 
      #t.flgWeight, #t.weight, #t.disab, #t.flgMinPrice
    FROM 
      #t
      inner join TDVI T on T.id=#t.id
      inner join Vendors Ve on Ve.Ncod=#t.Ncod 
      left join Inpdet i on i.id=T.StartID;


end