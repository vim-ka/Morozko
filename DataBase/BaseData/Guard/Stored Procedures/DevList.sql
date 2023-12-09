CREATE procedure Guard.DevList @day0 datetime
AS
BEGIN
  -- список развивающих:
  if Object_ID('tempdb.#dev') is not null drop table #dev;

  create table #dev (devId int); 
  insert into #dev (devId) 
  select distinct a.ag_id as DevID
    from agentlist a inner join Person P on P.p_id=a.p_id
    where a.depid=47;
  create index dev_tmp_idx on #dev(devId);

  -- Теперь к каждому развивающему агенту нужно привязать тех обычных агентов, к которым они были привязаны в заданном периоде с указанием даты привязки. 
  -- Создам таблицу ежедневной привязки и навтыкаю данные из Guard.Chain:
  select DISTINCT
    c.ChainAg_Id, p.Fio as DevFam, c.SourAG_ID, P2.Fio as AgFam
  from 
    Guard.Chain c 
    inner join AgentList A on A.ag_id=c.ChainAg_Id
    inner join Person P on P.P_id=a.p_id
    inner join AgentList A2 on A2.ag_id=c.SourAg_Id
    inner join Person P2 on P2.P_id=a2.p_id
  where C.day0<=@Day0 and c.Day1>=@Day0
  order by c.ChainAg_Id, c.SourAG_ID

END