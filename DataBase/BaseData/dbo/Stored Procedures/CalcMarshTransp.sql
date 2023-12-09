CREATE procedure CalcMarshTransp @d0 datetime, @d1 datetime, @N0 int, @N1 int with recompile
as
declare @TotalRash money, @NewSumma float
declare @TotalDW float, @Koeff float
begin

  -- Все транспортные расходы за период:
  set @TotalRash = (select SUM((IsNull(Dots,0)*IsNull(DotsPay,0))+(IsNull(Dist,0)*IsNull(DistPay,0))+
    IsNull(DrvPay,0)+IsNull(Spedpay,0)) from Marsh M  
    where M.ND between @D0 and @D1 and m.Marsh>0 and M.Marsh<>99 );
  -- Для каждого маршрута вычисляю повышающий коэффициент Dots*Weight:  
  create table #T (ND datetime, Marsh int, Rashod money, DW float, Dots int);
  
  insert into #t 
    select Nd, Marsh, 
    (IsNull(Dots,0)*IsNull(DotsPay,0))+(IsNull(Dist,0)*IsNull(DistPay,0))+
    IsNull(DrvPay,0)+IsNull(Spedpay,0) as Rashod,
    Dots*Weight/@TotalRash as DW,  Dots 
    from Marsh M
    where M.ND between @d0 and @d1 and m.Marsh<>0 and M.Marsh<>99 and M.Dots>0;



  -- Общая суммма расходов по всем покупателям с учетом повышающего коэффициента DW:    
  set @NewSumma = (select sum(F.Summa) as NewSumma from (
	  select T.B_id, Round(Sum(T.Rashod),2) as Summa
	  from 
	  (select distinct nc.B_id,nc.Nd,nc.Marsh,#t.Dots, #t.DW*#t.rashod/#t.Dots as Rashod
	    from NC inner join #t on #t.Nd=nc.Nd and #t.marsh=nc.marsh
	    where nc.Datnom between @N0 and @N1
	    and nc.Sp>0 and nc.Marsh>0 and nc.Marsh<>99) T
	  group by T.B_id
      ) F);
 
  -- Скорректированная сумма расходов для каждого покупателя:    
  select X.B_id, Round(Sum(X.Summa/@NewSumma*@TotalRash),2) as Summa
  from 
  (	  select F.B_id, Round(Sum(F.Rashod),2) as Summa
	  from 
	  (select distinct nc.B_id,nc.Nd,nc.Marsh,#t.Dots, #t.DW*#t.rashod/#t.Dots as Rashod
	    from NC inner join #t on #t.Nd=nc.Nd and #t.marsh=nc.marsh
	    where nc.Datnom between @N0 and @N1
	    and nc.Sp>0 and nc.Marsh>0 and nc.Marsh<>99) F
	  group by F.B_id
  ) X
  group by X.B_id
  order by X.B_ID;

end;