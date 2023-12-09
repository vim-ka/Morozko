CREATE PROCEDURE [db_FarLogistic].LongPusherPayBack
@m varchar(max),
@y varchar (max),
@det bit
AS
BEGIN
	declare @sql varchar(max)
	if not object_id('tempdb.dbo.#tmpPayBack') is null
  drop table #tmpPayBack
  
  if not object_id('tempdb.dbo.#tmpDrvCash') is null
  drop table #tmpDrvCash
  
  create table #tmpDrvCash ([dt] datetime not null)
  
  create table #tmpPayBack(	[PayBackID] int identity(1,1) not null, 
                            [VehID] int default 0 not null, 
                            [ExpID] int default 0 not null,
                            [VehN] int default 0 not null,
                            [VehName] varchar(100) default '' not null, 
                            [ExpName] varchar(40) default '' not null) 
                            
  if @det=1 
  begin
  	declare @curY int
  	declare @curM int
    
    declare curYear cursor for
    select * 
    from db_FarLogistic.String_to_Int(@y)
    order by 1
    
    open curYear
    
    fetch next from curYear into @curY
    
    while @@FETCH_STATUS=0
      begin
      	declare curMonth cursor for
      	select * 
    		from db_FarLogistic.String_to_Int(@m)
    		order by 1
        
        open curMonth
      	
        fetch next from curMonth into @curM
        
        while @@FETCH_STATUS=0
        begin
          set @sql=''
          set @sql='
          alter table #tmpPayBack add [ExpencePlan_'+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'] money default 0 null, 
                                      [ExpencePlanFact_'+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'] money default 0 null, 
                                      [ExpenceFact_'+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'] money default 0 null, 
                                      [ExpAbsLambda_'+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'] money default 0 null, 
                                      [ExpOtnLambda_'+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'] money default 0 null'
          exec(@sql)
          
          fetch next from curMonth into @curM
				end      
      	
        close curMonth
      	deallocate curMonth
      
      	fetch next from curYear into @curY
    	end
    
    close curYear
    deallocate curYear
  end
                            
                            
  set @sql=''
  set @sql='
  alter table #tmpPayBack add [ExpencePlan] money default 0  null, 
                           		[ExpencePlanFact] money default 0  null, 
                            	[ExpenceFact] money default 0  null, 
                            	[ExpAbsLambda] money default 0  null, 
                            	[ExpOtnLambda] money default 0  null'
  exec(@sql)
                      
  declare VehCursor cursor for
  select 	row_number() over(order by v.dlVehTypeID,v.dlVehiclesID) VehN,
					v.dlVehiclesID vID, 
  				isnull(p.dlVehiclesID,-1) pID,
  				case when p.dlVehiclesID is null then
          					'Транспортное средство: '+v.Model+' '+v.RegNom else
  							'Транспортное средство: '+v.Model+' '+v.RegNom+'+'+p.Model+' '+p.RegNom end vName
  from db_FarLogistic.dlVehicles v
  left join db_FarLogistic.dlVehicles p on p.dlMainVehID=v.dlVehiclesID
  where v.dlMainVehID=-1 
  		--and v.isDel=0 
        and v.dlVehiclesID in (	select m.IDdlVehicles 
        						from db_FarLogistic.dlMarsh m 
                              	where month(m.dt_end_fact) in (select * from db_FarLogistic.String_to_Int(@m)) and
                                  	  year(m.dt_end_fact) in (select * from db_FarLogistic.String_to_Int(@y)) and 
                                      m.IDdlMarshStatus=4) 
		
  

  
  
  open VehCursor
  
  declare @vID int
  declare @vTYPE int
  declare @pID int
  declare @vN int
  declare @vName varchar(100)
  declare @PKM int
  declare @FKM int
  declare @PAmort money
  declare @PStrah money
  declare @PServ money
  declare @PFuel money
  declare @PDrv money
  declare @PLog money
  declare @POth money
  declare @PCost money
  declare @tmp money
      
  declare @FAmort money
  declare @FStrah money
  declare @FServ money
  declare @FFuel money
  declare @FDrv money
  declare @FDrv1 money
  declare @FDrv2 money
  declare @FLog money
  declare @FOth money
  declare @FOth1 money
  declare @FCost money
  declare @FCost1 money
  
  fetch next from VehCursor into @vN, @vID, @pID, @vName
  
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
                          select v.dlVehTypeID from db_FarLogistic.dlVehicles v where v.dlVehiclesID=@pId)
                          
    select @FAmort=isnull(sum(ve.ExpenceSum),0)
    from db_FarLogistic.dlVehicleExpence ve
    where ve.dlVehicleID in (select @vId union all select @pId) and 
          month(ve.ExpenceDate) in (select * from db_FarLogistic.String_to_Int(@m)) and 
          year(ve.ExpenceDate) in (select * from db_FarLogistic.String_to_Int(@y)) and 
          ve.ExpenceListID=1 and 
          ve.IsDel=0
    
    select @FStrah=isnull(sum(ve.ExpenceSum),0)
    from db_FarLogistic.dlVehicleExpence ve
    where ve.dlVehicleID in (select @vId union all select @pId) and 
          month(ve.ExpenceDate) in (select * from db_FarLogistic.String_to_Int(@m)) and 
          year(ve.ExpenceDate) in (select * from db_FarLogistic.String_to_Int(@y)) and 
          ve.ExpenceListID=2 and 
          ve.IsDel=0
          
    select @FServ=isnull(sum(ve.ExpenceSum),0)
    from db_FarLogistic.dlVehicleExpence ve
    where ve.dlVehicleID in (select @vId union all select @pId) and 
          month(ve.ExpenceDate) in (select * from db_FarLogistic.String_to_Int(@m)) and 
          year(ve.ExpenceDate) in (select * from db_FarLogistic.String_to_Int(@y)) and 
          ve.ExpenceListID=3 and 
          ve.IsDel=0
          
    select @FLog=isnull(sum(ve.ExpenceSum),0)
    from db_FarLogistic.dlVehicleExpence ve
    where ve.dlVehicleID in (select @vId union all select @pId) and 
          month(ve.ExpenceDate) in (select * from db_FarLogistic.String_to_Int(@m)) and 
          year(ve.ExpenceDate) in (select * from db_FarLogistic.String_to_Int(@y)) and 
          ve.ExpenceListID=6 and 
          ve.IsDel=0
          
    select @FOth=isnull(sum(ve.ExpenceSum),0)
    from db_FarLogistic.dlVehicleExpence ve
    where ve.dlVehicleID in (select @vId union all select @pId) and 
          month(ve.ExpenceDate) in (select * from db_FarLogistic.String_to_Int(@m)) and 
          year(ve.ExpenceDate) in (select * from db_FarLogistic.String_to_Int(@y)) and 
          ve.ExpenceListID=7 and 
          ve.IsDel=0
          
    select @FOth1=isnull(sum(me.Cost),0)
    from db_FarLogistic.dlMarshExpence me
    left join db_FarLogistic.dlMarsh m on m.dlMarshID=me.MarshID
    where m.IDdlMarshStatus=4 and 
    			m.IDdlVehicles=@vId and
          month(m.dt_end_fact) in (select * from db_FarLogistic.String_to_Int(@m)) and
          year(m.dt_end_fact) in (select * from db_FarLogistic.String_to_Int(@y)) and 
          me.ExpenceID<>5
    
    select 	@PKM=sum(tm.KM),
    				@FKM=sum(m.odo_end_fact-m.odo_beg_fact)
    from db_FarLogistic.dlMarsh m
    left join db_FarLogistic.dlTmpMarshCost tm on tm.MarshID=m.dlMarshID and tm.WorkID=0
    where m.IDdlMarshStatus=4 and 
          m.IDdlVehicles=@vID and 
          month(m.dt_end_fact) in (select * from db_FarLogistic.String_to_Int(@m)) and 
          year(m.dt_end_fact) in (select * from db_FarLogistic.String_to_Int(@y))
    
    select @vTYPE=v.dlVehTypeID
    from db_FarLogistic.dlVehicles v
    where v.dlVehiclesID=@vID
    
    declare @DayCnt int
    truncate table #tmpDrvCash
    declare @FromDate datetime
		declare @ToDate datetime 
    declare curMarsh cursor for
    select 	m.dt_beg_fact,
    				m.dt_end_fact
    from db_FarLogistic.dlMarsh m
    where m.IDdlVehicles=@vID and
    			month(m.dt_end_fact) in (select * from db_FarLogistic.String_to_Int(@m)) and
          year(m.dt_end_fact) in (select * from db_FarLogistic.String_to_Int(@y))
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
      
      insert into #tmpDrvCash
      select D
      from Days
      fetch next from curMarsh into @FromDate, @ToDate
    end
    
    close curMarsh
    deallocate curMarsh 
    
    select @DayCnt=count(*)
    from (
    			select distinct * from #tmpDrvCash
    			) a
          
    if @vTYPE=1
    begin          
    	set @FDrv1=@DayCnt*(17500/24)
      
      select @FDrv=isnull(sum(d.KM*q.KMPrice),0) 
      from db_FarLogistic.dlPairDistanceDrv d 
      left join db_FarLogistic.dlJorneyInfo j on j.MarshID=d.MarshID
      left join db_FarLogistic.dlJorney jj on jj.IDReq=j.IDReq and jj.NumbForRace=d.FinishPointNumber
      left join db_FarLogistic.dlDriverQuality q on q.IDQuality=jj.DrvWorkQuality
      where d.MarshID in (select m.dlMarshID 
                          from db_FarLogistic.dlMarsh m
                          where m.IDdlMarshStatus=4 and 
                          m.IDdlVehicles=@vID and 
                          month(m.dt_end_fact) in (select * from db_FarLogistic.String_to_Int(@m)) and 
                          year(m.dt_end_fact) in (select * from db_FarLogistic.String_to_Int(@y)))                           
      
    end 
    
    if @vTYPE=3
    begin
    	set @FDrv1=@DayCnt*(35000/24)
      
    	select @FDrv=(count(*)*100)
      from db_FarLogistic.dlJorney j 
      left join db_FarLogistic.dlJorneyInfo ji on ji.IDReq=j.IDReq
      where j.IDdlPointAction in (2,3) and 
      			ji.MarshID in (select m.dlMarshID 
                          from db_FarLogistic.dlMarsh m
                          where m.IDdlMarshStatus=4 and 
                          m.IDdlVehicles=@vID and 
                          month(m.dt_end_fact) in (select * from db_FarLogistic.String_to_Int(@m)) and 
                          year(m.dt_end_fact) in (select * from db_FarLogistic.String_to_Int(@y)))  
                          
    end 
    
    select @FDrv2=isnull(sum(isnull(me.Cost,0)),0)
    from db_FarLogistic.dlMarshExpence me 
    where me.MarshID in (select m.dlMarshID 
                        from db_FarLogistic.dlMarsh m
                        where m.IDdlMarshStatus=4 and 
                        m.IDdlVehicles=@vID and 
                        month(m.dt_end_fact) in (select * from db_FarLogistic.String_to_Int(@m)) and 
                        year(m.dt_end_fact) in (select * from db_FarLogistic.String_to_Int(@y))) and
                        me.MarshExpID=5 
                       
    select @FCost=sum(b.ForPay)
    from db_FarLogistic.dlGroupBill b 
    where b.MarshID in (select m.dlMarshID 
    										from db_FarLogistic.dlMarsh m
                        where m.IDdlMarshStatus=4 and 
          							m.IDdlVehicles=@vID and 
          							month(m.dt_end_fact) in (select * from db_FarLogistic.String_to_Int(@m)) and 
          							year(m.dt_end_fact) in (select * from db_FarLogistic.String_to_Int(@y)))
                        
    select @FFuel=isnull(sum(f.summa),0)
    from FFuelNew f
    left join FCards c on c.CardNom=f.cardnum
    where c.fcID in (select c.IDCard from db_FarLogistic.dlFuelCard c where c.IDVeh=@vID) and 
          month(f.nd) in (select * from db_FarLogistic.String_to_Int(@m)) and 
          year(f.nd) in (select * from db_FarLogistic.String_to_Int(@y))
          
    insert into #tmpPayBack(VehN,
    												VehID,
    												ExpID,
                            VehName,
                            ExpName,
                            ExpencePlan,
                            ExpencePlanFact,
                            ExpenceFact,
                            ExpAbsLambda,
                            ExpOtnLambda)
    select 	@vN,
    				@vID,
    				eID,
            @vName,
            eName,
            (case 	when eID=0 then @PKM
            				when eID=1 then @PAmort*@PKM
                  	when eID=2 then	@PStrah*@PKM
                  	when eID=3 then	@PServ*@PKM
                  	when eID=4 then	@PFuel*@PKM
                  	when eID=5 then	@PDrv*@PKM
                  	when eID=6 then	@PLog*@PKM
                  	when eID=7 then	@POth*@PKM
                  	when eID=8 then	@PAmort*@PKM+@PStrah*@PKM+@PServ*@PKM+@PFuel*@PKM+@PDrv*@PKM+@PLog*@PKM+@POth*@PKM
                  	when eID=9 then	@PCost*@PKM
                  	when eID=10 then @PCost*@PKM-(@PAmort*@PKM+@PStrah*@PKM+@PServ*@PKM+@PFuel*@PKM+@PDrv*@PKM+@PLog*@PKM+@POth*@PKM)
                    when eID=11 then (@PAmort*@PKM+@PStrah*@PKM+@PServ*@PKM+@PFuel*@PKM+@PDrv*@PKM+@PLog*@PKM+@POth*@PKM)/@PKM
                    when eID=12 then (@PCost*@PKM)/@PKM
                    when eID=13 then (@PCost*@PKM-(@PAmort*@PKM+@PStrah*@PKM+@PServ*@PKM+@PFuel*@PKM+@PDrv*@PKM+@PLog*@PKM+@POth*@PKM))/@PKM
            end),
            (case 	when eID=0 then @FKM
            				when eID=1 then @PAmort*@FKM
                  	when eID=2 then	@PStrah*@FKM
                  	when eID=3 then	@PServ*@FKM
                  	when eID=4 then	@PFuel*@FKM
                  	when eID=5 then	@PDrv*@FKM
                  	when eID=6 then	@PLog*@FKM
                  	when eID=7 then	@POth*@FKM
                  	when eID=8 then	@PAmort*@FKM+@PStrah*@FKM+@PServ*@FKM+@PFuel*@FKM+@PDrv*@FKM+@PLog*@FKM+@POth*@FKM
                  	when eID=9 then	@FCost --сумма по маршруту без штрафов
                  	when eID=10 then @FCost-(@PAmort*@FKM+@PStrah*@FKM+@PServ*@FKM+@PFuel*@FKM+@PDrv*@FKM+@PLog*@FKM+@POth*@FKM)
                    when eID=11 then (@PAmort*@FKM+@PStrah*@FKM+@PServ*@FKM+@PFuel*@FKM+@PDrv*@FKM+@PLog*@FKM+@POth*@FKM)/@FKM
                    when eID=12 then (@FCost)/@FKM
                    when eID=13 then (@FCost-(@PAmort*@FKM+@PStrah*@FKM+@PServ*@FKM+@PFuel*@FKM+@PDrv*@FKM+@PLog*@FKM+@POth*@FKM))/@FKM
            end),
            (case 	when eID=0 then @FKM
            				when eID=1 then @FAmort
                  	when eID=2 then	@FStrah
                  	when eID=3 then	@FServ
                  	when eID=4 then	@FFuel
                  	when eID=5 then	@FDrv+@FDrv1+@FDrv2
                  	when eID=6 then	@FLog
                  	when eID=7 then	@FOth+@FOth1
                  	when eID=8 then	@FAmort+@FStrah+@FServ+@FFuel+@FDrv+@FDrv1+@FDrv2+@FLog+@FOth+@FOth1
                  	when eID=9 then	@FCost --сумма по маршруту со штрафов
                  	when eID=10 then @FCost-(@FAmort+@FStrah+@FServ+@FFuel+@FDrv+@FDrv1+@FDrv2+@FLog+@FOth+@FOth1)
                    when eID=11 then (@FAmort+@FStrah+@FServ+@FFuel+@FDrv+@FDrv1+@FDrv2+@FLog+@FOth+@FOth1)/@FKM
                    when eID=12 then (@FCost)/@FKM
                    when eID=13 then (@FCost-(@FAmort+@FStrah+@FServ+@FFuel+@FDrv+@FDrv1+@FDrv2+@FLog+@FOth+@FOth1))/@FKM
            end),
            (case 	when eID=0 then @FKM-@FKM
            				when eID=1 then @FAmort-@PAmort*@FKM
                  	when eID=2 then	@FStrah-@PStrah*@FKM
                  	when eID=3 then	@FServ-@PServ*@FKM
                  	when eID=4 then	@FFuel-@PFuel*@FKM
                  	when eID=5 then	@FDrv+@FDrv1+@FDrv2-@PDrv*@FKM
                  	when eID=6 then	@FLog-@PLog*@FKM
                  	when eID=7 then	@FOth+@FOth1-@POth*@FKM
                  	when eID=8 then	@FAmort+@FStrah+@FServ+@FFuel+@FDrv+@FDrv1+@FDrv2+@FLog+@FOth+@FOth1-(@PAmort*@FKM+@PStrah*@FKM+@PServ*@FKM+@PFuel*@FKM+@PDrv*@FKM+@PLog*@FKM+@POth*@FKM)
                  	when eID=9 then	@FCost-@FCost --сумма по маршруту со штрафов
                  	when eID=10 then @FCost-(@FAmort+@FStrah+@FServ+@FFuel+@FDrv+@FDrv1+@FDrv2+@FLog+@FOth+@FOth1)-(@FCost-(@PAmort*@FKM+@PStrah*@FKM+@PServ*@FKM+@PFuel*@FKM+@PDrv*@FKM+@PLog*@FKM+@POth*@FKM))
                    when eID=11 then (@FAmort+@FStrah+@FServ+@FFuel+@FDrv+@FDrv1+@FDrv2+@FLog+@FOth+@FOth1-(@PAmort*@FKM+@PStrah*@FKM+@PServ*@FKM+@PFuel*@FKM+@PDrv*@FKM+@PLog*@FKM+@POth*@FKM))/@FKM
                    when eID=12 then (@FCost-@FCost)/@FKM
                    when eID=13 then (@FCost-(@FAmort+@FStrah+@FServ+@FFuel+@FDrv+@FDrv1+@FDrv2+@FLog+@FOth+@FOth1)-(@FCost-(@PAmort*@FKM+@PStrah*@FKM+@PServ*@FKM+@PFuel*@FKM+@PDrv*@FKM+@PLog*@FKM+@POth*@FKM)))/@FKM
            end),
            (case 	when eID=0 then case when @FKM=0 then 0 else (@FKM-@FKM)/@FKM end
            				when eID=1 then case when @FAmort=0 then 0 else (@FAmort-@PAmort*@FKM)/@FAmort end
                  	when eID=2 then	case when @FStrah=0 then 0 else (@FStrah-@PStrah*@FKM)/@FStrah end
                  	when eID=3 then	case when @FServ=0 then 0 else (@FServ-@PServ*@FKM)/@FServ end
                  	when eID=4 then	case when @FFuel=0 then 0 else (@FFuel-@PFuel*@FKM)/@FFuel end
                  	when eID=5 then	case when (@FDrv+@FDrv1)=0 then 0 else (@FDrv+@FDrv1-@PDrv*@FKM)/(@FDrv+@FDrv1) end
                  	when eID=6 then	case when @FLog=0 then 0 else (@FLog-@PLog*@FKM)/@FLog end
                  	when eID=7 then	case when (@FOth+@FOth1)=0 then 0 else (@FOth+@FOth1-@POth*@FKM)/(@FOth+@FOth1) end
                  	when eID=8 then	case when (@FAmort+@FStrah+@FServ+@FFuel+@FDrv+@FDrv1+@FDrv2+@FLog+@FOth+@FOth1)=0 then 0 else (@FAmort+@FStrah+@FServ+@FFuel+@FDrv+@FDrv1+@FLog+@FOth+@FOth1-(@PAmort*@FKM+@PStrah*@FKM+@PServ*@FKM+@PFuel*@FKM+@PDrv*@FKM+@PLog*@FKM+@POth*@FKM))/(@FAmort+@FStrah+@FServ+@FFuel+@FDrv+@FDrv1+@FLog+@FOth+@FOth1) end
                  	when eID=9 then	case when @FCost=0 then 0 else (@FCost-@FCost)/@FCost end --сумма по маршруту со штрафов
                  	when eID=10 then case when (@FCost-(@FAmort+@FStrah+@FServ+@FFuel+@FDrv+@FDrv1+@FDrv2+@FLog+@FOth+@FOth1))=0 then 0 else (@FCost-(@FAmort+@FStrah+@FServ+@FFuel+@FDrv+@FDrv1+@FLog+@FOth+@FOth1)-(@FCost-(@PAmort*@FKM+@PStrah*@FKM+@PServ*@FKM+@PFuel*@FKM+@PDrv*@FKM+@PLog*@FKM+@POth*@FKM)))/(@FCost-(@FAmort+@FStrah+@FServ+@FFuel+@FDrv+@FDrv1+@FLog+@FOth+@FOth1)) end
                    when eID=11 then (case when (@FAmort+@FStrah+@FServ+@FFuel+@FDrv+@FDrv1+@FDrv2+@FLog+@FOth+@FOth1)=0 then 0 else (@FAmort+@FStrah+@FServ+@FFuel+@FDrv+@FDrv1+@FLog+@FOth+@FOth1-(@PAmort*@FKM+@PStrah*@FKM+@PServ*@FKM+@PFuel*@FKM+@PDrv*@FKM+@PLog*@FKM+@POth*@FKM))/(@FAmort+@FStrah+@FServ+@FFuel+@FDrv+@FDrv1+@FLog+@FOth+@FOth1) end)/@FKM
                    when eID=12 then (case when @FCost=0 then 0 else (@FCost-@FCost)/@FCost end)/@FKM
                    when eID=13 then (case when (@FCost-(@FAmort+@FStrah+@FServ+@FFuel+@FDrv+@FDrv1+@FDrv2+@FLog+@FOth+@FOth1))=0 then 0 else (@FCost-(@FAmort+@FStrah+@FServ+@FFuel+@FDrv+@FDrv1+@FLog+@FOth+@FOth1)-(@FCost-(@PAmort*@FKM+@PStrah*@FKM+@PServ*@FKM+@PFuel*@FKM+@PDrv*@FKM+@PLog*@FKM+@POth*@FKM)))/(@FCost-(@FAmort+@FStrah+@FServ+@FFuel+@FDrv+@FDrv1+@FLog+@FOth+@FOth1)) end)/@FKM
            end)
    from (select ExpenceListID eID, ExpenceName eName
          from db_FarLogistic.dlExpenceList 
          union all 
          select 0, 'Пробег'
          union all
          select 8, 'Итоговая сумма расходов'
          union all
          select 9, 'Итоговая сумма доходов'
          union all
          select 10, 'Сумма прибыль'
          union all
          select 11, 'в том числе на 1 км пробега'
          union all
          select 12, 'в том числе на 1 км пробега'
          union all
          select 13, 'в том числе на 1 км пробега') a
          order by 1
          
  	fetch next from VehCursor into @vN, @vID, @pID, @vName
  end
  
  close VehCursor
  deallocate VehCursor
  
  insert into #tmpPayBack(VehN,
                          VehID,
                          ExpID,
                          VehName,
                          ExpName,
                          ExpencePlan,
                          ExpencePlanFact,
                          ExpenceFact,
                          ExpAbsLambda,
                          ExpOtnLambda)
  select 	988,
          -1,
          -1,
          'Итого по автопарку:',
          'пробег',
          (select sum(pb.ExpencePlan) 
          from #tmpPayBack pb
          where pb.ExpID=0),
          (select sum(pb.ExpencePlanFact) 
          from #tmpPayBack pb
          where pb.ExpID=0),
          (select sum(pb.ExpenceFact) 
          from #tmpPayBack pb
          where pb.ExpID=0),
          (select sum(pb.ExpAbsLambda) 
          from #tmpPayBack pb
          where pb.ExpID=0),
          (select sum(pb.ExpOtnLambda) 
          from #tmpPayBack pb
          where pb.ExpID=0)
          
          
  --#
  insert into #tmpPayBack(VehN,
                          VehID,
                          ExpID,
                          VehName,
                          ExpName,
                          ExpencePlan,
                          ExpencePlanFact,
                          ExpenceFact,
                          ExpAbsLambda,
                          ExpOtnLambda)
  select 	989,
          -1,
          -2,
          'Итого по автопарку:',
          'Амортизация/лизинговые платежи',
          (select sum(pb.ExpencePlan) 
          from #tmpPayBack pb
          where pb.ExpID=1),
          (select sum(pb.ExpencePlanFact) 
          from #tmpPayBack pb
          where pb.ExpID=1),
          (select sum(pb.ExpenceFact) 
          from #tmpPayBack pb
          where pb.ExpID=1),
          (select sum(pb.ExpAbsLambda) 
          from #tmpPayBack pb
          where pb.ExpID=1),
          (select sum(pb.ExpOtnLambda) 
          from #tmpPayBack pb
          where pb.ExpID=1)
          
          
  insert into #tmpPayBack(VehN,
                          VehID,
                          ExpID,
                          VehName,
                          ExpName,
                          ExpencePlan,
                          ExpencePlanFact,
                          ExpenceFact,
                          ExpAbsLambda,
                          ExpOtnLambda)
  select 	990,
          -1,
          -3,
          'Итого по автопарку:',
          'Страховка',
          (select sum(pb.ExpencePlan) 
          from #tmpPayBack pb
          where pb.ExpID=2),
          (select sum(pb.ExpencePlanFact) 
          from #tmpPayBack pb
          where pb.ExpID=2),
          (select sum(pb.ExpenceFact) 
          from #tmpPayBack pb
          where pb.ExpID=2),
          (select sum(pb.ExpAbsLambda) 
          from #tmpPayBack pb
          where pb.ExpID=2),
          (select sum(pb.ExpOtnLambda) 
          from #tmpPayBack pb
          where pb.ExpID=2)
          
          
  insert into #tmpPayBack(VehN,
                          VehID,
                          ExpID,
                          VehName,
                          ExpName,
                          ExpencePlan,
                          ExpencePlanFact,
                          ExpenceFact,
                          ExpAbsLambda,
                          ExpOtnLambda)
  select 	991,
          -1,
          -4,
          'Итого по автопарку:',
          'Ремонт и ТО',
          (select sum(pb.ExpencePlan) 
          from #tmpPayBack pb
          where pb.ExpID=3),
          (select sum(pb.ExpencePlanFact) 
          from #tmpPayBack pb
          where pb.ExpID=3),
          (select sum(pb.ExpenceFact) 
          from #tmpPayBack pb
          where pb.ExpID=3),
          (select sum(pb.ExpAbsLambda) 
          from #tmpPayBack pb
          where pb.ExpID=3),
          (select sum(pb.ExpOtnLambda) 
          from #tmpPayBack pb
          where pb.ExpID=3)
          
          
  insert into #tmpPayBack(VehN,
                          VehID,
                          ExpID,
                          VehName,
                          ExpName,
                          ExpencePlan,
                          ExpencePlanFact,
                          ExpenceFact,
                          ExpAbsLambda,
                          ExpOtnLambda)
  select 	992,
          -1,
          -5,
          'Итого по автопарку:',
          'Топливо',
          (select sum(pb.ExpencePlan) 
          from #tmpPayBack pb
          where pb.ExpID=4),
          (select sum(pb.ExpencePlanFact) 
          from #tmpPayBack pb
          where pb.ExpID=4),
          (select sum(pb.ExpenceFact) 
          from #tmpPayBack pb
          where pb.ExpID=4),
          (select sum(pb.ExpAbsLambda) 
          from #tmpPayBack pb
          where pb.ExpID=4),
          (select sum(pb.ExpOtnLambda) 
          from #tmpPayBack pb
          where pb.ExpID=4)
          
          
  insert into #tmpPayBack(VehN,
                          VehID,
                          ExpID,
                          VehName,
                          ExpName,
                          ExpencePlan,
                          ExpencePlanFact,
                          ExpenceFact,
                          ExpAbsLambda,
                          ExpOtnLambda)
  select 	993,
          -1,
          -6,
          'Итого по автопарку:',
          'Зарплата водителям',
          (select sum(pb.ExpencePlan) 
          from #tmpPayBack pb
          where pb.ExpID=5),
          (select sum(pb.ExpencePlanFact) 
          from #tmpPayBack pb
          where pb.ExpID=5),
          (select sum(pb.ExpenceFact) 
          from #tmpPayBack pb
          where pb.ExpID=5),
          (select sum(pb.ExpAbsLambda) 
          from #tmpPayBack pb
          where pb.ExpID=5),
          (select sum(pb.ExpOtnLambda) 
          from #tmpPayBack pb
          where pb.ExpID=5)
          
          
  insert into #tmpPayBack(VehN,
                          VehID,
                          ExpID,
                          VehName,
                          ExpName,
                          ExpencePlan,
                          ExpencePlanFact,
                          ExpenceFact,
                          ExpAbsLambda,
                          ExpOtnLambda)
  select 	994,
          -1,
          -7,
          'Итого по автопарку:',
          'Зарплата логистам',
          (select sum(pb.ExpencePlan) 
          from #tmpPayBack pb
          where pb.ExpID=6),
          (select sum(pb.ExpencePlanFact) 
          from #tmpPayBack pb
          where pb.ExpID=6),
          (select sum(pb.ExpenceFact) 
          from #tmpPayBack pb
          where pb.ExpID=6),
          (select sum(pb.ExpAbsLambda) 
          from #tmpPayBack pb
          where pb.ExpID=6),
          (select sum(pb.ExpOtnLambda) 
          from #tmpPayBack pb
          where pb.ExpID=6)
          
          
  insert into #tmpPayBack(VehN,
                          VehID,
                          ExpID,
                          VehName,
                          ExpName,
                          ExpencePlan,
                          ExpencePlanFact,
                          ExpenceFact,
                          ExpAbsLambda,
                          ExpOtnLambda)
  select 	995,
          -1,
          -8,
          'Итого по автопарку:',
          'Прочие расходы',
          (select sum(pb.ExpencePlan) 
          from #tmpPayBack pb
          where pb.ExpID=7),
          (select sum(pb.ExpencePlanFact) 
          from #tmpPayBack pb
          where pb.ExpID=7),
          (select sum(pb.ExpenceFact) 
          from #tmpPayBack pb
          where pb.ExpID=7),
          (select sum(pb.ExpAbsLambda) 
          from #tmpPayBack pb
          where pb.ExpID=7),
          (select sum(pb.ExpOtnLambda) 
          from #tmpPayBack pb
          where pb.ExpID=7)
          
          
  
  --#
  
  insert into #tmpPayBack(VehN,
                          VehID,
                          ExpID,
                          VehName,
                          ExpName,
                          ExpencePlan,
                          ExpencePlanFact,
                          ExpenceFact,
                          ExpAbsLambda,
                          ExpOtnLambda)
  select 	996,
          -1,
          -9,
          'Итого по автопарку:',
          'Сумма расходов',
          (select sum(pb.ExpencePlan) 
          from #tmpPayBack pb
          where pb.ExpID=8),
          (select sum(pb.ExpencePlanFact) 
          from #tmpPayBack pb
          where pb.ExpID=8),
          (select sum(pb.ExpenceFact) 
          from #tmpPayBack pb
          where pb.ExpID=8),
          (select sum(pb.ExpAbsLambda) 
          from #tmpPayBack pb
          where pb.ExpID=8),
          (select sum(pb.ExpOtnLambda) 
          from #tmpPayBack pb
          where pb.ExpID=8)
          
  insert into #tmpPayBack(VehN,
                          VehID,
                          ExpID,
                          VehName,
                          ExpName,
                          ExpencePlan,
                          ExpencePlanFact,
                          ExpenceFact,
                          ExpAbsLambda,
                          ExpOtnLambda)
  select 	997,
          -1,
          -10,
          'Итого по автопарку:',
          'Сумма доходов',
          (select sum(pb.ExpencePlan) 
          from #tmpPayBack pb
          where pb.ExpID=9),
          (select sum(pb.ExpencePlanFact) 
          from #tmpPayBack pb
          where pb.ExpID=9),
          (select sum(pb.ExpenceFact) 
          from #tmpPayBack pb
          where pb.ExpID=9),
          (select sum(pb.ExpAbsLambda) 
          from #tmpPayBack pb
          where pb.ExpID=9),
          (select sum(pb.ExpOtnLambda) 
          from #tmpPayBack pb
          where pb.ExpID=9)
          
  insert into #tmpPayBack(VehN,
                          VehID,
                          ExpID,
                          VehName,
                          ExpName,
                          ExpencePlan,
                          ExpencePlanFact,
                          ExpenceFact,
                          ExpAbsLambda,
                          ExpOtnLambda)
  select 	998,
          -1,
          -11,
          'Итого по автопарку:',
          'Сумма прибыли',
          (select sum(pb.ExpencePlan) 
          from #tmpPayBack pb
          where pb.ExpID=10),
          (select sum(pb.ExpencePlanFact) 
          from #tmpPayBack pb
          where pb.ExpID=10),
          (select sum(pb.ExpenceFact) 
          from #tmpPayBack pb
          where pb.ExpID=10),
          (select sum(pb.ExpAbsLambda) 
          from #tmpPayBack pb
          where pb.ExpID=10),
          (select sum(pb.ExpOtnLambda) 
          from #tmpPayBack pb
          where pb.ExpID=10)
          
  insert into #tmpPayBack(VehN,
                          VehID,
                          ExpID,
                          VehName,
                          ExpName,
                          ExpencePlan,
                          ExpencePlanFact,
                          ExpenceFact,
                          ExpAbsLambda,
                          ExpOtnLambda)
  select 	999,
          -1,
          -12,
          'Итого по автопарку:',
          'в том числе на 1 км пробега',
          (select pb.ExpencePlan/(select ExpencePlan from #tmpPayBack where ExpID=-1) 
          from #tmpPayBack pb
          where pb.ExpID=-9),
          (select pb.ExpencePlanFact/(select ExpencePlanFact from #tmpPayBack where ExpID=-1) 
          from #tmpPayBack pb
          where pb.ExpID=-9),
          (select pb.ExpenceFact/(select ExpenceFact from #tmpPayBack where ExpID=-1) 
          from #tmpPayBack pb
          where pb.ExpID=-9),
          (select pb.ExpAbsLambda/(select ExpenceFact from #tmpPayBack where ExpID=-1) 
          from #tmpPayBack pb
          where pb.ExpID=-9),
          (select pb.ExpOtnLambda/(select ExpenceFact from #tmpPayBack where ExpID=-1) 
          from #tmpPayBack pb
          where pb.ExpID=-9)
          
  insert into #tmpPayBack(VehN,
                          VehID,
                          ExpID,
                          VehName,
                          ExpName,
                          ExpencePlan,
                          ExpencePlanFact,
                          ExpenceFact,
                          ExpAbsLambda,
                          ExpOtnLambda)
  select 	1000,
          -1,
          -13,
          'Итого по автопарку:',
          'в том числе на 1 км пробега',
          (select pb.ExpencePlan/(select ExpencePlan from #tmpPayBack where ExpID=-1) 
          from #tmpPayBack pb
          where pb.ExpID=-10),
          (select pb.ExpencePlanFact/(select ExpencePlanFact from #tmpPayBack where ExpID=-1) 
          from #tmpPayBack pb
          where pb.ExpID=-10),
          (select pb.ExpenceFact/(select ExpenceFact from #tmpPayBack where ExpID=-1) 
          from #tmpPayBack pb
          where pb.ExpID=-10),
          (select pb.ExpAbsLambda/(select ExpenceFact from #tmpPayBack where ExpID=-1) 
          from #tmpPayBack pb
          where pb.ExpID=-10),
          (select pb.ExpOtnLambda/(select ExpenceFact from #tmpPayBack where ExpID=-1) 
          from #tmpPayBack pb
          where pb.ExpID=-10)
          
  insert into #tmpPayBack(VehN,
                          VehID,
                          ExpID,
                          VehName,
                          ExpName,
                          ExpencePlan,
                          ExpencePlanFact,
                          ExpenceFact,
                          ExpAbsLambda,
                          ExpOtnLambda)
  select 	1001,
          -1,
          -14,
          'Итого по автопарку:',
          'в том числе на 1 км пробега',
          (select pb.ExpencePlan/(select ExpencePlan from #tmpPayBack where ExpID=-1) 
          from #tmpPayBack pb
          where pb.ExpID=-11),
          (select pb.ExpencePlanFact/(select ExpencePlanFact from #tmpPayBack where ExpID=-1) 
          from #tmpPayBack pb
          where pb.ExpID=-11),
          (select pb.ExpenceFact/(select ExpenceFact from #tmpPayBack where ExpID=-1) 
          from #tmpPayBack pb
          where pb.ExpID=-11),
          (select pb.ExpAbsLambda/(select ExpenceFact from #tmpPayBack where ExpID=-1) 
          from #tmpPayBack pb
          where pb.ExpID=-11),
          (select pb.ExpOtnLambda/(select ExpenceFact from #tmpPayBack where ExpID=-1) 
          from #tmpPayBack pb
          where pb.ExpID=-11)
  
  if @det=1 
  begin
    declare curYear cursor for
    select * 
    from db_FarLogistic.String_to_Int(@y)
    order by 1
    
    open curYear
    
    fetch next from curYear into @curY
    
    while @@FETCH_STATUS=0
      begin
      	declare curMonth cursor for
      	select * 
    		from db_FarLogistic.String_to_Int(@m)
    		order by 1
        
        open curMonth
      	
        fetch next from curMonth into @curM
        
        while @@FETCH_STATUS=0
        begin
        	
        	declare VehCursor cursor for
          select 	v.dlVehiclesID vID, 
                  isnull(p.dlVehiclesID,-1) pID
          from db_FarLogistic.dlVehicles v
          left join db_FarLogistic.dlVehicles p on p.dlMainVehID=v.dlVehiclesID
          where v.dlMainVehID=-1 --and v.isDel=0
          
          open VehCursor
          
          fetch next from VehCursor into @vID, @pID
          
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
                                  select v.dlVehTypeID from db_FarLogistic.dlVehicles v where v.dlVehiclesID=@pId)
                                  
            select @FAmort=isnull(sum(ve.ExpenceSum),0)
            from db_FarLogistic.dlVehicleExpence ve
            where ve.dlVehicleID in (select @vId union all select @pId) and 
                  month(ve.ExpenceDate) = @curM and 
                  year(ve.ExpenceDate) = @curY and 
                  ve.ExpenceListID=1 and 
          		  ve.IsDel=0
            
            select @FStrah=isnull(sum(ve.ExpenceSum),0)
            from db_FarLogistic.dlVehicleExpence ve
            where ve.dlVehicleID in (select @vId union all select @pId) and 
                  month(ve.ExpenceDate) = @curM and 
                  year(ve.ExpenceDate) = @curY and 
                  ve.ExpenceListID=2 and 
          		  ve.IsDel=0
                  
            select @FServ=isnull(sum(ve.ExpenceSum),0)
            from db_FarLogistic.dlVehicleExpence ve
            where ve.dlVehicleID in (select @vId union all select @pId) and 
                  month(ve.ExpenceDate) = @curM and 
                  year(ve.ExpenceDate) = @curY and
                  ve.ExpenceListID=3 and 
          		  ve.IsDel=0
                  
            select @FLog=isnull(sum(ve.ExpenceSum),0)
            from db_FarLogistic.dlVehicleExpence ve
            where ve.dlVehicleID in (select @vId union all select @pId) and 
                  month(ve.ExpenceDate) = @curM and 
                  year(ve.ExpenceDate) = @curY and
                  ve.ExpenceListID=6 and 
          		  ve.IsDel=0
                  
            select @FOth=isnull(sum(ve.ExpenceSum),0)
            from db_FarLogistic.dlVehicleExpence ve
            where ve.dlVehicleID in (select @vId union all select @pId) and 
                  month(ve.ExpenceDate) = @curM and 
                  year(ve.ExpenceDate) = @curY and
                  ve.ExpenceListID=7 and 
          		  ve.IsDel=0
                  
            select @FOth1=isnull(sum(me.Cost),0)
            from db_FarLogistic.dlMarshExpence me
            left join db_FarLogistic.dlMarsh m on m.dlMarshID=me.MarshID
            where m.IDdlMarshStatus=4 and 
                  m.IDdlVehicles=@vId and
                  month(m.dt_end_fact) = @curM and
                  year(m.dt_end_fact) = @curY and 
          				me.ExpenceID<>5
            
            select 	@PKM=sum(tm.KM),
                    @FKM=sum(m.odo_end_fact-m.odo_beg_fact)
            from db_FarLogistic.dlMarsh m
            left join db_FarLogistic.dlTmpMarshCost tm on tm.MarshID=m.dlMarshID and tm.WorkID=0
            where m.IDdlMarshStatus=4 and 
                  m.IDdlVehicles=@vID and 
                  month(m.dt_end_fact) = @curM and
                  year(m.dt_end_fact) = @curY
                  
            --зарплата водителям
            select @vTYPE=v.dlVehTypeID
    				from db_FarLogistic.dlVehicles v
    				where v.dlVehiclesID=@vID
            
            truncate table #tmpDrvCash
            declare curMarsh cursor for
            select 	m.dt_beg_fact,
                    m.dt_end_fact
            from db_FarLogistic.dlMarsh m
            where m.IDdlVehicles=@vID and
                  month(m.dt_end_fact) = @curM and
                  year(m.dt_end_fact) = @curY
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
              
              insert into #tmpDrvCash
              select D
              from Days
              fetch next from curMarsh into @FromDate, @ToDate
            end
            
            close curMarsh
            deallocate curMarsh 
            
            select @DayCnt=count(*)
            from (
                  select distinct * from #tmpDrvCash
                  ) a
                  
            if @vTYPE=1
            begin          
              set @FDrv1=@DayCnt*(17500/24)
              
              select @FDrv=isnull(sum(d.KM*q.KMPrice),0) 
              from db_FarLogistic.dlPairDistanceDrv d 
              left join db_FarLogistic.dlJorneyInfo j on j.MarshID=d.MarshID
              left join db_FarLogistic.dlJorney jj on jj.IDReq=j.IDReq and jj.NumbForRace=d.FinishPointNumber
              left join db_FarLogistic.dlDriverQuality q on q.IDQuality=jj.DrvWorkQuality
              where d.MarshID in (select m.dlMarshID 
                                  from db_FarLogistic.dlMarsh m
                                  where m.IDdlMarshStatus=4 and 
                                  m.IDdlVehicles=@vID and 
                                  month(m.dt_end_fact)=@curM and 
                                  year(m.dt_end_fact)=@curY)                           
              
            end 
            
            if @vTYPE=3
            begin
              set @FDrv1=@DayCnt*(35000/24)
              
              select @FDrv=(count(*)*100)
              from db_FarLogistic.dlJorney j 
              left join db_FarLogistic.dlJorneyInfo ji on ji.IDReq=j.IDReq
              where j.IDdlPointAction in (2,3) and 
                    ji.MarshID in (select m.dlMarshID 
                                  from db_FarLogistic.dlMarsh m
                                  where m.IDdlMarshStatus=4 and 
                                  m.IDdlVehicles=@vID and 
                                  month(m.dt_end_fact)=@curM and 
                                  year(m.dt_end_fact)=@curY)  
                                  
            end
            --зарплата водителям
                                
            select @FDrv2=isnull(sum(isnull(me.Cost,0)),0)
            from db_FarLogistic.dlMarshExpence me 
            where me.MarshID in (select m.dlMarshID 
                                from db_FarLogistic.dlMarsh m
                                where m.IDdlMarshStatus=4 and 
                                m.IDdlVehicles=@vID and 
                                month(m.dt_end_fact) = @curM and
                  							year(m.dt_end_fact) = @curY) and
                                me.MarshExpID=5 
                                
            select @FCost=sum(b.ForPay)
            from db_FarLogistic.dlGroupBill b 
            where b.MarshID in (select m.dlMarshID 
                                from db_FarLogistic.dlMarsh m
                                where m.IDdlMarshStatus=4 and 
                                m.IDdlVehicles=@vID and 
                                month(m.dt_end_fact) = @curM and
                  							year(m.dt_end_fact) = @curY)
                                
            select @FFuel=isnull(sum(f.summa),0)
            from FFuelNew f
            left join FCards c on c.CardNom=f.cardnum
            where c.fcID in (select c.IDCard from db_FarLogistic.dlFuelCard c where c.IDVeh=@vID) and 
                  month(f.nd) = @curM and 
                  year(f.nd) = @curY
                  
            if @FKM=0
            begin
              set @tmp=0
            end
            else
            begin
              set @tmp=(@FKM-@FKM)/@FKM
            end      
            
            set @sql=''
            set @sql='update #tmpPayBack set 	ExpencePlan_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'='+cast(@PKM as varchar(20))+',
                                              ExpencePlanFact_'+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'='+cast(@FKM as varchar(20))+',
                                              ExpenceFact_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'='+cast(@FKM as varchar(20))+',
                                              ExpAbsLambda_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'='+cast(@FKM-@FKM as varchar(20))+',
                                              ExpOtnLambda_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'='+cast(@tmp as varchar(20))+' 
                      where VehID='+cast(@vID as varchar(10))+' and ExpID=0'
            exec(@sql)
            
            if @FAmort=0
            begin
              set @tmp=0
            end
            else
            begin
              set @tmp=(@FAmort-@FKM*@PAmort)/@FAmort
            end      
            
            set @sql=''
            set @sql='update #tmpPayBack set 	ExpencePlan_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'='+cast(@PKM*@PAmort as varchar(20))+',
                                              ExpencePlanFact_'+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'='+cast(@FKM*@PAmort as varchar(20))+',
                                              ExpenceFact_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'='+cast(@FAmort as varchar(20))+',
                                              ExpAbsLambda_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'='+cast(@FAmort-@FKM*@PAmort as varchar(20))+',
                                              ExpOtnLambda_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'='+cast(@tmp as varchar(20))+' 
                      where VehID='+cast(@vID as varchar(10))+' and ExpID=1'
            exec(@sql)
            
            if @FStrah=0
            begin
              set @tmp=0
            end
            else
            begin
              set @tmp=(@FStrah-@PStrah*@FKM)/@FStrah
            end      
            
            set @sql=''
            set @sql='update #tmpPayBack set 	ExpencePlan_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'='+cast(@PStrah*@PKM as varchar(20))+',
                                              ExpencePlanFact_'+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'='+cast(@PStrah*@FKM as varchar(20))+',
                                              ExpenceFact_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'='+cast(@FStrah as varchar(20))+',
                                              ExpAbsLambda_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'='+cast(@FStrah-@PStrah*@FKM as varchar(20))+',
                                              ExpOtnLambda_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'='+cast(@tmp as varchar(20))+' 
                      where VehID='+cast(@vID as varchar(10))+' and ExpID=2'
            exec(@sql)
            
            if @FServ=0
            begin
              set @tmp=0
            end
            else
            begin
              set @tmp=(@FServ-@FKM*@PServ)/@FServ
            end      
            
            set @sql=''
            set @sql='update #tmpPayBack set 	ExpencePlan_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'='+cast(@PKM*@PServ as varchar(20))+',
                                              ExpencePlanFact_'+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'='+cast(@FKM*@PServ as varchar(20))+',
                                              ExpenceFact_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'='+cast(@FServ as varchar(20))+',
                                              ExpAbsLambda_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'='+cast(@FServ-@FKM*@PServ as varchar(20))+',
                                              ExpOtnLambda_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'='+cast(@tmp as varchar(20))+' 
                      where VehID='+cast(@vID as varchar(10))+' and ExpID=3'
            exec(@sql)
            
            if @FFuel=0
            begin
              set @tmp=0
            end
            else
            begin
              set @tmp=(@FFuel-@FKM*@PFuel)/@FFuel
            end      
            
            set @sql=''
            set @sql='update #tmpPayBack set 	ExpencePlan_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'='+cast(@PKM*@PFuel as varchar(20))+',
                                              ExpencePlanFact_'+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'='+cast(@FKM*@PFuel as varchar(20))+',
                                              ExpenceFact_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'='+cast(@FFuel as varchar(20))+',
                                              ExpAbsLambda_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'='+cast(@FFuel-@FKM*@PFuel as varchar(20))+',
                                              ExpOtnLambda_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'='+cast(@tmp as varchar(20))+' 
                      where VehID='+cast(@vID as varchar(10))+' and ExpID=4'
            exec(@sql)
            
            if @FDrv+@FDrv1+@FDrv2=0
            begin
              set @tmp=0
            end
            else
            begin
              set @tmp=(@FDrv+@FDrv1+@FDrv2-@FKM*@PDrv)/(@FDrv+@FDrv1+@FDrv2)
            end      
            
            set @sql=''
            set @sql='update #tmpPayBack set 	ExpencePlan_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'='+cast(@PKM*@PDrv as varchar(20))+',
                                              ExpencePlanFact_'+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'='+cast(@FKM*@PDrv as varchar(20))+',
                                              ExpenceFact_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'='+cast(@FDrv+@FDrv1+@FDrv2 as varchar(20))+',
                                              ExpAbsLambda_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'='+cast(@FDrv+@FDrv1+@FDrv2-@FKM*@PDrv as varchar(20))+',
                                              ExpOtnLambda_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'='+cast(@tmp as varchar(20))+' 
                      where VehID='+cast(@vID as varchar(10))+' and ExpID=5'
            exec(@sql)
            
            if @FLog=0
            begin
              set @tmp=0
            end
            else
            begin
              set @tmp=(@FLog-@FKM*@PLog)/@FLog
            end      
            
            set @sql=''
            set @sql='update #tmpPayBack set 	ExpencePlan_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'='+cast(@PKM*@PLog as varchar(20))+',
                                              ExpencePlanFact_'+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'='+cast(@FKM*@PLog as varchar(20))+',
                                              ExpenceFact_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'='+cast(@FLog as varchar(20))+',
                                              ExpAbsLambda_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'='+cast(@FLog-@FKM*@PLog as varchar(20))+',
                                              ExpOtnLambda_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'='+cast(@tmp as varchar(20))+' 
                      where VehID='+cast(@vID as varchar(10))+' and ExpID=6'
            exec(@sql)
            
            if @FOth+@FOth1=0
            begin
              set @tmp=0
            end
            else
            begin
              set @tmp=(@FOth+@FOth1-@FKM*@POth)/(@FOth+@FOth1)
            end      
            
            set @sql=''
            set @sql='update #tmpPayBack set 	ExpencePlan_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'='+cast(@PKM*@POth as varchar(20))+',
                                              ExpencePlanFact_'+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'='+cast(@FKM*@POth as varchar(20))+',
                                              ExpenceFact_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'='+cast(@FOth+@FOth1 as varchar(20))+',
                                              ExpAbsLambda_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'='+cast(@FOth+@FOth1-@FKM*@POth as varchar(20))+',
                                              ExpOtnLambda_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'='+cast(@tmp as varchar(20))+' 
                      where VehID='+cast(@vID as varchar(10))+' and ExpID=7'
            exec(@sql)
            
            if @FCost=0
            begin
              set @tmp=0
            end
            else
            begin
              set @tmp=(@FCost-@FCost)/@FCost
            end      
            
            set @sql=''
            set @sql='update #tmpPayBack set 	ExpencePlan_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'='+cast(@PKM*@PCost as varchar(20))+',
                                              ExpencePlanFact_'+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'='+cast(@FCost as varchar(20))+',
                                              ExpenceFact_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'='+cast(@FCost as varchar(20))+',
                                              ExpAbsLambda_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'='+cast(@FCost-@FCost as varchar(20))+',
                                              ExpOtnLambda_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'='+cast(@tmp as varchar(20))+' 
                      where VehID='+cast(@vID as varchar(10))+' and ExpID=9'
            exec(@sql)
            
            if (@FAmort+@FStrah+@FServ+@FFuel+@FDrv+@FDrv1+@FDrv2+@FLog+@FOth+@FOth1)=0
            begin
              set @tmp=0
            end
            else
            begin
              set @tmp=((@FAmort+@FStrah+@FServ+@FFuel+@FDrv+@FDrv1+@FDrv2+@FLog+@FOth+@FOth1)-(@PAmort*@FKM+@PStrah*@FKM+@PServ*@FKM+@PFuel*@FKM+@PDrv*@FKM+@PLog*@FKM+@POth*@FKM))/(@FAmort+@FStrah+@FServ+@FFuel+@FDrv+@FDrv1+@FDrv2+@FLog+@FOth+@FOth1)
            end      
            
            set @sql=''
            set @sql='update #tmpPayBack set 	ExpencePlan_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'='+cast(@PAmort*@PKM+@PStrah*@PKM+@PServ*@PKM+@PFuel*@PKM+@PDrv*@PKM+@PLog*@PKM+@POth*@PKM as varchar(20))+',
                                              ExpencePlanFact_'+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'='+cast(@PAmort*@FKM+@PStrah*@FKM+@PServ*@FKM+@PFuel*@FKM+@PDrv*@FKM+@PLog*@FKM+@POth*@FKM as varchar(20))+',
                                              ExpenceFact_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'='+cast(@FAmort+@FStrah+@FServ+@FFuel+@FDrv+@FDrv1+@FDrv2+@FLog+@FOth+@FOth1 as varchar(20))+',
                                              ExpAbsLambda_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'='+cast((@FAmort+@FStrah+@FServ+@FFuel+@FDrv+@FDrv1+@FDrv2+@FLog+@FOth+@FOth1)-(@PAmort*@FKM+@PStrah*@FKM+@PServ*@FKM+@PFuel*@FKM+@PDrv*@FKM+@PLog*@FKM+@POth*@FKM) as varchar(20))+',
                                              ExpOtnLambda_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'='+cast(@tmp as varchar(20))+' 
                      where VehID='+cast(@vID as varchar(10))+' and ExpID=8'
            exec(@sql)
            
            if @FCost-(@FAmort+@FStrah+@FServ+@FFuel+@FDrv+@FDrv1+@FDrv2+@FLog+@FOth+@FOth1)=0
            begin
              set @tmp=0
            end
            else
            begin
              set @tmp=(@FCost-(@FAmort+@FStrah+@FServ+@FFuel+@FDrv+@FDrv1+@FDrv2+@FLog+@FOth+@FOth1)-(@FCost-(@PAmort*@FKM+@PStrah*@FKM+@PServ*@FKM+@PFuel*@FKM+@PDrv*@FKM+@PLog*@FKM+@POth*@FKM)))/(@FCost-(@FAmort+@FStrah+@FServ+@FFuel+@FDrv+@FDrv1+@FLog+@FOth+@FOth1))
            end      
            
            set @sql=''
            set @sql='update #tmpPayBack set 	ExpencePlan_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'='+cast(@PCost*@PKM-(@PAmort*@PKM+@PStrah*@PKM+@PServ*@PKM+@PFuel*@PKM+@PDrv*@PKM+@PLog*@PKM+@POth*@PKM) as varchar(20))+',
                                              ExpencePlanFact_'+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'='+cast(@FCost-(@PAmort*@FKM+@PStrah*@FKM+@PServ*@FKM+@PFuel*@FKM+@PDrv*@FKM+@PLog*@FKM+@POth*@FKM) as varchar(20))+',
                                              ExpenceFact_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'='+cast(@FCost-(@FAmort+@FStrah+@FServ+@FFuel+@FDrv+@FDrv1+@FDrv2+@FLog+@FOth+@FOth1) as varchar(20))+',
                                              ExpAbsLambda_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'='+cast(@FCost-(@FAmort+@FStrah+@FServ+@FFuel+@FDrv+@FDrv1+@FDrv2+@FLog+@FOth+@FOth1)-(@FCost-(@PAmort*@FKM+@PStrah*@FKM+@PServ*@FKM+@PFuel*@FKM+@PDrv*@FKM+@PLog*@FKM+@POth*@FKM)) as varchar(20))+',
                                              ExpOtnLambda_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'='+cast(@tmp as varchar(20))+' 
                      where VehID='+cast(@vID as varchar(10))+' and ExpID=10'
            exec(@sql)
          	
            if (@FAmort+@FStrah+@FServ+@FFuel+@FDrv+@FDrv1+@FDrv2+@FLog+@FOth+@FOth1)=0
            begin
              set @tmp=0
            end
            else
            begin
              set @tmp=((@FAmort+@FStrah+@FServ+@FFuel+@FDrv+@FDrv1+@FDrv2+@FLog+@FOth+@FOth1)-(@PAmort*@FKM+@PStrah*@FKM+@PServ*@FKM+@PFuel*@FKM+@PDrv*@FKM+@PLog*@FKM+@POth*@FKM))/(@FAmort+@FStrah+@FServ+@FFuel+@FDrv+@FDrv1+@FDrv2+@FLog+@FOth+@FOth1)
            end      
            
            set @sql=''
            set @sql='update #tmpPayBack set 	ExpencePlan_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'='+cast((@PAmort*@PKM+@PStrah*@PKM+@PServ*@PKM+@PFuel*@PKM+@PDrv*@PKM+@PLog*@PKM+@POth*@PKM)/@PKM as varchar(20))+',
                                              ExpencePlanFact_'+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'='+cast((@PAmort*@FKM+@PStrah*@FKM+@PServ*@FKM+@PFuel*@FKM+@PDrv*@FKM+@PLog*@FKM+@POth*@FKM)/@FKM as varchar(20))+',
                                              ExpenceFact_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'='+cast((@FAmort+@FStrah+@FServ+@FFuel+@FDrv+@FDrv1+@FDrv2+@FLog+@FOth+@FOth1)/@FKM as varchar(20))+',
                                              ExpAbsLambda_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'='+cast(((@FAmort+@FStrah+@FServ+@FFuel+@FDrv+@FDrv1+@FDrv2+@FLog+@FOth+@FOth1)-(@PAmort*@FKM+@PStrah*@FKM+@PServ*@FKM+@PFuel*@FKM+@PDrv*@FKM+@PLog*@FKM+@POth*@FKM))/@FKM as varchar(20))+',
                                              ExpOtnLambda_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'='+cast(@tmp/@FKM as varchar(20))+' 
                      where VehID='+cast(@vID as varchar(10))+' and ExpID=11'
            exec(@sql)
            
            if @FCost=0
            begin
              set @tmp=0
            end
            else
            begin
              set @tmp=(@FCost-@FCost)/@FCost
            end      
            
            set @sql=''
            set @sql='update #tmpPayBack set 	ExpencePlan_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'='+cast((@PKM*@PCost)/@PKM as varchar(20))+',
                                              ExpencePlanFact_'+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'='+cast(@FCost/@FKM as varchar(20))+',
                                              ExpenceFact_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'='+cast(@FCost/@FKM as varchar(20))+',
                                              ExpAbsLambda_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'='+cast((@FCost-@FCost)/@FKM as varchar(20))+',
                                              ExpOtnLambda_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'='+cast(@tmp/@FKM as varchar(20))+' 
                      where VehID='+cast(@vID as varchar(10))+' and ExpID=12'
            exec(@sql)
            
            if @FCost-(@FAmort+@FStrah+@FServ+@FFuel+@FDrv+@FDrv1+@FDrv2+@FLog+@FOth+@FOth1)=0
            begin
              set @tmp=0
            end
            else
            begin
              set @tmp=(@FCost-(@FAmort+@FStrah+@FServ+@FFuel+@FDrv+@FDrv1+@FDrv2+@FLog+@FOth+@FOth1)-(@FCost-(@PAmort*@FKM+@PStrah*@FKM+@PServ*@FKM+@PFuel*@FKM+@PDrv*@FKM+@PLog*@FKM+@POth*@FKM)))/(@FCost-(@FAmort+@FStrah+@FServ+@FFuel+@FDrv+@FDrv1+@FLog+@FOth+@FOth1))
            end      
            
            set @sql=''
            set @sql='update #tmpPayBack set 	ExpencePlan_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'='+cast((@PCost*@PKM-(@PAmort*@PKM+@PStrah*@PKM+@PServ*@PKM+@PFuel*@PKM+@PDrv*@PKM+@PLog*@PKM+@POth*@PKM))/@PKM as varchar(20))+',
                                              ExpencePlanFact_'+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'='+cast((@FCost-(@PAmort*@FKM+@PStrah*@FKM+@PServ*@FKM+@PFuel*@FKM+@PDrv*@FKM+@PLog*@FKM+@POth*@FKM))/@FKM as varchar(20))+',
                                              ExpenceFact_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'='+cast((@FCost-(@FAmort+@FStrah+@FServ+@FFuel+@FDrv+@FDrv1+@FDrv2+@FLog+@FOth+@FOth1))/@FKM as varchar(20))+',
                                              ExpAbsLambda_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'='+cast((@FCost-(@FAmort+@FStrah+@FServ+@FFuel+@FDrv+@FDrv1+@FDrv2+@FLog+@FOth+@FOth1)-(@FCost-(@PAmort*@FKM+@PStrah*@FKM+@PServ*@FKM+@PFuel*@FKM+@PDrv*@FKM+@PLog*@FKM+@POth*@FKM)))/@FKM as varchar(20))+',
                                              ExpOtnLambda_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'='+cast(@tmp/@FKM as varchar(20))+' 
                      where VehID='+cast(@vID as varchar(10))+' and ExpID=13'
            exec(@sql)
            
            fetch next from VehCursor into @vID, @pID
          end
          
          close VehCursor
          deallocate VehCursor
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    
          set @sql=''
          set @sql='update #tmpPayBack set 	ExpencePlan_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'=(select sum(pb.ExpencePlan_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+') from #tmpPayBack pb where pb.ExpID=0),
                                            ExpencePlanFact_'+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'=(select sum(pb.ExpencePlanFact_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+') from #tmpPayBack pb where pb.ExpID=0),
                                            ExpenceFact_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'=(select sum(pb.ExpenceFact_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+') from #tmpPayBack pb where pb.ExpID=0),
                                            ExpAbsLambda_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'=(select sum(pb.ExpAbsLambda_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+') from #tmpPayBack pb where pb.ExpID=0),
                                            ExpOtnLambda_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'=(select sum(pb.ExpOtnLambda_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+') from #tmpPayBack pb where pb.ExpID=0)
                    where VehID=-1 and ExpID=-1'
          exec(@sql)   
          --#
          set @sql=''
          set @sql='update #tmpPayBack set 	ExpencePlan_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'=(select sum(pb.ExpencePlan_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+') from #tmpPayBack pb where pb.ExpID=1),
                                            ExpencePlanFact_'+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'=(select sum(pb.ExpencePlanFact_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+') from #tmpPayBack pb where pb.ExpID=1),
                                            ExpenceFact_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'=(select sum(pb.ExpenceFact_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+') from #tmpPayBack pb where pb.ExpID=1),
                                            ExpAbsLambda_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'=(select sum(pb.ExpAbsLambda_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+') from #tmpPayBack pb where pb.ExpID=1),
                                            ExpOtnLambda_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'=(select sum(pb.ExpOtnLambda_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+') from #tmpPayBack pb where pb.ExpID=1)
                    where VehID=-1 and ExpID=-2'
          exec(@sql)
          
          set @sql=''
          set @sql='update #tmpPayBack set 	ExpencePlan_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'=(select sum(pb.ExpencePlan_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+') from #tmpPayBack pb where pb.ExpID=2),
                                            ExpencePlanFact_'+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'=(select sum(pb.ExpencePlanFact_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+') from #tmpPayBack pb where pb.ExpID=2),
                                            ExpenceFact_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'=(select sum(pb.ExpenceFact_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+') from #tmpPayBack pb where pb.ExpID=2),
                                            ExpAbsLambda_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'=(select sum(pb.ExpAbsLambda_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+') from #tmpPayBack pb where pb.ExpID=2),
                                            ExpOtnLambda_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'=(select sum(pb.ExpOtnLambda_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+') from #tmpPayBack pb where pb.ExpID=2)
                    where VehID=-1 and ExpID=-3'
          exec(@sql)
          
          set @sql=''
          set @sql='update #tmpPayBack set 	ExpencePlan_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'=(select sum(pb.ExpencePlan_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+') from #tmpPayBack pb where pb.ExpID=3),
                                            ExpencePlanFact_'+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'=(select sum(pb.ExpencePlanFact_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+') from #tmpPayBack pb where pb.ExpID=3),
                                            ExpenceFact_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'=(select sum(pb.ExpenceFact_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+') from #tmpPayBack pb where pb.ExpID=3),
                                            ExpAbsLambda_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'=(select sum(pb.ExpAbsLambda_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+') from #tmpPayBack pb where pb.ExpID=3),
                                            ExpOtnLambda_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'=(select sum(pb.ExpOtnLambda_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+') from #tmpPayBack pb where pb.ExpID=3)
                    where VehID=-1 and ExpID=-4'
          exec(@sql)
          
          set @sql=''
          set @sql='update #tmpPayBack set 	ExpencePlan_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'=(select sum(pb.ExpencePlan_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+') from #tmpPayBack pb where pb.ExpID=4),
                                            ExpencePlanFact_'+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'=(select sum(pb.ExpencePlanFact_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+') from #tmpPayBack pb where pb.ExpID=4),
                                            ExpenceFact_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'=(select sum(pb.ExpenceFact_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+') from #tmpPayBack pb where pb.ExpID=4),
                                            ExpAbsLambda_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'=(select sum(pb.ExpAbsLambda_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+') from #tmpPayBack pb where pb.ExpID=4),
                                            ExpOtnLambda_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'=(select sum(pb.ExpOtnLambda_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+') from #tmpPayBack pb where pb.ExpID=4)
                    where VehID=-1 and ExpID=-5'
          exec(@sql)
          
          set @sql=''
          set @sql='update #tmpPayBack set 	ExpencePlan_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'=(select sum(pb.ExpencePlan_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+') from #tmpPayBack pb where pb.ExpID=5),
                                            ExpencePlanFact_'+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'=(select sum(pb.ExpencePlanFact_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+') from #tmpPayBack pb where pb.ExpID=5),
                                            ExpenceFact_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'=(select sum(pb.ExpenceFact_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+') from #tmpPayBack pb where pb.ExpID=5),
                                            ExpAbsLambda_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'=(select sum(pb.ExpAbsLambda_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+') from #tmpPayBack pb where pb.ExpID=5),
                                            ExpOtnLambda_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'=(select sum(pb.ExpOtnLambda_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+') from #tmpPayBack pb where pb.ExpID=5)
                    where VehID=-1 and ExpID=-6'
          exec(@sql)
          
          set @sql=''
          set @sql='update #tmpPayBack set 	ExpencePlan_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'=(select sum(pb.ExpencePlan_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+') from #tmpPayBack pb where pb.ExpID=6),
                                            ExpencePlanFact_'+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'=(select sum(pb.ExpencePlanFact_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+') from #tmpPayBack pb where pb.ExpID=6),
                                            ExpenceFact_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'=(select sum(pb.ExpenceFact_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+') from #tmpPayBack pb where pb.ExpID=6),
                                            ExpAbsLambda_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'=(select sum(pb.ExpAbsLambda_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+') from #tmpPayBack pb where pb.ExpID=6),
                                            ExpOtnLambda_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'=(select sum(pb.ExpOtnLambda_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+') from #tmpPayBack pb where pb.ExpID=6)
                    where VehID=-1 and ExpID=-7'
          exec(@sql)
          
          set @sql=''
          set @sql='update #tmpPayBack set 	ExpencePlan_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'=(select sum(pb.ExpencePlan_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+') from #tmpPayBack pb where pb.ExpID=7),
                                            ExpencePlanFact_'+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'=(select sum(pb.ExpencePlanFact_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+') from #tmpPayBack pb where pb.ExpID=7),
                                            ExpenceFact_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'=(select sum(pb.ExpenceFact_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+') from #tmpPayBack pb where pb.ExpID=7),
                                            ExpAbsLambda_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'=(select sum(pb.ExpAbsLambda_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+') from #tmpPayBack pb where pb.ExpID=7),
                                            ExpOtnLambda_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'=(select sum(pb.ExpOtnLambda_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+') from #tmpPayBack pb where pb.ExpID=7)
                    where VehID=-1 and ExpID=-8'
          exec(@sql)
          --#
          set @sql=''
          set @sql='update #tmpPayBack set 	ExpencePlan_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'=(select sum(pb.ExpencePlan_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+') from #tmpPayBack pb where pb.ExpID=8),
                                            ExpencePlanFact_'+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'=(select sum(pb.ExpencePlanFact_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+') from #tmpPayBack pb where pb.ExpID=8),
                                            ExpenceFact_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'=(select sum(pb.ExpenceFact_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+') from #tmpPayBack pb where pb.ExpID=8),
                                            ExpAbsLambda_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'=(select sum(pb.ExpAbsLambda_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+') from #tmpPayBack pb where pb.ExpID=8),
                                            ExpOtnLambda_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'=(select sum(pb.ExpOtnLambda_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+') from #tmpPayBack pb where pb.ExpID=8)
                    where VehID=-1 and ExpID=-9'
          exec(@sql)    
          
          set @sql=''
          set @sql='update #tmpPayBack set 	ExpencePlan_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'=(select sum(pb.ExpencePlan_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+') from #tmpPayBack pb where pb.ExpID=9),
                                            ExpencePlanFact_'+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'=(select sum(pb.ExpencePlanFact_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+') from #tmpPayBack pb where pb.ExpID=9),
                                            ExpenceFact_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'=(select sum(pb.ExpenceFact_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+') from #tmpPayBack pb where pb.ExpID=9),
                                            ExpAbsLambda_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'=(select sum(pb.ExpAbsLambda_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+') from #tmpPayBack pb where pb.ExpID=9),
                                            ExpOtnLambda_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'=(select sum(pb.ExpOtnLambda_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+') from #tmpPayBack pb where pb.ExpID=9)
                    where VehID=-1 and ExpID=-10'
          exec(@sql)	
          
          set @sql=''
          set @sql='update #tmpPayBack set 	ExpencePlan_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'=(select sum(pb.ExpencePlan_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+') from #tmpPayBack pb where pb.ExpID=10),
                                            ExpencePlanFact_'+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'=(select sum(pb.ExpencePlanFact_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+') from #tmpPayBack pb where pb.ExpID=10),
                                            ExpenceFact_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'=(select sum(pb.ExpenceFact_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+') from #tmpPayBack pb where pb.ExpID=10),
                                            ExpAbsLambda_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'=(select sum(pb.ExpAbsLambda_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+') from #tmpPayBack pb where pb.ExpID=10),
                                            ExpOtnLambda_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'=(select sum(pb.ExpOtnLambda_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+') from #tmpPayBack pb where pb.ExpID=10)
                    where VehID=-1 and ExpID=-11'
          exec(@sql)
          
          set @sql=''
          set @sql='update #tmpPayBack set 	ExpencePlan_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'=(select sum(pb.ExpencePlan_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+') from #tmpPayBack pb where pb.ExpID=11),
                                            ExpencePlanFact_'+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'=(select sum(pb.ExpencePlanFact_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+') from #tmpPayBack pb where pb.ExpID=11),
                                            ExpenceFact_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'=(select sum(pb.ExpenceFact_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+') from #tmpPayBack pb where pb.ExpID=11),
                                            ExpAbsLambda_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'=(select sum(pb.ExpAbsLambda_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+') from #tmpPayBack pb where pb.ExpID=11),
                                            ExpOtnLambda_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'=(select sum(pb.ExpOtnLambda_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+') from #tmpPayBack pb where pb.ExpID=11)
                    where VehID=-1 and ExpID=-12'
          exec(@sql)
          
          set @sql=''
          set @sql='update #tmpPayBack set 	ExpencePlan_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'=(select sum(pb.ExpencePlan_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+') from #tmpPayBack pb where pb.ExpID=12),
                                            ExpencePlanFact_'+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'=(select sum(pb.ExpencePlanFact_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+') from #tmpPayBack pb where pb.ExpID=12),
                                            ExpenceFact_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'=(select sum(pb.ExpenceFact_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+') from #tmpPayBack pb where pb.ExpID=12),
                                            ExpAbsLambda_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'=(select sum(pb.ExpAbsLambda_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+') from #tmpPayBack pb where pb.ExpID=12),
                                            ExpOtnLambda_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'=(select sum(pb.ExpOtnLambda_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+') from #tmpPayBack pb where pb.ExpID=12)
                    where VehID=-1 and ExpID=-13'
          exec(@sql)
          
          set @sql=''
          set @sql='update #tmpPayBack set 	ExpencePlan_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'=(select sum(pb.ExpencePlan_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+') from #tmpPayBack pb where pb.ExpID=13),
                                            ExpencePlanFact_'+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'=(select sum(pb.ExpencePlanFact_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+') from #tmpPayBack pb where pb.ExpID=13),
                                            ExpenceFact_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'=(select sum(pb.ExpenceFact_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+') from #tmpPayBack pb where pb.ExpID=13),
                                            ExpAbsLambda_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'=(select sum(pb.ExpAbsLambda_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+') from #tmpPayBack pb where pb.ExpID=13),
                                            ExpOtnLambda_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+'=(select sum(pb.ExpOtnLambda_'		+cast(@curY as varchar(4))+'_'+cast(@curM as varchar(2))+') from #tmpPayBack pb where pb.ExpID=13)
                    where VehID=-1 and ExpID=-14'
          exec(@sql)
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@          
          fetch next from curMonth into @curM
				end      
      	
        close curMonth
      	deallocate curMonth
      
      	fetch next from curYear into @curY
    	end
    
    close curYear
    deallocate curYear
  end     
  
  alter table #tmpPayBack add NewOrder int 
  
  update #tmpPayBack set NewOrder=case 
  									  when ExpID in (0,-1) then 1
                                      when ExpID in (1,-2) then 2
                                      when ExpID in (2,-3) then 3
                                      when ExpID in (3,-4) then 4
                                      when ExpID in (4,-5) then 5
                                      when ExpID in (5,-6) then 6 
                                      when ExpID in (6,-7) then 7 
                                      when ExpID in (7,-8) then 8
                                      when ExpID in (8,-9) then 9
                                      when ExpID in (9,-10) then 11
                                      when ExpID in (10,-11) then 13
                                      when ExpID in (11,-12) then 10
                                      when ExpID in (12,-13) then 12
                                      when ExpID in (13,-14) then 14
                                 end
                                 
  update #tmpPayBack set ExpID=NewOrder 
  
  update #tmpPayBack set VehN=9999 where VehN>900
  
  select * from #tmpPayBack
  order by VehN, ExpID
END