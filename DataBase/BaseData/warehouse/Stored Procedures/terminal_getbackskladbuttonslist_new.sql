CREATE procedure warehouse.terminal_getbackskladbuttonslist_new
@reqdetid int
as
begin
	set nocount on
  declare @depid int
  declare @sklad int
  
  select @depid=a.depid, @sklad=d.sklad
  from dbo.reqreturndet d
  join dbo.reqreturn r on d.reqretid=r.reqnum
  join dbo.defcontract dc on dc.dck=r.dck
  join dbo.agentlist a on a.ag_id=dc.ag_id
  where d.id=@reqdetid
	
  select iif(scb.sklad=-1,@sklad,scb.sklad) [sklad], bt.btid, bt.btnname, bt.btncaption [visible_name], bt.clr, bt.ord, bt.clr_
  from warehouse.backtypes bt 
  left join warehouse.sklad_categories_backs scb on scb.btid=bt.btid
  left join warehouse.sklad_category_contains scc on scc.scid=scb.scid
  where scc.sklad=@sklad and scb.depid=iif(scb.btid=2 and @depid=3,3,0)
  order by bt.ord
  set nocount off
end