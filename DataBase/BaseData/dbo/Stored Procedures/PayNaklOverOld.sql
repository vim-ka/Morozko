

CREATE PROCEDURE dbo.PayNaklOverOld @B_id int, @master int, @Plata money, @Remark varchar(60), @op int,
                                 @Bank_id int, @BankDay datetime, @Pay money OUTPUT, @DCK int=0, @Actn tinyint=0  with recompile
AS
BEGIN

  SET TRANSACTION ISOLATION LEVEL READ COMMITTED; 
  
  declare @DatNom_2 int,@NNak_2 int,@ND_2 datetime,@Fact_2 money, @B_id_2 int,@Sp_2 money,
          @Our_2 int, @Fam varchar(40), @DCKtek int
  declare @ND datetime, @TM char(8)
  declare @KolError int
  declare @TekPin int
  declare @datnom int
  declare @gpName varchar(40),@Srok int, @Our_ID int, @brAg_id int
  declare @DepID int
  
  create table #TempTable (DatNom int,ND datetime, NNak int,  Sp money,fact money, Our_id int,
                          Fam varchar(40), B_id int, DCK int);

  set @KolError=0
  
   /*курсор по закрытию накл*/
  DECLARE @CURSOR CURSOR 
   
  if @Plata>0 
  begin 
    SET @CURSOR  = CURSOR SCROLL
    FOR SELECT DatNom,Nd,NNAk,Fact,Sp,Our_id,Fam, B_id, DCK FROM #TempTable order by DatNom
  end
  else
  begin
    SET @CURSOR  = CURSOR SCROLL
    FOR SELECT DatNom,Nd,NNAk,Fact,Sp,Our_id,Fam, B_id, DCK FROM #TempTable order by DatNom desc
  end
  
BEGIN transaction trPayNaklOver;                           

