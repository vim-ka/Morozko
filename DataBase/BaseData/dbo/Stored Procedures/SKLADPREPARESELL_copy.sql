﻿CREATE PROCEDURE dbo.SKLADPREPARESELL_copy
  @ACTION TINYINT=0, -- 0 - НАБОР
  @COMP VARCHAR(30),
  @HITAG INT,
  @VES DECIMAL(10,3),
  @SKLADLIST VARCHAR(200),
  @DATNOM INT, 
  @OP INT, 
  @KOLERROR INT OUT,
  @SPK INT=0
  WITH RECOMPILE
AS
  DECLARE @ID INT, @JUNK INT, @NEWID INT, @LASTIZMID INT, @LASTID INT, @ORIGID INT, @ORIGWEIGHT DECIMAL(10,3),
    @PRICE DECIMAL(10,2), @COST DECIMAL(13,5), @NEWPRICE DECIMAL(10,2), @NEWCOST DECIMAL(13,5), 
    @SKLAD INT, @NEWSKLAD INT, @SS VARCHAR(100), @TEKWEIGHT DECIMAL(10,3), @TEKKOL DECIMAL(10,3),
    @PROCERROR INT, @UNIONWEIGHT DECIMAL(10,3), @QTY INT, @ORIGQTY INT, @FIRMGROUP INT,  @OK BIT, @MSG VARCHAR(MAX),
    @HEAD VARCHAR(256), @TRAN VARCHAR(20)

