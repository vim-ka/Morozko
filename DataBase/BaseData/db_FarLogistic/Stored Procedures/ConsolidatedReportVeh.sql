CREATE PROCEDURE [db_FarLogistic].ConsolidatedReportVeh
@dt1 datetime,
@dt2 datetime,
@VehID int,
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
			
if @isDet=1 
begin
	declare @tmpDT datetime
	declare @tmpMarsh int
	declare tmpMarsh cursor for 
	select m.dlMarshID 
	from db_FarLogistic.dlMarsh m
	where m.IDdlVehicles=@VehID
				and m.dt_end_fact>=@dt1
				and m.dt_end_fact<=@dt2
				and m.IDdlMarshStatus=4
				
	open tmpMarsh	
	fetch next from tmpMarsh into @tmpMarsh
	
	while @@FETCH_STATUS=0
	begin
		set @sql=''
		set @sql='alter table #resFarLogic add [ExpPlan_'		  +cast(@tmpMarsh as varchar)+'] money default 0, '+ 
             															'[ExpPlanFact_' +cast(@tmpMarsh as varchar)+'] money default 0 '	
		exec(@sql)		
		fetch next from tmpMarsh into @tmpMarsh	
	end	
	
	close tmpMarsh
	deallocate tmpMarsh
end

set @sql=''
set @sql='alter table #resFarLogic add [ExpPlan] money default 0  null, 
																			 [ExpPlanFact] money default 0  null'
exec(@sql)

insert into #resFarLogic(VehID, VehName, ExpID, ExpName)
select 	x.[VehID],
				x.[VehName],
				z.[ExpID],
				z.[ExpName]
from (select 	v.dlVehiclesID [VehID],
							case when not exists(select * from db_FarLogistic.dlVehicles a where a.dlMainVehID=v.dlVehiclesID) then v.Model+' {'+v.RegNom+'}' else v.Model+' {'+v.RegNom+'}::'+t.Model+' {'+t.RegNom+'}' end [VehName]							
			from db_FarLogistic.dlVehicles v 
			left join db_FarLogistic.dlVehicles t on v.dlVehiclesID=t.dlMainVehID 
			where v.dlVehiclesID=@VehID)x
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


	
select * from #resFarLogic
drop table #resFarLogic
END