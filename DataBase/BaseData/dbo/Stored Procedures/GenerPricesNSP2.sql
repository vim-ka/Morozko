CREATE procedure GenerPricesNSP2 @DCK INT
as
declare @theNMID int
declare @theOblID int, @theRNID int, @theDepID int
declare @theSvID int, @theAgID int, @theB_ID int
begin

  --ГОТОВЛЮ ЛОКАЛЬНУЮ КОПИЮ СКЛАДА
  create table #t (id int, hitag int, Ncod int, ngrp int, [Parent] int, MainParent int, weight decimal(10,3),
    OrigPrice decimal(12,2), NewPrice decimal(10,2), Nacen decimal(6,2), nmid int, Disab bit default 0);

  insert into #t (id,hitag,ncod,ngrp, [Parent], MainParent, WEIGHT,Origprice)
  select 
    v.id, v.hitag, v.ncod, nm.ngrp, gr.Parent, gr.MainParent, v.weight, v.price
  from 
    TDVI V inner join Nomen nm on nm.hitag=v.HITAG
    inner join GR on GR.Ngrp=nm.ngrp
  where v.MORN-v.SELL+v.ISPRAV-v.REMOV-v.REZERV > 0
  
  create index t_temp_idx on #t(id);

  -- Кто наш покупатель, какого роду-племени?

  select 
    @theAgID=DC.ag_id, @theB_ID=DC.Pin, @theDepID=SV.DepID,
    @theRnID=D.Rn_ID,
    @theOblID=D.Obl_ID
  from 
    DefContract DC 
    inner join Agentlist A on A.AG_ID=DC.ag_id
    inner join AgentList SV on SV.AG_ID=A.sv_ag_id
    inner join Def D on D.pin=dc.pin
  where 
    dc.DCK=@DCK and Dc.ContrTip=2

  -- ИЗ СПИСКА ЗАДАЧ ПО НАЦЕНКЕ ОТБИРАЮ ОТНОСЯЩИЕСЯ К ЗАДАННОМУ ПОКУПАТЕЛЮ:
  declare CurMain cursor fast_forward  
  for 
    select distinct w.nmid
    from 
      NetSpec2_Who w 
      inner join netspec2_main m on m.nmid=w.nmid
    where
      ( (w.CodeTip=1 and w.Code=@theOblID)
        or (w.CodeTip=2 and w.Code=@theRnID)
        or (w.CodeTip=3 and w.Code=@theDepID)
        or (w.CodeTip=4 and w.Code=@theSvID)
        or (w.CodeTip=5 and w.Code=@theAgID)
        or (w.CodeTip=6 and w.Code=@theB_ID)
      )
      and m.Activ=1 and GetDate() between m.StartDate and m.FinishDate;
 
  open CurMain; 
  fetch next from CurMain into @theNMID;
  WHILE (@@FETCH_STATUS=0)  BEGIN
    -- Теперь у нас есть номер задачи по наценке, которая точно относится к покупателю.

    -- Перво-наперво запрет продаж. Запрет для товаров с известным кодом:
    update #t 
    set #t.Disab=1 where nmid is null 
      and #t.hitag in (select Code from netspec2_what T 
      where t.nmid=@theNMID and T.RezTip=2 and T.CodeTip=2);
    -- Исключаю обработанные строки из дальнейшего рассмотрения:
    update #t set NmID=@TheNMID where NmID is null and #t.disab=1;

    -- Запрет продаж товаров известной группы:
    update #t 
      set #t.Disab=1 
      where nmid is null 
      and ((#t.Ngrp in (select Code from netspec2_what T where t.nmid=@theNMID and T.RezTip=2 and T.CodeTip=1))
             or (#t.Parent in (select Code from netspec2_what T where t.nmid=@theNMID and T.RezTip=2 and T.CodeTip=1))
             or (#t.MainParent in (select Code from netspec2_what T where t.nmid=@theNMID and T.RezTip=2 and T.CodeTip=1))
          );
    -- Исключаю обработанные строки из дальнейшего рассмотрения:
    update #t set NmID=@TheNMID where NmID is null and #t.disab=1;
          
    -- Запрет продаж товаров известного поставщика:
    update #t 
      set #t.Disab=1 
      where nmid is null 
      and #t.Ncod in (select Code from netspec2_what T where t.nmid=@theNMID and T.RezTip=2 and T.CodeTip=0);
    -- Исключаю обработанные строки из дальнейшего рассмотрения:
    update #t set NmID=@TheNMID where NmID is null and #t.disab=1;      

    -- Далее подправим цены по штучным товарам с известным кодом:
    update #t 
    set NewPrice=(select Rez from netspec2_what T 
      where t.nmid=@theNMID and T.RezTip=1 and T.Code=#t.hitag and T.CodeTip=2 and T.isWeightPrice=0)
    where nmid is null;
    -- Исключаю обработанные строки из дальнейшего рассмотрения:
    update #t set NmID=@TheNMID where NmID is null and NewPrice is not null;

    -- Далее подправим цены по весовым товарам с известным кодом:
    update #t 
    set NewPrice=[WEIGHT]*(select Rez from netspec2_what T 
      where t.nmid=@theNMID and T.RezTip=1 and T.Code=#t.hitag and T.CodeTip=2 and T.isWeightPrice=1)
    where nmid is null and [WEIGHT]>0;
    -- Исключаю обработанные строки из дальнейшего рассмотрения:
    update #t set NmID=@TheNMID where NmID is null and NewPrice is not null;

    -- А если задана наценка, то неважно, весовой товар или штучный:
    update #t 
    set Nacen=(select Rez from netspec2_what T 
      where T.nmid=@theNMID and T.RezTip=0 and T.Code=#t.hitag and T.CodeTip=2 )
    where nmid is null;
    -- Исключаю обработанные строки из дальнейшего рассмотрения:
    update #t set NmID=@TheNMID, NewPrice=OrigPrice*(1.0+Nacen/100.0) where NmID is null and Nacen is not null;

    -- Теперь устанавливаю НАЦЕНКУ для товаров с известной группой:

      update #t 
      set Nacen=(select max(Rez) from netspec2_what T 
        where t.nmid=@theNMID and T.RezTip=0 and (T.Code=#t.ngrp or T.Code=#t.MainParent or T.Code=#t.Parent) 
        and T.CodeTip=1)
        where nmid is null;
      -- Исключаю обработанные строки из дальнейшего рассмотрения:
      update #t set NmID=@TheNMID, NewPrice=OrigPrice*(1.0+Nacen/100.0) where NmID is null and Nacen is not null;


 
    
    fetch next from CurMain into @theNMID;
  end;
  close  CurMain;
  deallocate CurMain;
 
select #t.*, nm.[name] from #t inner join Nomen NM on nm.hitag=#t.Hitag
where Nmid is not null

end