CREATE PROCEDURE ELoadMenager.fl_marsh_cost
@nd1 datetime,
@nd2 datetime
AS
begin
  set nocount on
  if object_id('tempdb..#manager') is not null drop table #manager	

	select e.IDVehTYpe [type], e.KMPalCost [cost], e.DotCost [dot]
  into #manager
  from db_FarLogistic.dlExpence e
  where e.DateStart='20130101' and e.IDVehTYpe in (1,3)

  select x.dr [Водитель], x.regnom [гос.номер], x.nd [Дата], x.routes [Маршрут], sum(x.fuel) [Литры], x.brname [Заказчик], sum(x.upr) [Сумма], x.km [Пробег], iif(x.km=0,0,sum(x.upr) / x.km) [Коэффициент],
  			 x.[dates] [Дней], sum(x.cnt) [Паллет], sum(x.wei) [Масса],
         convert(varchar,@nd1,104) [#nd1],
         convert(varchar,@nd2,104) [#nd2]
  from (select b.MarshID, de.brname,
  						 convert(varchar,m.dt_beg_fact,104)+' - '+convert(varchar,m.dt_end_fact,104) [nd],
               isnull(ms.Routes, '<нет>') [routes],
							 isnull(p.Surname, '<нет>') +' '
							 +isnull(p.FirstName, '<нет>') +' '
							 +isnull(p.MiddleName, '<нет>') [dr],
               v.RegNom,
               b.ForPay [nalog],
               case when t.isFix=1 then b.ForPay else 
                    case when t.KM+t.delta<t.minKM then t.NewCost else (t.KM+t.delta)*mg.[cost]*t.PalCount+(t.DotsCount-2)*mg.dot end end+                    
                    isnull((select sum(e.Cost) from db_FarLogistic.dlMarshExpence e where e.MarshID=t.MarshID and e.WorkID=t.WorkID),0) [upr],
               (m.odo_end_fact-m.odo_beg_fact) [km],
               abs(datediff(day,m.dt_beg_fact,m.dt_end_fact)) [dates],
               isnull((select sum(f.Vol) from dbo.ffuel f where f.plannd between m.dt_beg_fact and m.dt_end_fact and f.p_id=m.IDdlDrivers),0) [fuel],
               t.PalCount [cnt], t.palWeight [wei]
        from db_FarLogistic.dlGroupBill b
        join db_FarLogistic.StrForBill(0) ms on ms.MarshID=b.MarshID and ms.WorkID=b.WorkID
        join db_FarLogistic.dldef de on de.id=b.casherid
        left join db_FarLogistic.dlTmpMarshCost t on b.MarshID=t.MarshID and b.WorkID=t.WorkID
        --join db_FarLogistic.MarshInStrings() ms on ms.MarshID=b.MarshID
        left join db_FarLogistic.dlMarsh m on m.dlMarshID=b.MarshID 
 				left join db_FarLogistic.dlDrivers p on p.ID=m.IDdlDrivers 
 				left join db_FarLogistic.dlVehicles v on v.dlVehiclesID=m.IDdlVehicles
        join #manager mg on mg.[type]=v.dlVehTypeID
        where convert(varchar,b.GivenDate,104) >= @nd1 
        			and convert(varchar,b.GivenDate,104) <= @nd2
              ) x
  group by x.dr, x.nd, x.routes, x.km, x.[dates], x.regnom, x.brname
  
	if object_id('tempdb..#manager') is not null drop table #manager
  set nocount off
 end