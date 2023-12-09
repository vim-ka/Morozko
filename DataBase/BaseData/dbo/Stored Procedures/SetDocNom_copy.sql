CREATE PROCEDURE dbo.SetDocNom_copy
@datnom int, @docnom int, @isMarsh bit, @op int
AS
BEGIN
  declare @marsh int 
	declare @nd datetime
  declare @b_id int
	declare @isLogged bit
	declare @nd1 datetime
	declare @nDocNom int
  declare @mhid int
  DECLARE @OtherDocNom INT
  DECLARE @DelDocNom INT
  DECLARE @MyDocNom INT
        
	begin try
    select @nDocnom = ISNULL(NC.SertifDoc, 0),  --документы в самой накладной (от всех операторов)
           --@marsh = NC.Marsh,
           @nd = NC.nd,
		       @b_id = NC.b_id,
           @mhid = NC.mhid
    from NC where NC.datnom = @datnom


/*  --накладная
	if @isMarsh=1
	begin		
		update NC set SertifDoc=@docnom 
		where mhid=@mhid
	END
	else
	begin
		update NC set SertifDoc=@docnom 
		where datnom=@datnom
	end
*/	


--для тестирования:
SET @nDocnom =      --документы в самой накладной (от всех операторов)
ISNULL(
        (SELECT SUM(ISNULL(SertifLog_copy.SertifDoc,0)) 
           FROM sertiflog_copy
          WHERE sertiflog_copy.DatNom = @datnom           
        ), 0)



--находим документы других операторов, чтобы их не учитывать для текущего оператора
SET @OtherDocNom =      
ISNULL(
        (SELECT SUM(ISNULL(SertifLog_copy.SertifDoc,0)) 
           FROM sertiflog_copy
          WHERE sertiflog_copy.DatNom = @datnom
            AND sertiflog_copy.Op <> @op
        ), 0)


--находим переданные документы для текущего оператора
      SET @MyDocNom =       --все переданные (@docnom) минус чужие переданные    
            ISNULL(
              (SELECT ABS(@docnom - isnull(SUM((sertiflog_copy.SertifDoc & @docnom)),0)) 
                 FROM sertiflog_copy
                WHERE sertiflog_copy.DatNom = @datnom
                  AND sertiflog_copy.Op <> @op
                  AND (sertiflog_copy.SertifDoc & @docnom) <> 0
              ), 0)


--вычисляем сумму ЧУЖИХ документов, с которых сняты галочки (для правильной записи в SertifLog)

SET @DelDocNom =      
ISNULL(abs(@OtherDocNom - @docnom + @MyDocNom), 0)



--SELECT @nDocnom AS nDocnom, @docnom AS docnom, @OtherDocNom AS OtherDocNom, @DelDocNom AS DelDocNom, @MyDocNom AS MyDocNom


-----------------------------------------------------------------------------------------------------------------------------------------------------------
	if exists(select SertifLog_copy.sid 
              from SertifLog_copy
             where SertifLog_copy.op = @op and SertifLog_copy.datnom = @datnom)
	begin      
		if @docnom<>0 --изменение данных по накладной
		begin
			if @docnom <> @ndocnom
      update SertifLog_copy             --обновление текущего оператора 
         set SertifLog_copy.SertifDoc = @MyDocNom   --abs(@docnom - @OtherDocNom + @DelDocNom)    --(документы всех операторов @docnom) минус ("чужие" документы @OtherDocNom)
			 where SertifLog_copy.datnom = @datnom
				 and SertifLog_copy.op = @op				
		end
		else
			delete from SertifLog_copy where SertifLog_copy.datnom = @datnom
	end
	else
	begin	          --вставка данных для текущего оператора
		if @docnom<>0 
		begin 
      if @MyDocNom <> 0
			insert into SertifLog_copy (Act,
															    DatNom,
															    OP,
															    CompName,
															    SertifDoc,
															    nd) 
			values	(case when @isMarsh = 1 then 'МАРШ' else 'НАКЛ' end,
							 @DatNom,
							 @OP,
							 host_name(),
							 @MyDocNom,  --abs(@docnom - @nDocnom + @DelDocNom),   --(документы всех операторов @docnom) минус ("чужие" документы @nDocnom)
							 @nd)
		end
		else
			delete from SertifLog_copy where SertifLog_copy.datnom = @datnom		
	end

  
  --обновление у других операторов (если сняты галочки)
  IF @DelDocNom <> 0    
  BEGIN
    UPDATE SertifLog_copy  
       SET SertifLog_copy.SertifDoc = (SertifLog_copy.SertifDoc & @docnom)  
     WHERE SertifLog_copy.DatNom = @datnom
       AND sertiflog_copy.Op <> @op 
  END



  
  delete from SertifLog_copy
   WHERE SertifLog_copy.DatNom = @datnom
     and SertifLog_copy.SertifDoc = 0 




    end try
    begin catch
      --    SELECT ERROR_NUMBER() AS ErrorNumber, ERROR_MESSAGE() AS ErrorMessage
      insert into ProcErrors(errnum, errmess, procname, errline) select ERROR_NUMBER(), ERROR_MESSAGE(), object_name(@@procid), ERROR_LINE()
    end catch      
END