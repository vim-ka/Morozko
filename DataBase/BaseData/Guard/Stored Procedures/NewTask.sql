CREATE procedure Guard.NewTask @Name varchar(100), @Day0 datetime, @Day1 datetime, 
  @Remark varchar(100), @DepID int, @Ag_ID int, @SKU int, 
  @code INT, @CodeTip smallint,
  @tsID int out
as
begin
  INSERT into Guard.Tasks(name, dayCreate, Day0,Day1,Remark,DepID,Ag_ID,Active,SKU,Code,CodeTip)
    values(@name, dbo.today(), @Day0,@Day1,@Remark,@DepID,@Ag_ID,1,@SKU,@Code,@CodeTip);
  SET @tsID=SCOPE_IDENTITY()
  RETURN  @tsID;  
end;