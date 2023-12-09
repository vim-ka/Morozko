CREATE PROCEDURE MobAgents.MobGetParams @ag_id int
AS
BEGIN
  select param,val from MobAgents.MobConfig
END