BEGIN
  SET @MSG=''
  IF @VES>0 
  BEGIN
	  DELETE FROM PARAMSKLAD WHERE COMP=@COMP;
		
	  SET @KOLERROR=0
	  SET @PROCERROR=0
	  
    SET @FIRMGROUP=(SELECT F.FIRMGROUP FROM NC C JOIN FIRMSCONFIG F ON C.OURID=F.OUR_ID WHERE C.DATNOM=@DATNOM)
	  
    SELECT @TEKWEIGHT=SUM(V.WEIGHT*(V.MORN-V.SELL+V.ISPRAV-V.REMOV-V.REZERV)) 
		FROM TDVI V
		WHERE V.SKLAD IN (SELECT K FROM DBO.STR2INTARRAY(@SKLADLIST))
				  AND V.HITAG=@HITAG
		
	 
	  -- ПОДБОР ТОЧНОГО СОВПАДЕНИЯ ВЕСА:
	  SELECT TOP 1 @ID=ID,
		             @ORIGID=V.ID, 
                 @SKLAD=V.SKLAD, 
                 @ORIGWEIGHT=V.WEIGHT*(V.MORN-V.SELL+V.ISPRAV-V.REMOV),
		             @PRICE=V.PRICE, 
                 @COST=V.COST, 
                 @UNIONWEIGHT=V.WEIGHT, 
                 @ORIGQTY=(V.MORN-V.SELL+V.ISPRAV-V.REMOV)
	  FROM TDVI V 
    JOIN FIRMSCONFIG F ON V.OUR_ID=F.OUR_ID
	  WHERE V.HITAG=@HITAG 
          AND V.WEIGHT>0
			    AND V.SKLAD IN (SELECT K FROM DBO.STR2INTARRAY(@SKLADLIST))
			    AND V.WEIGHT*(V.MORN-V.SELL+V.ISPRAV-V.REMOV)=@VES 
          AND V.LOCKED=0 
          AND (V.MORN-V.SELL+V.ISPRAV-V.REMOV)>0
			    AND F.FIRMGROUP=@FIRMGROUP
	  ORDER BY V.SROKH;
	  
    IF @ID IS NULL 
      SET @OK=0
	  ELSE 
    BEGIN  
			SET @OK=1
			SET @LASTID=@ORIGID
			SET @NEWCOST=@COST
			SET @NEWPRICE=@PRICE
			SET @NEWSKLAD=@SKLAD
			SET @QTY=@ORIGQTY
      /*
      SET @MSG=@MSG+CAST(GETDATE() AS VARCHAR)+CHAR(13)+CHAR(10)
      SET @MSG=@MSG+'ПОДБОР ТОЧНОГО ВЕСА:'+CHAR(13)+CHAR(10)
      SET @MSG=@MSG+'HOSTNAME='+@COMP+CHAR(13)+CHAR(10)
      SET @MSG=@MSG+'@LASTID<>0!!!='+CAST(@LASTID AS VARCHAR)+CHAR(13)+CHAR(10)
      SET @MSG=@MSG+'@SKLAD='+CAST(@SKLAD AS VARCHAR)+CHAR(13)+CHAR(10)
      SET @MSG=@MSG+'@PRICE='+CAST(@PRICE AS VARCHAR)+CHAR(13)+CHAR(10)
      SET @MSG=@MSG+'@COST='+CAST(@COST AS VARCHAR)+CHAR(13)+CHAR(10)
      SET @MSG=@MSG+'==============================================='+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)
			IF @MSG IS NULL SET @MSG='ХУЙНЯ ПОДБО ТОЧНОГО ВЕСА'+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)
      */
	  END;
    		
	  -- ПОДБОР КРАТНОГО ВЕСА:
	  IF @OK=0 
    BEGIN
			SELECT TOP 1 @ID=ID,
				           @ORIGID=V.ID, 
                   @SKLAD=V.SKLAD, 
                   @ORIGWEIGHT=V.WEIGHT*(V.MORN-V.SELL+V.ISPRAV-V.REMOV),
				           @PRICE=V.PRICE, 
                   @COST=V.COST, 
                   @UNIONWEIGHT=V.WEIGHT, 
                   @ORIGQTY=(V.MORN-V.SELL+V.ISPRAV-V.REMOV),
				           @QTY=IIF(@VES/V.WEIGHT=0,1,@VES/V.WEIGHT)
			FROM TDVI V JOIN FIRMSCONFIG F ON V.OUR_ID=F.OUR_ID
			WHERE V.HITAG=@HITAG 
            AND V.WEIGHT>0
				    AND V.SKLAD IN (SELECT K FROM DBO.STR2INTARRAY(@SKLADLIST))
				    AND @VES % V.WEIGHT=0
				    AND V.WEIGHT*(V.MORN-V.SELL+V.ISPRAV-V.REMOV)>@VES 
            AND V.LOCKED=0 
            AND (V.MORN-V.SELL+V.ISPRAV-V.REMOV)>0
				    AND F.FIRMGROUP=@FIRMGROUP
			ORDER BY V.SROKH;  
			
      IF @ID IS NULL 
        SET @OK=0
			ELSE 
      BEGIN
				SET @OK=1
				SET @LASTID=@ORIGID
				SET @NEWCOST=@COST
				SET @NEWPRICE=@PRICE
				SET @NEWSKLAD=@SKLAD
        /*
        SET @MSG=@MSG+CAST(GETDATE() AS VARCHAR)+CHAR(13)+CHAR(10)
        SET @MSG=@MSG+'ПОДБОР КРАТНОГО ВЕСА:'+CHAR(13)+CHAR(10)
        SET @MSG=@MSG+'HOSTNAME='+@COMP+CHAR(13)+CHAR(10)
        SET @MSG=@MSG+'@LASTID<>0!!!='+CAST(@LASTID AS VARCHAR)+CHAR(13)+CHAR(10)
        SET @MSG=@MSG+'@SKLAD='+CAST(@SKLAD AS VARCHAR)+CHAR(13)+CHAR(10)
        SET @MSG=@MSG+'@PRICE='+CAST(@PRICE AS VARCHAR)+CHAR(13)+CHAR(10)
        SET @MSG=@MSG+'@COST='+CAST(@COST AS VARCHAR)+CHAR(13)+CHAR(10)
        SET @MSG=@MSG+'==============================================='+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)
			  IF @MSG IS NULL SET @MSG='ХУЙНЯ ПОДБО КРАТНОГО ВЕСА'+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)
        */
			END;
	  END;
        
		-- ПОДБОР ЛЮБОГО ВЕСА:
	  IF @OK=0 
    BEGIN
		  SELECT TOP 1 @ID=ID,
			             @ORIGID=V.ID, 
                   @SKLAD=V.SKLAD, 
                   @ORIGWEIGHT=V.WEIGHT*(V.MORN-V.SELL+V.ISPRAV-V.REMOV),
			             @PRICE=V.PRICE, 
                   @COST=V.COST, 
                   @UNIONWEIGHT=V.WEIGHT, 
                   @ORIGQTY=(V.MORN-V.SELL+V.ISPRAV-V.REMOV)
		  FROM TDVI V JOIN FIRMSCONFIG F ON V.OUR_ID=F.OUR_ID
		  WHERE V.HITAG=@HITAG 
            AND V.WEIGHT>0
				    AND V.SKLAD IN (SELECT K FROM DBO.STR2INTARRAY(@SKLADLIST))
				    AND V.WEIGHT*(V.MORN-V.SELL+V.ISPRAV-V.REMOV)>@VES 
				    AND V.LOCKED=0 
            AND (V.MORN-V.SELL+V.ISPRAV-V.REMOV)>0
				    AND F.FIRMGROUP=@FIRMGROUP
		  ORDER BY V.WEIGHT DESC, V.SROKH
		  
		  IF @ID IS NULL 
        SET @OK=0
		  ELSE 
      BEGIN
				SET @OK=1;
				SET @QTY=CEILING(@VES/@UNIONWEIGHT);

				-- КАКУЮ СТРОКУ РАСПИЛИТЬ:
				INSERT INTO PARAMSKLAD(COMP,  ACT,  ID,  HITAG,  SKLAD,  [WEIGHT],  PRICE,  COST,  NOMER,  QTY) 
				VALUES (@COMP,  'DIV-',  @ORIGID,  @HITAG,  @SKLAD,  @UNIONWEIGHT,  @PRICE,  @COST, 0,  @QTY);
				IF @@ERROR<>0 SET @KOLERROR=@KOLERROR+2;

				-- НОВАЯ СТРОКА С ОСТАТКОМ ПРИ ЕДИНИЧНОМ ИСХОДНОМ КОЛИЧЕСТВЕ:
			  IF @ORIGQTY=1 BEGIN
					INSERT INTO PARAMSKLAD(COMP,  ACT,  ID,  HITAG,  SKLAD,  [WEIGHT],  PRICE,  COST,  NOMER,  QTY) 
					VALUES (@COMP,  'DIV-',  NULL,  @HITAG,  @SKLAD,  @UNIONWEIGHT-@VES,  
						@PRICE/@UNIONWEIGHT*(@UNIONWEIGHT-@VES), @COST/@UNIONWEIGHT*(@UNIONWEIGHT-@VES), 1,  1);
					IF @@ERROR<>0 SET @KOLERROR=@KOLERROR+4; 
			  END
				ELSE BEGIN
					INSERT INTO PARAMSKLAD(COMP,  ACT,  ID,  HITAG,  SKLAD,  [WEIGHT],  PRICE,  COST,  NOMER,  QTY) 
					VALUES (@COMP,  'DIV-',  NULL,  @HITAG,  @SKLAD,  
						@UNIONWEIGHT*@QTY-@VES,  
						@PRICE/@UNIONWEIGHT*(@UNIONWEIGHT*@QTY-@VES),  
						@COST/@UNIONWEIGHT*(@UNIONWEIGHT*@QTY-@VES), 1,  1);
					IF @@ERROR<>0 SET @KOLERROR=@KOLERROR+8; 
				END;
			 
			  -- ВТОРАЯ НОВАЯ СТРОКА, ЭТО БУДЕТ ПРОДАНО:
			  INSERT INTO PARAMSKLAD(COMP,  ACT,  ID,  HITAG,  SKLAD,  [WEIGHT],  PRICE,  COST,  NOMER,  QTY) 
			  VALUES (@COMP,  'DIV-',  NULL,  @HITAG,  @SKLAD,  @VES,  
					@PRICE*@VES/@UNIONWEIGHT,  @COST*@VES/@UNIONWEIGHT, 2,  1);
			  IF @@ERROR<>0 SET @KOLERROR=@KOLERROR+16

				SET @JUNK=0; SET @NEWID=0;
        
				IF @KOLERROR=0 
				BEGIN
                 SET @PROCERROR=-1;
        print('Перед вызовом ProcessSklad_nn')
        print('@Hitag='+cast(@Hitag as varchar));
        print('@OP='+cast(@Op as varchar));
        print('@Comp='+@Comp);
        print('@JUNK='+cast(@JUNK as varchar));