if @DCK = 0 -- оплата по всем договорам
BEGIN

  if @master=0 
  begin  
    if @Plata>0 
    begin
     /*Находим их незакрытые накл*/
      insert into  #TempTable (DatNom,ND,NNak, Sp, fact,Our_id,Fam, B_id, DCK)
      select DatNom, dbo.DatNomInDate(nc.DatNom), 
             cast(RIGHT(nc.DatNom,4) as int),SP+Izmen ,Fact,Ourid,
             CAST(A.gpName as varchar(40)),B_id, DCK
      from NC
      cross apply
      (select d.gpName, d.pin from def d where d.pin=nc.B_id) A 
      where B_id=@B_id and SP+Izmen>Fact and actn=0 and Tara=0 and Frizer=0 
      order by DatNom
    end
    else
    if @Plata<0
    begin
        insert into  #TempTable (DatNom,ND,NNak, Sp, fact,Our_id,Fam, B_id, DCK)
        select SourDatNom,SourDate, NNak,0,Plata,Our_id,
               CAST(Fam as varchar(40)),B_id, DCK
        from Kassa1
        where oper=-2 and act='ВЫ' and B_id=@B_id and Plata>0
        order by SourDatNom desc
     end
  end
  else
  begin
    if @Plata>0 
    begin
     /*Находим их незакрытые накл*/
      insert into  #TempTable (DatNom,ND,NNak, Sp, fact,Our_id,Fam, B_id, DCK)
      select DatNom, dbo.DatNomInDate(nc.DatNom), 
             cast(RIGHT(nc.DatNom,4) as int),SP+Izmen ,Fact,Ourid,
             CAST(A.gpName as varchar(40)),B_id, DCK
      from NC
      cross apply 
      (select d.gpName, d.pin from def d where d.pin=nc.B_id) A 
      where B_id in (select pin from Def where master = @master) 
            and SP+Izmen>Fact and actn=0 and Tara=0 and Frizer=0 
      order by DatNom
    end
    else
     if @Plata<0
     begin
        insert into  #TempTable (DatNom,ND,NNak, Sp, fact,Our_id,Fam, B_id, DCK)
        Select SourDatNom,SourDate, NNak,0,Plata,Our_id,
               CAST(Fam as varchar(40)),B_id, DCK
        from Kassa1
        where B_id in (select pin from Def where master = @master) and 
           oper=-2 and act='ВЫ' and Plata>0
        order by SourDatNom desc
     end
  end
  
  select * from #TempTable
  
    OPEN @CURSOR 

    FETCH NEXT FROM @CURSOR INTO  @DatNom_2, @ND_2, @NNAk_2, @Fact_2, @Sp_2, @Our_2, @Fam, @B_id_2, @DCKtek
        
    WHILE @@FETCH_STATUS = 0 and @Plata!=0
    BEGIN
      set @DepID=(select DepID from agentlist where ag_id=(select c.ag_id from defcontract c where c.dck=@DCKtek))          
      if @Plata>0
      begin 
      /* если переплата <= Долга по накл 
        закрыть накл по переплате и закрыть накл с долгом*/
        if @Plata<=@Sp_2-@Fact_2
        begin
                                      
          insert into Kassa1(nd,tm,Oper,Act,SourDate,Nnak,Plata,Fam,P_ID,B_ID,V_ID,Ncod,Remark,
                RashFlag,LostFlag,LastFlag,Op,Bank_ID,Our_ID,BankDay,
                Actn,Ck,Thr,ThrFam,DocNom,OrigRecn,ForPrint,SourDatNom,StNom,FromBank_ID, DCK, DepID)  
                                     
          values (CONVERT(varchar,getdate(),104) ,CONVERT(varchar,getdate(),8),-2,
                  'ВЫ', @ND_2,@NNAk_2,@Plata,@Fam,0,@B_id_2,0,0,
                  @Remark,
                  0,0,0,@op, @Bank_id,@Our_2,@BankDay,@Actn,0,0,'',0,0,0,@DatNom_2,0,0, @DCKtek, @DepID)
          
          if @@Error<>0 set @KolError=@KolError + 1        
          set @Plata=0
                                    
        end
        else 
         /*если переплата > Долга по накл 
               закрыть накл по переплате и закрыть накл с долгом*/
          if @Plata>@Sp_2-@Fact_2
          begin
                                    
            insert into Kassa1(nd,tm,Oper,Act,SourDate,Nnak,Plata,Fam,P_ID,B_ID,V_ID,Ncod,
                Remark,RashFlag,LostFlag,LastFlag,Op,Bank_ID,Our_ID,BankDay,
                Actn,Ck,Thr,ThrFam,DocNom,OrigRecn,ForPrint,SourDatNom,StNom,FromBank_ID, DCK, DepID)  
                                          
            values (CONVERT(varchar,getdate(),104) ,CONVERT(varchar,getdate(),8),-2,
                    'ВЫ', @ND_2,@NNAk_2,@Sp_2-@Fact_2,@Fam,0,@B_id_2,0,0,
                    @Remark,
                    0,0,0,@op, @Bank_id,@Our_2,@BankDay,@Actn,0,0,'',0,0,0,@DatNom_2,0,0, @DCKtek, @DepID)
            if @@Error<>0 set @KolError=@KolError + 1        
            set @Plata=@Plata-(@Sp_2-@Fact_2)  
          end 
      end 
      else
        if @Plata<0 
        begin
          if @Plata+@Fact_2<0
          begin                               
            insert into Kassa1(nd,tm,Oper,Act,SourDate,Nnak,Plata,Fam,P_ID,B_ID,V_ID,Ncod,Remark,
                  RashFlag,LostFlag,LastFlag,Op,Bank_ID,Our_ID,BankDay,
                  Actn,Ck,Thr,ThrFam,DocNom,OrigRecn,ForPrint,SourDatNom,StNom,FromBank_ID, DCK)  
                                       
            values (CONVERT(varchar,getdate(),104) ,CONVERT(varchar,getdate(),8),-2,
                    'ВЫ', @ND_2,@NNAk_2,-@Fact_2,@Fam,0,@B_id_2,0,0,
                    @Remark,
                    0,0,0,@op, @Bank_id,@Our_2,@BankDay,@Actn,0,0,'',0,0,0,@DatNom_2,0,0, @DCKtek)
            if @@Error<>0 set @KolError=@KolError + 1        
             
            set @Plata=@Plata+@Fact_2
          end
          else
            if @Plata+@Fact_2>=0
            begin
              insert into Kassa1(nd,tm,Oper,Act,SourDate,Nnak,Plata,Fam,P_ID,B_ID,V_ID,Ncod,Remark,
                    RashFlag,LostFlag,LastFlag,Op,Bank_ID,Our_ID,BankDay,
                    Actn,Ck,Thr,ThrFam,DocNom,OrigRecn,ForPrint,SourDatNom,StNom,FromBank_ID, DCK, DepID)  
                                         
              values (CONVERT(varchar,getdate(),104) ,CONVERT(varchar,getdate(),8),-2,
                      'ВЫ', @ND_2,@NNAk_2,@Plata,@Fam,0,@B_id_2,0,0,
                      @Remark,
                      0,0,0,@op, @Bank_id,@Our_2,@BankDay,@Actn,0,0,'',0,0,0,@DatNom_2,0,0, @DCKtek, @DepID)
              if @@Error<>0 set @KolError=@KolError + 1        
              set @Plata=0
            end 
        end      
      FETCH NEXT FROM @CURSOR INTO  @DatNom_2,@ND_2,@NNAk_2, @Fact_2, @Sp_2,@Our_2,@Fam,@B_id_2, @DCKTek
    END
    CLOSE @CURSOR
  
  drop table #TempTable; 
  
  if @Plata > 0 
  begin
    if @NNak_2 <= 0
    begin 
      select @DatNom_2 = datnom,@ND_2 = nd,@NNAk_2 = cast(RIGHT(nc.DatNom,4) as int) , @Fact_2 = fact, @Sp_2 = sp,@Our_2=ourid,@Fam = fam,@B_id_2 = b_id,
             @gpName=cast(A.gpName as varchar(40)), @DCKTek = DCK
      from NC
      left join
      (select gpName,pin from def)A on A.pin=B_id
      where B_id=@B_id and actn=0 and Tara=0 and Frizer=0 and datnom = (select max(datnom) from nc where b_id=@B_id) 
    end  
    if @NNak_2 > 0 
    begin
      set @DepID=(select DepID from agentlist where ag_id=(select c.ag_id from defcontract c where c.dck=@DCKtek))      
      insert into Kassa1(nd,tm,Oper,Act,SourDate,Nnak,Plata,Fam,P_ID,B_ID,V_ID,Ncod,Remark,
                       RashFlag,LostFlag,LastFlag,Op,Bank_ID,Our_ID,BankDay,
                       Actn,Ck,Thr,ThrFam,DocNom,OrigRecn,ForPrint,SourDatNom,StNom,FromBank_ID, DCK, DepID)  
                                         
      values (CONVERT(varchar,getdate(),104) ,CONVERT(varchar,getdate(),8),-2,
                       'ВЫ', @ND_2,@NNAk_2,@Plata,@Fam,0,@B_id_2,0,0,
                       @Remark,
                       0,0,0,@op, @Bank_id,@Our_2,@BankDay,@Actn,0,0,'',0,0,0,@DatNom_2,0,0, @DCKTek, @DepID)
      if @@Error<>0 set @KolError=@KolError + 1                 
      set @Plata = 0               
    end                 
    else -- вставка пустой накладной для проведения аванса
    begin
      if @op<1000 
      begin
        if @master>0  set @TekPin=@master
        else set @TekPin=@B_id
      
        set @DCKTek = (select min(DCK) from DefContract where pin=@TekPin and ContrTip=2 and Actual=1)
        
        if @DCKTek>0 
        begin        
          set @DepID=(select DepID from agentlist where ag_id=(select c.ag_id from defcontract c where c.dck=@DCKtek))      
          set @ND=convert(char(10), getdate(),104);
          set @TM=convert(char(8), getdate(),108);
          
        
              
          select @gpName=gpName, @Our_ID=Our_ID,@Srok=Srok,@brAg_id=brAg_id
          from Def where pin=@TekPin 
      
          set @datnom=1+isnull((select max(datnom) from Nc where Nd=@ND),dbo.InDatNom(0,@ND));  
      
          insert into NC (ND,datnom,B_ID,Fam,Tm,OP,SP,SC,Extra,Srok,OurID,Pko,Man_ID, 
                       BankId,TovChk,Frizer,ag_id,stfnom,stfdate,tomorrow,qtyFriz,
    	               Remark,Printed,Marsh,BoxQty,WEIGHT,Actn,CK,Tara,
                       RefDatnom,MarshDay,Sk50prn, Done, Izmen, RemarkOp, DayShift,Comp, Sk50present, DCK)
                values (@ND,@datnom,@TekPin,left(@gpName,35),convert(char(8), getdate(),108),@op,0,0,
     	             0,@Srok,@Our_ID,0,0/*@Man_ID*/, 0,0,0,@brAg_id,0,0,0,0,
	                 'для предоплаты',0,0,0,0,0,0,0,0,0,0, 0, 0.0, 'для предоплаты',0, '', 0, @DCKTek);
          if @@Error<>0 set @KolError=@KolError + 1  
          insert into Kassa1(nd,tm,Oper,Act,SourDate,Nnak,Plata,Fam,P_ID,B_ID,V_ID,Ncod,Remark,
                        RashFlag,LostFlag,LastFlag,Op,Bank_ID,Our_ID,BankDay,
                        Actn,Ck,Thr,ThrFam,DocNom,OrigRecn,ForPrint,SourDatNom,StNom,FromBank_ID, DCK, DepID)  
                                         
                values (CONVERT(varchar,getdate(),104) ,CONVERT(varchar,getdate(),8),-2,
                       'ВЫ', @ND, dbo.INNnak(@DatNom),@Plata,@gpName,0,@TekPin,0,0,
                       @Remark,  0,0,0,@op, @Bank_id, @Our_ID, @BankDay,@Actn,0,0,'',0,0,0,@DatNom,0,0, @DCKTek, @DepID)
          if @@Error<>0 set @KolError=@KolError + 1             
          set @Plata = 0        
        end
      end
    end
  end
