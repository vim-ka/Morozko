CREATE VIEW ELoadMenager.skladgroupslist
as
select dbo.SkladGroups.skg [id], 
			 dbo.SkladGroups.skgName + ' (' + (select cast(dbo.SkladList.skladno as varchar) + ', ' from dbo.skladlist where dbo.skladlist.skg = dbo.SkladGroups.skg for xml path('')) + ')' [list] 
from dbo.SkladGroups