-- GOTO exxitt;

				 EXEC ProcessSklad_nn 'DIV-', NULL, @HITAG, NULL, 
							NULL, NULL, 0, @OP, @COMP,
							NULL, 0, 1,  0, 0,0,
							'ПРОДАЖА НА ВЕС', @NEWID OUTPUT,  0,
							@PROCERROR OUTPUT, NULL, @JUNK,NULL;


        print('После вызова ProcessSklad_nn')
        /*
        SET @MSG=@MSG+CAST(GETDATE() AS VARCHAR)+CHAR(13)+CHAR(10)
        SET @MSG=@MSG+'ВЫПОЛНЕНИЕ PROCESSSKLAD:'+CHAR(13)+CHAR(10)
        SET @MSG=@MSG+'HOSTNAME='+@COMP+CHAR(13)+CHAR(10)
        SET @MSG=@MSG+'@KOLERROR='+CAST(@KOLERROR AS VARCHAR)+CHAR(13)+CHAR(10)
        SET @MSG=@MSG+'@PROCERROR='+CAST(@PROCERROR AS VARCHAR)+CHAR(13)+CHAR(10)
        SET @MSG=@MSG+'@DATNOM='+CAST(@DATNOM AS VARCHAR)+CHAR(13)+CHAR(10)
        SET @MSG=@MSG+'@NEWID<>0!!!='+CAST(@NEWID AS VARCHAR)+CHAR(13)+CHAR(10)
        SET @MSG=@MSG+'@HITAG='+CAST(@HITAG AS VARCHAR)+CHAR(13)+CHAR(10)
        SET @MSG=@MSG+'@SKLAD='+CAST(@SKLAD AS VARCHAR)+CHAR(13)+CHAR(10)
        SET @MSG=@MSG+'@PRICE='+CAST(@PRICE AS VARCHAR)+CHAR(13)+CHAR(10)
        SET @MSG=@MSG+'@COST='+CAST(@COST AS VARCHAR)+CHAR(13)+CHAR(10)
        SET @MSG=@MSG+'@QTY='+CAST(@QTY AS VARCHAR)+CHAR(13)+CHAR(10)
        SET @MSG=@MSG+'@UNIONWEIGHT<>0!!!='+CAST(@UNIONWEIGHT AS VARCHAR)+CHAR(13)+CHAR(10)
        SET @MSG=@MSG+'==============================================='+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)
			  IF @MSG IS NULL SET @MSG='ХУЙНЯ ПРОЦЕСС СКЛАД'+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)		
        */
