CREATE PROCEDURE [db_FarLogistic].ConsolidatedReportPark
@dt1 datetime,
@dt2 datetime,
@isDet bit=1
AS
BEGIN
declare @sql varchar(4000)
declare @MarshStart int
declare @MarshEnd int

if not object_id('tempdb.dbo.#resFarLogic') is null
  drop table #resFarLogic

create table #resFarLogic ( [RowID] int identity(1,1) not null, 
														[VehID] int default 0 not null, 
														[ExpID] int default 0 not null,
														[VehName] varchar(100) default '' not null, 
														[ExpName] varchar(40) default '' not null)

set @dt1=case when @dt1 is null then (select min(m.date_creation) from db_FarLogistic.dlMarsh m) else @dt1 end
set @dt2=case when @dt2 is null then (select max(m.date_creation) from db_FarLogistic.dlMarsh m) else @dt2 end

select 	@MarshStart=right(year(@dt1),2)*100+month(@dt1),
			@MarshEnd=right(year(@dt2),2)*100+month(@dt2)

			
if @isDet=1 
begin
	declare @tmpDT datetime
	declare @tmpMarsh int
	set @tmpDT=@dt1
	while @tmpDT<=@dt2
	begin
		set @tmpMarsh=right(year(@tmpDT),2)*100+month(@tmpDT)
		set @sql=''
		set @sql='alter table #resFarLogic add [ExpPlan_'		  +cast(@tmpMarsh as varchar)+'] money default 0, '+ 
             															'[ExpPlanFact_' +cast(@tmpMarsh as varchar)+'] money default 0, '+ 
             															'[ExpFact_'		  +cast(@tmpMarsh as varchar)+'] money default 0, '+ 
             															'[ExpAbsLambda_'+cast(@tmpMarsh as varchar)+'] money default 0, '+ 
             															'[ExpOtnLambda_'+cast(@tmpMarsh as varchar)+'] money default 0'		
		exec(@sql)
		set @tmpDT=dateadd(month, 1, @tmpDT)
	end	
end
set @sql=''
set @sql='alter table #resFarLogic add [ExpPlan] money default 0  null, 
																			 [ExpPlanFact] money default 0  null, 
																			 [ExpFact] money default 0  null, 
																			 [ExpAbsLambda] money default 0  null, 
																			 [ExpOtnLambda] money default 0  null'
exec(@sql)

insert into #resFarLogic(VehID, VehName, ExpID, ExpName)
select 	x.[VehID],
				x.[VehName],
				z.[ExpID],
				z.[ExpName]
from (select 	top 1000
							z.[VehID], 
							z.[VehName]
			from (select 	v.dlVehiclesID [VehID],
										v.dlVehTypeID,
										case when not exists(select * from db_FarLogistic.dlVehicles a where a.dlMainVehID=v.dlVehiclesID) then v.Model+' {'+v.RegNom+'}' else v.Model+' {'+v.RegNom+'}::'+t.Model+' {'+t.RegNom+'}' end [VehName]							
						from db_FarLogistic.dlVehicles v 
						left join db_FarLogistic.dlVehicles t on v.dlVehiclesID=t.dlMainVehID 
						where v.dlVehTypeID in (1,2,3,4)			
						union 
						select 999,999, 'Весь Автопарк') z
			order by z.dlVehTypeID) x
left join (	select 	l.ExpenceListID [ExpID],
										l.ExpenceName [ExpName]
						from db_FarLogistic.dlExpenceList l
						union 
						select 0, 'Пробег'
						union 
						select 8, 'Итого расходов'
						union 
						select 9, 'Итого расходов(на 1км)'
						union 
						select 10, 'Итого доходов'
						union 
						select 11, 'Итого доходов (на 1км)'
						union 
						select 12, 'Прибыль'
						union 
						select 13, 'Прибыль (на 1км)') z on 1=1 

