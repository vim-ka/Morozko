CREATE PROCEDURE db_FarLogistic.FillStaticCharge
@dt1 datetime,
@dt2 datetime,
@VehID int
AS
BEGIN
declare @tranname varchar(20)
declare @erReg int
set @erReg=0
set @tranname='FillStaticCharge'
begin tran @tranname 	
	declare @MarshStart int
	declare @MarshEnd int
	
	set @dt1=case when @dt1 is null then (select min(m.date_creation) from db_FarLogistic.dlMarsh m) else @dt1 end
	if @@error<>0
	set @erReg=@erReg+1
	if (@erReg>0)	goto end_procedure
	
	set @dt2=case when @dt2 is null then (select max(m.date_creation) from db_FarLogistic.dlMarsh m) else @dt2 end
	if @@error<>0
	set @erReg=@erReg+2
	if (@erReg>0)	goto end_procedure
	
	select 	@MarshStart=right(year(@dt1),2)*100+month(@dt1),
					@MarshEnd=right(year(@dt2),2)*100+month(@dt2)
	if @@error<>0
	set @erReg=@erReg+4
	if (@erReg>0)	goto end_procedure
	
	delete from db_FarLogistic.dlStaticCharge 
	where db_FarLogistic.dlStaticCharge.[date]>=@MarshStart
				and db_FarLogistic.dlStaticCharge.[date]<=@MarshEnd
				and db_FarLogistic.dlStaticCharge.[VehID]>=@VehID
	if @@error<>0
	set @erReg=@erReg+8
	if (@erReg>0)	goto end_procedure
	
	insert into db_FarLogistic.dlStaticCharge (
					[date],
					[VehTypeID],
					[VehID],
					[RealDistance],
					[CalcDistance],
					[ForPay],
					[OtherExp],
					[AmortExp],
					[StrahExp],
					[ServExp],
					[LogExp],
					[DrvExp],
					[FuelExp]
					)			
	select 	z.[date],
					z.[vType],
					z.[Veh],
					z.[odo],
					z.[KM],
					z.[ForPay],
          z.[OtherExp1]+z.[OtherExp2] [OtherExp],
					z.[AmortExp],
					z.[StrahExp],
					z.[ServExp],
					z.[LogExp],
					case when z.[vType]=1 then z.[DrvOklExp]+z.[DrvCargoExp] else z.[DrvOklExp]+z.[DrvRefExp] end [DrvExp],
					/*isnull((select isnull(sum(f.summa),0)
									from FFuelNew f
									left join FCards c on c.CardNom=f.cardnum
									where c.fcID in (	select c.IDCard 
																		from db_FarLogistic.dlFuelCard c 
																		where c.IDVeh=z.[Veh]) 
												and	month(f.nd)=right(z.[date],2) 
												and right(year(f.nd),2)=left(z.[date],2)),0)*/ 0 [FuelExp]
	from (
				select 	x.[date],
								x.[vType],
								x.[Veh],
								sum(x.[odo]) [odo],
								sum(x.[KM]) [KM],
								sum(x.[ForPay]) [ForPay],
								sum(x.[OtherExp1]) [OtherExp1],
								case when x.[vType]=1 then (17500/24)* db_FarLogistic.PeriodDayCount(0, x.[date], x.[date],x.[Veh]) else (35000/24)* db_FarLogistic.PeriodDayCount(0, x.[date], x.[date],x.[Veh]) end [DrvOklExp],
								sum(x.[DrvRefExp]) [DrvRefExp],
								sum(x.[DrvCargoExp]) [DrvCargoExp],							
								isnull((select sum(isnull(ve.ExpenceSum,0)) 
												from db_FarLogistic.dlVehicleExpence ve 
												where (ve.dlVehicleID=x.[Veh] or
															ve.dlVehicleID=(select s.dlVehiclesID from db_FarLogistic.dlVehicles s where s.dlMainVehID=x.[veh])) 
															and month(ve.ExpenceDate)=right(x.[date],2) 
															and year(ve.ExpenceDate)=2000+left(x.[date],2) 
															and ve.ExpenceListID=7
															and ve.IsDel=0),0) [OtherExp2],
											
								isnull((select sum(isnull(ve.ExpenceSum,0)) 
												from db_FarLogistic.dlVehicleExpence ve 
												where (ve.dlVehicleID=x.[Veh] or
															ve.dlVehicleID=(select s.dlVehiclesID from db_FarLogistic.dlVehicles s where s.dlMainVehID=x.[veh]))
															and month(ve.ExpenceDate)=right(x.[date],2) 
															and year(ve.ExpenceDate)=2000+left(x.[date],2) 
															and ve.ExpenceListID=6
															and ve.IsDel=0),0) [LogExp],
											
								isnull((select sum(isnull(ve.ExpenceSum,0)) 
												from db_FarLogistic.dlVehicleExpence ve 
												where (ve.dlVehicleID=x.[Veh] or
															ve.dlVehicleID=(select s.dlVehiclesID from db_FarLogistic.dlVehicles s where s.dlMainVehID=x.[veh])) 
															and month(ve.ExpenceDate)=right(x.[date],2) 
															and year(ve.ExpenceDate)=2000+left(x.[date],2) 
															and ve.ExpenceListID=3
															and ve.IsDel=0),0) [ServExp],
																		
								isnull((select sum(isnull(ve.ExpenceSum,0)) 
												from db_FarLogistic.dlVehicleExpence ve 
												where (ve.dlVehicleID=x.[Veh] or
															ve.dlVehicleID=(select s.dlVehiclesID from db_FarLogistic.dlVehicles s where s.dlMainVehID=x.[veh])) 
															and month(ve.ExpenceDate)=right(x.[date],2) 
															and year(ve.ExpenceDate)=2000+left(x.[date],2) 
															and ve.ExpenceListID=2
															and ve.IsDel=0),0) [StrahExp],
																		
								isnull((select sum(isnull(ve.ExpenceSum,0)) 
												from db_FarLogistic.dlVehicleExpence ve 
												where (ve.dlVehicleID=x.[Veh] or
															ve.dlVehicleID=(select s.dlVehiclesID from db_FarLogistic.dlVehicles s where s.dlMainVehID=x.[veh])) 
															and month(ve.ExpenceDate)=right(x.[date],2) 
															and year(ve.ExpenceDate)=2000+left(x.[date],2)
															and ve.ExpenceListID=1
															and ve.IsDel=0),0) [AmortExp]																	
								
				from (	select 	right(year(m.dt_end_fact),2)*100+month(m.dt_end_fact) [date],
											m.odo_end_fact-m.odo_beg_fact [odo],
											
											isnull((select isnull(t.KM,0)+isnull(t.delta,0) 
															from db_FarLogistic.dlTmpMarshCost t 
															where t.MarshID=m.dlMarshID 
																		and t.WorkID=0),0) [KM],
											/*
											(select sum(g.ForPay) 
											from db_FarLogistic.dlGroupBill g 
                      where g.MarshID=m.dlMarshID) [ForPay],
											*/
                      (select sum(cs.cs) from 
                      (select isnull(sum(t.Cost),0) [cs]
                      from db_FarLogistic.dlTmpMarshCost t 
                      where t.MarshID=m.dlMarshID
                      			and t.isFix=1
                            and t.WorkID<>0
                      union 
                      select isnull(sum(isnull(t.KM,0)+isnull(t.delta,0))*db_FarLogistic.GetPalnExpence(8,m.IDdlVehicles,m.dt_end_fact),0)
                      from db_FarLogistic.dlTmpMarshCost t 
                      where t.MarshID=m.dlMarshID
                      			and t.isFix=0
                            and t.WorkID<>0) cs) [ForPay],
                      
											(select v.dlVehTypeID 
											from db_FarLogistic.dlVehicles v 
											where v.dlVehiclesID=m.IDdlVehicles) [vType],
											
											isnull((select sum(isnull(e.Cost,0)) 
															from db_FarLogistic.dlMarshExpence e 
															where e.MarshID=m.dlMarshID 
																		and e.ExpenceID<>5),0) [OtherExp1],									
											
											
											isnull((select count(*)*100
															from db_FarLogistic.dlJorney j 
															left join db_FarLogistic.dlJorneyInfo ji on ji.IDReq=j.IDReq
															where j.IDdlPointAction in (2,3) and 
																		ji.MarshID=m.dlMarshID),0) [DrvRefExp],
																		
											isnull((select sum(z.[s])
															from (
															select	db_FarLogistic.GetDistancePair(j.IDdlDelivPoint, 
																																			case when j.NumbForRace=1 
																																			then 8 
																																			else (select top 1 j1.IDdlDelivPoint 
																																						from db_FarLogistic.dlJorney j1
																																						join db_FarLogistic.dlJorneyInfo ji1 on ji1.IDReq=j1.IDReq
																																						where ji1.MarshID=m.dlMarshID
																																									and j1.NumbForRace=j.NumbForRace-1) 
																																		 end) 
																				*q.KMPrice/1000 [s]
															from db_FarLogistic.dlJorney j
															join db_FarLogistic.dlJorneyInfo ji on ji.IDReq=j.IDReq
															join db_FarLogistic.dlDriverQuality q on q.IDQuality=j.DrvWorkQuality
															where ji.MarshID=m.dlMarshID
																		and j.NumbForRace>0
															) z ),0) [DrvCargoExp],
															
											m.IDdlVehicles [Veh]
							from db_FarLogistic.dlMarsh m
							where right(year(m.dt_end_fact),2)*100+month(m.dt_end_fact)>=@MarshStart
										and right(year(m.dt_end_fact),2)*100+month(m.dt_end_fact)<=@MarshEnd
										and m.IDdlMarshStatus=4
										and m.IDdlVehicles=case when @VehID=0 then m.IDdlVehicles else @VehID end
										and exists(select * from db_FarLogistic.dlGroupBill g where g.MarshID=m.dlMarshID)
							) x
				group by 	x.[date],
									x.[vType],
									x.[Veh]
	) z					
	if @@error<>0
	set @erReg=@erReg+16
	if (@erReg>0)	goto end_procedure
	
	
	update db_FarLogistic.dlStaticCharge set PAmortKM=case when VehTypeID=5 then 0 else db_FarLogistic.GetPalnExpence (1, VehID, cast([date] as varchar)+'01') end,
																					 PStrahKM=case when VehTypeID=5 then 0 else db_FarLogistic.GetPalnExpence (2, VehID, cast([date] as varchar)+'01') end,
																					 PServKM=case when VehTypeID=5 then 0 else db_FarLogistic.GetPalnExpence (3, VehID, cast([date] as varchar)+'01') end,
																					 PFuelKM=case when VehTypeID=5 then 0 else db_FarLogistic.GetPalnExpence (4, VehID, cast([date] as varchar)+'01') end,
																					 PDrvKM=case when VehTypeID=5 then 0 else db_FarLogistic.GetPalnExpence (5, VehID, cast([date] as varchar)+'01') end,
																					 PlogKM=case when VehTypeID=5 then 0 else db_FarLogistic.GetPalnExpence (6, VehID, cast([date] as varchar)+'01') end,
																					 POtherKM=case when VehTypeID=5 then 0 else db_FarLogistic.GetPalnExpence (7, VehID, cast([date] as varchar)+'01') end,
																					 PPriceKM=case when VehTypeID=5 then 0 else db_FarLogistic.GetPalnExpence (8, VehID, cast([date] as varchar)+'01') end
	if @@error<>0
	set @erReg=@erReg+32
	if (@erReg>0)	goto end_procedure
  
  --/*
  select c.date,
  			 cast('20'+left(c.date,2)+right(c.date,2)+'01' as datetime) dt1,
         cast(null as datetime) dt2,
         c.VehID
         into #tmpCarsFuels
  from db_FarLogistic.dlStaticCharge c
  where c.date >= cast(right(year(@dt1),2)*100+month(@dt1) as int)
  			and c.date <= cast(right(year(@dt2),2)*100+month(@dt2) as int)
        and c.VehID=case when @VehID=0 then c.VehID else @VehID end 
  update #tmpCarsFuels set dt2=eomonth(dt1)
  declare @dt int
  declare @nd1 datetime
  declare @nd2 datetime
  declare @veh int
  declare @sm decimal(10,2)
  declare curFuel cursor for
  select * from #tmpCarsFuels
  open curFuel
  fetch next from curFuel into @dt,@nd1,@nd2,@veh
  while @@fetch_status=0
  begin
  	set @sm=0
    
    exec dbo.GetFuelSumm @veh,@nd1,@nd2,@sum=@sm out
    
    update db_FarLogistic.dlStaticCharge set [FuelExp]=@sm
    where [date]=@dt and VehID=@veh
  	
    fetch next from curFuel into @dt,@nd1,@nd2,@veh
  end
  close curFuel
  deallocate curFuel
  drop table #tmpCarsFuels
	--*/
	end_procedure:
	if @erReg=0 
	begin
		commit tran @tranname
		select cast(0 as bit) [res], cast('' as varchar(100)) [mes]
	end
	else
	begin
		declare @msg varchar(100)
		set @msg=''
		if (@erReg & 1)<>0
		set @msg=@msg+'Ошибка преобразования Дата1; '
		if (@erReg & 2)<>0
		set @msg=@msg+'Ошибка преобразования Дата2; '
		if (@erReg & 4)<>0
		set @msg=@msg+'Ошибка преобразования Дата<=>ГГММ; '
		if (@erReg & 8)<>0
		set @msg=@msg+'Ошибка при очистке статичных данных; '
		if (@erReg & 16)<>0
		set @msg=@msg+'Ошибка вставки факта; '
		if (@erReg & 32)<>0
		set @msg=@msg+'Ошибка вставки плана; '
		rollback tran @tranname
		select cast(1 as bit) [res], @msg [mes]
	end			
END