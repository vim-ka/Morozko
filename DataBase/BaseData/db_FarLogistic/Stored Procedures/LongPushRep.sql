CREATE PROCEDURE [db_FarLogistic].LongPushRep
@m varchar(max),
@y varchar(max),
@v int 
AS
begin
  declare @marsh int
  declare @col1 varchar(12)
  declare @col2 varchar(12)
  declare @col3 varchar(12)
  declare @col4 varchar(12)
  declare @col5 varchar(12)
  declare @t int
  declare @marshcnt int
  declare @PKM int
  declare @FKM int
  declare @dt_end datetime
  declare @dt_beg datetime
  declare @sql varchar(max)
  declare @tmp varchar(max)
  declare @tmpVal money

  declare @PAmort money
  declare @PStrah money
  declare @PServ money
  declare @PFuel money
  declare @PDrv money
  declare @PLog money
  declare @POth money
  declare @PCost money
  
  declare @PFAmort money
  declare @PFStrah money
  declare @PFServ money
  declare @PFFuel money
  declare @PFDrv money
  declare @PFLog money
  declare @PFOth money
  declare @PFCost money

  declare @FAmort money
  declare @FStrah money
  declare @FServ money
  declare @FFuel money
  declare @FDrv money
  declare @FLog money
  declare @FOth money
  declare @FOth1 money
  declare @FCost money
  
  declare @FSumAmort money
  declare @FSumStrah money
  declare @FSumServ money
  declare @FSumFuel money
  declare @FSumDrv money
  declare @FSumLog money
  declare @FSumOth money
  declare @FSumOth1 money
  declare @FSumCost money
  
  declare @PFSumAmort money
  declare @PFSumStrah money
  declare @PFSumServ money
  declare @PFSumFuel money
  declare @PFSumDrv money
  declare @PFSumLog money
  declare @PFSumOth money
  declare @PFSumCost money
  
  declare @PSumAmort money
  declare @PSumStrah money
  declare @PSumServ money
  declare @PSumFuel money
  declare @PSumDrv money
  declare @PSumLog money
  declare @PSumOth money
  declare @PSumCost money
  
  declare @PSumKM int
  declare @FSumKM int
  
  create table #tmpCalc (i int IDENTITY(1, 1) NOT NULL, name varchar(30), id int)
  
  insert into #tmpCalc(name,id)
  select a.ExpenceName, a.id 
  from (	select e.ExpenceListID id, e.ExpenceName 
          from db_FarLogistic.dlExpenceList e
          union all
          select 0, 'КМ'
          union all
          select 8, 'Сумма расходов'
          union all
          select 9, 'Сумма доходов'
          union all
          select 10, 'Прибыль') a
  order by a.id
  

  select @t=isnull(v.dlVehiclesID,-1) from db_FarLogistic.dlVehicles v where v.dlMainVehID=@v

  select @marshcnt=count(m.dlMarshID)
  from db_FarLogistic.dlMarsh m
  left join db_FarLogistic.dlTmpMarshCost tm on tm.MarshID=m.dlMarshID and tm.WorkID=0
  where m.IDdlMarshStatus=4 and 
        m.IDdlVehicles=@v and 
        month(m.dt_end_fact) in (select * from db_FarLogistic.String_to_Int(@m)) and 
        year(m.dt_end_fact) in (select * from db_FarLogistic.String_to_Int(@y))
        
  select @FSumAmort=isnull(sum(ve.ExpenceSum),0)
  from db_FarLogistic.dlVehicleExpence ve
  where ve.dlVehicleID in (select @v union all select @t) and 
        month(ve.ExpenceDate) in (select * from db_FarLogistic.String_to_Int(@m)) and 
        year(ve.ExpenceDate) in (select * from db_FarLogistic.String_to_Int(@y)) and 
        ve.ExpenceListID=1
  
  set @FAmort=@FSumAmort / @marshcnt
        
  select @FSumStrah=isnull(sum(ve.ExpenceSum),0)
  from db_FarLogistic.dlVehicleExpence ve
  where ve.dlVehicleID in (select @v union all select @t) and 
        month(ve.ExpenceDate) in (select * from db_FarLogistic.String_to_Int(@m)) and 
        year(ve.ExpenceDate) in (select * from db_FarLogistic.String_to_Int(@y)) and 
        ve.ExpenceListID=2
        
  set @FStrah=@FSumStrah / @marshcnt

  select @FSumServ=isnull(sum(ve.ExpenceSum),0)
  from db_FarLogistic.dlVehicleExpence ve
  where ve.dlVehicleID in (select @v union all select @t) and 
        month(ve.ExpenceDate) in (select * from db_FarLogistic.String_to_Int(@m)) and 
        year(ve.ExpenceDate) in (select * from db_FarLogistic.String_to_Int(@y)) and 
        ve.ExpenceListID=3
        
  set @FServ=@FSumServ / @marshcnt
        
  select @FSumLog=isnull(sum(ve.ExpenceSum),0)
  from db_FarLogistic.dlVehicleExpence ve
  where ve.dlVehicleID in (select @v union all select @t) and 
        month(ve.ExpenceDate) in (select * from db_FarLogistic.String_to_Int(@m)) and 
        year(ve.ExpenceDate) in (select * from db_FarLogistic.String_to_Int(@y)) and 
        ve.ExpenceListID=6
        
  set @FLog=@FSumLog / @marshcnt
  
  select @FSumFuel=isnull(sum(f.summa),0)
  from FFuelNew f
  left join FCards c on c.CardNom=f.cardnum
  where c.fcID in (select c.IDCard from db_FarLogistic.dlFuelCard c where c.IDVeh=@v) and 
  			month(f.nd) in (select * from db_FarLogistic.String_to_Int(@m)) and 
        year(f.nd) in (select * from db_FarLogistic.String_to_Int(@y))
        
	set @FFuel=@FSumFuel / @marshcnt
  
  select @FSumOth1=isnull(sum(ve.ExpenceSum),0)
  from db_FarLogistic.dlVehicleExpence ve
  where ve.dlVehicleID in (select @v union all select @t) and 
        month(ve.ExpenceDate) in (select * from db_FarLogistic.String_to_Int(@m)) and 
        year(ve.ExpenceDate) in (select * from db_FarLogistic.String_to_Int(@y)) and 
        ve.ExpenceListID=7
        
  set @FOth1=@FSumOth1 / @marshcnt
        
  declare cur_mar cursor for
  select m.dlMarshID, tm.KM, m.odo_end_fact-m.odo_beg_fact, m.dt_beg_fact, m.dt_end_fact
  from db_FarLogistic.dlMarsh m
  left join db_FarLogistic.dlTmpMarshCost tm on tm.MarshID=m.dlMarshID and tm.WorkID=0
  where m.IDdlMarshStatus=4 and 
        m.IDdlVehicles=@v and 
        month(m.dt_end_fact) in (select * from db_FarLogistic.String_to_Int(@m)) and 
        year(m.dt_end_fact) in (select * from db_FarLogistic.String_to_Int(@y))
  order by m.dt_end_fact

  open cur_mar 

  fetch next from cur_mar into @marsh, @PKM, @FKM, @dt_beg, @dt_end
	
  set @FSumKM=0
  set @PSumKM=0
  set @FSumCost=0
  set @FSumOth=0
  set @PSumAmort=0
  set @PSumCost=0
  set @PSumDrv=0
  set @PSumFuel=0
  set @PSumLog=0
  set @PSumOth=0
  set @PSumServ=0
  set @PSumStrah=0
  set @PFSumAmort=0
  set @PFSumCost=0
  set @PFSumDrv=0
  set @PFSumFuel=0
  set @PFSumLog=0
  set @PFSumOth=0
  set @PFSumServ=0
  set @PFSumStrah=0
  
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
    where e.IDVehTYpe in (	select m.IDdlVehicles from db_FarLogistic.dlMarsh m 
                            left join db_FarLogistic.dlVehicles v on v.dlVehiclesID=m.IDdlVehicles
                            where m.dlMarshID=@marsh
                            union all
                            select m.idTrailer from db_FarLogistic.dlMarsh m 
                            left join db_FarLogistic.dlVehicles v on v.dlVehiclesID=m.IDdlVehicles
                            where m.dlMarshID=@marsh)
    
    select @FDrv=isnull(sum(d.KM*q.KMPrice),0) 
    from db_FarLogistic.dlPairDistanceDrv d 
    left join db_FarLogistic.dlJorneyInfo j on j.MarshID=d.MarshID
    left join db_FarLogistic.dlJorney jj on jj.IDReq=j.IDReq and jj.NumbForRace=d.FinishPointNumber
    left join db_FarLogistic.dlDriverQuality q on q.IDQuality=jj.DrvWorkQuality
    where d.MarshID=@marsh
    
    select @FDrv=@FDrv+sum(isnull(s.ChargeSum,0))
    from db_FarLogistic.dlSalarySheet s where s.MarshID=@marsh
    
    select @FCost=sum(b.ForPay)
    from db_FarLogistic.dlGroupBill b 
    where b.MarshID=@marsh
    
    select @FOth=isnull(sum(me.Cost),0)
  	from db_FarLogistic.dlMarshExpence me
  	where me.MarshID=@marsh
        
    set @col1='p_'+cast(@marsh as varchar(10))
    set @col4='pf_'+cast(@marsh as varchar(10))
    set @col2='f_'+cast(@marsh as varchar(10))
    set @col3='l_'+cast(@marsh as varchar(10))
    set @col5='ol_'+cast(@marsh as varchar(10))
    
    set @sql=''
    set @sql='alter table #tmpCalc add '+@col1+' money'
    exec(@sql)
    
    set @sql=''
    set @sql='alter table #tmpCalc add '+@col4+' money'
    exec(@sql)
    
    set @sql=''
    set @sql='alter table #tmpCalc add '+@col2+' money'
    exec(@sql)
    
    set @sql=''
    set @sql='alter table #tmpCalc add '+@col3+' money'
    exec(@sql)
    
    set @sql=''
    set @sql='alter table #tmpCalc add '+@col5+' money'
    exec(@sql)
    
    if @FKM=0
    begin
    	set @tmpVal=0
    end
    else
    begin
    	set @tmpVal=cast(@FKM-@PKM as money)/@FKM
    end
    
    set @sql=''
    set @sql='update #tmpCalc set p_'+cast(@marsh as varchar(10))+'='+cast(@PKM as varchar(20))+
    														',f_'+cast(@marsh as varchar(10))+'='+cast(@FKM as varchar(20))+
                                ',pf_'+cast(@marsh as varchar(10))+'='+cast(@FKM as varchar(20))+
                                ',l_'+cast(@marsh as varchar(10))+'='+cast(@FKM-@PKM as varchar(20))+
                                ',ol_'+cast(@marsh as varchar(10))+'='+cast(@tmpVal as varchar(20))+ 
    				 ' where id=0'
    exec(@sql)
    
    if @FAmort=0
    begin
    	set @tmpVal=0
    end
    else
    begin
    	set @tmpVal=(@FAmort-@PAmort*@FKM)/@FAmort
    end
    
    set @sql=''
    set @sql='update #tmpCalc set p_'+cast(@marsh as varchar(10))+'='+cast(@PAmort*@PKM as varchar(20))+
    														',f_'+cast(@marsh as varchar(10))+'='+cast(@FAmort as varchar(20))+
                                ',pf_'+cast(@marsh as varchar(10))+'='+cast(@PAmort*@FKM as varchar(20))+
                                ',l_'+cast(@marsh as varchar(10))+'='+cast(@FAmort-@PAmort*@FKM as varchar(20))+
                                ',ol_'+cast(@marsh as varchar(10))+'='+cast(@tmpVal as varchar(20))+ 
    				 ' where id=1'
    exec(@sql)
    
    if @FStrah=0
    begin
    	set @tmpVal=0
    end
    else
    begin
    	set @tmpVal=(@FStrah-@PStrah*@FKM)/@FStrah
    end
    
    set @sql=''
    set @sql='update #tmpCalc set p_'+cast(@marsh as varchar(10))+'='+cast(@PStrah*@PKM as varchar(20))+
    														',f_'+cast(@marsh as varchar(10))+'='+cast(@FStrah as varchar(20))+
                                ',pf_'+cast(@marsh as varchar(10))+'='+cast(@PStrah*@FKM as varchar(20))+
                                ',l_'+cast(@marsh as varchar(10))+'='+cast(@FStrah-@PStrah*@FKM as varchar(20))+
                                ',ol_'+cast(@marsh as varchar(10))+'='+cast(@tmpVal as varchar(20))+ 
    				 ' where id=2'
    exec(@sql)
    
    if @FServ=0
    begin
    	set @tmpVal=0
    end
    else
    begin
    	set @tmpVal=(@FServ-@PServ*@FKM)/@FServ
    end
    
    set @sql=''
    set @sql='update #tmpCalc set p_'+cast(@marsh as varchar(10))+'='+cast(@PServ*@PKM as varchar(20))+
    														',f_'+cast(@marsh as varchar(10))+'='+cast(@FServ as varchar(20))+
                                ',pf_'+cast(@marsh as varchar(10))+'='+cast(@PServ*@FKM as varchar(20))+
                                ',l_'+cast(@marsh as varchar(10))+'='+cast(@FServ-@PServ*@FKM as varchar(20))+
                                ',ol_'+cast(@marsh as varchar(10))+'='+cast(@tmpVal as varchar(20))+  
    				 ' where id=3'
    exec(@sql)
    
    if @FFuel=0
    begin
    	set @tmpVal=0
    end
    else
    begin
    	set @tmpVal=(@FFuel-@PFuel*@FKM)/@FFuel
    end
    
    set @sql=''
    set @sql='update #tmpCalc set p_'+cast(@marsh as varchar(10))+'='+cast(@PFuel*@PKM as varchar(20))+
    														',f_'+cast(@marsh as varchar(10))+'='+cast(@FFuel as varchar(20))+
                                ',pf_'+cast(@marsh as varchar(10))+'='+cast(@PFuel*@FKM as varchar(20))+
                                ',l_'+cast(@marsh as varchar(10))+'='+cast(@FFuel-@PFuel*@FKM as varchar(20))+
                                ',ol_'+cast(@marsh as varchar(10))+'='+cast(@tmpVal as varchar(20))+  
    				 ' where id=4'
    exec(@sql)    
    
    if @FDrv=0
    begin
    	set @tmpVal=0
    end
    else
    begin
    	set @tmpVal=(@FDrv-@PDrv*@FKM)/@FDrv
    end
    
    set @sql=''
    set @sql='update #tmpCalc set p_'+cast(@marsh as varchar(10))+'='+cast(@PDrv*@PKM as varchar(20))+
    														',f_'+cast(@marsh as varchar(10))+'='+cast(@FDrv as varchar(20))+
                                ',pf_'+cast(@marsh as varchar(10))+'='+cast(@PDrv*@PKM as varchar(20))+
                                ',l_'+cast(@marsh as varchar(10))+'='+cast(@FDrv-@PDrv*@FKM as varchar(20))+
                                ',ol_'+cast(@marsh as varchar(10))+'='+cast(@tmpVal as varchar(20))+ 
    				 ' where id=5'
    exec(@sql)
    
    if @FLog=0
    begin
    	set @tmpVal=0
    end
    else
    begin
    	set @tmpVal=(@FLog-@PLog*@FKM)/@FLog
    end
    
    set @sql=''
    set @sql='update #tmpCalc set p_'+cast(@marsh as varchar(10))+'='+cast(@PLog*@PKM as varchar(20))+
    														',f_'+cast(@marsh as varchar(10))+'='+cast(@FLog as varchar(20))+
                                ',pf_'+cast(@marsh as varchar(10))+'='+cast(@PLog*@FKM as varchar(20))+
                                ',l_'+cast(@marsh as varchar(10))+'='+cast(@FLog-@PLog*@FKM as varchar(20))+ 
                                ',ol_'+cast(@marsh as varchar(10))+'='+cast(@tmpVal as varchar(20))+
    				 ' where id=6'
    exec(@sql)
    
    if @FOth=0
    begin
    	set @tmpVal=0
    end
    else
    begin
    	set @tmpVal=(@FOth+@FOth1-@POth*@FKM)/(@FOth+@FOth1)
    end
    
    set @sql=''
    set @sql='update #tmpCalc set p_'+cast(@marsh as varchar(10))+'='+cast(@POth*@PKM as varchar(20))+
    														',f_'+cast(@marsh as varchar(10))+'='+cast(@FOth+@FOth1 as varchar(20))+
                                ',pf_'+cast(@marsh as varchar(10))+'='+cast(@POth*@FKM as varchar(20))+
                                ',l_'+cast(@marsh as varchar(10))+'='+cast(@FOth+@FOth1-@POth*@FKM as varchar(20))+
                                ',ol_'+cast(@marsh as varchar(10))+'='+cast(@tmpVal as varchar(20))+  
    				 ' where id=7'
    exec(@sql)
    
    if @FAmort+@FStrah+@FServ+@FFuel+@FDrv+@FLog+@FOth+@FOth1=0
    begin
    	set @tmpVal=0
    end
    else
    begin
    	set @tmpVal=(@FAmort+@FStrah+@FServ+@FFuel+@FDrv+@FLog+@FOth+@FOth1-(@PAmort+@PStrah+@PServ+@PFuel+@PDrv+@PLog+@POth)*@FKM)/(@FAmort+@FStrah+@FServ+@FFuel+@FDrv+@FLog+@FOth+@FOth1)
    end
    
    set @sql=''
    set @sql='update #tmpCalc set p_'+cast(@marsh as varchar(10))+'='+cast(@PAmort*@PKM+@PStrah*@PKM+@PServ*@PKM+@PFuel*@PKM+@PDrv*@PKM+@PLog*@PKM+@POth*@PKM as varchar(20))+
    														',f_'+cast(@marsh as varchar(10))+'='+cast(@FAmort+@FStrah+@FServ+@FFuel+@FDrv+@FLog+@FOth+@FOth1 as varchar(20))+
                                ',pf_'+cast(@marsh as varchar(10))+'='+cast(@PAmort*@FKM+@PStrah*@FKM+@PServ*@FKM+@PFuel*@FKM+@PDrv*@FKM+@PLog*@FKM+@POth*@FKM as varchar(20))+
                                ',l_'+cast(@marsh as varchar(10))+'='+cast((@FAmort+@FStrah+@FServ+@FFuel+@FDrv+@FLog+@FOth+@FOth1)-(@PAmort*@FKM+@PStrah*@FKM+@PServ*@FKM+@PFuel*@FKM+@PDrv*@FKM+@PLog*@FKM+@POth*@FKM) as varchar(20))+
                                ',ol_'+cast(@marsh as varchar(10))+'='+cast(@tmpVal as varchar(20))+ 
    				 ' where id=8'
    exec(@sql)
    
    set @sql=''
    set @sql='update #tmpCalc set p_'+cast(@marsh as varchar(10))+'='+cast(@PCost*@PKM as varchar(20))+
    														',f_'+cast(@marsh as varchar(10))+'='+cast(@FCost as varchar(20))+
                                ',pf_'+cast(@marsh as varchar(10))+'='+cast(@FCost as varchar(20))+
                                ',l_'+cast(@marsh as varchar(10))+'='+cast(@FCost-@FCost as varchar(20))+
                                ',ol_'+cast(@marsh as varchar(10))+'='+cast((@FCost-@FCost)/@FCost as varchar(20))+ 
    				 ' where id=9'
    exec(@sql)
    
    set @sql=''
    set @sql='update #tmpCalc set p_'+cast(@marsh as varchar(10))+'='+cast(@PCost*@PKM-(@PAmort*@PKM+@PStrah*@PKM+@PServ*@PKM+@PFuel*@PKM+@PDrv*@PKM+@PLog*@PKM+@POth*@PKM) as varchar(20))+
    														',f_'+cast(@marsh as varchar(10))+'='+cast(@FCost-(@FAmort+@FStrah+@FServ+@FFuel+@FDrv+@FLog+@FOth+@FOth1) as varchar(20))+
                                ',pf_'+cast(@marsh as varchar(10))+'='+cast(@FCost-(@PAmort*@FKM+@PStrah*@FKM+@PServ*@FKM+@PFuel*@FKM+@PDrv*@FKM+@PLog*@FKM+@POth*@FKM) as varchar(20))+
                                ',l_'+cast(@marsh as varchar(10))+'='+cast((@FCost-(@FAmort+@FStrah+@FServ+@FFuel+@FDrv+@FLog+@FOth+@FOth1))-(@FCost-(@PAmort*@FKM+@PStrah*@FKM+@PServ*@FKM+@PFuel*@FKM+@PDrv*@FKM+@PLog*@FKM+@POth*@FKM)) as varchar(20))+
                                ',ol_'+cast(@marsh as varchar(10))+'='+cast(((@FCost-(@FAmort+@FStrah+@FServ+@FFuel+@FDrv+@FLog+@FOth+@FOth1))-(@FCost-(@PAmort*@FKM+@PStrah*@FKM+@PServ*@FKM+@PFuel*@FKM+@PDrv*@FKM+@PLog*@FKM+@POth*@FKM)))/((@FCost-(@FAmort+@FStrah+@FServ+@FFuel+@FDrv+@FLog+@FOth+@FOth1))) as varchar(20))+ 
    				 ' where id=10'
    exec(@sql)
    
    set @FSumKM=@FSumKM+@FKM
    set @PSumKM=@PSumKM+@PKM
    set @FSumCost=@FSumCost+@FCost
    set @FSumOth=@FSumOth+@FOth
    set @PSumAmort=@PSumAmort+@PAmort
    set @PSumCost=@PSumCost+@PCost
    set @PSumDrv=@PSumDrv+@PDrv
    set @PSumFuel=@PSumFuel+@PFuel
    set @PSumLog=@PSumLog+@PLog
    set @PSumOth=@PSumOth+@POth
    set @PSumServ=@PSumServ+@PServ
    set @PSumStrah=@PSumStrah+@PStrah
    
    fetch next from cur_mar into @marsh, @PKM, @FKM, @dt_beg, @dt_end
  end

  close cur_mar
  deallocate cur_mar
  
  set @col1='p_SUM'
  set @col2='f_SUM'
  --set @col4='pf_SUM'
  set @col3='l_SUM'
  --set @col5='ol_SUM'
    
  set @sql=''
  set @sql='alter table #tmpCalc add '+@col1+' money'
  exec(@sql)
    
  set @sql=''
  set @sql='alter table #tmpCalc add '+@col2+' money'
  exec(@sql)
  
  --set @sql=''
  --set @sql='alter table #tmpCalc add '+@col4+' money'
  --exec(@sql)
    
  set @sql=''
  set @sql='alter table #tmpCalc add '+@col3+' money'
  exec(@sql)
  
  --set @sql=''
  --set @sql='alter table #tmpCalc add '+@col5+' money'
  --exec(@sql)
  
  set @sql=''
  set @sql='update #tmpCalc set p_SUM'+'='+cast(@PSumKM as varchar(20))+
                              ',f_SUM'+'='+cast(@FSumKM as varchar(20))+
                              ',l_SUM'+'='+cast(@PSumKM-@FSumKM as varchar(20))+ 
           ' where id=0'
  exec(@sql)
  
  set @sql=''
  set @sql='update #tmpCalc set p_SUM'+'='+cast(@PSumAmort as varchar(20))+
                              ',f_SUM'+'='+cast(@FSumAmort as varchar(20))+
                              ',l_SUM'+'='+cast(@PSumAmort-@FSumAmort as varchar(20))+ 
           ' where id=1'
  exec(@sql)
  
  set @sql=''
  set @sql='update #tmpCalc set p_SUM'+'='+cast(@PSumStrah as varchar(20))+
                              ',f_SUM'+'='+cast(@FSumStrah as varchar(20))+
                              ',l_SUM'+'='+cast(@PSumStrah-@FSumStrah as varchar(20))+ 
           ' where id=2'
  exec(@sql)
  
  set @sql=''
  set @sql='update #tmpCalc set p_SUM'+'='+cast(@PSumServ as varchar(20))+
                              ',f_SUM'+'='+cast(@FSumServ as varchar(20))+
                              ',l_SUM'+'='+cast(@PSumServ-@FSumServ as varchar(20))+ 
           ' where id=3'
  exec(@sql)
  
  set @sql=''
  set @sql='update #tmpCalc set p_SUM'+'='+cast(@PSumFuel as varchar(20))+
                              ',f_SUM'+'='+cast(@FSumFuel as varchar(20))+
                              ',l_SUM'+'='+cast(@PSumFuel-@FSumFuel as varchar(20))+ 
           ' where id=4'
  exec(@sql)
  
  set @sql=''
  set @sql='update #tmpCalc set p_SUM'+'='+cast(@PSumDrv as varchar(20))+
                              ',f_SUM'+'='+cast(@FSumDrv as varchar(20))+
                              ',l_SUM'+'='+cast(@PSumDrv-@FSumDrv as varchar(20))+ 
           ' where id=5'
  exec(@sql)
  
  set @sql=''
  set @sql='update #tmpCalc set p_SUM'+'='+cast(@PSumLog as varchar(20))+
                              ',f_SUM'+'='+cast(@FSumLog as varchar(20))+
                              ',l_SUM'+'='+cast(@PSumLog-@FSumLog as varchar(20))+ 
           ' where id=6'
  exec(@sql)
  
  set @sql=''
  set @sql='update #tmpCalc set p_SUM'+'='+cast(@PSumOth as varchar(20))+
                              ',f_SUM'+'='+cast(@FSumOth as varchar(20))+
                              ',l_SUM'+'='+cast(@PSumOth-@FSumOth as varchar(20))+ 
           ' where id=7'
  exec(@sql)
  
  set @sql=''
  set @sql='update #tmpCalc set p_SUM'+'='+cast(@PSumAmort+@PSumStrah+@PSumServ+@PSumFuel+@PSumDrv+@PSumLog+@PSumOth as varchar(20))+
                              ',f_SUM'+'='+cast(@FSumAmort+@FSumStrah+@FSumServ+@FSumFuel+@FSumDrv+@FSumLog+@FSumOth as varchar(20))+
                              ',l_SUM'+'='+cast((@PSumAmort+@PSumStrah+@PSumServ+@PSumFuel+@PSumDrv+@PSumLog+@PSumOth)-(@FSumAmort+@FSumStrah+@FSumServ+@FSumFuel+@FSumDrv+@FSumLog+@FSumOth) as varchar(20))+ 
           ' where id=8'
  exec(@sql)
  
  set @sql=''
  set @sql='update #tmpCalc set p_SUM'+'='+cast(@PSumCost as varchar(20))+
                              ',f_SUM'+'='+cast(@FSumCost as varchar(20))+
                              ',l_SUM'+'='+cast(@PSumCost-@FSumCost as varchar(20))+ 
           ' where id=9'
  exec(@sql)
  
  set @sql=''
  set @sql='update #tmpCalc set p_SUM'+'='+cast(@PSumCost-(@PSumAmort+@PSumStrah+@PSumServ+@PSumFuel+@PSumDrv+@PSumLog+@PSumOth) as varchar(20))+
                              ',f_SUM'+'='+cast(@FSumCost-(@FSumAmort+@FSumStrah+@FSumServ+@FSumFuel+@FSumDrv+@FSumLog+@FSumOth) as varchar(20))+
                              ',l_SUM'+'='+cast((@PSumCost-(@PSumAmort+@PSumStrah+@PSumServ+@PSumFuel+@PSumDrv+@PSumLog+@PSumOth))-(@FSumCost-(@FSumAmort+@FSumStrah+@FSumServ+@FSumFuel+@FSumDrv+@FSumLog+@FSumOth)) as varchar(20))+ 
           ' where id=10'
  exec(@sql)
  
  select * from #tmpCalc
end