END
ELSE --*************************оплата по конкретному договору*******************************
BEGIN


  if @B_id=0 set @B_id=(select pin from DefContract where Dck=@Dck)
  set @DepID=(select DepID from agentlist where ag_id=(select c.ag_id from defcontract c where c.dck=@DCK))

	if @master=0 
	begin  
    if @Plata>0 
    begin
     /*Находим их незакрытые накл*/
      insert into  #TempTable (DatNom,ND,NNak, Sp, fact,Our_id,Fam, B_id, DCK)
      select DatNom, dbo.DatNomInDate(nc.DatNom), 
             cast(RIGHT(nc.DatNom,4) as int),SP+Izmen ,Fact,Ourid,
             CAST(A.gpName as varchar(40)),B_id, DCK
      from NC
      left join
      (select gpName,pin from def)A on A.pin=B_id
      where B_id=@B_id and DCK=@Dck and SP+Izmen>Fact and actn=0 and Tara=0 
            and Frizer=0 
      order by DatNom
    end
    else
    if @Plata<0
    begin
        insert into  #TempTable (DatNom,ND,NNak, Sp, fact,Our_id,Fam, B_id, DCK)
        select SourDatNom,SourDate, NNak,0,Plata,Our_id,
               CAST(Fam as varchar(40)),B_id, DCK
        from Kassa1
        where oper=-2 and act='ВЫ' and B_id=@B_id and DCK = @DCK and Plata>0
        order by SourDatNom desc
     end
    
	end
	else --master>0
	begin
    if @Plata>0 
    begin
     /*Находим их незакрытые накл*/
      insert into  #TempTable (DatNom,ND,NNak, Sp, fact,Our_id,Fam, B_id, DCK)
      select DatNom, dbo.DatNomInDate(nc.DatNom), 
             cast(RIGHT(nc.DatNom,4) as int),SP+Izmen ,Fact,Ourid,
             CAST(A.gpName as varchar(40)),B_id, DCK
      from NC left join
              (select gpName,pin from def)A on A.pin=B_id
      where B_id in (select pin from Def where master = @master) 
            and SP+Izmen>Fact and actn=0 and Tara=0 and Frizer=0 
      order by DatNom
    end
    else
      if @Plata<0
      begin
        insert into  #TempTable (DatNom,ND,NNak, Sp, fact,Our_id,Fam, B_id, DCK)
        Select SourDatNom,SourDate, NNak,0,Plata,Our_id,
               CAST(Fam as varchar(40)),B_id, DCK
        from Kassa1
        where B_id in (select pin from Def where master = @master) and 
           oper=-2 and act='ВЫ' and Plata>0
        order by SourDatNom desc
      end
	end
    
     /*курсор по закрытию накл*/
  OPEN @CURSOR 

  FETCH NEXT FROM @CURSOR INTO  @DatNom_2, @ND_2, @NNAk_2, @Fact_2, @Sp_2, @Our_2, @Fam, @B_id_2, @DCKtek
        
  WHILE @@FETCH_STATUS = 0 and @Plata!=0
  BEGIN
     
    if @Plata>0
    begin 
    /* если переплата <= Долга по накл 
     закрыть накл по переплате и закрыть накл с долгом*/
      if @Plata<=@Sp_2-@Fact_2
      begin
                                   
          insert into Kassa1(nd,tm,Oper,Act,SourDate,Nnak,Plata,Fam,P_ID,B_ID,V_ID,Ncod,Remark,
                RashFlag,LostFlag,LastFlag,Op,Bank_ID,Our_ID,BankDay,
                Actn,Ck,Thr,ThrFam,DocNom,OrigRecn,ForPrint,SourDatNom,StNom,FromBank_ID, DCK, DepID)  
                                     
          values (CONVERT(varchar,getdate(),104) ,CONVERT(varchar,getdate(),8),-2,
                  'ВЫ', @ND_2,@NNAk_2,@Plata,@Fam,0,@B_id_2,0,0,
                  @Remark,
                  0,0,0,@op, @Bank_id,@Our_2,@BankDay,@Actn,0,0,'',0,0,0,@DatNom_2,0,0, @DCKtek, @DepID)
          if @@Error<>0 set @KolError=@KolError + 1        
          set @Plata=0
                                    
      end
      else 
         /*если переплата > Долга по накл 
               закрыть накл по переплате и закрыть накл с долгом*/
        if @Plata>@Sp_2-@Fact_2
        begin
                                    
           insert into Kassa1(nd,tm,Oper,Act,SourDate,Nnak,Plata,Fam,P_ID,B_ID,V_ID,Ncod,
                Remark,RashFlag,LostFlag,LastFlag,Op,Bank_ID,Our_ID,BankDay,
                Actn,Ck,Thr,ThrFam,DocNom,OrigRecn,ForPrint,SourDatNom,StNom,FromBank_ID, DCK, DepID)  
                                          
                        values (CONVERT(varchar,getdate(),104) ,CONVERT(varchar,getdate(),8),-2,
                    'ВЫ', @ND_2,@NNAk_2,@Sp_2-@Fact_2,@Fam,0,@B_id_2,0,0,
                    @Remark,
                    0,0,0,@op, @Bank_id,@Our_2,@BankDay,@Actn,0,0,'',0,0,0,@DatNom_2,0,0, @DCKtek, @DepID)
            if @@Error<>0 set @KolError=@KolError + 1        
            set @Plata=@Plata-(@Sp_2-@Fact_2)                
        end 
    end 
    else
      if @Plata<0 
      begin
        if @Plata+@Fact_2<0
        begin                               
          insert into Kassa1(nd,tm,Oper,Act,SourDate,Nnak,Plata,Fam,P_ID,B_ID,V_ID,Ncod,Remark,
                  RashFlag,LostFlag,LastFlag,Op,Bank_ID,Our_ID,BankDay,
                  Actn,Ck,Thr,ThrFam,DocNom,OrigRecn,ForPrint,SourDatNom,StNom,FromBank_ID, DCK)  
                                       
          values (CONVERT(varchar,getdate(),104) ,CONVERT(varchar,getdate(),8),-2,
                    'ВЫ', @ND_2,@NNAk_2,-@Fact_2,@Fam,0,@B_id_2,0,0,
                    @Remark,
                    0,0,0,@op, @Bank_id,@Our_2,@BankDay,@Actn,0,0,'',0,0,0,@DatNom_2,0,0, @DCKtek)
          if @@Error<>0 set @KolError=@KolError + 1          
          set @Plata=@Plata+@Fact_2
        end
        else
        if @Plata+@Fact_2>=0
        begin
          insert into Kassa1(nd,tm,Oper,Act,SourDate,Nnak,Plata,Fam,P_ID,B_ID,V_ID,Ncod,Remark,
                    RashFlag,LostFlag,LastFlag,Op,Bank_ID,Our_ID,BankDay,
                    Actn,Ck,Thr,ThrFam,DocNom,OrigRecn,ForPrint,SourDatNom,StNom,FromBank_ID, DCK, DepID)  
                                         
          values (CONVERT(varchar,getdate(),104) ,CONVERT(varchar,getdate(),8),-2,
                      'ВЫ', @ND_2,@NNAk_2,@Plata,@Fam,0,@B_id_2,0,0,
                      @Remark,
                      0,0,0,@op, @Bank_id,@Our_2,@BankDay,@Actn,0,0,'',0,0,0,@DatNom_2,0,0, @DCKtek, @DepID)
          if @@Error<>0 set @KolError=@KolError + 1            
          set @Plata=0
        end 
      end      
    FETCH NEXT FROM @CURSOR INTO  @DatNom_2,@ND_2,@NNAk_2, @Fact_2, @Sp_2,@Our_2,@Fam,@B_id_2, @DCKTek
  END
  CLOSE @CURSOR
  
  drop table #TempTable; 
  
  if @Plata > 0 
  begin
    if @NNak_2 <= 0
    begin 
      select @DatNom_2 = datnom,@ND_2 = nd,@NNAk_2 = cast(RIGHT(nc.DatNom,4) as int) , @Fact_2 = fact, @Sp_2 = sp,@Our_2=ourid,@Fam = fam,@B_id_2 = b_id,
             @gpName=cast(A.gpName as varchar(40)), @DCKTek = DCK
      from NC
      left join (select gpName,pin from def)A on A.pin=B_id
      where B_id=@B_id and actn=0 and Tara=0 and Frizer=0 and datnom = (select max(datnom) from nc where b_id=@B_id and DCK=@DCK) 
    end  
    if @NNak_2 > 0 
    begin
      insert into Kassa1(nd,tm,Oper,Act,SourDate,Nnak,Plata,Fam,P_ID,B_ID,V_ID,Ncod,Remark,
                       RashFlag,LostFlag,LastFlag,Op,Bank_ID,Our_ID,BankDay,
                       Actn,Ck,Thr,ThrFam,DocNom,OrigRecn,ForPrint,SourDatNom,StNom,FromBank_ID, DCK, DepID)  
                                         
      values (CONVERT(varchar,getdate(),104) ,CONVERT(varchar,getdate(),8),-2,
                       'ВЫ', @ND_2,@NNAk_2,@Plata,@Fam,0,@B_id_2,0,0,
                       @Remark,
                       0,0,0,@op, @Bank_id,@Our_2,@BankDay,@Actn,0,0,'',0,0,0,@DatNom_2,0,0, @DCKTek, @DepID)
      if @@Error<>0 set @KolError=@KolError + 1                 
      set @Plata = 0               
    end                 
    else -- вставка пустой накладной для проведения аванса
    begin
      if @op<1000 
      begin
        if @master>0  set @TekPin=@master
        else set @TekPin=@B_id
        
        set @DCKTek=(select min(DCK) from DefContract where ContrTip=2 and pin=@TekPin)
      
        set @ND=convert(char(10), getdate(),104);
        set @TM=convert(char(8), getdate(),108);
      
        select @gpName=gpName, @Our_ID=Our_ID,@Srok=Srok,@brAg_id=brAg_id
        from Def where pin=@TekPin 
      
        set @datnom=1+isnull((select max(datnom) from Nc where Nd=@ND),dbo.InDatNom(0,@ND));  
    
        insert into NC (ND,datnom,B_ID,Fam,Tm,OP,SP,SC,Extra,Srok,OurID,Pko,Man_ID, 
                       BankId,TovChk,Frizer,ag_id,stfnom,stfdate,tomorrow,qtyFriz,
    	               Remark,Printed,Marsh,BoxQty,WEIGHT,Actn,CK,Tara,
                       RefDatnom,MarshDay,Sk50prn, Done, Izmen, RemarkOp, DayShift,Comp, Sk50present, DCK)
              values (@ND,@datnom,@TekPin,left(@gpName,35),convert(char(8), getdate(),108),@op,0,0,
     	             0,@Srok,@Our_ID,0,0/*@Man_ID*/, 0,0,0,@brAg_id,0,0,0,0,
	                 'для предоплаты',0,0,0,0,0,0,0,0,0,0, 0, 0.0, 'для предоплаты',0, '', 0, @DCKTek);
        if @@Error<>0 set @KolError=@KolError + 1  
        insert into Kassa1(nd,tm,Oper,Act,SourDate,Nnak,Plata,Fam,P_ID,B_ID,V_ID,Ncod,Remark,
                        RashFlag,LostFlag,LastFlag,Op,Bank_ID,Our_ID,BankDay,
                        Actn,Ck,Thr,ThrFam,DocNom,OrigRecn,ForPrint,SourDatNom,StNom,FromBank_ID, DCK, DepID)  
                                         
        values (CONVERT(varchar,getdate(),104) ,CONVERT(varchar,getdate(),8),-2,
                       'ВЫ', @ND, dbo.INNnak(@DatNom),@Plata,@gpName,0,@TekPin,0,0,
                       @Remark,  0,0,0,@op, @Bank_id, @Our_ID, @BankDay,@Actn,0,0,'',0,0,0,@DatNom,0,0, @DCKTek, @DepID)
        if @@Error<>0 set @KolError=@KolError + 1              
        set @Plata = 0        
      end
    end
  end
