CREATE procedure ReadSPlan_Fact @b_id int
as
declare @ag_id int, @sv_id int, @dep_id int, @master int
begin
  set @ag_id=(select brag_id from def where tip=1 and pin=@b_id);
  set @sv_id=(select sv_ag_id from agentlist where ag_id=@ag_id);
  set @dep_id=(select depid from agentlist where ag_id=@ag_id);
  set @master=(select master from def where tip=1 and pin=@b_id);
  if @master is null or @master=0 set @master=-1;

  select distinct hitag
  from Splan_Fact sf
  where sf.netFlag=0 and sf.b_id=@b_id and ((sf.WeightLimit>0 and sf.WeightFact>sf.WeightLimit) or (sf.QtyLimit>0 and sf.QtyFact>sf.QtyLimit) or (sf.RubLimit>0 and sf.RubFact>sf.RubLimit))
    UNION
  select distinct hitag
  from Splan_Fact sf
  where sf.ag_id=@ag_id and sf.ag_id>0 and ((sf.WeightLimit>0 and sf.WeightFact>sf.WeightLimit) or (sf.QtyLimit>0 and sf.QtyFact>sf.QtyLimit) or (sf.RubLimit>0 and sf.RubFact>sf.RubLimit))
    UNION
  select distinct hitag
  from Splan_Fact sf
  where sf.sv_id=@sv_id and sf.sv_id>0 and ((sf.WeightLimit>0 and sf.WeightFact>sf.WeightLimit) or (sf.QtyLimit>0 and sf.QtyFact>sf.QtyLimit) or (sf.RubLimit>0 and sf.RubFact>sf.RubLimit))
    UNION
  select distinct hitag
  from Splan_Fact sf
  where sf.dep_id=@dep_id and sf.dep_id>0 and ((sf.WeightLimit>0 and sf.WeightFact>sf.WeightLimit) or (sf.QtyLimit>0 and sf.QtyFact>sf.QtyLimit) or (sf.RubLimit>0 and sf.RubFact>sf.RubLimit))
    UNION
  select distinct hitag
  from Splan_Fact sf
  where sf.b_id=@master and ((sf.WeightLimit>0 and sf.WeightFact>sf.WeightLimit) or (sf.QtyLimit>0 and sf.QtyFact>sf.QtyLimit) or (sf.RubLimit>0 and sf.RubFact>sf.RubLimit))
    

end