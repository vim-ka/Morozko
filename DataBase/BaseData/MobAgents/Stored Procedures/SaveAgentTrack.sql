create procedure MobAgents.SaveAgentTrack  @ND datetime, @AG_ID int
as
begin
  declare @atID int
  set @atID=(select atID from MobAgents.AgentTrack where ND=@ND and ag_id=@AG_ID);
  if @atID is null begin
    insert into MobAgents.AgentTrack(ag_id, nd) values(@ag_id, @ND);
    set @atID=scope_identity();
  end;
  select @atID as AtID
end;