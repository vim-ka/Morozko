create procedure Guard.SaveGroupQuot @WorkDate datetime,  @ag_ID int, @B_ID int, @Hitag int,
  @PlanWeight decimal(10,1), @PlanPcs int, @Op int
as
declare @GqID int
begin
  set @GqID=(select top 1 GqID from Guard.GroupQuot where WorkDate=@WorkDate and AG_ID=@AG_ID and B_ID=@B_ID and Hitag=@Hitag);
  if @GqID is null
    insert into Guard.GroupQuot(WorkDate,Ag_Id,B_ID,Hitag,PlanWeight,PlanPcs, OP, host_name)
    values(@WorkDate,@Ag_Id,@B_ID,@Hitag,@PlanWeight,@PlanPcs, @OP, host_name());
  ELSE
    update Guard.GroupQuot set PlanWeight=@PlanWeight, PlanPcs=@PlanPcs, Host_Name=host_name(), OP=@OP
    where gqid=@GqID;
end