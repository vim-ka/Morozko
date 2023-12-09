CREATE PROCEDURE dbo.ClearAgentList
AS
BEGIN
  insert into dbo.AgentListHistory(NDClose,AG_ID,P_ID,Agent,OrdStick,DepID,sv_ag_id,IsAgent,IsSupervis,
    Remark,SkipSver,TmrENAB,NomerOP,AgentPart,ServerName,FolderName,FolderNameBackup,Merch) 
  select dbo.today(),a.AG_ID,a.P_ID,a.Agent,a.OrdStick,a.DepID,a.sv_ag_id,a.IsAgent,a.IsSupervis,
    a.Remark,a.SkipSver,a.TmrENAB,a.NomerOP,a.AgentPart,a.ServerName,a.FolderName,a.FolderNameBackup,a.Merch
  from AgentList a join Person p on a.p_id=p.p_id and p.Closed=1;
  
  update agentlist set p_id=0, ordstick=0, DepID=0, sv_ag_id=0, isagent=0, issupervis=0, remark='',
    skipsver=0, TmrEnab=0, AgentPart=0.7, ServerName='sqlsrv',
    FolderName='AgentsW', FolderNameBackup='', Merch=0
  where p_id in (select p_id from Person where Closed=1);
END