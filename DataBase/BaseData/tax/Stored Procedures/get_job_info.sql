CREATE procedure tax.get_job_info
@job_id int
as 
begin
select d.gpaddr [addr],
			 'т.т.: '+d.gpPhone+', юр.тел.: '+d.brPhone [phone],
			 '[договор: '+cast(dc.dck as varchar)+' '+dc.ContrName+', точка: '+cast(dc.pin as varchar)+' '+isnull(d.gpname,d.brname)+']'+
       '['+fc.ourname+']['+b.fio+']'+char(13)+char(10)+
			 '['+de.dname+']'+
       '['+p.fio+', '+ltrim(rtrim(p.phone))+']'+'[супер '+sp.fio+', '+ltrim(rtrim(sp.phone))+']'+char(13)+char(10) [msg]
from tax.job j
join dbo.def d on d.pin=j.pin
join dbo.defcontract dc on dc.pin=d.pin
join dbo.agentlist a on a.ag_id=iif(dc.ag_id in (33),dc.prevag_id,dc.ag_id)
join dbo.agentlist s on s.ag_id=a.sv_ag_id
join dbo.deps de on de.depid=a.depid
join dbo.person p on p.p_id=a.p_id
join person sp on sp.p_id=s.p_id
join dbo.usrpwd b on b.uin=d.buh_id 
join dbo.firmsconfig fc on fc.our_id=dc.our_id
where j.job_id=@job_id
end