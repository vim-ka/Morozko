CREATE procedure dbo.SkladExamFindBadPrices @maxPercErr smallint=10
as -- Поиск цен, отличающихся от исходных более чем на порог:
begin

  -- Текущие остатки на складе, к которым привязаны исходные (на момент поставки) веса и цены:
  create table #t (ncod int, ncom int, startid int, id int, ngrp int, hitag int, name varchar(100), sklad smallint, 
    cost decimal(15,5), price decimal(12,2), Rest int, flgWeight bit,
    TekWeight decimal(10,3), InpWeight decimal(10,3),
    InpCost decimal(15,5), InpPrice decimal(12,2),
    Cost1kg decimal(15,5), InpCost1kg decimal(15,5),
    Price1kg decimal(15,5), InpPrice1kg decimal(15,5));

  -- Заполнение этой таблицы фактическими данными:
  insert into #t
  select *, 
     round(cost/TekWeight,5) as Cost1kg,
     iif(InpWeight>0, round(Inpcost/InpWeight,5),null) as InpCost1kg,
     round(Price/TekWeight,5) as Price1kg,
     iif(InpWeight>0, round(InpPrice/InpWeight,5),null) as InpPrice1kg
  from
  (
    SELECT 
      v.ncod, v.ncom, v.startid, v.id, 
      nm.ngrp, v.hitag, nm.name, v.sklad, 
      v.cost, v.price, 
      sum(v.morn-v.sell+v.ISPRAV-v.REMOV) as Rest,
      nm.flgWeight,
      iif(v.weight>0, v.weight, nm.netto) as TekWeight,
      -- iif(i.weight>0, i.weight, nm.netto) as InpWeight,
      i.weight as InpWeight,
      i.Cost as InpCost, i.Price as InpPrice
    from
      tdvi v
      left join inpdet i on i.id=v.STARTID
      inner join nomen nm on nm.hitag=v.HITAG
    where nm.ngrp not in (0,10,19,21,84,86)
    group by 
      v.ncod, v.ncom, v.startid, v.id, nm.ngrp, v.hitag, nm.name, v.sklad, 
      v.cost, v.price, nm.flgWeight,  iif(v.weight>0, v.weight, nm.netto),
      i.weight, i.Cost, i.Price
  )E
  order by name

-- Для программы SkladExemPeriod разобьем эту таблицу на две части.

-- Та, где полностью или частично отсутствует информация о поставке:


/*
select cast(0 as bit) as flgFullInfo, * from #t 
where #t.hitag in (select distinct hitag from #t where inpcost is null)  
-- и та, где вся нужная информация есть:
   UNION

select cast(1 as bit) as flgFullInfo, * from #t 
where #t.hitag not in (select distinct hitag from #t where inpcost is null)  
and (InpPrice1kg=0 or abs(100.0*(InpPrice1kg-Price1kg)/InpPrice1kg)>=@maxPercErr)
  -- and hitag=24677
ORDER BY flgFullInfo, #t.name, #t.ncod, #t.id
*/
-- Нет, алгоритм изменен, теперь вытаскиваем все вместе, не интересуясь флагом flgFullInfo:
select cast(0 as bit) as flgFullInfo, * from #t 
ORDER BY #t.name, #t.ncod, #t.id

end;