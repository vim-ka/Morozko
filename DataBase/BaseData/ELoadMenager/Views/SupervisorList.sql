CREATE VIEW ELoadMenager.SupervisorList
AS
select  s.ag_id [id], sp.Fio [List] from dbo.AgentList s
join person sp on s.P_ID=sp.P_ID
 where IsSupervis=1 and sp.Closed = 0