if @isDet=1 
begin
	set @tmpDT=@dt1
	while @tmpDT<=@dt2
	begin
		set @tmpMarsh=right(year(@tmpDT),2)*100+month(@tmpDT)
		set @sql=''
		set @sql='update #resFarLogic set [ExpPlan_'		  +cast(@tmpMarsh as varchar)+']=case when ExpID=0 then s.CalcDistance '+
																																												 'when ExpID=1 then s.PAmortKM * s.CalcDistance '+
																																												 'when ExpID=2 then s.PStrahKM * s.CalcDistance '+
																																												 'when ExpID=3 then s.PServKM * s.CalcDistance '+
																																												 'when ExpID=4 then s.PFuelKM * s.CalcDistance '+
																																												 'when ExpID=5 then s.PDrvKM * s.CalcDistance '+
																																												 'when ExpID=6 then s.PLogKM * s.CalcDistance '+
																																												 'when ExpID=7 then s.POtherKM * s.CalcDistance '+
																																												 'when ExpID=8 then (s.PAmortKM+s.PStrahKM+s.PServKM+s.PFuelKM+s.PDrvKM+s.PLogKM+S.POtherKM) * s.CalcDistance '+
																																												 'when ExpID=9 then (s.PAmortKM+s.PStrahKM+s.PServKM+s.PFuelKM+s.PDrvKM+s.PLogKM+S.POtherKM) '+
																																												 'when ExpID=10 then s.PPriceKM * s.CalcDistance '+
																																												 'when ExpID=11 then S.PPriceKM '+
																																												 'when ExpID=12 then (s.PPriceKM-(s.PAmortKM+s.PStrahKM+s.PServKM+s.PFuelKM+s.PDrvKM+s.PLogKM+S.POtherKM)) * s.CalcDistance '+
																																												 'when ExpID=13 then (s.PPriceKM-(s.PAmortKM+s.PStrahKM+s.PServKM+s.PFuelKM+s.PDrvKM+s.PLogKM+S.POtherKM)) end,'+
																		 '[ExpPlanFact_' +cast(@tmpMarsh as varchar)+']=case when  ExpID=0 then s.RealDistance '+
																																												 'when ExpID=1 then s.PAmortKM * s.RealDistance '+
																																												 'when ExpID=2 then s.PStrahKM * s.RealDistance '+
																																												 'when ExpID=3 then s.PServKM * s.RealDistance '+
																																												 'when ExpID=4 then s.PFuelKM * s.RealDistance '+
																																												 'when ExpID=5 then s.PDrvKM * s.RealDistance '+
																																												 'when ExpID=6 then s.PLogKM * s.RealDistance '+
																																												 'when ExpID=7 then s.POtherKM * s.RealDistance '+
																																												 'when ExpID=8 then (s.PAmortKM+s.PStrahKM+s.PServKM+s.PFuelKM+s.PDrvKM+s.PLogKM+S.POtherKM) * s.RealDistance '+
																																												 'when ExpID=9 then (s.PAmortKM+s.PStrahKM+s.PServKM+s.PFuelKM+s.PDrvKM+s.PLogKM+S.POtherKM) '+
																																												 'when ExpID=10 then s.PPriceKM * s.RealDistance '+
																																												 'when ExpID=11 then s.PPriceKM '+
																																												 'when ExpID=12 then (s.PPriceKM-(s.PAmortKM+s.PStrahKM+s.PServKM+s.PFuelKM+s.PDrvKM+s.PLogKM+S.POtherKM)) * s.RealDistance '+
																																												 'when ExpID=13 then (s.PPriceKM-(s.PAmortKM+s.PStrahKM+s.PServKM+s.PFuelKM+s.PDrvKM+s.PLogKM+S.POtherKM)) end,'+
																		 '[ExpFact_'		  +cast(@tmpMarsh as varchar)+']=case when ExpID=0 then s.RealDistance '+
																																												 'when ExpID=1 then s.AmortExp '+
																																												 'when ExpID=2 then s.StrahExp '+
																																												 'when ExpID=3 then s.ServExp '+
																																												 'when ExpID=4 then s.FuelExp '+
																																												 'when ExpID=5 then s.DrvExp '+
																																												 'when ExpID=6 then s.LogExp '+
																																												 'when ExpID=7 then s.OtherExp '+
																																												 'when ExpID=8 then s.AmortExp+s.StrahExp+s.ServExp+s.FuelExp+s.DrvExp+s.LogExp+s.OtherExp '+
																																												 'when ExpID=9 then case when s.RealDistance=0 then 0 else (s.AmortExp+s.StrahExp+s.ServExp+s.FuelExp+s.DrvExp+s.LogExp+s.OtherExp)/s.RealDistance end '+
																																												 'when ExpID=10 then s.ForPay '+
																																												 'when ExpID=11 then case when s.RealDistance=0 then 0 else s.ForPay/s.RealDistance end '+
																																												 'when ExpID=12 then (s.ForPay-(s.AmortExp+s.StrahExp+s.ServExp+s.FuelExp+s.DrvExp+s.LogExp+s.OtherExp)) '+
																																												 'when ExpID=13 then case when s.RealDistance=0 then 0 else (s.ForPay-(s.AmortExp+s.StrahExp+s.ServExp+s.FuelExp+s.DrvExp+s.LogExp+s.OtherExp))/s.RealDistance end end '+
						 'from #resFarLogic c '+
						 'inner join db_FarLogistic.dlStaticCharge s on s.VehID=c.VehID '+
						 'where s.date='+cast(@tmpMarsh as varchar)
		exec(@sql)
		
		set @sql=''
		set @sql='with zResSum as (select ExpID,'+ 
																		 'sum([ExpFact_'+cast(@tmpMarsh as varchar)+']) [sExpFact],'+ 
																		 'sum([ExpPlanFact_'+cast(@tmpMarsh as varchar)+']) [sExpPlanFact],'+ 
																		 'sum([ExpPlan_'+cast(@tmpMarsh as varchar)+']) [sExpPlan] '+
															'from  #resFarLogic '+
															'where VehID<>999 '+
															'group by ExpID)'
		set @sql=@sql+' update #resFarLogic set [ExpFact_'+cast(@tmpMarsh as varchar)+']=			r.[sExpFact],'+
																					 '[ExpPlanFact_'+cast(@tmpMarsh as varchar)+']=	r.[sExpPlanFact],'+
																					 '[ExpPlan_'+cast(@tmpMarsh as varchar)+']= 		r.[sExpPlan] '+
							'from  #resFarLogic c '+
							'inner join zResSum r on r.ExpID=c.ExpID '+
							'where c.VehID=999 '
		exec(@sql)
	  
		set @sql=''
		set @sql='with zResSum as (select r1.[ExpFact_'+cast(@tmpMarsh as varchar)+'] [fKM],'+ 
																		 'r1.[ExpPlanFact_'+cast(@tmpMarsh as varchar)+'] [pfKM],'+ 
																		 'r1.[ExpPlan_'+cast(@tmpMarsh as varchar)+'] [pKM], '+
																		 'r2.[ExpFact_'+cast(@tmpMarsh as varchar)+'] [fRas],'+ 
																		 'r2.[ExpPlanFact_'+cast(@tmpMarsh as varchar)+'] [pfRas],'+ 
																		 'r2.[ExpPlan_'+cast(@tmpMarsh as varchar)+'] [pRas], '+
																		 'r3.[ExpFact_'+cast(@tmpMarsh as varchar)+'] [fDoh],'+ 
																		 'r3.[ExpPlanFact_'+cast(@tmpMarsh as varchar)+'] [pfDoh],'+ 
																		 'r3.[ExpPlan_'+cast(@tmpMarsh as varchar)+'] [pDoh], '+
																		 'r4.[ExpFact_'+cast(@tmpMarsh as varchar)+'] [fPr],'+ 
																		 'r4.[ExpPlanFact_'+cast(@tmpMarsh as varchar)+'] [pfPr],'+ 
																		 'r4.[ExpPlan_'+cast(@tmpMarsh as varchar)+'] [pPr] '+
															'from  #resFarLogic r1 '+
															'inner join #resFarLogic r2 on r1.VehID=r2.VehID '+
															'inner join #resFarLogic r3 on r1.VehID=r3.VehID '+
															'inner join #resFarLogic r4 on r1.VehID=r4.VehID '+
															'where r1.VehID=999 '+
																		 'and r1.ExpID=0 '+ 
																		 'and r2.ExpID=8 '+
																		 'and r3.ExpID=10 '+
																		 'and r4.ExpID=12) '
		set @sql=@sql+'update #resFarLogic set [ExpFact_'+cast(@tmpMarsh as varchar)+']=case when ExpID=9 then case when z.fKM=0 then 0 else z.fRas / z.fKM end '+
																																												'when ExpID=11 then case when z.fKM=0 then 0 else z.fDoh / z.fKM end '+
																																												'when ExpID=13 then case when z.fKM=0 then 0 else z.fPr / z.fKM end end, '+
																					'[ExpPlanFact_'+cast(@tmpMarsh as varchar)+']=case when ExpID=9 then case when z.pfKM=0 then 0 else z.pfRas / z.pfKM end '+
																																														'when ExpID=11 then case when z.pfKM=0 then 0 else z.pfDoh / z.pfKM end '+
																																														'when ExpID=13 then case when z.pfKM=0 then 0 else z.pfPr / z.pfKM end end, '+
																					'[ExpPlan_'+cast(@tmpMarsh as varchar)+']=case when ExpID=9 then case when z.pKM=0 then 0 else z.pRas / z.pKM end '+
																																												'when ExpID=11 then case when z.pKM=0 then 0 else z.pDoh / z.pKM end '+
																																												'when ExpID=13 then case when z.pKM=0 then 0 else z.pPr / z.pKM end end '+
									'from  #resFarLogic c '+
									'inner join zResSum z on 1=1 '+
									'where c.VehID=999 '+
												'and c.ExpID in (9,11,13)'
		exec(@sql)
			
		set @sql=''
		set @sql='update #resFarLogic set [ExpAbsLambda_'+cast(@tmpMarsh as varchar)+']=[ExpFact_'+cast(@tmpMarsh as varchar)+']-[ExpPlanFact_'+cast(@tmpMarsh as varchar)+'],'+ 
             												 '[ExpOtnLambda_'+cast(@tmpMarsh as varchar)+']=case when [ExpFact_'+cast(@tmpMarsh as varchar)+']=0 then 0 else ([ExpFact_'+cast(@tmpMarsh as varchar)+']-[ExpPlanFact_'+cast(@tmpMarsh as varchar)+']) / [ExpFact_'+cast(@tmpMarsh as varchar)+'] end'
		exec(@sql)		
		
		set @tmpDT=dateadd(month, 1, @tmpDT)
	end	
