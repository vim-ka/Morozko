CREATE procedure tax.get_works_list
@dck int
as
begin
	select w.work_id, iif(w.work_closed=1,'[Закрыт] ','')+w.remark [remark], 
  			 w.dt_start+isnull('-'+w.dt_end,'') [dt], isnull(w.op_end_fio,op_fio) [op]
  from tax.works w 
  where w.dck=@dck
  order by w.work_closed,isnull(w.dt_end,w.dt_start) desc
end