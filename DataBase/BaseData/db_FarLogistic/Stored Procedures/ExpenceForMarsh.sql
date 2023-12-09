CREATE PROCEDURE [db_FarLogistic].ExpenceForMarsh
@IDMarsh int
AS
BEGIN
  declare @sub bit   
  select @sub=m.SubMarsh from db_FarLogistic.dlMarsh m where m.dlMarshID=@IDMarsh
  
  if @sub=0
  begin
    declare @t table (n int,NameExp varchar(50), PlanValue money, FactValue money, p float)  
    declare @Amort float
    declare @Strah float
    declare @Serv float
    declare @Fuel float
    declare @DrvZ float
    declare @LogZ float
    declare @Oth float
    declare @Hand float
    declare @PDistance int
    declare @FDistance int
    declare @NormFuel float
    declare @PRash float
    declare @FRash float
    declare @PDoh float
    declare @FDoh float
    
    declare cur_Expence cursor for 
    select sum(e.Amort),sum(e.Strah),sum(e.Serv),sum(e.Fuel),sum(e.DriverZar),sum(e.LogicZar),sum(e.Handler),sum(e.Other)
    from db_FarLogistic.dlExpence e
    where e.IDVehTYpe in (select v.dlVehTypeID  
                          from db_FarLogistic.dlMarsh m 
                          left join db_FarLogistic.dlVehicles v on v.dlVehiclesID=m.IDdlVehicles                         
                          where m.dlMarshID=@IDMarsh
                          union
                          select isnull(v1.dlVehTypeID,-1)  
                          from db_FarLogistic.dlMarsh m 
                          left join db_FarLogistic.dlVehicles v1 on v1.dlVehiclesID=m.idTrailer 
                          where m.dlMarshID=@IDMarsh) 
         and e.DateStart<(select isnull(m.dt_beg_fact, getdate()) from db_FarLogistic.dlMarsh m where m.dlMarshID=@IDMarsh)
    
    open cur_Expence
    
    fetch next from cur_Expence into 
    @Amort, @Strah, @Serv, @Fuel, @DrvZ, @LogZ, @Hand, @Oth
    
    close cur_Expence
    deallocate cur_Expence
    
    select @FDistance=m.odo_end_fact-m.odo_beg_fact from db_FarLogistic.dlMarsh m where m.dlMarshID=@IDMarsh
    select @PDistance=tm.KM, @PDoh=tm.Cost from db_FarLogistic.dlTmpMarshCost tm where tm.MarshID=@IDMarsh and tm.WorkID=0
    select @FDoh=sum(tm.Cost) from db_FarLogistic.dlTmpMarshCost tm where tm.MarshID=@IDMarsh and tm.WorkID<>0
    
    if @FDistance<0 or @FDistance is null
    set @FDistance=0
    
    if @PDistance<0 or @PDistance is null
    set @PDistance=0
    
    insert into @t values (1,'Пробег',@PDistance,@FDistance,0)  
    insert into @t values (2,'Амортизация',@PDistance*@Amort,@FDistance*@Amort, @Amort)
    insert into @t values (3,'Страховка',@PDistance*@Strah,@FDistance*@Strah, @Strah)
    insert into @t values (4,'Сервисные расходы',@PDistance*@Serv,@FDistance*@Serv, @Serv)
    insert into @t values (5,'Топливо',@PDistance*@Fuel,@FDistance*@Fuel, @Fuel)
    insert into @t values (6,'Зарплата водителю',@PDistance*@DrvZ,@FDistance*@DrvZ, @DrvZ)
    insert into @t values (7,'Зарплата логистам',@PDistance*@LogZ,@FDistance*@LogZ, @LogZ)
    insert into @t values (8,'Прочие расходы',@PDistance*@Oth,(select isnull(sum(me.Cost),0) from db_FarLogistic.dlMarshExpence me where me.MarshID=@IDMarsh), @Oth)
    
    select @PRash=sum(t.PlanValue), @FRash=sum(t.FactValue) 
    from @t t 
    where t.n>1 and t.n<9  
    
    insert into @t values (9,'Суммарно расходов',@PRash, @FRash,0)
    insert into @t values (10, 'Суммарно доходов', @PDoh, @FDoh,0)
    insert into @t values (11, 'Доход владельца',@PDoh-@PRash, @FDoh-@FRash,0)
    
    select t.nameExp 'Наименование', t.PlanValue 'Расчетное значение', t.FactValue 'Фактическое значение', t.p 'Норматив 1р./км' from @t t
  end
  else
  begin
  	declare @tt table (RName varchar(30), FCost money)
    declare @tDoh money
    declare @tRash money
    select @tDoh=sum(tm.Cost) from db_FarLogistic.dlTmpMarshCost tm where tm.MarshID=@IDMarsh and tm.WorkID<>0
    select @tRash=sum(e.cost) from db_FarLogistic.dlMarshExpence e where e.marshid=@IDMarsh
    insert into @tt values('К оплате заказчикам',@tDoh)
    insert into @tt values('К выплате грузоперевозчику',isnull(@tRash,0))
    insert into @tt values('Доход владельца',@tDoh-isnull(@tRash,0))
    select t.Rname 'Наименование', t.FCost 'Сумма' from @tt t
  end
END