end;	

with xSums as (
select 	c.VehID,
				sum(c.RealDistance) [fKM],
				sum(c.AmortExp) [fAMort],
				sum(c.StrahExp) [fStrah],
				sum(c.ServExp) [fServ],
				sum(c.FuelExp) [fFuel],
				sum(c.DrvExp) [fDrv],
				sum(c.LogExp) [fLog],
				sum(c.OtherExp) [fOth],
				sum(c.ForPay) [fDoh],
				case when sum(c.RealDistance)=0 then 0 else sum(c.ForPay)/sum(c.RealDistance) end [fDohKM],
				sum(c.AmortExp+c.StrahExp+c.ServExp+c.FuelExp+c.DrvExp+c.LogExp+c.OtherExp) [fRas],
				case when sum(c.RealDistance)=0 then 0 else sum(c.AmortExp+c.StrahExp+c.ServExp+c.FuelExp+c.DrvExp+c.LogExp+c.OtherExp)/sum(c.RealDistance) end [fRasKM],
				sum(c.ForPay)-sum(c.AmortExp+c.StrahExp+c.ServExp+c.FuelExp+c.DrvExp+c.LogExp+c.OtherExp) [fCost],
				case when sum(c.RealDistance)=0 then 0 else (sum(c.ForPay)-sum(c.AmortExp+c.StrahExp+c.ServExp+c.FuelExp+c.DrvExp+c.LogExp+c.OtherExp))/sum(c.RealDistance) end [fCostKM],
				sum(c.CalcDistance) [pKM],
				sum(c.PAmortKM*c.CalcDistance) [pAMort],
				sum(c.PStrahKM*c.CalcDistance) [pStrah],
				sum(c.PServKM*c.CalcDistance) [pServ],
				sum(c.PFuelKM*c.CalcDistance) [pFuel],
				sum(c.PDrvKM*c.CalcDistance) [pDrv],
				sum(c.PLogKM*c.CalcDistance) [pLog],
				sum(c.POtherKM*c.CalcDistance) [pOth],
				sum(c.PAmortKM*c.CalcDistance+c.PStrahKM*c.CalcDistance+c.PServKM*c.CalcDistance+c.PFuelKM*c.CalcDistance+c.PDrvKM*c.CalcDistance+c.PLogKM*c.CalcDistance+c.POtherKM*c.CalcDistance) [pRas],
				case when sum(c.CalcDistance)=0 then 0 else sum(c.PAmortKM*c.CalcDistance+c.PStrahKM*c.CalcDistance+c.PServKM*c.CalcDistance+c.PFuelKM*c.CalcDistance+c.PDrvKM*c.CalcDistance+c.PLogKM*c.CalcDistance+c.POtherKM*c.CalcDistance)/sum(c.CalcDistance) end [pRasKM],
				sum(c.PPriceKM*c.CalcDistance) [pDoh],
				case when sum(c.CalcDistance)=0 then 0 else sum(c.PPriceKM*c.CalcDistance)/sum(c.CalcDistance) end [pDohKM],
				sum(c.PPriceKM*c.CalcDistance)-sum(c.PAmortKM*c.CalcDistance+c.PStrahKM*c.CalcDistance+c.PServKM*c.CalcDistance+c.PFuelKM*c.CalcDistance+c.PDrvKM*c.CalcDistance+c.PLogKM*c.CalcDistance+c.POtherKM*c.CalcDistance) [pCost],
				case when sum(c.CalcDistance)=0 then 0 else (sum(c.PPriceKM*c.CalcDistance)-sum(c.PAmortKM*c.CalcDistance+c.PStrahKM*c.CalcDistance+c.PServKM*c.CalcDistance+c.PFuelKM*c.CalcDistance+c.PDrvKM*c.CalcDistance+c.PLogKM*c.CalcDistance+c.POtherKM*c.CalcDistance))/sum(c.CalcDistance) end [pCostKM],
				sum(c.RealDistance) [pfKM],
				sum(c.PAmortKM*c.RealDistance) [pfAMort],
				sum(c.PStrahKM*c.RealDistance) [pfStrah],
				sum(c.PServKM*c.RealDistance) [pfServ],
				sum(c.PFuelKM*c.RealDistance) [pfFuel],
				sum(c.PDrvKM*c.RealDistance) [pfDrv],
				sum(c.PLogKM*c.RealDistance) [pfLog],
				sum(c.POtherKM*c.RealDistance) [pfOth],
				sum(c.PAmortKM*c.RealDistance+c.PStrahKM*c.RealDistance+c.PServKM*c.RealDistance+c.PFuelKM*c.RealDistance+c.PDrvKM*c.RealDistance+c.PLogKM*c.RealDistance+c.POtherKM*c.RealDistance) [pfRas],
				case when sum(c.RealDistance)=0 then 0 else sum(c.PAmortKM*c.RealDistance+c.PStrahKM*c.RealDistance+c.PServKM*c.RealDistance+c.PFuelKM*c.RealDistance+c.PDrvKM*c.RealDistance+c.PLogKM*c.RealDistance+c.POtherKM*c.RealDistance)/sum(c.RealDistance) end [pfRasKM],
				sum(c.PPriceKM*c.RealDistance) [pfDoh],
				case when sum(c.RealDistance)=0 then 0 else sum(c.PPriceKM*c.RealDistance)/sum(c.RealDistance) end [pfDohKM],
				sum(c.PPriceKM*c.RealDistance)-sum(c.PAmortKM*c.RealDistance+c.PStrahKM*c.RealDistance+c.PServKM*c.RealDistance+c.PFuelKM*c.RealDistance+c.PDrvKM*c.RealDistance+c.PLogKM*c.RealDistance+c.POtherKM*c.RealDistance) [pfCost],
				case when sum(c.RealDistance)=0 then 0 else (sum(c.PPriceKM*c.RealDistance)-sum(c.PAmortKM*c.RealDistance+c.PStrahKM*c.RealDistance+c.PServKM*c.RealDistance+c.PFuelKM*c.RealDistance+c.PDrvKM*c.RealDistance+c.PLogKM*c.RealDistance+c.POtherKM*c.RealDistance))/sum(c.RealDistance) end [pfCostKM]
from db_FarLogistic.dlStaticCharge c
where c.[date]>=@MarshStart
			and c.[date]<=@MarshEnd
group by c.VehID
union 
select 	999,
				sum(c.RealDistance) [fKM],
				sum(c.AmortExp) [fAMort],
				sum(c.StrahExp) [fStrah],
				sum(c.ServExp) [fServ],
				sum(c.FuelExp) [fFuel],
				sum(c.DrvExp) [fDrv],
				sum(c.LogExp) [fLog],
				sum(c.OtherExp) [fOth],
				sum(c.ForPay) [fDoh],
				case when sum(c.RealDistance)=0 then 0 else sum(c.ForPay)/sum(c.RealDistance) end [fDohKM],
				sum(c.AmortExp+c.StrahExp+c.ServExp+c.FuelExp+c.DrvExp+c.LogExp+c.OtherExp) [fRas],
				case when sum(c.RealDistance)=0 then 0 else sum(c.AmortExp+c.StrahExp+c.ServExp+c.FuelExp+c.DrvExp+c.LogExp+c.OtherExp)/sum(c.RealDistance) end [fRasKM],
				sum(c.ForPay)-sum(c.AmortExp+c.StrahExp+c.ServExp+c.FuelExp+c.DrvExp+c.LogExp+c.OtherExp) [fCost],
				case when sum(c.RealDistance)=0 then 0 else (sum(c.ForPay)-sum(c.AmortExp+c.StrahExp+c.ServExp+c.FuelExp+c.DrvExp+c.LogExp+c.OtherExp))/sum(c.RealDistance) end [fCostKM],
				sum(c.CalcDistance) [pKM],
				sum(c.PAmortKM*c.CalcDistance) [pAMort],
				sum(c.PStrahKM*c.CalcDistance) [pStrah],
				sum(c.PServKM*c.CalcDistance) [pServ],
				sum(c.PFuelKM*c.CalcDistance) [pFuel],
				sum(c.PDrvKM*c.CalcDistance) [pDrv],
				sum(c.PLogKM*c.CalcDistance) [pLog],
				sum(c.POtherKM*c.CalcDistance) [pOth],
				sum(c.PAmortKM*c.CalcDistance+c.PStrahKM*c.CalcDistance+c.PServKM*c.CalcDistance+c.PFuelKM*c.CalcDistance+c.PDrvKM*c.CalcDistance+c.PLogKM*c.CalcDistance+c.POtherKM*c.CalcDistance) [pRas],
				case when sum(c.CalcDistance)=0 then 0 else sum(c.PAmortKM*c.CalcDistance+c.PStrahKM*c.CalcDistance+c.PServKM*c.CalcDistance+c.PFuelKM*c.CalcDistance+c.PDrvKM*c.CalcDistance+c.PLogKM*c.CalcDistance+c.POtherKM*c.CalcDistance)/sum(c.CalcDistance) end [pRasKM],
				sum(c.PPriceKM*c.CalcDistance) [pDoh],
				case when sum(c.CalcDistance)=0 then 0 else sum(c.PPriceKM*c.CalcDistance)/sum(c.CalcDistance) end [pDohKM],
				sum(c.PPriceKM*c.CalcDistance)-sum(c.PAmortKM*c.CalcDistance+c.PStrahKM*c.CalcDistance+c.PServKM*c.CalcDistance+c.PFuelKM*c.CalcDistance+c.PDrvKM*c.CalcDistance+c.PLogKM*c.CalcDistance+c.POtherKM*c.CalcDistance) [pCost],
				case when sum(c.CalcDistance)=0 then 0 else (sum(c.PPriceKM*c.CalcDistance)-sum(c.PAmortKM*c.CalcDistance+c.PStrahKM*c.CalcDistance+c.PServKM*c.CalcDistance+c.PFuelKM*c.CalcDistance+c.PDrvKM*c.CalcDistance+c.PLogKM*c.CalcDistance+c.POtherKM*c.CalcDistance))/sum(c.CalcDistance) end [pCostKM],
				sum(c.RealDistance) [pfKM],
				sum(c.PAmortKM*c.RealDistance) [pfAMort],
				sum(c.PStrahKM*c.RealDistance) [pfStrah],
				sum(c.PServKM*c.RealDistance) [pfServ],
				sum(c.PFuelKM*c.RealDistance) [pfFuel],
				sum(c.PDrvKM*c.RealDistance) [pfDrv],
				sum(c.PLogKM*c.RealDistance) [pfLog],
				sum(c.POtherKM*c.RealDistance) [pfOth],
				sum(c.PAmortKM*c.RealDistance+c.PStrahKM*c.RealDistance+c.PServKM*c.RealDistance+c.PFuelKM*c.RealDistance+c.PDrvKM*c.RealDistance+c.PLogKM*c.RealDistance+c.POtherKM*c.RealDistance) [pfRas],
				case when sum(c.RealDistance)=0 then 0 else sum(c.PAmortKM*c.RealDistance+c.PStrahKM*c.RealDistance+c.PServKM*c.RealDistance+c.PFuelKM*c.RealDistance+c.PDrvKM*c.RealDistance+c.PLogKM*c.RealDistance+c.POtherKM*c.RealDistance)/sum(c.RealDistance) end [pfRasKM],
				sum(c.PPriceKM*c.RealDistance) [pfDoh],
				case when sum(c.RealDistance)=0 then 0 else sum(c.PPriceKM*c.RealDistance)/sum(c.RealDistance) end [pfDohKM],
				sum(c.PPriceKM*c.RealDistance)-sum(c.PAmortKM*c.RealDistance+c.PStrahKM*c.RealDistance+c.PServKM*c.RealDistance+c.PFuelKM*c.RealDistance+c.PDrvKM*c.RealDistance+c.PLogKM*c.RealDistance+c.POtherKM*c.RealDistance) [pfCost],
				case when sum(c.RealDistance)=0 then 0 else (sum(c.PPriceKM*c.RealDistance)-sum(c.PAmortKM*c.RealDistance+c.PStrahKM*c.RealDistance+c.PServKM*c.RealDistance+c.PFuelKM*c.RealDistance+c.PDrvKM*c.RealDistance+c.PLogKM*c.RealDistance+c.POtherKM*c.RealDistance))/sum(c.RealDistance) end [pfCostKM]
from db_FarLogistic.dlStaticCharge c
where c.[date]>=@MarshStart
			and c.[date]<=@MarshEnd)
