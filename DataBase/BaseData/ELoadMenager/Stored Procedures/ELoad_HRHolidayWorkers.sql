

CREATE PROCEDURE [ELoadMenager].ELoad_HRHolidayWorkers
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

  select 	month(t.[date]) [month],
          datename(month,t.[date]) [monthname],
          t.[date],
          p.persid,
          p.SecondName+' '+p.FirstName+' '+p.MiddleName [FIO],
          p.PersStaff,
          (year(@nd)-year(t.[date])) [years],
          p.DateOfBirth [hb]
  into #res
  from #ord t
  left join hrmain.dbo.pers p on p.persid=t.persid
  where not p.PersState in (-1,5)
        --and (year(@nd)-year(t.[date])) % 5 = 0
        
  drop table #ord

  select r.[monthname] [Месяц],
         r.[date] [Дата приема],
         r.[FIO] [Сотрудник],
         p.PostsName+', '+d.DepsName [Должность],
         d.DepsName [Отдел],
         r.[years] [Юбилейный стаж],
         r.hb [Дата рождения],
         iif(datediff(year,r.hb,@nd)=50,cast(1 as bit),cast(0 as bit)) [Полтишок]         
  from #res r 
  left join hrmain.dbo.staffs s on r.persstaff=s.StaffsID
  left join hrmain.dbo.deps d on d.DepsID=s.DepsID
  left join HRmain.dbo.posts p on p.PostsID=s.PostsID
  order by r.[month],r.[date],r.[fio]

  drop table #res
END