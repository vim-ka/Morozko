CREATE VIEW ELoadMenager.ObjectStructure
AS
with ObjectStructure (id, parentid, name, level, pathstr)
as (select 0,-1,cast('Корень' as varchar(50)),0,cast('Корень' as varchar(2000))
    union all
    select o.id,o.parentid,o.name,s.level+1,cast(s.pathstr+'.'+o.name as varchar(2000))
    from ELoadMenager.objects o
    inner join ObjectStructure s on s.id=o.ParentID
    where o.isFolder=1
    )
select id,
			 parentid,
			 replace(space(level*2),' ','-')+name [name],
       pathstr
from ObjectStructure