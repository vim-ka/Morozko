CREATE PROCEDURE [db_FarLogistic].FarLogicPayBackMarsh
@vID int,
@m varchar(max),
@y varchar(max)
AS
BEGIN
  if not object_id('tempdb.dbo.#tmpPayBackMarsh') is null 
  drop table #tmpPayBackMarsh
  
  if not object_id('tempdb.dbo.#tmpDrvMarsh') is null 
  drop table #tmpDrvMarsh 
  
  if not object_id('tempdb.dbo.#tmp') is null 
  drop table #tmp
  
  create table #tmp (dt datetime)
  
  declare @FromDate datetime
  declare @ToDate datetime 
  declare curMarsh cursor for
  select 	m.dt_beg_fact,
          m.dt_end_fact
  from db_FarLogistic.dlMarsh m
  where m.IDdlVehicles=@vID and
        month(m.dt_end_fact) in (select * from db_FarLogistic.String_to_Int(@m)) and
        year(m.dt_end_fact) in (select * from db_FarLogistic.String_to_Int(@y)) and 
        m.IDdlMarshStatus=4
  order by 1
      
  open curMarsh 
      
  fetch next from curMarsh into @FromDate, @ToDate
      
  while @@FETCH_STATUS=0 
  begin
      	
        
    with Days(D) AS
    (
     select @FromDate where @FromDate <= @ToDate
     union all
     select dateadd(day,1,D) from Days where D < @ToDate
    )
        
    insert into #tmp
    select cast(D as date)
    from Days
    fetch next from curMarsh into @FromDate, @ToDate 
  end
      
  close curMarsh
  deallocate curMarsh
  
  create table #tmpDrvMarsh (dt datetime, IsUSE bit)
  
  insert into #tmpDrvMarsh  
  select distinct dt,0 from  #tmp
  
  create table #tmpPayBackMarsh (eID int, eName varchar(50))
  
  insert into #tmpPayBackMarsh
  select * from (
  select ExpenceListID eID, ExpenceName eName
  from db_FarLogistic.dlExpenceList 
  union all 
  select 0, 'Пробег'
  union all
  select 8, 'Итоговая сумма расходов'
  union all
  select 10, 'Итоговая сумма доходов'
  union all
  select 12, 'Сумма прибыль'
  union all
  select 9, 'в том числе на 1 км пробега'
  union all
  select 11, 'в том числе на 1 км пробега'
  union all
  select 13, 'в том числе на 1 км пробега') a
  order by 1
  
  declare @sql varchar(max)
  declare @mID int 
  declare @FKM int
  declare @PKM int
  declare @PAmort money
  declare @PStrah money
  declare @PServ money
  declare @PFuel money
  declare @PDrv money
  declare @PLog money
  declare @POth money
  declare @PCost money
  declare @FCost money
  
  declare @PSumKM int  
  declare @FSumKM int
  declare @FSumCost money
    
  declare curMarsh cursor for
  select 	m.dlMarshID,
          m.dt_beg_fact,
          m.dt_end_fact,
          m.odo_end_fact-m.odo_beg_fact,
          mc.KM
  from db_FarLogistic.dlMarsh m
  left join db_FarLogistic.dlTmpMarshCost mc on mc.MarshID=m.dlMarshID and mc.WorkID=0
  where m.IDdlVehicles=@vID and
        month(m.dt_end_fact) in (select * from db_FarLogistic.String_to_Int(@m)) and
        year(m.dt_end_fact) in (select * from db_FarLogistic.String_to_Int(@y)) and 
        m.IDdlMarshStatus=4
  order by 2
  
  open curMarsh 
      
  fetch next from curMarsh into @mID, @FromDate, @ToDate, @FKM, @PKM
  
  while @@FETCH_STATUS=0 
  begin
  	select 	@PAmort=sum(isnull(e.Amort,0)),
            @PStrah=sum(isnull(e.Strah,0)),
            @PServ=sum(isnull(e.Serv,0)),
            @PFuel=sum(isnull(e.Fuel,0)),
            @PDrv=sum(isnull(e.DriverZar,0)),
            @PLog=sum(isnull(e.LogicZar,0)),
            @POth=sum(isnull(e.Other,0)),
            @PCost=sum(isnull(e.PriceKM,0)) 
    from db_FarLogistic.dlExpence e
    where e.IDVehTYpe in (select v.dlVehTypeID from db_FarLogistic.dlVehicles v where v.dlVehiclesID=@vId
    											union all
                          select v.dlVehTypeID from db_FarLogistic.dlVehicles v where v.dlMainVehID=@vId)
  
  	set @sql=''
    set @sql='
          alter table #tmpPayBackMarsh add [ExpencePlan_'+cast(@mID as varchar(7))+'] money default 0, 
                                      		 [ExpencePlanFact_'+cast(@mID as varchar(7))+'] money default 0'
    exec(@sql)
    
    select @FCost=sum(b.ForPay)
    from db_FarLogistic.dlGroupBill b
    where b.MarshID=@mID
    
    set @sql=''
    set @sql='
    		update  #tmpPayBackMarsh set [ExpencePlan_'+cast(@mID as varchar(7))+']=case when eID=0 then '+cast(@PKM as varchar(50))+'
        																																						 when eID=1 then '+cast(@PKM*@PAmort as varchar(50))+'
                                                                                     when eID=2 then '+cast(@PKM*@PStrah as varchar(50))+'
                                                                                     when eID=3 then '+cast(@PKM*@PServ as varchar(50))+'
                                                                                     when eID=4 then '+cast(@PKM*@PFuel as varchar(50))+'
                                                                                     when eID=5 then '+cast(@PKM*@PDrv as varchar(50))+'
                                                                                     when eID=6 then '+cast(@PKM*@PLog as varchar(50))+'
                                                                                     when eID=7 then '+cast(@PKM*@POth as varchar(50))+'
                                                                                     when eID=8 then '+cast((@PKM*@PAmort+@PKM*@PStrah+@PKM*@PServ+@PKM*@PFuel+@PKM*@PDrv+@PKM*@PLog+@PKM*@POth) as varchar(50))+'
                                                                                     when eID=9 then '+cast((@PKM*@PAmort+@PKM*@PStrah+@PKM*@PServ+@PKM*@PFuel+@PKM*@PDrv+@PKM*@PLog+@PKM*@POth)/@PKM as varchar(50))+'
                                                                                     when eID=10 then '+cast(@PCost*@PKM as varchar(50))+'
                                                                                     when eID=11 then '+cast((@PCost*@PKM)/@PKM as varchar(50))+'
                                                                                     when eID=12 then '+cast(@PCost*@PKM-(@PKM*@PAmort+@PKM*@PStrah+@PKM*@PServ+@PKM*@PFuel+@PKM*@PDrv+@PKM*@PLog+@PKM*@POth) as varchar(50))+'
                                                                                     when eID=13 then '+cast((@PCost*@PKM-(@PKM*@PAmort+@PKM*@PStrah+@PKM*@PServ+@PKM*@PFuel+@PKM*@PDrv+@PKM*@PLog+@PKM*@POth))/@PKM as varchar(50))+' 
        																																																															 end, 
    																 [ExpencePlanFact_'+cast(@mID as varchar(7))+']=case when eID=0 then '+cast(@FKM as varchar(50))+'
                                                                                         when eID=1 then '+cast(@FKM*@PAmort as varchar(50))+'
                                                                                         when eID=2 then '+cast(@FKM*@PStrah as varchar(50))+'
                                                                                         when eID=3 then '+cast(@FKM*@PServ as varchar(50))+'
                                                                                         when eID=4 then '+cast(@FKM*@PFuel as varchar(50))+'
                                                                                         when eID=5 then '+cast(@FKM*@PDrv as varchar(50))+'
                                                                                         when eID=6 then '+cast(@FKM*@PLog as varchar(50))+'
                                                                                         when eID=7 then '+cast(@FKM*@POth as varchar(50))+'
                                                                                         when eID=8 then '+cast((@FKM*@PAmort+@FKM*@PStrah+@FKM*@PServ+@FKM*@PFuel+@FKM*@PDrv+@FKM*@PLog+@FKM*@POth) as varchar(50))+'
                                                                                         when eID=9 then '+cast((@FKM*@PAmort+@FKM*@PStrah+@FKM*@PServ+@FKM*@PFuel+@FKM*@PDrv+@FKM*@PLog+@FKM*@POth)/@FKM as varchar(50))+'
                                                                                         when eID=10 then '+cast(@FCost as varchar(50))+'
                                                                                         when eID=11 then '+cast((@FCost)/@FKM as varchar(50))+'
                                                                                         when eID=12 then '+cast(@FCost-(@FKM*@PAmort+@FKM*@PStrah+@FKM*@PServ+@FKM*@PFuel+@FKM*@PDrv+@FKM*@PLog+@FKM*@POth) as varchar(50))+'
                                                                                         when eID=13 then '+cast((@FCost-(@FKM*@PAmort+@FKM*@PStrah+@FKM*@PServ+@FKM*@PFuel+@FKM*@PDrv+@FKM*@PLog+@FKM*@POth))/@FKM as varchar(50))+' 
        																																																															 end'
    exec(@sql)
    
    fetch next from curMarsh into @mID, @FromDate, @ToDate, @FKM, @PKM
  end
  
  close curMarsh
  deallocate curMarsh
  
  select 	@FSumKM=sum(m.odo_end_fact-m.odo_beg_fact)
  from db_FarLogistic.dlMarsh m  
  where m.IDdlVehicles=@vID and
        month(m.dt_end_fact) in (select * from db_FarLogistic.String_to_Int(@m)) and
        year(m.dt_end_fact) in (select * from db_FarLogistic.String_to_Int(@y)) and 
        m.IDdlMarshStatus=4
        
  select 	@PSumKM=sum(mc.KM)
  from db_FarLogistic.dlMarsh m
  left join db_FarLogistic.dlTmpMarshCost mc on mc.MarshID=m.dlMarshID and mc.WorkID=0
  where m.IDdlVehicles=@vID and
        month(m.dt_end_fact) in (select * from db_FarLogistic.String_to_Int(@m)) and
        year(m.dt_end_fact) in (select * from db_FarLogistic.String_to_Int(@y)) and 
        m.IDdlMarshStatus=4
        
  select 	@FSumCost=sum(b.ForPay)
  from db_FarLogistic.dlMarsh m
  left join db_FarLogistic.dlGroupBill b on b.MarshID=m.dlMarshID
  where m.IDdlVehicles=@vID and
        month(m.dt_end_fact) in (select * from db_FarLogistic.String_to_Int(@m)) and
        year(m.dt_end_fact) in (select * from db_FarLogistic.String_to_Int(@y)) and 
        m.IDdlMarshStatus=4 
        
  set @sql=''
  set @sql='
        alter table #tmpPayBackMarsh add [ExpencePlan] money default 0, 
                                         [ExpencePlanFact] money default 0'
  exec(@sql)
  
  set @sql=''
  set @sql='
      update  #tmpPayBackMarsh set [ExpencePlan]=case  when eID=0 then '		+cast(@PSumKM as varchar(50))+'
                                                       when eID=1 then '		+cast(@PSumKM*@PAmort as varchar(50))+'
                                                       when eID=2 then '		+cast(@PSumKM*@PStrah as varchar(50))+'
                                                       when eID=3 then '		+cast(@PSumKM*@PServ as varchar(50))+'
                                                       when eID=4 then '		+cast(@PSumKM*@PFuel as varchar(50))+'
                                                       when eID=5 then '		+cast(@PSumKM*@PDrv as varchar(50))+'
                                                       when eID=6 then '		+cast(@PSumKM*@PLog as varchar(50))+'
                                                       when eID=7 then '		+cast(@PSumKM*@POth as varchar(50))+'
                                                       when eID=8 then '		+cast((@PSumKM*@PAmort+@PSumKM*@PStrah+@PSumKM*@PServ+@PSumKM*@PFuel+@PSumKM*@PDrv+@PSumKM*@PLog+@PSumKM*@POth) as varchar(50))+'
                                                       when eID=9 then '		+cast((@PSumKM*@PAmort+@PSumKM*@PStrah+@PSumKM*@PServ+@PSumKM*@PFuel+@PSumKM*@PDrv+@PSumKM*@PLog+@PSumKM*@POth)/@PSumKM as varchar(50))+'
                                                       when eID=10 then '		+cast(@PCost*@PSumKM as varchar(50))+'
                                                       when eID=11 then '		+cast((@PCost*@PSumKM)/@PKM as varchar(50))+'
                                                       when eID=12 then '		+cast(@PCost*@PSumKM-(@PSumKM*@PAmort+@PSumKM*@PStrah+@PSumKM*@PServ+@PSumKM*@PFuel+@PSumKM*@PDrv+@PSumKM*@PLog+@PSumKM*@POth) as varchar(50))+'
                                                       when eID=13 then '		+cast((@PCost*@PSumKM-(@PSumKM*@PAmort+@PSumKM*@PStrah+@PSumKM*@PServ+@PSumKM*@PFuel+@PSumKM*@PDrv+@PSumKM*@PLog+@PSumKM*@POth))/@PSumKM as varchar(50))+' 
                                                                                                         end,
  
																	[ExpencePlanFact]=case when eID=0 then '	+cast(@FSumKM as varchar(50))+'
                                                         when eID=1 then '	+cast(@FSumKM*@PAmort as varchar(50))+'
                                                         when eID=2 then '	+cast(@FSumKM*@PStrah as varchar(50))+'
                                                         when eID=3 then '	+cast(@FSumKM*@PServ as varchar(50))+'
                                                         when eID=4 then '	+cast(@FSumKM*@PFuel as varchar(50))+'
                                                         when eID=5 then '	+cast(@FSumKM*@PDrv as varchar(50))+'
                                                         when eID=6 then '	+cast(@FSumKM*@PLog as varchar(50))+'
                                                         when eID=7 then '	+cast(@FSumKM*@POth as varchar(50))+'
                                                         when eID=8 then '	+cast((@FSumKM*@PAmort+@FSumKM*@PStrah+@FSumKM*@PServ+@FSumKM*@PFuel+@FSumKM*@PDrv+@FSumKM*@PLog+@FSumKM*@POth) as varchar(50))+'
                                                         when eID=9 then '	+cast((@FSumKM*@PAmort+@FSumKM*@PStrah+@FSumKM*@PServ+@FSumKM*@PFuel+@FSumKM*@PDrv+@FSumKM*@PLog+@FSumKM*@POth)/@FSumKM as varchar(50))+'
                                                         when eID=10 then '	+cast(@FSumCost as varchar(50))+'
                                                         when eID=11 then '	+cast((@FSumCost)/@FSumKM as varchar(50))+'
                                                         when eID=12 then '	+cast(@FSumCost-(@FSumKM*@PAmort+@FSumKM*@PStrah+@FSumKM*@PServ+@FSumKM*@PFuel+@FSumKM*@PDrv+@FSumKM*@PLog+@FSumKM*@POth) as varchar(50))+'
                                                         when eID=13 then '	+cast((@FSumCost-(@FSumKM*@PAmort+@FSumKM*@PStrah+@FSumKM*@PServ+@FSumKM*@PFuel+@FSumKM*@PDrv+@FSumKM*@PLog+@FSumKM*@POth))/@FSumKM as varchar(50))+' 
                                                                                                       end'
  exec(@sql)
  
  print @FSumKM
  print @FSumCost
  
  select * from #tmpPayBackMarsh
  order by eID
END