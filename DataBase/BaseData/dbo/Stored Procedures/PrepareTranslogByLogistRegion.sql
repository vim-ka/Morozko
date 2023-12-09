CREATE procedure PrepareTranslogByLogistRegion @day0 datetime, @day1 datetime
as
begin
  -- извлекаю важную информацию из накладных:
  create table #nc (nd datetime, datnom int, sp decimal(10,2), sc decimal(10,2), 
    VMaster int,  weight decimal(10,3),  Marsh int, NDM varchar(30), ag_id int, DepID varchar(3) );
  
  -- получается такая сильно усеченная по ширине таблица накладных:
  insert into #nc(nd,DatNom,sp,sc,VMaster,WEIGHT,marsh, NDM, ag_id, DepID)
  select nc.nd, nc.datnom, nc.sp, nc.sc,
    case when Def.vmaster=0 then def.pin else def.vmaster end as VMaster,
    nc.weight, nc.marsh, 
    convert(varchar,nc.nd)+'-'+cast(nc.marsh as varchar(3)) as NDM,
    nc.ag_id, 
    def.reg_id as Depid
  from 
    nc inner join Def on Def.pin=nc.b_id
    inner join AgentList A on A.AG_ID=nc.Ag_Id
    inner join AgentList S on S.AG_ID=A.SV_AG_ID
  where nc.nd between @day0 and @day1
    and nc.frizer=0 and nc.actn=0 and nc.tara=0
    and nc.marsh>0 and nc.marsh<>99
    and nc.weight<>0;
    
  create index nc_ndm_idx on #nc(NDM);    
    
  -- Теперь свернем ее по номерам маршрутов - это понадобится, чтобы рассчитать 
  -- полный вес каждого маршрута и соответственно долю каждой накладной:
  create table #s (nd datetime, marsh int, NDM varchar(30), Weight decimal(12,3), 
    SP decimal(10,2), SC decimal(10,2), Rashod decimal(10,2), KolNakl int, DopWeight decimal(12,3) );
    
  -- По-новой рассчитываю суммарный вес кажого маршрута за период:
  insert into #s (nd,marsh, NDM, weight,sp,sc,rashod, KolNakl, DopWeight)  
  select 
    #nc.nd, #nc.marsh, 
    convert(varchar,#nc.nd)+'-'+cast(#nc.marsh as varchar(3)) as NDM,
    sum(#nc.weight) as Weight, sum(#nc.sp) as SP, sum(#nc.sc) as SC, 
    isnull(case when M.NdMarsh<='20120212' then M.OplataSum else M.OplataSum+M.PercWorkPay end,0) as Rashod,
    count(#nc.DatNom),
    (select r.DopWeight from Marsh r where r.ND=#nc.nd and r.Marsh=#NC.Marsh) as DopWeight
  from #nc left join MarshOplDet M on M.ndMarsh=#nc.nd and M.Marsh=#nc.Marsh
  group by 
    #nc.nd, #nc.marsh, isnull(case when M.NdMarsh<='20120212' then M.OplataSum else M.OplataSum+M.PercWorkPay end,0)
  order by #nc.nd, #nc.marsh;

  select
    E.DepID, 
    Regions.Place,
    sum(E.Weight) as Weight,
    sum(E.DopWeight) as DopWeight,
    sum(E.Weight)+sum(E.DopWeight) as AllWeight,
    round(sum(E.Koeff),1) as KolMarsh,
    round(sum(E.Rashod),2) Rashod,
    round((sum(E.Weight)+sum(E.DopWeight))/sum(E.Koeff),1) as AvgZagruz,
    sum(E.Dots) as Dots,
    round(SUM(E.Rashod)/(sum(E.Weight)+sum(E.DopWeight)),3) as Rashod1kg,
    round((sum(E.SP)-sum(E.SC))/(sum(E.Weight)+sum(E.DopWeight)),3) as Dohod1kg,
    round(sum(e.Rashod)/sum(E.Sp),3) as Rashod1rub,
    round(sum(E.Rashod)/Sum(E.Dots),2) as Rashod1Dot,
    round(sum(E.SP),2) as SP,
    round(sum(E.SC),2) as SC
  from (select 
        #nc.DepID, 
        sum(#nc.weight) Weight, sum(#nc.weight)/(#s.weight+#s.DopWeight) as PartWeight,
        sum(#s.Dopweight) DopWeight,
        sum(#nc.sp) SP, #S.sp as TotalSP,
        sum(#nc.sc) SC, #S.sc as TotalSC,
        round(SUM(#nc.[Weight] / (#s.Weight+#s.DopWeight) * #s.Rashod),2) as Rashod,
        count(#nc.datnom) as NcNaklCount, #S.KolNakl as TotalNakl,
        round(1.0*count(#nc.datnom)/#S.KolNakl,3) as Koeff,    
        count(distinct #nc.VMaster) as Dots,
        count(distinct #s.NDM) as MarshCount
      from 
        #nc inner join #s on #s.ndm=#nc.ndm
      group by #nc.depid, #S.Sp, #S.SC, #S.KolNakl, #s.Weight,  #s.DopWeight
      ) E
  inner join Regions on Regions.Reg_id = E.DepId
  group by E.DepId, Regions.Place
  order by E.DepId;

end;