print('@PROCERROR='+cast(@PROCERROR as varchar));
print('@NEWID='+CAST(@NEWID AS VARCHAR));

        IF ISNULL(@PROCERROR,0)<>0 OR ISNULL(@NEWID,0)=0
						 SET @KOLERROR=@KOLERROR+32;
				END 
			
			
				IF @KOLERROR=0 
				BEGIN
					SET @LASTID=@NEWID;
					-- SELECT @LASTID=NEWID, @NEWCOST=NEWCOST, @NEWPRICE=NEWPRICE, @NEWSKLAD=NEWSKLAD FROM IZMEN WHERE IZMID=@LASTIZMID;
					SELECT @NEWCOST=COST, @NEWPRICE=PRICE, @NEWSKLAD=SKLAD FROM TDVI WHERE ID=@NEWID;
					IF @@ERROR<>0 SET @KOLERROR=@KOLERROR+64;
					SET @QTY=1;
				END
			END
		
		END;  -- КОНЕЦ БЛОКА ПОДБОРА ЛЮБОГО ВЕСА.




    -- ОПЕРАЦИИ ПОСЛЕ ПОДБОРА:
		IF @OK=0 SET @KOLERROR=1;
	  IF @KOLERROR=0 BEGIN
			UPDATE TDVI SET SELL=SELL+@QTY WHERE ID=@LASTID
			IF @@ERROR<>0 SET @KOLERROR=@KOLERROR+128;
      /*
      SET @MSG=@MSG+CAST(GETDATE() AS VARCHAR)+CHAR(13)+CHAR(10)
      SET @MSG=@MSG+'ОБНОВЛЕНИЕ TDVI:'+CHAR(13)+CHAR(10)
      SET @MSG=@MSG+'HOSTNAME='+@COMP+CHAR(13)+CHAR(10)
      SET @MSG=@MSG+'@KOLERROR='+CAST(@KOLERROR AS VARCHAR)+CHAR(13)+CHAR(10)
      SET @MSG=@MSG+'@LASTID='+CAST(@LASTID AS VARCHAR)+CHAR(13)+CHAR(10)
      SET @MSG=@MSG+'@QTY='+CAST(@QTY AS VARCHAR)+CHAR(13)+CHAR(10)
      SET @MSG=@MSG+'==============================================='+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)
      IF @MSG IS NULL SET @MSG='ХУЙНЯ ТДВИ'+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)	
      */
	  END;
	    
	  IF @KOLERROR=0 BEGIN
         SET @TEKKOL=(SELECT KOL FROM NV WHERE DATNOM=@DATNOM AND TEKID=@LASTID);
         IF @TEKKOL IS NULL 
            INSERT INTO NV(DATNOM,TEKID,HITAG,SKLAD,PRICE,COST,KOL,TIP)
                  VALUES(@DATNOM, @LASTID, @HITAG, @NEWSKLAD, @NEWPRICE, @NEWCOST, @QTY, 0);
         ELSE IF @TEKKOL=0
            UPDATE NV SET HITAG=@HITAG, SKLAD=@NEWSKLAD,PRICE=@NEWPRICE,COST=@NEWCOST, KOL=@QTY, TIP=0 WHERE DATNOM=@DATNOM AND TEKID=@LASTID;
         ELSE SET @KOLERROR=@KOLERROR+512;
       /*
       SET @MSG=@MSG+CAST(GETDATE() AS VARCHAR)+CHAR(13)+CHAR(10)
       SET @MSG=@MSG+'ОБНОВЛЕНИЕ NV:'+CHAR(13)+CHAR(10)
       SET @MSG=@MSG+'HOSTNAME='+@COMP+CHAR(13)+CHAR(10)
       SET @MSG=@MSG+'@KOLERROR='+CAST(@KOLERROR AS VARCHAR)+CHAR(13)+CHAR(10)
       SET @MSG=@MSG+'@DATNOM='+CAST(@DATNOM AS VARCHAR)+CHAR(13)+CHAR(10)
       SET @MSG=@MSG+'@LASTID='+CAST(@LASTID AS VARCHAR)+CHAR(13)+CHAR(10)
       SET @MSG=@MSG+'@HITAG='+CAST(@HITAG AS VARCHAR)+CHAR(13)+CHAR(10)
       SET @MSG=@MSG+'@BEWSKLAD='+CAST(@NEWSKLAD AS VARCHAR)+CHAR(13)+CHAR(10)
       SET @MSG=@MSG+'@NEWPRICE='+CAST(@NEWPRICE AS VARCHAR)+CHAR(13)+CHAR(10)
       SET @MSG=@MSG+'@NEWCOST='+CAST(@NEWCOST AS VARCHAR)+CHAR(13)+CHAR(10)
       SET @MSG=@MSG+'@QTY='+CAST(@QTY AS VARCHAR)+CHAR(13)+CHAR(10)
       SET @MSG=@MSG+'==============================================='+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)
       IF @MSG IS NULL SET @MSG='ХУЙНЯ НВ'+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)	
       */
	  END;
      
    IF @KOLERROR=0 
	  BEGIN    
	      UPDATE NVZAKAZ SET DONE=1,
		                       TMEND=CONVERT(VARCHAR(8),GETDATE(),108),
			                     DTEND=CONVERT(VARCHAR(10),GETDATE(),104),
			                     CURWEIGHT=@VES,
			                     TEKWEIGHT=@TEKWEIGHT,
			                     ID=@LASTID,
			                     COMP=COMP+'#'+@COMP,
                           OP=@OP,
                           SPK=@SPK
		    WHERE DATNOM=@DATNOM 
              AND HITAG=@HITAG 
              AND DONE=0;
	      
        IF @@ERROR<>0 SET @KOLERROR=@KOLERROR+1024;	
       /*
       SET @MSG=@MSG+CAST(GETDATE() AS VARCHAR)+CHAR(13)+CHAR(10)
       SET @MSG=@MSG+'ОБНОВЛЕНИЕ NVZAKAZ:'+CHAR(13)+CHAR(10)
       SET @MSG=@MSG+'HOSTNAME='+@COMP+CHAR(13)+CHAR(10)
       SET @MSG=@MSG+'@KOLERROR='+CAST(@KOLERROR AS VARCHAR)+CHAR(13)+CHAR(10)
       SET @MSG=@MSG+'@DATNOM='+CAST(@DATNOM AS VARCHAR)+CHAR(13)+CHAR(10)
       SET @MSG=@MSG+'@HITAG='+CAST(@HITAG AS VARCHAR)+CHAR(13)+CHAR(10)
       SET @MSG=@MSG+'@VES='+CAST(@VES AS VARCHAR)+CHAR(13)+CHAR(10)
       SET @MSG=@MSG+'@TEKWEIGHT='+CAST(@TEKWEIGHT AS VARCHAR)+CHAR(13)+CHAR(10)
       SET @MSG=@MSG+'@OP='+CAST(@OP AS VARCHAR)+CHAR(13)+CHAR(10)
       SET @MSG=@MSG+'@SPK='+CAST(@SPK AS VARCHAR)+CHAR(13)+CHAR(10)
       SET @MSG=@MSG+'==============================================='+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)
       IF @MSG IS NULL SET @MSG='ХУЙНЯ НВЗАКАЗ'+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)
       */	       
	  END
		
	END; 
  

exxitt:

END