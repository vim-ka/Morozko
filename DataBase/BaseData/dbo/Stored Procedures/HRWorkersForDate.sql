CREATE PROCEDURE dbo.HRWorkersForDate
@dt datetime
AS
BEGIN
  select d.persid [Код],
         p.SecondName+' '+p.FirstName+' '+p.MiddleName [ФИОСотрудника],
         ed.DepsName+','+po.PostsName [Должность],
         d.OrdersDetStartDate [ДатаПриема] 
  from hrmain.dbo.OrdersDet d 
  inner join hrmain.dbo.orders o on o.OrdersID=d.ordersid
  inner join hrmain.dbo.pers p on p.persid=d.PersID
  inner join hrmain.dbo.staffs s on s.StaffsID=p.PersStaff
  inner join hrmain.dbo.deps ed on ed.DepsID=s.DepsID
  inner join hrmain.dbo.posts po on po.PostsID=s.PostsID
  where month(d.OrdersDetStartDate) = month(@dt)
        and year(d.OrdersDetStartDate) = year(@dt)
        and o.OrdersTypeID=1
        and not p.PersState in (-1,5)
        and d.IsDel=0
        and d.IsHold=1
  order by d.OrdersDetStartDate
END