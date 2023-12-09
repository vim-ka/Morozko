CREATE PROCEDURE dbo.MassSetPrice                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    
AS
DECLARE @ID INT, @Ncod int, @Hitag int, @Sklad smallint, @flgWeight bit, @Weight DECIMAL(10,3), @Cost DECIMAL(12,5), 
    @TekPrice DECIMAL(10,2), @NewPriceW DECIMAL(10,2), @NewPrice DECIMAL(10,2),
    @Cnt int, @SerialNom int, @KolErr INT, @Units VARCHAR(10), @MinP int, @Code1c varchar(20), @Koeff decimal(10,2)
BEGIN
  set @SerialNom=0;
  set @KolErr=0;
  DECLARE c1 CURSOR FAST_FORWARD FOR 
    SELECT 
      v.id, v.ncod, p.hitag, V.SKLAD, p.flgWeight, V.WEIGHT, V.COST, V.PRICE as TekPrice, 
      P.Price AS NewPrice,
      iif(P.flgWeight=1, P.Price*V.WEIGHT, 0) AS NewPriceW,
      P.units, P.MINP, P.Code1c
    FROM 
      TempRestPrice P
      -- inner JOIN tdVi V ON V.HITAG=P.hitag -- это для первой массированной переоценки по неопределенному списку ID
      inner JOIN tdVi V ON V.ID=P.ID -- а это для обратной переоценки, когда список ID известен и занарее прописан в TempRestPrice
    WHERE 
      P.ND=dbo.today() -- в этой таблице присутствует куча данных, но обрабатываются только текущие.
      and V.DCK=44283 
      AND P.hitag IS NOT NULL
      AND P.flgErr=0
      AND P.flgExists=1
      AND P.Suspicious=0
    order by v.id;
      

  OPEN c1;
  set @Cnt=0;
  FETCH NEXT FROM c1 INTO @ID, @Ncod, @Hitag, @Sklad, @flgWeight, @Weight, @Cost, @TekPrice, @NewPrice, @NewPriceW, @Units, @MinP,@Code1c
  WHILE @@fetch_status=0 BEGIN

    if @FlgWeight=1 set @NewPrice=@NewPriceW; -- для весового товара новая цена сразу умножена на массу
    ELSE IF @Units IN ('ящ','уп') SET @NewPrice=round(@NewPrice/@MinP,2)
    if @TekPrice<>@NewPrice begin

      set @Cnt=@Cnt+1;
      set @Koeff=round(@NewPrice/(@TekPrice+0.0001),1);

      --  update TempRestPrice set Suspicious=1 where Hitag=@Hitag and flgWeight=@flgWeight;

      
      if @Cnt<1000 begin -- выполняю только первую строку из списка, или серию заданной длины!
        PRINT cast(@cnt as varchar)+')  @ID='+cast(@ID as varchar)+',  @Hitag='+cast(@hitag as VARCHAR)+iif(@flgWeight=1,' (вес)','')
          +' ед.из='+@Units
          +' Цена='+CAST(@TekPrice as VARCHAR)+' ==> '+CAST(@NewPrice as varchar)
          +iif(@TekPrice=@NewPrice, ' - ПРОПУСК','')
          +'  K='+cast(@Koeff as varchar)
          +'  Code1c='+cast(@Code1c as varchar)

        exec ProcessSklad 'ИзмЦ', @ID, @Hitag, @Sklad,
          @NewPrice,@Cost,null,0,'IT4',
          null,0,0, 
          0,0,0, 
          'Массовая переоценка',0, @SerialNom, @KolErr;
      end;   
    end;

    FETCH NEXT FROM c1 INTO @ID, @Ncod, @Hitag, @Sklad, @flgWeight, @Weight, @Cost, @TekPrice, @NewPrice, @NewPriceW, @Units, @MinP,@Code1c
  END;
  CLOSE c1;
  DEALLOCATE c1;
END

/* Аргументы хранимой процедуры ProcessSklad:
  @Act char(4), @ID int, @NewHitag int=0, @NewSklad smallint, 
  @NewPrice decimal(10,2), @NewCost decimal(15,5),  @Delta int, @Op int, @Comp varchar(30),
  @irId int, @ServiceFlag bit=0, @DivFlag bit=0, 
  @TransmDec int=0, @TransmAdd int=0, -- эти два параметра - только для операции "Tran"
  @NewNcod int=0, -- А это для "Tran" и для "Div+" тоже
  @remark varchar(40), @Newid int out, 
  @SerialNom int=0 out,  -- Это и входной параметр тоже. Если 0, то вычисляется новый, иначе передается как есть
  @kolError int out, @Dck INT=0, @Junk int=0, 
  @NewWEIGHT decimal(12, 3)=0 -- это входной параметр для операции "Tran"
*/