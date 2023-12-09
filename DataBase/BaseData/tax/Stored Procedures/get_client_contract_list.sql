create procedure tax.get_client_contract_list
@pin int
as
begin
	select dc.dck [id], '['+cast(dc.dck as varchar)+']['+dc.contrname+']['+fc.ourname+']['+t.tipname+']'  [list]
	from dbo.defcontract dc 
	join dbo.firmsconfig fc on fc.our_id=dc.our_id
	join dbo.defcontracttip t on t.contrtip=dc.contrtip
	where dc.pin=@pin
	union all 
	select 0, 'Все договоры'
	order by id
end