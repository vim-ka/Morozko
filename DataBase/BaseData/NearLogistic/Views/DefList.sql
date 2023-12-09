create view NearLogistic.DefList
as
select pin [id],
			 cast(pin as varchar)+' '+isnull(gpname,brname) [list]  
from dbo.def 
where len(isnull(gpname,brname))>5 and worker=0
order by isnull(gpname,brname) offset 0 rows