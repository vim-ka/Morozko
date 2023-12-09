CREATE procedure AddFMonitor @TaskKey varchar(20), @ag_id int, @dck int,
  @taskname varchar(80), @Remark varchar(200), @Report varchar(200), @fmid int OUT
as
begin
  if exists(select * from FMonitor where taskkey=@taskkey and ag_id=@ag_id and dck=@dck)
    set @fmid=-1;
  else begin
    INSERT INTO  FMonitor ( taskKey,  ag_id,  DCK,  taskname, Remark, Report)
      values (@taskKey,  @ag_id,  @DCK,  @taskname, @Remark, @Report);
    set @fmid=(select scope_identity());
  end;
  select @fmid as NewFMID;
end