update #resFarLogic set [ExpPlan]=case when ExpID=0 then b.[pKM]
																			 when ExpID=1 then b.[pAmort]
																			 when ExpID=2 then b.[pStrah]
																			 when ExpID=3 then b.[pServ]
																			 when ExpID=4 then b.[pFuel]
																			 when ExpID=5 then b.[pDrv]
																			 when ExpID=6 then b.[pLog]
																			 when ExpID=7 then b.[pOth]
																			 when ExpID=8 then b.[pRas]
																			 when ExpID=9 then b.[pRasKM]
																			 when ExpID=10 then b.[pDoh]
																			 when ExpID=11 then b.[pDohKM]
																			 when ExpID=12 then b.[pCost]
																			 when ExpID=13 then b.[pCostKM] end,
												[ExpPlanFact]=case when ExpID=0 then b.[pfKM]
																			 when ExpID=1 then b.[pfAmort]
																			 when ExpID=2 then b.[pfStrah]
																			 when ExpID=3 then b.[pfServ]
																			 when ExpID=4 then b.[pfFuel]
																			 when ExpID=5 then b.[pfDrv]
																			 when ExpID=6 then b.[pfLog]
																			 when ExpID=7 then b.[pfOth]
																			 when ExpID=8 then b.[pfRas]
																			 when ExpID=9 then b.[pfRasKM]
																			 when ExpID=10 then b.[pfDoh]
																			 when ExpID=11 then b.[pfDohKM]
																			 when ExpID=12 then b.[pfCost]
																			 when ExpID=13 then b.[pfCostKM] end,
												[ExpFact]=case when ExpID=0 then b.[fKM]
																			 when ExpID=1 then b.[fAmort]
																			 when ExpID=2 then b.[fStrah]
																			 when ExpID=3 then b.[fServ]
																			 when ExpID=4 then b.[fFuel]
																			 when ExpID=5 then b.[fDrv]
																			 when ExpID=6 then b.[fLog]
																			 when ExpID=7 then b.[fOth]
																			 when ExpID=8 then b.[fRas]
																			 when ExpID=9 then b.[fRasKM]
																			 when ExpID=10 then b.[fDoh]
																			 when ExpID=11 then b.[fDohKM]
																			 when ExpID=12 then b.[fCost]
																			 when ExpID=13 then b.[fCostKM] end
from #resFarLogic a
inner join xSums b on b.VehID=a.VehID					

set @sql=''
set @sql='update #resFarLogic set [ExpAbsLambda]=[ExpFact]-[ExpPlanFact],'+ 
																 '[ExpOtnLambda]=case when [ExpFact]=0 then 0 else ([ExpFact]-[ExpPlanFact]) / [ExpFact] end'
exec(@sql)
	
select * from #resFarLogic
drop table #resFarLogic
END