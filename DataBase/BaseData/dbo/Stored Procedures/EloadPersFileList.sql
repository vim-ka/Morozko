CREATE PROCEDURE dbo.EloadPersFileList
AS 
BEGIN
  select p.persid [КодСотрудника],
         p.SecondName+' '+p.FirstName+' '+p.MiddleName+' - '+ISNULL(d.DepsName,'#')+','+ISNULL(po.PostsName,'#') [ФИО и Должность],
         '\\192.168.151.55\foto\EDoc\'+cast(p.PersID AS VARCHAR)+'\'+cast(p.PersID AS VARCHAR)+'_p.jpg' [source],
         p.SecondName+'_'+p.FirstName+'_'+p.MiddleName+'.jpg' [savename]
  from hrmain.dbo.Pers p
  left join hrmain.dbo.staffs s on s.staffsid=p.persstaff
  left join hrmain.dbo.posts po on po.postsid=s.postsid
  left join hrmain.dbo.deps d on d.depsid=s.depsid
  where p.PersState>=0
  ORDER BY p.SecondName,p.FirstName,p.MiddleName
END