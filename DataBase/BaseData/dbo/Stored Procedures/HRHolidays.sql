CREATE PROCEDURE dbo.HRHolidays
@nd datetime
AS
BEGIN
  select 	max(d.OrdersDetStartDate) [date],
          d.persid
  into #ord
  from hrmain.dbo.OrdersDet d
  left join HRmain.dbo.orders o on o.OrdersID=d.ordersid 
  where d.IsHold=1
        and d.IsDel=0
        and o.IsDel=0
        and o.OrdersTypeID=1
  group by d.persid

  select 	month(p.DateOfBirth) [month],
          datename(month,p.DateOfBirth) [monthname],
          t.[date],
          p.persid,
          p.SecondName+' '+p.FirstName+' '+p.MiddleName [FIO],
          p.PersStaff,
          p.DateOfBirth,
          cast(abs(datediff(m,@nd,t.[date])/12.0) as decimal(5,1)) [years]
  into #res
  from #ord t
  left join hrmain.dbo.pers p on p.persid=t.persid
  where not p.PersState in (-1,5)
  			and month(p.DateOfBirth)=month(@nd)
        --and year(p.DateOfBirth)=1966
        
  drop table #ord
	
  select [Месяц],[Дата приема],[Дата рождения],[Сотрудник],[Должность],[Cтаж]
  from (select r.[monthname] [Месяц],
               r.[date] [Дата приема],
               r.[dateofbirth] [Дата рождения],
               r.[FIO] [Сотрудник],
               p.PostsName+', '+d.DepsName [Должность],
               d.DepsName+' '+sd.SubDepsName [DepsName],
               r.[years] [Cтаж],
               cast(0 as bit) [ord]
        from #res r 
        left join hrmain.dbo.staffs s on r.persstaff=s.StaffsID
        left join hrmain.dbo.deps d on d.DepsID=s.DepsID
        left join HRmain.dbo.posts p on p.PostsID=s.PostsID
        left join HRmain.dbo.SubDeps sd on sd.SubDepsID=s.SubDepsID  
        
        union all
        select distinct * from (
        select distinct r.[monthname],
                        dateadd(m,-1,dateadd(d,1,eomonth(@nd))) x1,
                        dateadd(m,-1,dateadd(d,1,eomonth(@nd))) x2,
                        '' x3,
                        d.DepsName+' '+sd.SubDepsName [Отдел],
                        d.DepsName+' '+sd.SubDepsName [DepsName],
                        0 x4,
                        cast(1 as bit) x5
        from #res r
        left join hrmain.dbo.staffs s on r.persstaff=s.StaffsID
        left join hrmain.dbo.deps d on d.DepsID=s.DepsID
        left join HRmain.dbo.SubDeps sd on sd.SubDepsID=s.SubDepsID) y
        ) x
  order by x.DepsName,x.Ord desc,x.[Месяц],x.[Дата рождения],x.[Сотрудник]

  drop table #res
END