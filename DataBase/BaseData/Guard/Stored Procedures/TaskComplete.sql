

CREATE procedure guard.TaskComplete 
  @Day0 datetime, @Day1 datetime, @tsID int
as
begin
  -- Задачи:
  create table #z(tsID int, Name varchar(100), Remark varchar(100), DepID int, Ag_id int, 
    SKU int,  Code int,  CodeTip smallint, DName varchar(70), AgentFam varchar(100), What varchar(90));

  if (@day0=dbo.today()) and (@day1=dbo.today()) begin
  
    insert into #z
    SELECT
      t.tsid, t.name, t.remark, t.depid, t.ag_id, t.sku, t.Code, t.codetip,  
      deps.dname, p.Fio as AgentFam,
      case 
         when t.CodeTip=0 then Nm.Name
         when t.CodeTip=1 then def.brName
      end as What
    from
      guard.Tasks T
      left join Deps on Deps.depid=t.DepID
      left join Agentlist A on A.ag_ID=T.ag_id
      left join Person P on P.P_ID=A.P_id
      left join Nomen nm on nm.hitag=t.Code and t.CodeTip=0
      left join Def on Def.Pin=t.Code and t.CodeTip=1
    where 
      t.tsid=@tsID
      and t.Active<>0 and dbo.today()>=t.day0 and dbo.today()<=t.day1;
    
    select * from #z;
    
  end
end