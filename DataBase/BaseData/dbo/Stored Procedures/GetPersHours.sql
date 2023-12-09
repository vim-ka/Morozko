CREATE PROCEDURE dbo.GetPersHours
@P_ID int,
@dt1 datetime, 
@dt2 datetime
AS
BEGIN
  declare @PersID int=-1 
	declare @need float=0.0
	declare @hoursperday int=-1
	declare @worked float=0.0
	
	select @PersID=HRPersID 
	from Person 
	where p_id=@P_ID
	
	select 	@need=(case when s.DaysInPeriod=-1 then 1 else s.DaysInPeriod end),
					@hoursperday=(case when isnull(s.HoursInDay,0)=0 then -1 else s.HoursInDay end)
	from hrmain.dbo.staffs s
	where s.staffsid=(select persstaff from hrmain.dbo.pers where persid=@persid)
	
	select @worked=isnull(sum(w.fhours/60/@hoursperday),0.0) 
	from hrmain.dbo.worksheet w 
	where w.persid=@persid 
				and w.workdate>=@dt1 
				and w.workdate<=@dt2 
				and w.ftableid<>-1
				
	select 	@need [NEED],
					case when @need=1 then 1 else @worked end [WASTED]
END