
CREATE PROCEDURE NearLogistic.UpdateVehRasp
@drID int,
@dt datetime,
@v_id int,
@tm char(5),
@op int,
@for_all bit =0
AS
BEGIN
 if @for_all=0
  begin
  if exists(select 1 from VehRasp where drID=@drID and PlanDay=@dt)
  begin
   update VehRasp set tmWork=@tm, v_id=@v_id, op=@op
    where drID=@drID and PlanDay=@dt
  end
  else
  begin
   insert into vehrasp (tmWork,v_id,drID,Planday,op)
    values(@tm,@v_id,@drID,@dt,@op)
  end
  end
  else
  begin
   delete from dbo.vehrasp where planday=@dt
    insert into vehrasp (tmWork,v_id,drID,Planday,op)
    select @tm,v_id,drID,@dt,@op
    from dbo.drivers 
    where closed=0
  end
END