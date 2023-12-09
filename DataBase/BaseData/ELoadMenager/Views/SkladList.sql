CREATE VIEW ELoadMenager.SkladList
AS
  select skladno [id],
  			 skladname [list],
         fc.ourname
  from [dbo].skladlist sl
  left join [dbo].skladgroups sg on sl.skg=sg.skg
  left join [dbo].firmsconfig fc on fc.our_id=sg.our_id
  --where discard=0
  --			and equipment=0