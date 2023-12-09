CREATE procedure dbo.GenerFormatPrices with recompile   -- результат - табл. FormatPrices
as -- Команда от главбуха: 7-й фирме продавать ТОЛЬКО товары 7-й фирмы. 17.06.2016
--set transaction isolation level read uncommitted;
declare @theNMID int, @theOblID int, @theRNID int, @theDepID int, @theSvID int, 
  @theAgID int,  @theB_ID int, @theMaster int, @theFmt int, @theContrTip smallint,
  @FixPrice decimal(10,2), @N int, @nmid int, @rez decimal(12,4), @reztip INT, @FirmGroup smallint
declare @ctVendor tinyint, @ctGroup tinyint, @ctWares tinyint, @ctAll tinyint,
  @mtAdCostPerc tinyint, @mtFixedPrice tinyint, @mtDisabled tinyint, @mtAdCostRub tinyint, 
  @mtAdPriceRub tinyint, @mtAdPricePerc tinyint, @mtFixAdCostPerc tinyint, @Koeff decimal(15,8),
  @today datetime, @StartDay DATETIME, @OnlyMorozko bit, @ContrTip smallint, @PLID int

set @OnlyMorozko=0;

set @ctAll=0	 -- вообще все товары :)
set @ctVendor=10 -- типы групп товаров: товары заданного поставщика
set @ctGroup=20	 -- группа товаров
set @ctWares=30  -- код товара

set @mtAdCostPerc=0 -- тип наценки: добавочный % к цене прихода
set @mtFixedPrice=1 -- фиксированная цена
set @mtDisabled=2   -- запрет продажи
set @mtAdCostRub=3  -- наценка в рублях к цене прихода
set @mtAdPriceRub=4 -- наценка в рублях к цене продажи
set @mtAdPricePerc=5 -- наценка в % к цене продажи
set @mtFixAdCostPerc=6 -- фиксированная наценка в % к цене прихода
  

begin
  --SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
  truncate table formatPrices; -- поля FpID, FormatID, Hitag, flgWeight,BasePrice

  -- Формирую список активных задач (только базовые форматы точек, у них приоритет 0), примерно 30 строк:
  -- begin try  
  set @today = dbo.today()
  create table #J (nmid int, [Format] smallint);
  insert into #J 
    select m.nmid, w.code
    from 
      netspec2_main m 
      inner join netspec2_who w on w.nmid=m.nmid
    where m.Activ=1
    and m.StartDate<=@today and m.FinishDate>=@today and m.[prior]=0 and w.codetip=4;
  create index J_tmp_idx on #J(nmid);
  
  
  -- Список клиентов, сначала - сети:
  create table #BR (Master int, Pin int default 0, DfID int);
  insert into #br(Master) select distinct Master from Def where Master>0 and Actual=1;

  insert into #br(Pin) 
  select distinct Def.Pin 
  from 
    Defcontract DC 
    inner join Def on Def.pin=DC.Pin 
  where dc.Contrtip=2 and dc.Pin>0 and def.Actual=1
  EXCEPT select [Master] from #br;
  
  update #BR set DfID=def.DfID from #br inner join Def on Def.pin=#br.Master where #br.MAster is not null;
  update #BR set DfID=def.DfID from #br inner join Def on Def.pin=#br.Pin where #br.MAster is null;
  --  select * from #br;
  --  select pin, count(pin) from #br group by pin having count(pin)>1;


  -- Список товаров, присутствующих в TDVI, примерно 8000 записей:
  create table #T (hitag int, Cost decimal(15,5), Price decimal(15,5), Ngrp int, Parent int, MainParent int)
  -- Сначала штучные товары:
  insert into #t(Hitag,Cost,Price) select v.Hitag, max(v.cost), max(v.price) 
  from tdvi v inner join nomen nm on nm.hitag=v.hitag 
  where nm.flgWeight=0 group by v.hitag;
  -- Теперь весовые, для них указывается цена1 кг:
  insert into #t (Hitag,Cost,Price)
  select v.Hitag, max(v.cost/iif(v.weight=0, nm.netto, v.weight)), max(v.price/iif(v.weight=0, nm.netto, v.weight)) 
  from tdvi v 
  inner join nomen nm on nm.hitag=v.hitag 
  where nm.flgWeight=1 and iif(v.weight=0, nm.netto, v.weight)>0 group by v.hitag;
  -- Проставляю номера групп:
  update #t set Ngrp=n.ngrp, Parent=gr.Parent, MainParent=gr.MainParent
  from 
    #t 
    inner join Nomen N on N.Hitag=#t.Hitag 
    inner join Gr on GR.Ngrp=N.Ngrp;
  select * from #t;


/*
  select #t.*
  FROM
    #t, (netspec2_what W 

  
  
  update #t set MinAddCost=W.Rez
  from
    #T

    inner join netspec2_what W on w.
*/






