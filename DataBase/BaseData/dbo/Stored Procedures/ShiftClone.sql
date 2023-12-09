CREATE PROCEDURE dbo.ShiftClone
AS
declare @p_id int
declare @ids varchar(500)
declare cClone cursor for
/*select b.p_id, replace(b.ids,cast(b.p_id as varchar)+',','') [ids]
from (
			select 	a.p_id, 
							a.fio,
							a.ids,
							row_number() over(partition by ids order by p_id) n
			from (
						select p.p_id, p.fio,
										stuff((select N', '+cast(s.p_id as varchar) 
										from Person s 
										where s.hrpersid>0 and s.hrpersid=p.hrpersid
										for xml path(''), type).value('.','varchar(max)'),1,2,'') [ids]
						from person p 
						where p.hrpersid>0) a
			where patindex('%,%',a.ids)<>0) b
where b.n=1*/

/*select distinct x.p_id, x.newid from (
select 	c.p_id,
				c.tip,
				cast(c.newID as int) [newID]
from (
select 	t.p_id,
				t.fio,
				t.tip,
				case when isnull(p.hrpersid,-1)=-1 then '' else 
				case when p.closed=1 then isnull((select top 1 cast(a.p_id as varchar) from person a where a.hrpersid=p.hrpersid and a.closed=0),'') else '' end end [newID]
from PersonTemp t 
join person p on p.p_id=t.p_id
where not t.p_id in (select b.p_id from persontemp_1 b)) c
where c.newID<>'' and c.tip in (3,4)) x
where not x.newid in (14,1573,1668,3831,3591,3970)*/

/*select t.p_id,t.p_id2
from persontemp t 
where t.tip=6 and t.p_id<>t.p_id2*/

select x.p_id, x.openP_ID from (
select distinct n.p_id, n.fio, p.HRPersID, isnull((select top 1 p_id from person where closed=0 and hrpersid=p.hrpersid),-1) [openP_ID]
from PersonNewWave n 
left join person p on p.p_id=n.p_id 
where n.NotUse=0 and p.HRPersID>0 and closed=1) x
where x.openP_ID>0


open cClone

fetch next from cClone into @p_id, @ids

while @@fetch_status=0
begin
	exec dbo.ShiftP_ID @ids, @p_id
	fetch next from cClone into @p_id, @ids
end

close cClone
deallocate cClone