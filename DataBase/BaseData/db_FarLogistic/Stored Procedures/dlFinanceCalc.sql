CREATE PROCEDURE [db_FarLogistic].dlFinanceCalc
@ID int 
AS
declare @p_want decimal(5,2)
declare @p_amor decimal(5,2)
declare @p_strah decimal(5,2)
declare @p_serv decimal(5,2)
declare @p_fuel decimal(5,2)
declare @p_driv decimal(5,2)
declare @p_log decimal(5,2)
declare @p_oth decimal(5,2)
declare @p_han decimal(5,2)
declare @PKM int
declare @FKM int
declare @PCost money
declare @FCost money

set ANSI_WARNINGS off

declare @tmp table( [Наименование]  varchar(40), 
										[Проценты]   decimal(5,2), 
                    [1 км (норма)] money,
                    [1 км (факт)] money,
                    [Ожидаемая прибыль] money,
                    [Фактическая прибыль] money)
                    
declare cur_perc cursor for
select * from [db_FarLogistic].dlPercent

open cur_perc
fetch next from cur_perc
into @p_want, @p_amor, @p_strah, @p_serv, @p_fuel, @p_driv, @p_log, @p_oth, @p_han
close cur_perc
deallocate cur_perc

declare cur_marsh cursor for
select m.FactCost, m.FactDistance, m.PlanCost, m.PlanDistance from [db_FarLogistic].dlMarsh m
where m.dlMarshID = @ID

open cur_marsh
fetch next from cur_marsh
into @FCost, @FKM, @PCost, @PKM
close cur_marsh
deallocate cur_marsh

insert into @tmp ([Наименование], 
									[Проценты], 
                  [1 км (норма)], 
                  [1 км (факт)], 
                  [Ожидаемая прибыль], 
                  [Фактическая прибыль])
values ('Желаемый результат', @p_want, @PCost / @PKM, @FCost / @FKM, @PCost, @FCost)

insert into @tmp ([Наименование], 
									[Проценты], 
                  [1 км (норма)], 
                  [1 км (факт)], 
                  [Ожидаемая прибыль], 
                  [Фактическая прибыль])
values ('Расходы на приобретение автотранспорта', 
				@p_amor, 
        @PCost / @PKM * @p_amor / 100, 
        @FCost / @FKM * @p_amor / 100, 
        @PCost * @p_amor / 100, 
        @FCost * @p_amor / 100 )

insert into @tmp ([Наименование], 
									[Проценты], 
                  [1 км (норма)], 
                  [1 км (факт)], 
                  [Ожидаемая прибыль], 
                  [Фактическая прибыль])
values ('Расходы на страховку', 
				@p_strah, 
        @PCost / @PKM * @p_strah / 100, 
        @FCost / @FKM * @p_strah / 100, 
        @PCost * @p_strah / 100, 
        @FCost * @p_strah / 100 )
        
insert into @tmp ([Наименование], 
									[Проценты], 
                  [1 км (норма)], 
                  [1 км (факт)], 
                  [Ожидаемая прибыль], 
                  [Фактическая прибыль])
values ('Расходы на сервисное обслуживание', 
				@p_serv, 
        @PCost / @PKM * @p_serv / 100, 
        @FCost / @FKM * @p_serv / 100, 
        @PCost * @p_serv / 100, 
        @FCost * @p_serv / 100 )

insert into @tmp ([Наименование], 
									[Проценты], 
                  [1 км (норма)], 
                  [1 км (факт)], 
                  [Ожидаемая прибыль], 
                  [Фактическая прибыль])
values ('Расходы на топливо', 
				@p_fuel, 
        @PCost / @PKM * @p_fuel / 100, 
        @FCost / @FKM * @p_fuel / 100, 
        @PCost * @p_fuel / 100, 
        @FCost * @p_fuel / 100 )

insert into @tmp ([Наименование], 
									[Проценты], 
                  [1 км (норма)], 
                  [1 км (факт)], 
                  [Ожидаемая прибыль], 
                  [Фактическая прибыль])
values ('Расходы на зарплату водителю', 
				@p_driv, 
        @PCost / @PKM * @p_driv / 100, 
        @FCost / @FKM * @p_driv / 100, 
        @PCost * @p_driv / 100, 
        @FCost * @p_driv / 100 )

insert into @tmp ([Наименование], 
									[Проценты], 
                  [1 км (норма)], 
                  [1 км (факт)], 
                  [Ожидаемая прибыль], 
                  [Фактическая прибыль])
values ('Расходы на зарплату логистам', 
				@p_log, 
        @PCost / @PKM * @p_log / 100, 
        @FCost / @FKM * @p_log / 100, 
        @PCost * @p_log / 100, 
        @FCost * @p_log / 100 )

insert into @tmp ([Наименование], 
									[Проценты], 
                  [1 км (норма)], 
                  [1 км (факт)], 
                  [Ожидаемая прибыль], 
                  [Фактическая прибыль])
values ('Прочие расоды и налоги', 
				@p_oth, 
        @PCost / @PKM * @p_oth / 100, 
        @FCost / @FKM * @p_oth / 100, 
        @PCost * @p_oth / 100, 
        @FCost * @p_oth / 100 )

insert into @tmp ([Наименование], 
									[Проценты], 
                  [1 км (норма)], 
                  [1 км (факт)], 
                  [Ожидаемая прибыль], 
                  [Фактическая прибыль])
values ('Доход владельца бизнеса', 
				@p_han, 
        @PCost / @PKM * @p_han / 100, 
        @FCost / @FKM * @p_han / 100, 
        @PCost * @p_han / 100, 
        @FCost * @p_han / 100 )

select * from @tmp