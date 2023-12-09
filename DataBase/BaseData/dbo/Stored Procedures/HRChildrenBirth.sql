CREATE PROCEDURE dbo.HRChildrenBirth
@nd datetime
AS
BEGIN
  select p.persid,
         p.SecondName+' '+p.FirstName+' '+p.MiddleName [FIO],
         p.PersStaff
  into #tmp
  from hrmain.dbo.pers p
  where not p.PersState in (-1,5)  
        and exists(select 1 from hrmain.dbo.Children c where c.PersID=p.PersID and c.IsDel=0)
        
  select datename(month,c.YearOfBirth) [Месяц рождения],
         c.YearOfBirth [Дата рождения],
  			 c.FIO [ФИО Ребенка],
         case when c.Gender=1 then 'мальчик' else 'девочка' end [ПОЛ],
         year(@nd)-year(c.YearOfBirth) [Возраст],         
         t.fio [ФИО отрудника],         
         p.PostsName [Должность],
         d.DepsName [Отдел],
         sb.SubDepsName [Подотдел]         
  from #tmp t
  left join hrmain.dbo.staffs s on s.StaffsID=t.persstaff
  left join HRmain.dbo.deps d on d.depsid=s.DepsID
  left join hrmain.dbo.SubDeps sb on sb.SubDepsID=s.SubDepsID
  left join hrmain.dbo.posts p on p.PostsID=s.PostsID
  inner join hrmain.dbo.children c on c.PersID=t.persid
  where year(@nd)-year(c.YearOfBirth)<15
  order by month(c.YearOfBirth), t.fio, c.YearOfBirth, c.fio

  drop table #tmp
END