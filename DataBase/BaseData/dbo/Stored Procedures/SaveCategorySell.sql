CREATE procedure SaveCategorySell @datnom0 int
as 
BEGIN
    -- Настройка категорий:
    -- update gr set Category=1; -- прочее
    -- update gr set Category=2 where Parent=3 or ngrp=3 or mainparent=3; -- мороженое
    -- update gr set Category=3 where Parent=83 or ngrp=83 or mainparent=83; -- полуфабрикаты
    

    -- Теперь еще один интересный поворот сюжета. Для некоторых товаров в расчетах
    -- зарплаты должна использоваться не обычная цена прихода, а специальная,
    -- которая хранится в табл. SpecPrice. Расчет суммы поправок:
    update NC set DeltaSpecSC=0 where DeltaSpecSC<>0;

    -- Таблица поправок (временная):
    create table #a(datnom int, DeltaSpecSC decimal(9,2));
    insert into #a
    select 
      nv.datnom, sum(nv.kol*(s.specCost-nv.Cost)) as DeltaSpecSC
    from nv 
      inner join Visual v on v.id=nv.tekid
      inner join specprice s on s.startid=v.startid
    group by nv.datnom;

    -- Перезапись:
    update NC set DeltaSpecSC=(select DeltaSpecSC from #a where #a.datnom=NC.Datnom)
    where Nc.datnom in (select Datnom from #a);
    -- Этот кусок кода выполняется довольно быстро, секунды за три.


  CREATE TABLE #SCS ( [datnom] int NOT NULL,
    sp1 money, sc1 money,
    sp2 money, sc2 money,
    sp3 money, sc3 money,
    PRIMARY KEY CLUSTERED ([datnom]) );
    
  insert into #SCS(datnom,sp1,sc1,sp2,sc2,sp3,sc3)
	select 
	  NV.datnom,
	  sum(case when gr.Category=1 then nv.Kol*nv.Price*(1.0+nc.Extra/100.0) else 0 end) as sp1,
	  sum(case when gr.Category=1 then nv.Kol*nv.cost else 0 end) as sc1,
	  sum(case when gr.Category=2 then nv.Kol*nv.Price*(1.0+nc.Extra/100.0) else 0 end) as sp2,
	  sum(case when gr.Category=2 then nv.Kol*nv.cost else 0 end) as sc2,
	  sum(case when gr.Category=3 then nv.Kol*nv.Price*(1.0+nc.Extra/100.0) else 0 end) as sp3,
	  sum(case when gr.Category=3 then nv.Kol*nv.cost else 0 end) as sc3
	from 
	  NV inner join NC on NC.datnom=NV.datnom
	  inner join Nomen nm on nm.hitag=nv.hitag
	  inner join GR on GR.Ngrp=nm.ngrp  
	where nv.datnom>=@datnom0
	group by nv.datnom
	order by nv.datnom;
    
	update nc set SpOther=(select t.sp1 from #SCS t where t.datnom=nc.DatNom) where nc.datnom>=@datnom0;
	update nc set ScOther=(select t.sc1 from #SCS t where t.datnom=nc.DatNom) where nc.datnom>=@datnom0;
	update nc set SpIce=(select t.sp2 from #SCS t where t.datnom=nc.DatNom) where nc.datnom>=@datnom0;
	update nc set ScIce=(select t.sc2 from #SCS t where t.datnom=nc.DatNom) where nc.datnom>=@datnom0;
	update nc set SpPf=(select t.sp3 from #SCS t where t.datnom=nc.DatNom) where nc.datnom>=@datnom0;
	update nc set ScPf=(select t.sc3 from #SCS t where t.datnom=nc.DatNom) where nc.datnom>=@datnom0;
    
    update Config set val=convert(char(10), getdate(),104) where param='ZarplLastDay';
    


    
end;