CREATE PROCEDURE [ELoadMenager].ELoad_ConsolidatedPeriodBuyerInfo
@dt1 datetime,
@dt2 datetime
AS
BEGIN
	set nocount on
  if object_id('tempdb..#tt_filtered') is not null drop table #tt_filtered
  if object_id('tempdb..#tmp_nc') is not null drop table #tmp_nc
  if object_id('tempdb..#tmp_kassa') is not null drop table #tmp_kassa
  if object_id('tempdb..#tmp_saldo') is not null drop table #tmp_saldo
  
  select row_number() over(order by dc.dck,dc.our_id) [rowID],
         dc.dck [ttID],
         d.pin [ttPin], 
         d.Master [ttMasterID],
         dc.Our_id [ttFirmID], 
         fc.OurName [ttFirmName],
         d.brName [ttName],
         d.BeginDate [ttDateBegin],
         iif(d.obl_id=18 and dc.our_id=17,cast(1 as bit),cast(0 as bit)) [isCrimea],
         dc.ag_id,
         pa.Fio [aFIO],
         a.sv_ag_id,
         ps.fio [sFIO],
         de.DepID,
         de.DName
  into #tt_filtered
  from morozdata.dbo.defcontract dc
  inner join morozdata.dbo.def d on dc.pin=d.pin
  inner join morozdata.dbo.FirmsConfig fc on fc.Our_id=dc.Our_id
  left join morozdata.dbo.AgentList a on a.ag_id=dc.ag_id
  left join morozdata.dbo.agentlist s on s.ag_id=a.sv_ag_id
  left join morozdata.dbo.person pa on pa.p_id=a.p_id
  left join morozdata.dbo.person ps on ps.p_id=s.p_id
  left join morozdata.dbo.deps de on de.DepID=a.depid
  where not dc.ag_id in (17,32)
        and d.Worker=0
        and dc.ContrTip=2
  group by dc.dck, 
  				 dc.Our_id, 
           d.brName, 
           d.obl_id, 
           d.Master, 
           fc.OurName, 
           d.BeginDate,
           d.pin,
           dc.ag_id,
           pa.Fio,
           a.sv_ag_id,
           ps.fio,
           de.DepID,
           de.DName

  create nonclustered index idx_tt_filtered_ttID on #tt_filtered(ttID)
  create nonclustered index idx_tt_filtered_ttFirmID on #tt_filtered(ttFirmID)
  alter table #tt_filtered add isOborot bit not null default cast(0 as bit)
  alter table #tt_filtered add isClear bit not null default cast(0 as bit)

  select dck [pin],
         ourid 
  into #tmp_nc
  from morozdata.dbo.nc 
  where nd between @dt1 and @dt2
  group by dck,ourid

  select dck [pin],
         Our_ID [ourid]
  into #tmp_kassa
  from morozdata.dbo.kassa1 
  where nd between @dt1 and @dt2
  group by dck,our_id

  select ds.dck [pin],
         dc.Our_ID [ourid]
  into #tmp_saldo
  from morozdata.dbo.DailySaldoDck ds
  inner join morozdata.dbo.DefContract dc on dc.dck=ds.dck
  where ds.ND=@dt2

  update #tt_filtered set isOborot=iif(exists(select 1 from #tmp_nc c where c.pin=ttID and c.ourid=ttFirmID)
                                   or exists(select 1 from #tmp_kassa c where c.pin=ttID and c.ourid=ttFirmID),
                                   cast(1 as bit),cast(0 as bit))
  
  update #tt_filtered set isOborot=1 
  where ttMasterID in (select distinct c.ttMasterID 
  										 from #tt_filtered c 
                       where c.ttMasterID<>0 
                       			 and c.isOborot=1 
                             and c.ttFirmID=#tt_filtered.ttFirmID)
                                     
  update #tt_filtered set isClear=iif(isOborot=0 and not exists(select 1 from #tmp_saldo c where c.pin=ttID and c.ourid=ttFirmID),cast(1 as bit),cast(0 as bit))                                 
	
  select * into #friz from morozdata.dbo.frizer 
  
  --/*
  select t.ttFirmName+':['+cast(t.ttFirmID as varchar)+']'+iif(t.isCrimea=1,' - Крым','') [Наименование фирмы],
  			 (select count(1) from #tt_filtered a where t.ttFirmID=a.ttFirmID and t.isCrimea=a.isCrimea) [Всего точек],
         (select count(distinct a.ttMasterID) from #tt_filtered a where t.ttFirmID=a.ttFirmID and t.isCrimea=a.isCrimea and a.ttMasterID<>0) [Всего сетей], 
         (select count(1) from #tt_filtered a where t.ttFirmID=a.ttFirmID and t.isCrimea=a.isCrimea and a.ttMasterID<>0) [Всего сетевых точек], 
         (select count(1) from #tt_filtered a where t.ttFirmID=a.ttFirmID and t.isCrimea=a.isCrimea and isnull(a.ttMasterID,0)=0) [Всего не сетевых точек],
         (select count(distinct a.ttMasterID) from #tt_filtered a where t.ttFirmID=a.ttFirmID and t.isCrimea=a.isCrimea and a.ttMasterID<>0 and a.isClear=1) [Всего сетей без оборотов],  
         (select count(1) from #tt_filtered a where t.ttFirmID=a.ttFirmID and t.isCrimea=a.isCrimea and a.ttMasterID<>0 and a.isClear=1) [Всего сетевых точек без оборотов],
         (select count(1) from #tt_filtered a where t.ttFirmID=a.ttFirmID and t.isCrimea=a.isCrimea and isnull(a.ttMasterID,0)=0 and a.isClear=1) [Всего не сетевых точек без оборотов]
  from #tt_filtered t
  group by t.ttFirmName,
  				 t.isCrimea,
           t.ttFirmID 
  order by t.ttFirmID
 --*/
 
 	select [ttID] [КодДоговора],
         [ttPin] [КодТочки], 
         [ttMasterID] [КодМастера],
         [ttFirmID] [КодФирмы], 
         [ttFirmName] [НаименованиеФирмы],
         [ttName] [НаименованиеТорговойТочки],
         [ttDateBegin] [ДатаЗаведения],
         ag_id [КодАгента],
         [aFIO] [ФИОАгента],
         sv_ag_id [КодСупервизора],
         [sFIO] [ФИОСупервизора],
         DepID [КодОтдела],
         DName [НаименованиеОтдела],
         [isCrimea] [ЭтоКрым],
         [isOborot] [БылОборотПериод],
         [isClear] [ЧистаНаКонецПериода],
         (select IsNull(Count(1),0) from #friz where B_id=[ttPin] and tip=0) [Холодильники],
         (select IsNull(Count(1),0) from #friz where B_id=[ttPin] and tip!=0) as [Оборудование] 
  from #tt_filtered
  
 	
  drop table #tt_filtered
  drop table #tmp_nc
  drop table #tmp_kassa
  drop table #tmp_saldo
  drop table #friz
END