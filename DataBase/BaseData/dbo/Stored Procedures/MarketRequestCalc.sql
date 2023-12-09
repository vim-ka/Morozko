CREATE procedure dbo.MarketRequestCalc @ND datetime, @MRID int=51, @flgDebug bit=0, @flgByDot bit=0, @B_ID int=0 -- номер акции
  -- Входные данные держатся в таблице table MarketRequestParams(ag_id int, b_id int)
as
declare @day0 datetime,@day1 datetime,@tek datetime, @datnom0 int, @datnom1 int

begin

  set @datnom0=dbo.fnDatNom(@ND,1); -- интересуют продажи за один день, заданный.
  set @datnom1=dbo.fnDatNom(@ND,9999);

  -- На сколько дней запланирована акция? И сколько среди них рабочих, т.е. кроме воскресений?
  --  select @day0=R.datefrom, @day1=R.dateto from MarketRequest R where id=@MRID
  declare @WorkDays int
  set @WorkDays=0;
  set @tek=@Day0
  while @tek<=@Day1 begin
    if datepart(WEEKDAY,@tek)<7 set @WorkDays=@WorkDays+1
    set @tek=@tek+1
  end;
  if @WorkDays=0 set @WorkDays=1; -- это чтобы на 0 не делить, если что.
  if @flgDebug=1 print('@day0='+cast(@day0 as varchar)+',  @day0='+cast(@day1 as varchar)+',  рабочих дней в акции: '+cast(@WorkDays as varchar))

 
 -- План продаж за день по точкам и товарам, штуках, килограммах и рублях:
 if object_id('tempdb..#mrt') is not null drop table #mrt
  create table #mrt(ag_id int, b_id int, SlotID int, hitag int, pl_kol decimal(10,3), pl_weight numeric(10, 3),
    pl_rub numeric(15, 5), f_kol int default 0, f_weight numeric(10, 3) default 0, f_rub numeric(12, 2) default 0, Done int default 0);

  insert into #mrt(ag_id,b_id,SlotID,hitag,pl_kol,pl_weight,pl_rub)
    select distinct
      mrp.ag_id, mrp.b_id, T.slotid,  T.hitag, T.minvkol, T.minvKG, T.minvRub
    from
      MarketRequestParams mrp, 
      MarketRequestTovs T
    where T.mrid = @MRID and T.inactn=1
  
  create index mrtidx on #mrt(ag_id, b_id, hitag)
  
  if @flgDebug=1 select 'Исходно #MRT' as remark, * from #mrt
  
  update #mrt 
  set 
    f_kol = E.kol, f_weight = E.wgt, f_rub = E.rub
  from 
    #mrt 
    inner join (select nc.Ag_Id, NC.B_ID, nv.hitag, sum(nv.kol) kol, 
      sum(nv.kol * nv.price * (1 + nc.extra / 100)) rub, 
      sum(NV.kol * iif(v.weight = 0, n.Netto, v.weight)
      ) wgt
  from
    nc
    inner join nv on nv.datnom = nc.datnom
    inner join visual v on v.id = nv.tekid
    inner join nomen n on n.hitag = nv.hitag
  where 
    nc.datnom >= @Datnom0 and nc.datnom <= @Datnom1 and nc.actn=0
  group by 
    nc.Ag_Id, NC.B_ID, nv.hitag) E on E.ag_id = #mrt.ag_id and E.b_id = #mrt.b_id and E.hitag = #mrt.hitag;
  
  -- Какие общие задания есть по объему продаж в рублях, кг и штуках для каждого слота? И сколько записей для каждого слота?
  create table #z(SlotID int, PlanRub decimal(10,2), PlanWeight decimal(10,3), PlanQty int);
  insert into #z(slotid,Planrub,PlanWeight,PlanQty)  
    select s.id, s.allvRub, isnull(s.allvkg,0), s.allvkol from MarketRequestSlot S where s.mrid=@MRID;

