CREATE procedure PrepareTranslog @day0 datetime, @day1 datetime
as
begin
  -- извлекаю важную информацию из накладных:
  create table #nc (nd datetime, datnom int, sp decimal(10,2), sc decimal(10,2), 
    VMaster int,  weight decimal(10,3),  Marsh int, NDM varchar(30), ag_id int, DepID int );
  
  -- получается такая сильно усеченная по ширине таблица накладных:
  insert into #nc(nd,DatNom,sp,sc,VMaster,WEIGHT,marsh, NDM, ag_id, DepID)
  select nc.nd, nc.datnom, nc.sp, nc.sc,
    case when Def.vmaster=0 then def.pin else def.vmaster end as VMaster,
    nc.weight, nc.marsh, 
    convert(varchar,nc.nd)+'-'+cast(nc.marsh as varchar(3)) as NDM,
    nc.ag_id, S.DepID
  from 
    nc inner join Def on Def.pin=nc.b_id 
    inner join Agentlist A on A.AG_ID=nc.Ag_Id
    inner join AgentList S on S.AG_ID=A.SV_AG_ID
  where nc.nd between @day0 and @day1
        and nc.frizer=0 and nc.tara=0
        and (nc.marsh>0 or (nc.sp<0 and nc.remark<>'')) and nc.marsh<>99 and nc.stip<>4 and nc.marsh<200
        and nc.weight<>0;
    
  create index nc_ndm_idx on #nc(NDM);    
    
/*    
  create table #T (nd datetime, Marsh int, KolNakl int);
  insert into #T (nd, Marsh, KolNakl) select Nd,marsh,count(*) as KolNakl from #nc group by nd,marsh ;
  SELECT TOP 100 * FROM #t ORDER BY ND,MARSH;
*/
  
  -- Теперь свернем ее по номерам маршрутов - это понадобится, чтобы рассчитать 
  -- полный вес каждого маршрута и соответственно долю каждой накладной:
  create table #s (nd datetime, marsh int, NDM varchar(30), Weight decimal(12,3), 
    SP decimal(10,2), SC decimal(10,2), Rashod decimal(10,2), KolNakl int );
    
  -- По-новой рассчитываю суммарный вес кажого маршрута за период:
  insert into #s(nd,marsh, NDM, weight,sp,sc,rashod, KolNakl)  
  select 
    #nc.nd, #nc.marsh, 
    convert(varchar,#nc.nd)+'-'+cast(#nc.marsh as varchar(3)) as NDM,
    sum(#nc.weight) as Weight, sum(#nc.sp) as SP, sum(#nc.sc) as SC, 
    isnull(case when M.NdMarsh<='20120212' then M.OplataSum else M.OplataSum+M.PercWorkPay end,0) as Rashod,
    count(#nc.DatNom)
  from #nc left join MarshOplDet M on M.ndMarsh=#nc.nd and M.Marsh=#nc.Marsh
  group by 
    #nc.nd, #nc.marsh, isnull(case when M.NdMarsh<='20120212' then M.OplataSum else M.OplataSum+M.PercWorkPay end,0)
  order by #nc.nd, #nc.marsh;

  -- Теперь выдергиваю отдельные накладные (интересует главным образом отдел!) 
  -- и для каждой считаю ее весовую долю общем весе маршрута, и пропорционально
  -- раскидываю на нее соотв. часть расходов по маршруту:

  select
    E.DepID, Deps.DName,
    sum(E.Weight) as Weight,
    round(sum(E.Koeff),1) as KolMarsh,
    round(sum(E.Rashod),2) Rashod,
    round(sum(E.Weight)/sum(E.Koeff),1) as AvgZagruz,
    sum(E.Dots) as Dots,
    round(SUM(E.Rashod)/sum(E.Weight),3) as Rashod1kg,
    round((sum(E.SP)-sum(E.SC))/sum(E.Weight),3) as Dohod1kg,
    round(sum(e.Rashod)/sum(E.Sp),3) as Rashod1rub,
    round(sum(E.Rashod)/sum(E.Dots),2) as Rashod1Dot,
    round(sum(E.SP),2) as SP,
    round(sum(E.SC),2) as SC,
    case when E.Depid in (6,26) then E.DepID else 1 end as Grp
  from ( select 
        #nc.DepID, 
        sum(#nc.weight) Weight, sum(#nc.weight)/#s.weight as PartWeight,
        sum(#nc.sp) SP, #S.sp as TotalSP,
        sum(#nc.sc) SC, #S.sc as TotalSC,
        round(SUM(#nc.[Weight] / #s.Weight * #s.Rashod),2) as Rashod,
        count(#nc.datnom) as NcNaklCount, #S.KolNakl as TotalNakl,
        round(1.0*count(#nc.datnom)/#S.KolNakl,3) as Koeff,    
        count(distinct #nc.VMaster) as Dots,
        count(distinct #s.NDM) as MarshCount
      from 
        #nc inner join #s on #s.ndm=#nc.ndm
      group by #nc.depid, #S.Sp, #S.SC, #S.KolNakl, #s.Weight
      ) E
  inner join Deps on Deps.depid=E.DepId
  group by E.DepId, Deps.DName, case when E.Depid in (6,26) then E.DepID else 1 end
  order by case when E.Depid in (6,26) then E.DepID else 1 end,  E.DepId;

end;