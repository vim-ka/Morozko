CREATE PROCEDURE PermissCopy
@uin_to int,
@uin_fr int,
@action_flg bit --1 добавление, 0 замена   
AS

if @action_flg = 1
begin --1 
	declare @prg_fr int
	declare @perm_fr int 
	declare @prg_to int
	declare @perm_to int
	declare @tmp_fr table(i int) 
	declare @tmp_to table(i int)
	declare @i int
	declare @ilast int 
	declare @iperm int
	declare @cur_i int  

	declare cur_fr cursor for 
	select Prg, Permiss from permisscurrent 
	where uin = @uin_fr

	declare cur_tmp_fr cursor for 
	select i from @tmp_fr

	open cur_fr
	fetch next from cur_fr
	into @prg_fr, @perm_fr

	while @@FETCH_STATUS = 0
	begin --2
    print @uin_fr 
    print @uin_to
    print @prg_fr
 		if isnull((select prg from permisscurrent where (uin = @uin_to) AND (prg=@prg_fr)),-1)=-1
    begin --3
			--у пользователя нет такой программы
      print 'вставка'
   		insert into permisscurrent (uin, prg, permiss)
   		values (@uin_to, @prg_fr, @perm_fr)                           
   		fetch next from cur_fr into @prg_fr, @perm_fr
 		end --3
 		else
			--у пользователя есть такая программа
 		begin --4
   		select @prg_to = prg, @perm_to = permiss
   		from permisscurrent 
   		where (uin = @uin_to) and (prg = @prg_fr)
              
   		if @perm_fr <> @perm_to
    		--наборы прав не совпадают
   		begin --6
     		delete from @tmp_fr
     		delete from @tmp_to
                        
     		set @i=1
     		set @ilast=1
     		set @iperm=@perm_fr
                        
             --заполненние временной таблицы прав пользователя (от кого)
     		while @iperm > 0
     		begin --7
       		if @iperm>@i
       		begin --8
        		set @ilast=@i
        		set @i=@i*2
       		end --8
     			else 
     			begin --9
       			insert into @tmp_fr (i) values (@ilast)
       			set @iperm=@iperm-@ilast
       			set @i=1
       			set @ilast=1
     			end --9
   			end --7
                        
   			set @i=1
   			set @ilast=1
   			set @iperm=@perm_to
                       
           --заполнение временной таблицы прав пользователя (кому)
   			while @iperm > 0
   			begin --10
     			if @iperm>@i
     			begin --11
       			set @ilast=@i
       			set @i=@i*2
     			end --11
     			else 
     			begin --12
       			insert into @tmp_to (i) values (@ilast)
       			set @iperm=@iperm-@ilast
       			set @i=1
       			set @ilast=1
     			end --12
   			end --10 	
                        
   			open cur_tmp_fr
   			fetch next from cur_tmp_fr
   			into @cur_i
                       
   			while @@FETCH_STATUS = 0
   			begin  --13
       		--проверка наличия права
     			if not(@cur_i in (select i from @tmp_to))
     			begin --14
        		--права нет                          	                          	
       			update permisscurrent                          	
       			set permiss = permiss + @cur_i
       			where (uin = @uin_to)and(prg = @prg_fr) 
     			end --14                       
     			
          fetch next from cur_tmp_fr
     			into @cur_i
        end --13 
        close cur_tmp_fr
   		end --6
    end    --4
    
 		fetch next from cur_fr
 		into @prg_fr, @perm_fr 
	end	--2
close cur_fr
deallocate cur_tmp_fr   
deallocate cur_fr
end --1

if @action_flg = 0
begin
  DECLARE @curPrg INTEGER 
  DECLARE @curPermiss INTEGER

--создаем курсор для построчной переборки прав донора
	DECLARE n_cursor CURSOR FOR
	SELECT p.Prg, p.Permiss 
	FROM PermissCurrent p 
	WHERE uin = @UIN_fr

--удаляем текущие права у конечного пользователя
	DELETE FROM PermissCurrent WHERE uin = @UIN_to

--устанавливаем курсор в начальное положение с выгрузкой
--значений в локальные переменные
	OPEN n_cursor
	FETCH NEXT FROM n_cursor
	INTO @curPrg, @curPermiss

--организация цикла перебора записей внутри запроса курсора
	WHILE @@FETCH_STATUS = 0 --если равен 0 значит внутри не пусто
	BEGIN
-- вставка записей с правами
		INSERT INTO PermissCurrent (prg, permiss, uin)
		VALUES (@curPrg, @curPermiss, @UIN_to)

		FETCH NEXT FROM n_cursor  --перемещение курсора на следующую
		INTO @curPrg, @curPermiss --позицию с выгрузкой данных
	END

--освобождаем память
	CLOSE n_cursor
	DEALLOCATE n_cursor
END