--  select 'Суммы' as Remark, * from #z;
--  update #mrt set pl_rub=
--  from MarketRequestTovs T
   
  create table #g(ag_id int, slotid int, RazKol int, razWeigth int, razRub int);
  insert into #g(ag_id, slotid) select distinct ag_id,slotid from #mrt;

  -- Определим, выполнен план или нет по каждой строке:
  update #mrt set Done=dbo.PlanProgress(pl_kol, f_kol, pl_weight, f_weight, pl_rub, f_rub)

  if @flgDebug=1 select '#mrt' as Remark, #mrt.*, nm.name, nm.minp,nm.mpu from #mrt inner join nomen nm on nm.hitag=#mrt.hitag order by f_rub desc, ag_id, b_id, hitag asc 

  if @flgDebug=1 select slotid, sum(pl_rub) as Pl_rub, sum(f_rub) as F_RUB, sum(pl_kol) pl_kol, sum(f_kol) f_kol 
  from #mrt group by slotid;

  -- А вот уже почти готовый ответ:
  create table #ot (ag_id int, B_ID int, SlotID int, pl_Rub decimal(10,2), F_Rub decimal(10,2), pl_kol int, f_kol int, pl_kg decimal(10, 2), f_kg decimal(10, 2),
    Done int);

  insert into #ot(ag_id, b_id, SlotID, pl_rub,f_rub, pl_kol, f_kol, pl_kg, f_kg, Done) 
    select ag_id,-1, slotid,sum(pl_rub) as Pl_rub, sum(f_rub) as F_RUB, sum(pl_kol) pl_kol, sum(f_kol) f_kol, sum(pl_weight) pl_kg, sum(f_weight) f_kg,
    min(done)
    from #mrt group by ag_id,slotid;

  if @flgDebug=1 select 'Промежуточный' as Remark,* from #ot;


  create table #P(ag_id int, b_id int, SlotID int, F_Rub decimal(10,2), F_Kol int, F_KG decimal(10,3), CommonDone int);
  insert into #p
    select #MRT.ag_id, #MRT.b_id, #MRT.slotid,sum(#MRT.f_rub) as F_RUB, sum(#MRT.f_kol) f_kol, sum(#MRT.f_weight) F_KG,
      dbo.PlanProgress(#z.PlanRub, sum(#MRT.f_rub), #z.PlanWeight, sum(#MRT.f_weight), #z.PlanQty, sum(#MRT.f_kol))  as CommonDone
    from 
      #MRT 
      inner join #z on #z.SlotID=#mrt.slotid
    group by #MRT.ag_id, #MRT.b_id, #MRT.slotid, #z.PlanRub, #z.PlanWeight, #z.PlanQty;

  -- create table Guard.DevActnExec(Comp varchar(30), ag_id int, b_id int, SlotID int, F_Rub decimal(10,2), F_Kol int, F_KG decimal(10,3), CommonDone int);
  delete from Guard.DevActnExec where Comp=HOST_NAME();
  insert into Guard.DevActnExec select Host_Name() as  Comp, * from #p;

  
  if @flgDebug=1   select 'По агентам' as Remark,  ag_id, sum(Commondone) CommonDone from #p group by ag_id;
  
  if @flgDebug=1   select 'Общий план' as Remark, * from #z;
 

  if @flgByDot=1 and @B_ID=0
    select 'По точкам' as Remark,  * from #p where Commondone>0;
  else if @B_ID>0
    select #mrt.*, nm.name from #mrt inner join nomen nm on nm.hitag=#mrt.hitag where #mrt.b_id=@b_id and #mrt.done<>777
  else 
    select #ot.ag_id, max(#ot.Done) done, E.CommonDone
    from 
      #ot 
      left join (select ag_id, sum(Commondone) CommonDone from #p group by ag_id) E on E.ag_id=#ot.ag_id
    group by #ot.ag_id, E.CommonDone;
  -- having max(Done)>0;

end;