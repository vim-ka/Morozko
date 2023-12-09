CREATE PROCEDURE dbo.SetDocNom
@datnom BIGint,
@docnom int,
@isMarsh bit,
@op int
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
           @marsh = ISNULL(marsh.Marsh, 0),
           @nd = NC.nd,
		       @b_id = NC.b_id,
           @mhid = NC.mhid
    from NC 
    JOIN marsh ON NC.mhID = Marsh.mhid
   where NC.datnom = @datnom
   

  --накладная
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
	

--находим документы других операторов, чтобы их не учитывать для текущего оператора
SET @OtherDocNom =      
ISNULL(
        (SELECT SUM(ISNULL(SertifLog.SertifDoc,0)) 
           FROM SertifLog
          WHERE SertifLog.DatNom = @datnom
            AND SertifLog.Op <> @op
        ), 0)


--находим переданные документы для текущего оператора
      SET @MyDocNom =       --все переданные (@docnom) минус чужие переданные    
            ISNULL(
              (SELECT ABS(@docnom - isnull(SUM((SertifLog.SertifDoc & @docnom)),0)) 
                 FROM SertifLog
                WHERE SertifLog.DatNom = @datnom
                  AND SertifLog.Op <> @op
                  AND (SertifLog.SertifDoc & @docnom) <> 0
              ), 0)


--вычисляем сумму ЧУЖИХ документов, с которых сняты галочки (для правильной записи в SertifLog)

SET @DelDocNom =      
ISNULL(abs(@OtherDocNom - @docnom + @MyDocNom), 0)



-----------------------------------------------------------------------------------------------------------------------------------------------------------
	if exists(select SertifLog.sid 
              from SertifLog
             where SertifLog.op = @op and SertifLog.datnom = @datnom)
	begin      
		if @docnom<>0 --изменение данных по накладной
		begin
			if @docnom <> @ndocnom
      update SertifLog             --обновление текущего оператора 
         set SertifLog.SertifDoc = @MyDocNom   --abs(@docnom - @OtherDocNom + @DelDocNom)    --(документы всех операторов @docnom) минус ("чужие" документы @OtherDocNom)
			 where SertifLog.datnom = @datnom
				 and SertifLog.op = @op				
		end
		else
			delete from SertifLog where SertifLog.datnom = @datnom
	end
	else
	begin	          --вставка данных для текущего оператора
		if @docnom<>0 
		begin 
      if @MyDocNom <> 0
			insert into SertifLog (Act,
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
			delete from SertifLog where SertifLog.datnom = @datnom		
	end

  
  --обновление у других операторов (если сняты галочки)
  IF @DelDocNom <> 0    
  BEGIN
    UPDATE SertifLog  
       SET SertifLog.SertifDoc = (SertifLog.SertifDoc & @docnom)  
     WHERE SertifLog.DatNom = @datnom
       AND SertifLog.Op <> @op 
  END

  
  delete from SertifLog
   WHERE SertifLog.DatNom = @datnom
     and SertifLog.SertifDoc = 0 


    end try
    begin catch
      --    SELECT ERROR_NUMBER() AS ErrorNumber, ERROR_MESSAGE() AS ErrorMessage
      insert into ProcErrors(errnum, errmess, procname, errline) select ERROR_NUMBER(), ERROR_MESSAGE(), object_name(@@procid), ERROR_LINE()
    end catch      

END