END


 --разблокировка точек 
  DECLARE @Overdue money, @Dis bit
  
    if @master=0 
    begin
      set @Dis=(select disab from Def where pin=@B_id);
      if @Dis=1
      begin
        set @Overdue=(select isnull(sum(nc.SP-isnull(nc.Fact,0)+isnull(NC.Izmen,0)),0) from nc
                      where nc.b_id=@b_id and nc.srok>0
                      and nc.SP-isnull(nc.Fact,0)+isnull(NC.Izmen,0)>1
                      and nc.ND+2+nc.Srok<GetDate()
                      and nc.Actn=0 and nc.Tara=0 and NC.Frizer=0
                      and nc.SP>0)
             
        if not (@Overdue>0) update Def set Disab=0 where tip=1 and pin=@b_id

      end
    end
    else
    begin
      select pin into #Temp002 from Def where master=@master and tip=1 and Disab=0
      
      update Def set Disab=0 where master=@master;
      
      select b_id as pin into #Temp001 from nc
      where 
        nc.b_id in (select pin from Def where tip=1 and MASTER=@master) and nc.srok>0
        and nc.SP-isnull(nc.Fact,0)+isnull(NC.Izmen,0)>0
        and nc.ND+2+nc.Srok<GetDate()
        and nc.Actn=0 and nc.Tara=0 and NC.Frizer=0
      order by b_id;
      
      update Def set Disab=1 where tip=1 and pin in (select pin from #Temp001)
      drop table #Temp001;
      
      update Def set Disab=0 where tip=1 and pin in (select pin from #Temp002)
      drop table #Temp002;
      
    end 
if @KolError = 0 COMMIT ELSE ROLLBACK;      
    set @Pay=@Plata
    select @Pay
END