--  
--  create table #LocalTDVI (ID int, hitag int, Ncod int, Sklad int, Rest int, 
--    Our_ID int, price money, cost money, locked bit, minp int, mpu int, weight float, 
--    startid int, datepost datetime, DCK int)
--  
--    
--  if (@Datnom>0) and (@Action=1 or @Action=2) and dbo.DatnomInDate(@datnom)=@today
--
--    insert into #LocalTDVI (ID, hitag , Ncod, Sklad, Rest, Our_ID, price, cost, locked, minp, mpu, weight, startid, datepost,DCK)
--                   select v.ID, v.hitag , v.Ncod, v.sklad, v.morn-v.sell+v.isprav-v.remov-v.rezerv-v.bad, v.Our_ID, v.price, v.cost, v.Locked, v.minp, v.mpu, v.weight, v.startid, v.datepost,v.DCK
--                   from   tdvi v inner join nv on v.id=nv.tekid 
--                   where nv.datnom=@Datnom;
--
--  else                 
--  
--  if (@Datnom>0) and (@Action=1 or @Action=2) and dbo.DatnomInDate(@datnom)<@today
--    insert into #LocalTDVI (ID, hitag , Ncod, Sklad, Rest, Our_ID, price, cost, locked, minp, mpu, weight, startid, datepost,DCK)
--                   select v.ID, v.hitag , v.Ncod, v.sklad, v.start, v.Our_ID, v.price, v.cost, v.Locked, v.minp, v.mpu, v.weight, v.startid, v.datepost,v.DCK
--                   from   visual v inner join nv on v.id=nv.tekid 
--                   where nv.datnom=@Datnom;
--  else  
--  if @Action = 3 
--    begin
--      insert into #LocalTDVI (ID, hitag , Ncod, Sklad, Rest, Our_ID, price, cost, locked, minp, mpu, weight, startid, datepost,DCK)
--                   select v.ID, v.hitag , v.Ncod, v.sklad, v.morn-v.sell+v.isprav-v.remov-v.rezerv-v.bad, v.Our_ID,
--                          iif(n.flgWeight=1 and v.weight<>0, round(v.price/v.weight,2), v.price),
--                          iif(n.flgWeight=1 and v.weight<>0, round(v.cost/v.weight,2), v.cost),
--                          v.Locked, v.minp, v.mpu, v.weight, v.startid, v.datepost,v.DCK
--                   from   tdvi v join zakaz z on v.Id=z.tekID
--                                 join nomen n on v.hitag=n.hitag  
--                   where z.dck=@DCK
--    end              
--  else    
--  
--  if @Action = 4 
--    insert into #LocalTDVI (ID, hitag , Ncod, Sklad, Rest, Our_ID, price, cost, locked, minp, mpu, weight, startid, datepost,DCK)
--      select v.ID, v.hitag , v.Ncod, v.sklad, v.morn-v.sell+v.isprav-v.remov-v.rezerv-v.bad, v.Our_ID, v.price, v.cost, v.Locked, v.minp, v.mpu, v.weight, v.startid, v.datepost,v.DCK
--      from   
--          tdvi v 
--          join dbo.Str2intarray(@IdList) e on v.Id=e.K
--          JOIN FirmsConfig fc ON fc.Our_id=v.OUR_ID
--      WHERE fc.FirmGroup=@FirmGroup
--
--  else                   
--  if @Action = 6 
--  begin
--    insert into #LocalTDVI (ID, hitag , Ncod, Sklad, Rest, Our_ID, price, cost, locked, minp, mpu, weight, startid, datepost,DCK)
--                   select distinct  v.ID, v.hitag , v.Ncod, v.sklad, v.morn-v.sell+v.isprav-v.remov-v.rezerv-v.bad-isnull(z.zakaz,0), v.Our_ID, v.price, v.cost, v.Locked, v.minp, v.mpu, v.weight, v.startid, v.datepost,v.DCK
--                   from   tdvi v join dbo.Str2intarray(@HitagList) e on v.Hitag=e.K
--                                 outer apply (select sum(isnull(z.qty,0)) as zakaz from zakaz z where z.tekid=v.id) z
--    create table #NeedVendDCK(DCK int)                
--    if @VendDCK <> 0 insert into #NeedVendDCK (dck) select @VendDCK
--    if @VendDCK = 43737 or @VendDCK=44290 
--    begin
--      insert into #NeedVendDCK (dck) values (43737);
--      insert into #NeedVendDCK (dck) values (44290);
--    end
--    if @VendDCK=44283
--    begin
--    	insert into #NeedVendDCK
--      select dck
--      from DefContract 
--      where Our_id in (10,18)
--      			and ContrTip in (1,2)
--    end
--  end                 
--  else  
--    -- Здесь, Виктор! Для фирмы 7 допустимо продавать только товар фирмы 7:
--    insert into #LocalTDVI (ID, hitag , Ncod, Sklad, Rest, Our_ID, price, cost, locked, minp, mpu, weight, startid, datepost,DCK)
--    select ID, hitag , Ncod, Sklad, morn-sell+isprav-remov-rezerv-iif(bad<0,0,bad), tdVi.Our_ID, price, cost, locked, minp, mpu, weight, startid, datepost,DCK
--    from 
--      tdvi 
--      JOIN FirmsConfig fc ON fc.Our_id=tdvi.OUR_ID
--     where fc.FirmGroup=@FirmGroup and (@OnlyMorozko=0 or tdvi.OUR_ID=7)
--
--  
--  create index LTDVI_index1 on #LocalTDVI(ID)
--  create index LTDVI_index2 on #LocalTDVI(hitag)
--  create index LTDVI_index3 on #LocalTDVI(Ncod)
--  create index LTDVI_index4 on #LocalTDVI(Sklad)
--  
--  create table #LocalDefContract (DCK int, pin int, ag_id int, ContrTip int, Actual bit)
--    
--  -- ************************************************************************
--  -- **   Список контрактов клиентов, подпадающих под действие правил:     **
--  -- ************************************************************************
--  create table #NeedDCK (dck int)  
--  
--  if @Action=5 
--  begin
--    insert into #LocalDefContract (DCK, pin, ag_id, ContrTip, Actual)
--    select DCK, pin, ag_id, ContrTip, Actual from DefContract where ag_id=@ag_id
--   
--  	insert into #NeedDCK (dck)
--      select c.dck from #LocalDefContract c where c.ag_id=@ag_id /*or c.ag_id in (select b.add_ag_id from agaddbases b where b.ag_id=@ag_id and b.add_ag_id<>0)
--      union
--      select b.add_dck from agaddbases b where b.ag_id=@ag_id and b.add_dck<>0*/
--  end;
-- 
--  if (@DCK <> 0) and (@Action <> 5)
--  begin
--    insert into #LocalDefContract (DCK, pin, ag_id, ContrTip, Actual)
--    select DCK, pin, ag_id, ContrTip, Actual from DefContract where dck=@dck
--    insert into #NeedDCK (DCK) values (@DCK);
--  end
--  
--  create index LDC_index1 on #LocalDefContract(DCK)
--  create index LDC_index2 on #LocalDefContract(pin)
--  create index LDC_index3 on #LocalDefContract(ag_id)
--  create index LDC_index4 on #LocalDefContract(ContrTip)
--  
--  create index NeedDCK_tmp_idx on #NeedDCK(DCK);
--  
--  create table #DetWho (nmid int, dck int, codeTip int);
--  insert into #DetWho(nmid, dck, CodeTip)
--  select 
--      W.nmid, dc.dck, W.CodeTip
--    from 
--      #J inner join netspec2_who W on #J.nmid=W.nmid
--         inner join #LocalDefContract DC on dc.pin=W.Code and (W.ContrTip=0 or W.ContrTip=dc.contrtip)
--         inner join #NeedDCK N on DC.dck=N.dck
--      
--    where 
--      W.CodeTip=8
--      and dc.Actual=1
--      
--  union
--    select 
--      W.nmid, dc.dck, W.CodeTip
--    from 
--      netspec2_who W
--      inner join #J on #J.nmid=W.nmid
--      inner join Def D on D.Master=W.Code
--      inner join #LocalDefContract DC on dc.pin=d.pin and (W.ContrTip=0 or W.ContrTip=dc.contrtip)
--      inner join #NeedDCK N on DC.dck=N.dck
--    where 
--      W.CodeTip=7
--      and dc.Actual=1
--  union
--    select 
--      W.nmid, dc.dck, W.CodeTip
--    from 
--      netspec2_who W
--      inner join #J on #J.nmid=W.nmid
--      inner join #LocalDefContract DC on dc.ag_id=W.Code and (W.ContrTip=0 or W.ContrTip=dc.contrtip)
--      inner join #NeedDCK N on DC.dck=N.dck
--    where 
--      W.CodeTip=6
--      and dc.Actual=1
--   union
--    select 
--      W.nmid, dc.dck, W.CodeTip
--    from 
--      netspec2_who W
--      inner join #J on #J.nmid=W.nmid
--      inner join AgentList A on A.sv_ag_id=W.Code
--      inner join #LocalDefContract DC on dc.ag_id=A.AG_ID and (W.ContrTip=0 or W.ContrTip=dc.contrtip)
--      inner join #NeedDCK N on DC.dck=N.dck
--    where 
--      W.CodeTip=5
--      and dc.Actual=1
--   union
--    select 
--      W.nmid, dc.dck, W.CodeTip
--    from 
--      netspec2_who W
--      inner join #J on #J.nmid=W.nmid
--      inner join Def D on D.DFID=W.Code
--      inner join #LocalDefContract DC on dc.pin=d.pin and (W.ContrTip=0 or W.ContrTip=dc.contrtip)
--      inner join #NeedDCK N on DC.dck=N.dck
--    where 
--      W.CodeTip=4
--      and dc.Actual=1
--   union
--    select 
--      W.nmid, dc.dck, W.CodeTip
--    from 
--      netspec2_who W
--      inner join #J on #J.nmid=W.nmid
--      inner join AgentList A on A.depid=W.Code
--      inner join #LocalDefContract DC on dc.ag_id=A.AG_ID and (W.ContrTip=0 or W.ContrTip=dc.contrtip)
--      inner join #NeedDCK N on DC.dck=N.dck
--    where 
--      W.CodeTip=3
--      and dc.Actual=1
--   union
--    select 
--      W.nmid, dc.dck, W.CodeTip
--    from 
--      netspec2_who W
--      inner join #J on #J.nmid=W.nmid
--      inner join Def D on D.Rn_ID=W.Code
--      inner join #LocalDefContract DC on dc.pin=d.pin and (W.ContrTip=0 or W.ContrTip=dc.contrtip)
--      inner join #NeedDCK N on DC.dck=N.dck
--    where 
--      W.CodeTip=2
--      and dc.Actual=1
--   union
--    select 
--      W.nmid, dc.dck, W.CodeTip
--    from 
--      netspec2_who W
--      inner join #J on #J.nmid=W.nmid
--      inner join Def D on D.Obl_ID=W.Code
--      inner join #LocalDefContract DC on dc.pin=d.pin and (W.ContrTip=0 or W.ContrTip=dc.contrtip)
--      inner join #NeedDCK N on DC.dck=N.dck
--    where 
--      dc.Actual=1
--      and W.CodeTip=1
--   union
--    select 
--      W.nmid, dc.dck, W.CodeTip
--    from 
--      netspec2_who W
--      inner join #J on #J.nmid=W.nmid
--      inner join #LocalDefContract DC on (W.ContrTip=0 or W.ContrTip=dc.contrtip)
--      inner join #NeedDCK N on DC.dck=N.dck
--    where 
--      dc.Actual=1
--      and W.CodeTip=0
--      
--  create index DetWho_tmp_idx1 on #DetWho(nmid) 
--  create index DetWho_tmp_idx2 on #DetWho(dck)
--  create index DetWho_tmp_idx3 on #DetWho(CodeTip)    
--
--  create table #Sk (Sklad int); -- список спользуемых складов
--  if (@SkladList is NULL) or (@SkladList='') insert into #Sk select SkladNo from SkladList; -- where agInvis=0;
--  else 
--    insert into #Sk 
--    select K from dbo.Str2intarray(@SkladList) 
--    where K in (select SkladNo from SkladList); --  where agInvis=0
--   
--  create index Sk_ind_temp on #Sk(Sklad)
--  
--  create table #DetWhat (nmid int, hitag int, Rez decimal(15,5), RezTip tinyint, isWeightPrice bit, CodeTip int);
--
--  -- Частные условия, от самого подробного к более общим:
--  insert into #DetWhat
--  
--     select distinct w.nmid, w.Code, w.rez, w.reztip,w.isWeightPrice, w.CodeTip
--     from netspec2_what w join #LocalTDVI v on w.code=v.hitag
--                          join #J on w.nmid=#J.nmid
--                          join #Sk s on v.sklad=s.sklad
--     where w.CodeTip=@ctWares -- конкретные коды товаров
--
--  union
--      select distinct w.nmid, n.hitag, w.rez, w.reztip,w.isWeightPrice, w.CodeTip+g1.levl*3
--      from 
--        netspec2_what w 
--        inner join #J on w.nmid=#J.nmid
--        inner join Gr g on w.Code=g.MainParent or w.Code=g.Parent or w.Code=g.Ngrp 
--        inner join Gr g1 on g1.Ngrp=w.Code
--        inner join nomen n on g.Ngrp=n.Ngrp
--        inner join #LocalTDVI v on n.hitag=v.hitag
--        inner join #Sk s on v.sklad=s.sklad
--      where w.CodeTip=@ctGroup -- коды групп товаров
--   --   and n.hitag not in (select hitag from #detwhat)
--
--   union
--      select distinct w.nmid, v.hitag, w.rez, w.reztip,w.isWeightPrice, w.CodeTip
--      from 
--        netspec2_what w 
--        inner join #J on w.nmid=#J.nmid
--        inner join #LocalTDVI v on w.code=v.ncod
--        inner join #Sk s on v.sklad=s.sklad
--      where w.CodeTip=@ctVendor -- товары определенных поставщиков
--  --    and v.hitag not in (select hitag from #detwhat)
--   union
--      select distinct w.nmid, v.hitag, w.rez, w.reztip,w.isWeightPrice, w.CodeTip
--      from 
--        netspec2_what w inner join #J on w.nmid=#J.nmid,
--        #LocalTDVI v          inner join #Sk s on v.sklad=s.sklad
--      where w.CodeTip=@ctAll -- все товары
--   
--  create index DetWhat_tmp_idx1 on #DetWhat(hitag);     
--  create index DetWhat_tmp_idx2 on #DetWhat(CodeTip);     
-- 
--  --ГОТОВЛЮ ЛОКАЛЬНУЮ КОПИЮ СКЛАДА
--  create table #t (id int, sklad int, hitag int, Ncod int, ngrp int, [Parent] int, MainParent int, 
--    weight decimal(10,3), Cost decimal(12,4), OrigPrice decimal(15,5), NewPrice decimal(15,5), 
--    Nacen decimal(6,2), nmid int, Disab bit default 0, flgWeight bit default 0, 
--    Locked bit default 0, MinP int, Mpu int, Rest int, flgMinPrice bit default 1, DCK int default 0, 
--    Kol int default 0, Kol_b int default 0, Country varchar(50),DateR datetime,SrokH datetime,
--    Sert_ID int, Gtd varchar(100),NvId int, NvPrice decimal(15,5) default 0); -- последние 8 полей, с Kol по NvID - для анализа накладных.
--    -- flgMinPrice=1 если вычисленная цена NewPrice -минимально допустимая,
--    -- flgMinPrice=0 если вычисленная цена NewPrice - в точности нужная.
--
--/****************************************************************/
--  if @Action=4 -- задан список ID товаров:
--    insert into #t (id,sklad,hitag,ncod,ngrp, [Parent], MainParent, WEIGHT,Origprice, flgWeight, Cost, Locked,Minp,Mpu, Rest,DCK,nmid)
--    select 
--      v.id, v.sklad, v.hitag, v.ncod, nm.ngrp, gr.Parent, gr.MainParent, case when v.weight=0 then nm.netto else v.weight end as weight, 
--      v.price, nm.flgWeight,V.Cost, v.Locked, v.minp, v.mpu,
--      cast(v.Rest as integer) as Rest, @DCK,
--       iif(s.discard=1 or s.Discount=1, 0,null)
--    from 
--      dbo.Str2intarray(@idlist) E
--      inner join #LocalTDVI V on V.ID=E.K
--      inner join Nomen nm on nm.hitag=v.HITAG
--      inner join GR on GR.Ngrp=nm.ngrp
--      inner join skladlist S on S.SkladNo=v.Sklad
--      INNER JOIN FirmsConfig FC ON FC.Our_id=V.Our_ID
--    where 
--      S.Locked=0
--      and v.Rest > 0
--      -- and (@OurID=0 or V.Our_ID=@OurID);
--      and (@FirmGroup=0 or FC.FirmGroup=@FirmGroup);
-- else     
--/****************************************************************/
--  if @Action=6 and @VendDCK>0 -- задан список HITAG товаров:
--  begin
--    set @PLID=isnull((select PLID from Deps d join agentlist a on d.DepID=a.DepID
--                                       join DefContract c on c.Ag_id=a.ag_id
--              where c.DCK=@DCK ),1)
--  
--    insert into #t (id,sklad,hitag,ncod,ngrp, [Parent], MainParent, WEIGHT,Origprice, flgWeight, Cost, Locked,Minp,Mpu, Rest,DCK,nmid)
--    select 
--      v.id, v.sklad, v.hitag, v.ncod, nm.ngrp, gr.Parent, gr.MainParent, case when v.weight=0 then nm.netto else v.weight end as weight, 
--      v.price, nm.flgWeight,V.Cost, v.Locked, v.minp, v.mpu,
--      cast(v.Rest as integer) as Rest, @DCK,
--       iif(s.discard=1 or s.Discount=1, 0,null)
--    from 
--      dbo.Str2intarray(@HitagList) E
--      inner join #LocalTDVI V on V.Hitag=E.K
--      inner join Nomen nm on nm.hitag=V.Hitag
--      inner join GR on GR.Ngrp=nm.ngrp
--      inner join skladlist S on S.SkladNo=v.Sklad
--      inner join skladgroups g on g.skg=s.skg
--    where 
--      V.DCK in (select dck from #NeedVendDCK)
--      and S.Locked=0 and s.Discard=0 and s.Discount=0 and s.safecust=1
--      and v.Rest > 0
--      and g.PLID=@PLID
-- end     
-- else     
--/****************************************************************/
--  if @Action=6 and @VendDCK=0 -- задан список HITAG товаров:
--    insert into #t (id,sklad,hitag,ncod,ngrp, [Parent], MainParent, WEIGHT,Origprice, flgWeight, Cost, Locked,Minp,Mpu, Rest,DCK,nmid)
--    select 
--      v.id, v.sklad, v.hitag, v.ncod, nm.ngrp, gr.Parent, gr.MainParent, case when v.weight=0 then nm.netto else v.weight end as weight, 
--      v.price, nm.flgWeight,V.Cost, v.Locked, v.minp, v.mpu,
--      cast(v.Rest as integer) as Rest, @DCK,
--       iif(s.discard=1 or s.Discount=1, 0,null)
--    from 
--      dbo.Str2intarray(@HitagList) E
--      inner join #LocalTDVI V on V.Hitag=E.K
--      inner join Nomen nm on nm.hitag=V.Hitag
--      inner join GR on GR.Ngrp=nm.ngrp
--      inner join skladlist S on S.SkladNo=v.Sklad
--      inner join FirmsConfig FC on FC.Our_id=V.Our_ID
--      inner join Defcontract dc on dc.dck=v.dck 
--    where 
--     S.Locked=0 and s.SafeCust=0
--     and dc.ContrTip=1
--     and s.Discard=0 and s.Discount=0 and s.Equipment=0
--     and v.Rest > 0 
--     and (@FirmGroup=0 or FC.FirmGroup=@FirmGroup)
--     --and (@OurID=0 or V.Our_ID=@OurID)   
--     and (s.skladno<100 or s.skladno>200) and s.skladno<299
--/****************************************************************/
--  else if @Action=3
--    insert into #t (id,sklad,hitag,ncod,ngrp, [Parent], MainParent, WEIGHT,Origprice, flgWeight, Cost, Locked,Minp,Mpu, Rest,DCK)
--    select 
--      z.tekid, z.sklad, z.hitag, v.ncod, nm.ngrp, gr.Parent, gr.MainParent, case when v.weight=0 then nm.netto else v.weight end as weight,
--      v.price, nm.flgWeight,V.Cost, v.Locked, v.minp, v.mpu,
--      cast(v.Rest as integer) as Rest, @DCK
--    from 
--      zakaz z
--      inner join #LocalTDVI V on v.id=z.tekid
--      inner join Nomen nm on nm.hitag=v.HITAG
--      inner join GR on GR.Ngrp=nm.ngrp
--      INNER JOIN FirmsConfig FC ON FC.Our_id=V.Our_ID
--    where z.DCK=@DCK
--      -- and (@OurID=0 or V.Our_ID=@OurID);
--      and (@FirmGroup=0 or FC.FirmGroup=@FirmGroup);
--/****************************************************************/    
--  else if (@Datnom>0) and (@Action=1 or @Action=2) and (dbo.DatnomInDate(@datnom)=dbo.today()) -- накладная за сегодня
--    insert into #t (id,sklad,hitag,ncod,ngrp, [Parent], MainParent, WEIGHT,Origprice, 
--      flgWeight, Cost, Locked,Minp,Mpu, Rest,DCK,Kol,Kol_B,Country,DateR,SrokH,Sert_ID,Gtd,NvId,nmid, NvPrice)
--    select 
--      nv.tekid, nv.sklad, nv.hitag, v.ncod, nm.ngrp, gr.Parent, gr.MainParent, case when v.weight=0 then nm.netto else v.weight end as weight, 
--      v.price, nm.flgWeight,V.Cost, v.Locked, v.minp, v.mpu,
--      cast(v.MORN-v.SELL+v.ISPRAV-v.REMOV-v.REZERV-v.bad as integer) as Rest, @DCK,
--      nv.kol, nv.kol_b, V.Country,V.DateR,V.SrokH,v.Sert_ID,v.Gtd,nv.NvId,
--      iif(s.discard=1 or s.Discount=1, 0,null), nv.Price
--    from 
--      nv
--      inner join tdvi V on v.id=nv.tekid
--      inner join Nomen nm on nm.hitag=v.HITAG
--      inner join GR on GR.Ngrp=nm.ngrp
--      inner join skladlist s on s.SkladNo=nv.Sklad
--      INNER JOIN FirmsConfig FC ON FC.Our_id=V.Our_ID
--    where nv.datnom=@Datnom 
--      -- and (@OurID=0 or V.Our_ID=@OurID)                -- ЗДЕСЬ НАДО ПОДУМАТЬ
--      -- and (@FirmGroup=0 or FC.FirmGroup=@FirmGroup)    -- ЗДЕСЬ НАДО ПОДУМАТЬ
--/****************************************************************/    
--  else if (@Datnom>0) and (@Action=1 or @Action=2)  and (dbo.DatnomInDate(@datnom)<>dbo.today()) -- накладная за вчера
--    insert into #t (id,sklad,hitag,ncod,ngrp, [Parent], MainParent, WEIGHT,Origprice, 
--      flgWeight, Cost, Locked,Minp,Mpu, Rest,DCK,Kol,Kol_B,Country,DateR,SrokH,Sert_ID,Gtd,NvId, nmid, NvPrice)
--    select 
--      nv.tekid, nv.sklad, nv.hitag, v.ncod, nm.ngrp, gr.Parent, gr.MainParent, case when v.weight=0 then nm.netto else v.weight end as weight, 
--      v.price, nm.flgWeight,V.Cost, v.Locked, v.minp, v.mpu,
--      cast(v.MORN-v.SELL+v.ISPRAV-v.REMOV-v.REZERV-v.bad as integer) as Rest, @DCK,
--      nv.kol, nv.kol_b, V.Country, v.DateR,v.SrokH,v.Sert_ID,v.Gtd,nv.NvId,
--      iif(s.discard=1 or s.Discount=1, 0,null), nv.Price
--    from 
--      nv
--      inner join visual V on v.id=nv.tekid
--      inner join Nomen nm on nm.hitag=v.HITAG
--      inner join GR on GR.Ngrp=nm.ngrp
--      inner join skladlist s on s.SkladNo=nv.Sklad
--      INNER JOIN FirmsConfig FC ON FC.Our_id=V.Our_ID
--    where nv.datnom=@Datnom 
--      -- and (@OurID=0 or V.Our_ID=@OurID)                 -- ЗДЕСЬ НАДО ПОДУМАТЬ 
--      -- and (@FirmGroup=0 or FC.FirmGroup=@FirmGroup)     -- ЗДЕСЬ НАДО ПОДУМАТЬ 
--/****************************************************************/    
--  else if @SkladList is null
--    insert into #t (id,sklad,hitag,ncod,ngrp, [Parent], MainParent, WEIGHT,Origprice, flgWeight, Cost, Locked,Minp,Mpu, Rest,DCK, nmid)
--    select 
--      v.id, v.sklad, v.hitag, v.ncod, nm.ngrp, gr.Parent, gr.MainParent, case when v.weight=0 then nm.netto else v.weight end as weight,
--      v.price, nm.flgWeight,V.Cost, v.Locked, v.minp, v.mpu,
--      cast(v.Rest as integer) as Rest, @DCK,
--      iif(s.discard=1 or s.Discount=1, 0,null)
--    from 
--      #LocalTDVI V 
--      inner join Nomen nm on nm.hitag=v.HITAG
--      inner join GR on GR.Ngrp=nm.ngrp
--      inner join skladlist S on S.SkladNo=v.Sklad
--      INNER JOIN FirmsConfig FC ON FC.Our_id=V.Our_ID
--    where 
--      S.Locked=0
--      and V.Rest > 0
--      -- and (@OurID=0 or V.Our_ID=@OurID);
--      and (@FirmGroup=0 or FC.FirmGroup=@FirmGroup);
--/****************************************************************/      
--  else if @Action=0 and @VendDCK=0
--    insert into #t (id,sklad,hitag,ncod,ngrp, [Parent], MainParent, WEIGHT,Origprice, flgWeight, Cost, Locked,Minp,Mpu,Rest,DCK, nmid)
--    select 
--      v.id, v.sklad, v.hitag, v.ncod, nm.ngrp, gr.Parent, gr.MainParent, case when v.weight=0 then nm.netto else v.weight end as weight, 
--      v.price, nm.flgWeight,V.Cost, v.Locked, v.minp, v.mpu,
--      cast(v.Rest as integer) as Rest, @DCK,
--      iif(s.discard=1  or s.Discount=1, 0,null)
--    from 
--      #LocalTDVI V 
--	  inner join #Sk E on E.Sklad=v.SKLAD
--      inner join Nomen nm on nm.hitag=v.HITAG
--      inner join GR on GR.Ngrp=nm.ngrp
--      inner join skladlist S on S.SkladNo=v.Sklad
--      INNER JOIN FirmsConfig FC ON FC.Our_id=V.Our_ID
--      inner join Defcontract dc on dc.dck=v.dck 
--    where 
--     -- S.Locked=0 and
--      s.safecust=0
--      and v.Rest <> 0
--      -- and (@OurID=0 or V.Our_ID=@OurID)
--      and (@FirmGroup=0 or FC.FirmGroup=@FirmGroup)
--      and (dc.ContrTip = 1 or dc.dck=44283);
--/****************************************************************/      
--  else if @Action=0 and @VendDCK<>0
--    insert into #t (id,sklad,hitag,ncod,ngrp, [Parent], MainParent, WEIGHT,Origprice, flgWeight, Cost, Locked,Minp,Mpu,Rest,DCK, nmid)
--    select 
--      v.id, v.sklad, v.hitag, v.ncod, nm.ngrp, gr.Parent, gr.MainParent, case when v.weight=0 then nm.netto else v.weight end as weight, 
--      v.price, nm.flgWeight,V.Cost, v.Locked, v.minp, v.mpu,
--      cast(v.Rest as integer) as Rest, @DCK,
--      iif(s.discard=1  or s.Discount=1, 0,null)
--    from 
--      #LocalTDVI V 
--      inner join Nomen nm on nm.hitag=v.HITAG
--      inner join GR on GR.Ngrp=nm.ngrp
--      inner join skladlist S on S.SkladNo=v.Sklad
--      INNER JOIN FirmsConfig FC ON FC.Our_id=V.Our_ID
--    where 
--      --S.Locked=0 and
--      v.Rest > 0
--      -- and (@OurID=0 or V.Our_ID=@OurID)
--      and (@FirmGroup=0 or FC.FirmGroup=@FirmGroup)
--      and V.DCK=@VendDCK;      
--/****************************************************************/      
--  else if @Action=5
--    insert into #t (id,sklad,hitag,ncod,ngrp, [Parent], MainParent, WEIGHT,Origprice, flgWeight, Cost, Locked,Minp,Mpu,Rest,DCK, nmid)
--    select 
--      v.id, v.sklad, v.hitag, v.ncod, nm.ngrp, gr.Parent, gr.MainParent, case when v.weight=0 then nm.netto else v.weight end as weight,
--      v.price, nm.flgWeight,V.Cost, v.Locked, v.minp, v.mpu,
--      cast(v.Rest as integer) as Rest,
--      C.DCK,
--      iif(s.discard=1 or s.Discount=1, 0,null)
--    from 
--      #LocalTDVI V 
--	  inner join #Sk E on E.Sklad=v.SKLAD
--      inner join Nomen nm on nm.hitag=v.HITAG
--      inner join GR on GR.Ngrp=nm.ngrp
--      INNER JOIN FirmsConfig FC ON FC.Our_id=V.Our_ID
--      inner join skladlist S on S.SkladNo=v.Sklad
--      , #NeedDCK C
--    where 
--      S.Locked=0
--      and v.Rest > 0
--      -- and (@OurID=0 or V.Our_ID=@OurID)
--      and (@FirmGroup=0 or FC.FirmGroup=@FirmGroup);
--  create index t_temp_idx on #t(dck,id);
--  
--  
--   /*****************************Выбор приоритетных правил из всех полученных******************************/
--   
--  create table #DetFinalTemp (nmid int, dck int, hitag int,Rez decimal(15,5), RezTip tinyint, CodeTip tinyint, isWeightPrice bit, CodeTipWhat int, Prior tinyint)
--  
--  insert into #DetFinalTemp 
--  select w.nmid, h.dck, w.hitag,w.Rez, w.RezTip, h.CodeTip, w.isWeightPrice, w.CodeTip, j.prior
--  from #DetWhat w inner join #DetWho h on w.nmid=h.nmid
--                  inner join #J j on j.nmid=h.nmid
--
--  create table #DetFinal (nmid int, dck int, hitag int,Rez decimal(15,5), RezTip tinyint, CodeTip tinyint, isWeightPrice bit, CodeTipWhat int, Prior tinyint)
--
--  insert into #DetFinal
--  select d.nmid, d.dck, d.hitag,d.Rez, d.RezTip, d.CodeTip, d.isWeightPrice, d.CodeTipWhat, d.prior from #DetFinalTemp d inner join
--  (select dck,hitag,max(Prior) as MaxPrior from #DetFinalTemp group by dck,hitag) m on d.dck=m.dck and d.hitag=m.hitag and d.Prior=m.MaxPrior
--  
--  truncate table #DetFinalTemp
--
--  insert into #DetFinalTemp
--  select d.nmid, d.dck, d.hitag,d.Rez, d.RezTip, d.CodeTip, d.isWeightPrice, d.CodeTipWhat, d.prior from #DetFinal d inner join
--  (select dck,hitag,max(CodeTip) as MaxCodeTip from #DetFinal group by dck,hitag) m on d.dck=m.dck and d.hitag=m.hitag and d.CodeTip=m.MaxCodeTip
--  
--  truncate table #DetFinal
--  
--  insert into #DetFinal
--  select d.nmid, d.dck, d.hitag,d.Rez, d.RezTip, d.CodeTip, d.isWeightPrice, d.CodeTipWhat, d.prior from #DetFinalTemp d inner join
--  (select dck,hitag,max(CodeTipWhat) as MaxCodeTip from #DetFinalTemp group by dck,hitag) m on d.dck=m.dck and d.hitag=m.hitag and d.CodeTipWhat=m.MaxCodeTip
--  
--
--  create index IndDetFinal on #DetFinal(dck, hitag)
--
--  -- ******************************************************************************
--  -- **  ПРОСТАНОВКА ЗАПРЕТОВ                                                    **   
--  -- ******************************************************************************
--
--  update #t set #t.Disab=1, #t.nmid=w.nmid
--  from   
--    #t inner join #DetFinal w on #t.hitag=w.hitag and #t.dck=w.dck
--  where w.RezTip=@mtDisabled and #t.nmid is null
--  
--  -- то же для полного списка товаров, если есть:
--  /*set @N=(select min(w.nmid) as N
--    from 
--      netspec2_what W
--      inner join #J on #J.nmid=W.nmid
--    where W.RezTip=@mtDisabled and W.CodeTip=@ctAll);
--  if @n is not null update #t set #t.Disab=1, #t.nmid=@N where #t.nmid is null;*/
--
--
--  -- ******************************************************************************
--  -- **  ЗАПИСЬ ФИКСИРОВАННЫХ ЦЕН                                                **   
--  -- ******************************************************************************
--  -- на конкретные штучные товары:
--  update #t set #t.NewPrice=w.Rez, #t.nmid=w.nmid, #t.flgMinPrice=0
--  from   
--    #t inner join #DetFinal w on #t.hitag=w.hitag and #t.dck=w.dck
--  where 
--    w.RezTip=@mtFixedPrice 
--    and #t.flgWeight=0 and w.isWeightPrice=0 
--    and #t.nmid is null
--    
--  -- то же самое, только товары весовые, фиксированная цена продажи за 1 кг:
--  update #t 
--    set #t.NewPrice=w.Rez*#t.Weight, #t.nmid=w.nmid, #t.flgMinPrice=0
--  from   
--    #t inner join #DetFinal w on #t.hitag=w.hitag and #t.dck=w.dck
--  where 
--    w.RezTip=@mtFixedPrice --and #t.flgWeight=1
--    and w.isWeightPrice=1
--    and #t.nmid is null
--    
--  -- ОШИБКА то же самое, только товары весовые, а цена за указана штуку???????
--  update #t 
--    set #t.NewPrice=0, #t.nmid=-1, #t.flgMinPrice=0
--  from   
--    #t inner join #DetFinal w on #t.hitag=w.hitag and #t.dck=w.dck
--  where 
--    w.RezTip=@mtFixedPrice 
--    and w.isWeightPrice=0 and #t.flgWeight=1
--    and #t.nmid is null   
--
--  -- ******************************************************************************
--  -- **  ЗАПИСЬ ФИКСИРОВАННЫХ НАЦЕНОК в процентах К ЦЕНЕ ПРИХОДА                 **
--  -- ******************************************************************************
--  update #t 
--    set #t.NewPrice=(1.0+w.Rez/100.0)*#t.Cost, #t.nmid=w.nmid, #t.flgMinPrice=0
--  from   
--    #t inner join #DetFinal w on #t.hitag=w.hitag and #t.dck=w.dck
--  where 
--    w.RezTip=@mtFixAdCostPerc
--    and #t.nmid is null
--
--  -- ******************************************************************************
--  -- **  ЗАПИСЬ МИНИМАЛЬНЫХ НАЦЕНОК в процентах К ЦЕНЕ ПРОДАЖИ                   **   
--  -- ******************************************************************************
--  update #t 
--    set #t.NewPrice=(1.0+w.Rez/100.0)*#t.OrigPrice, #t.nmid=w.nmid, #t.flgMinPrice=1
--  from   
--    #t inner join #DetFinal w on #t.hitag=w.hitag and #t.dck=w.dck
--  where 
--    w.RezTip=@mtAdPricePerc
--    and #t.nmid is null
--
--
--  -- ******************************************************************************
--  -- **  ЗАПИСЬ МИНИМАЛЬНЫХ НАЦЕНОК в рублях К ЦЕНЕ ПРИХОДА                      **   
--  -- ******************************************************************************
--  -- на штучные товары:
--  update #t 
--    set #t.NewPrice=w.Rez+#t.Cost, #t.nmid=w.nmid, #t.flgMinPrice=1
--  from   
--    #t inner join #DetFinal w on #t.hitag=w.hitag and #t.dck=w.dck
--  where 
--    w.RezTip=@mtAdCostRub
--    and w.isWeightPrice=0 and #t.flgWeight=0  
--    and #t.nmid is null
--  -- то же на весовые товары:
--  update #t 
--    set #t.NewPrice=#t.Cost+#t.weight*w.Rez, #t.nmid=w.nmid, #t.flgMinPrice=1
--  from   
--    #t inner join #DetFinal w on #t.hitag=w.hitag and #t.dck=w.dck
--  where 
--    w.RezTip=@mtAdCostRub
--    and w.isWeightPrice=1 and #t.weight<>0 --and #t.flgWeight=1
--    and #t.nmid is null
--
--  -- ******************************************************************************
--  -- **  ЗАПИСЬ МИНИМАЛЬНЫХ НАЦЕНОК в рублях К ЦЕНЕ ПРОДАЖИ                      **   
--  -- ******************************************************************************
--  -- на штучные товары:
--  update #t 
--    set #t.NewPrice=w.Rez+#t.OrigPrice, #t.nmid=w.nmid, #t.flgMinPrice=1
--  from   
--    #t inner join #DetFinal w on #t.hitag=w.hitag and #t.dck=w.dck
--  where 
--    w.RezTip=@mtAdPriceRub
--    and #t.flgWeight=0 and w.isWeightPrice=0 
--    and #t.nmid is null
--  -- то же на весовые товары:
--  update #t 
--    set #t.NewPrice=#t.OrigPrice+w.Rez*#t.weight, #t.nmid=w.nmid, #t.flgMinPrice=1
--  from   
--    #t inner join #DetFinal w on #t.hitag=w.hitag and #t.dck=w.dck
--  where 
--    w.RezTip=@mtAdPriceRub
--    and w.isWeightPrice=1 --and #t.flgWeight=1 
--    and #t.nmid is null
--    
--  -- ******************************************************************************
--  -- **  ЗАПИСЬ МИНИМАЛЬНЫХ НАЦЕНОК в процентах К ЦЕНЕ ПРИХОДА                   **
--  -- ******************************************************************************
--
--  update #t 
--    set #t.NewPrice=(1.0+w.Rez/100.0)*#t.Cost, #t.nmid=w.nmid, #t.flgMinPrice=1
--  from   
--    #t inner join #DetFinal w on #t.hitag=w.hitag and #t.dck=w.dck
--  where 
--    w.RezTip=@mtAdCostPerc
--    and #t.nmid is null
--
--
--
--
--  -- ******************************************************************************
--  -- **  ПОДГОТОВКА РЕЗУЛЬТАТА                                                   **
--  -- ******************************************************************************
--  
--  -- Подготовка таблицы последних цен (за 4 месяца, кроме сегодня) для режима 0,1,4,6:
--  if isnull(@Action,0)=0 or @Action=1 or @Action=4 or @Action=6 begin
--    set @theB_id=(select pin from defcontract where dck=@DCK);
--    
--    create table #bpl(hitag int, LastPrice decimal(15,5));
--
--    if @Action=0 set @StartDay=@Today-120; else set @StartDay=@Today-60;
--    
--    insert into #bpl select hitag,price 
--    from BigPriceList 
--    where b_id=@theB_ID and Saved>=@StartDay and Saved<@today;
--    
--    create index bpl_tmp_idx on #bpl(hitag);    
--  end;
--
--  --выгрузка прайса для DCK, с последними ценами за два месяца
--  if isnull(@Action,0)=0 
----    select #t.*, nm.[name], nm.FName, case when s.OnlyMinP = 1 then cast(1 as bit) else nm.OnlyMinP end OnlyMinP, nm.Nds,s.UpWeight,nm.netto, #bpl.LastPrice
--	select #t.*, nm.[name], nm.FName, s.OnlyMinP, nm.Nds,s.UpWeight,nm.netto, #bpl.LastPrice
--    from #t 
--      inner join Nomen NM on nm.hitag=#t.Hitag
--      inner join SkladList S on S.SkladNo=#t.Sklad
--      left join #bpl on #bpl.hitag=#t.Hitag
--    order by nm.[name], #t.sklad, s.onlyminp;
--    
--  --выгрузка накладной по datnom
--  else if isnull(@Action,0)=1
----  select #t.*, nm.[name], nm.FName, case when s.OnlyMinP = 1 then cast(1 as bit) else nm.OnlyMinP end OnlyMinP, nm.Nds,s.UpWeight,nm.netto,#bpl.LastPrice
--  select #t.*, nm.[name], nm.FName, s.OnlyMinP, nm.Nds,s.UpWeight,nm.netto,#bpl.LastPrice
--  from #t 
--    inner join Nomen NM on nm.hitag=#t.Hitag
--    inner join SkladList S on S.SkladNo=#t.Sklad
--    left join #bpl on #bpl.hitag=#t.Hitag
--  order by  #t.sklad, nm.[name], s.onlyminp;
--  
-- --исправление накладной Datnom
--  else if @Action=2 and @Datnom>0 begin
--    update nv set Price=(select top 1 NewPrice from #t where #t.id=nv.tekid)
--      where nv.DatNom=@datnom and  nv.tekid not in (select id from #t where NewPrice is not null);
--    update NC set sp=(1.0+NC.extra/100.0)*(select sum(nv.kol*nv.price) from nv where nv.DatNom=nc.datnom) where datnom=@datnom;
--  end;
--  
-- --исправление заказа
--  else if @Action = 3 begin
--    declare @B_ID int 
--    
--    select @Ag_id=ag_id, @B_ID=pin from #LocalDefContract where dck=@dck
--  
--    delete from Zakaz where DCK=@DCK and tekid in (select id from #t where Disab=1);
--    
--    insert into MobAgents.Mess (ag_id, pin, dck, Remark, MessType, data0)
--    select distinct @Ag_id, @B_ID, @DCK, cast(t.hitag as varchar(5)) +' '+ n.name, 1, o.nmid
--    from #LocalTDVI t join nomen n on t.hitag=n.hitag 
--                      join #t o on t.id=o.id 
--    where o.Disab=1;                     
--    
--    update Zakaz set Price=(select top 1 NewPrice from #t where #t.id=zakaz.tekid)
--      where Zakaz.dck=@DCK  and  Zakaz.tekid in (select id from #t where NewPrice is not null and flgMinPrice=0);
--    update Zakaz set Price=(select top 1 NewPrice from #t where #t.id=zakaz.tekid)
--    where Zakaz.dck=@DCK  and  Zakaz.tekid in (select id from #t join Zakaz on  Zakaz.tekid=#t.id where Zakaz.dck=@dck and Zakaz.Price<isnull(#t.NewPrice,0) );
--  end;
--  
--  --выгрузка прайса для DCK по товару IDList
--  else if (@Action = 4) or (@Action = 6)
----    select #t.*, nm.[name], nm.FName, case when s.OnlyMinP = 1 then cast(1 as bit) else nm.OnlyMinP end OnlyMinP, nm.Nds, i.Cost as SourceCost, 
--      select #t.*, nm.[name], nm.FName, s.OnlyMinP, nm.Nds, i.Cost as SourceCost, 
--      nm.Netto, def.brName as fam, V.DatePost, s.UpWeight, #bpl.LastPrice
--    FROM 
--      #t
--      inner join Nomen NM on nm.hitag=#t.Hitag
--      inner join #LocalTDVI v on v.id=#t.id
--      left join Inpdet i on i.id=v.StartID
--      inner join SkladList S on S.SkladNo=#t.Sklad
--      inner join Def on Def.Ncod=#t.Ncod
--      left join #bpl on #bpl.hitag=#t.Hitag
--    order by #t.hitag, #t.id;
--  --выгрузка прайса для КПК
--  else if @Action = 5 begin
--    select dck as pin, 
--           Hitag,
--           round(SumPrice/Rest,2) as Price
--    from (
--      select #t.dck,
--             #t.Hitag, 
--        sum(#t.Rest*iif(#t.NewPrice is NULL, #t.OrigPrice, #t.NewPrice)) as SumPrice,
--        sum(#t.Rest) as Rest
--      from #t 
--      group by #t.dck, #t.Hitag
--      ) E
--    order by pin, Hitag
--  end;
--  
--  end try
--  begin catch
--    --    SELECT ERROR_NUMBER() AS ErrorNumber, ERROR_MESSAGE() AS ErrorMessage
--    insert into ProcErrors(errnum, errmess, procname, errline) select ERROR_NUMBER(), ERROR_MESSAGE(), object_name(@@procid), ERROR_LINE()
--  end catch 

end