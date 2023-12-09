CREATE PROCEDURE dbo.[PayAllOver] @B_id int, @master int, @Plata money,@Remark varchar(60), @op int,
              @Bank_id int,@BankDay datetime, @Thr int ,@Actn tinyint, @Ck tinyint, @thrFam  varchar(40),
              @Pay money OUTPUT
AS
BEGIN
  DECLARE @DatNom_2 int,@NNak_2 int,@ND_2 datetime,@Fact_2 money, @B_id_2 int,@Sp_2 money,
          @Our_2 int, @Fam varchar(40), @Pl_ money;
    Create table #TableNC(DatNom int,Pay money,NDS0 money,NDS10 money,NDS18 money);
    create table #Table2 (DatNom int,ND datetime, NNAk int,  Sp money,fact money, Our_id int,
                          Fam varchar(40), B_id int);
                          
 if @bankday is not null set @bankday=cast(floor(cast(@bankday as decimal(38,19))) as datetime)                       
 
 if @master=0 
begin  
    if @Plata>0 
    begin
     /*Находим их незакрытые накл*/
     insert into  #Table2 (DatNom,ND,NNak, Sp, fact,Our_id,Fam, B_id)
      select DatNom, dbo.DatNomInDate(nc.DatNom), 
             cast(RIGHT(nc.DatNom,4) as int),SP+Izmen ,Fact,Ourid,
             CAST(A.gpName as varchar(40)),B_id
      from NC
      left join
      (select gpName,pin from def where tip=1)A on A.pin=B_id
      where B_id=@B_id and SP+Izmen>Fact and actn=0 and Tara=0 
            and Frizer=0 
      order by DatNom
    end
    else
     if @Plata<0
     begin
        insert into  #Table2 (DatNom,ND,NNak, Sp, fact,Our_id,Fam, B_id)
        Select SourDatNom,SourDate, NNak,0,Plata,Our_id,
               CAST(Fam as varchar(40)),B_id
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
      insert into  #Table2 (DatNom,ND,NNak, Sp, fact,Our_id,Fam, B_id)
      select DatNom, dbo.DatNomInDate(nc.DatNom), 
             cast(RIGHT(nc.DatNom,4) as int),SP+Izmen ,Fact,Ourid,
             CAST(A.gpName as varchar(40)),B_id
      from NC
      left join
      (select gpName,pin from def where tip=1)A on A.pin=B_id
      where B_id in (select pin from Def where master=@master and tip=1) 
            and SP+Izmen>Fact and actn=0 and Tara=0 
            and Frizer=0 
      order by DatNom
    end
    else
     if @Plata<0
     begin
        insert into  #Table2 (DatNom,ND,NNak, Sp, fact,Our_id,Fam, B_id)
        Select SourDatNom,SourDate, NNak,0,Plata,Our_id,
               CAST(Fam as varchar(40)),B_id
        from Kassa1
        where B_id in (select pin from Def where master=@master and tip=1) and 
           oper=-2 and act='ВЫ' and Plata>0
        order by SourDatNom desc
     end
end

  create table #Temp001 (DatNom int ,SDate datetime, DatNumber int, Sp money, Sp_B money,
              Ourid int,NDSf bit, Nds10 money,Nds18 money,Nds0 money, NDS10sum money, NDS18sum money);
    
     /*курсор по закрытию накл*/
     DECLARE @CURSOR CURSOR 
    SET @CURSOR  = CURSOR SCROLL
    FOR SELECT DatNom,Nd,NNAk,Fact,Sp,Our_id,Fam, B_id FROM #Table2

    OPEN @CURSOR 

    FETCH NEXT FROM @CURSOR INTO  @DatNom_2,@ND_2,@NNAk_2, @Fact_2, @Sp_2,@Our_2,@Fam,@B_id_2
        
    WHILE @@FETCH_STATUS = 0 and @Plata!=0
    BEGIN
             
      if @Plata>0
      begin 
      /* если переплата <= Долга по накл 
        закрыть накл по переплате и закрыть накл с долгом*/
         if @Plata<=@Sp_2-@Fact_2
        begin
            
                            
          Insert into Kassa2(nd,tm,Oper,Act,SourDate,Nnak,Plata,Fam,P_ID,B_ID,V_ID,Ncod,Remark,
                RashFlag,LostFlag,LastFlag,Op,Bank_ID,Our_ID,BankDay,
                Actn,Ck,Thr,ThrFam,DocNom,OrigRecn,ForPrint,SourDatNom,StNom,FromBank_ID,B_idPlat)  
                                     
          values (CONVERT(varchar,getdate(),104) ,CONVERT(varchar,getdate(),8),-2,
                  'ВЫ', @ND_2,@NNAk_2,@Plata,@Fam,0,@B_id_2,0,0,
                  @Remark,
                  0,0,0,@op, @Bank_id,@Our_2,@BankDay,@Actn,@ck,@thr,@ThrFam,0,0,0,@DatNom_2,0,0,@B_id)
          
          if @Ck>0
          begin
          
            insert into #Temp001
            EXEC CalcNsdSumPay @B_id, @Plata , @DatNom_2
            
            if @Ck=1
            begin 
              Insert into Ck_ (nd, tm, B_ID, Op,Plata , NDS0, NDS10, NDS18,Our_ID, Remark)
              select CONVERT(varchar,getdate(),4) ,CONVERT(varchar,getdate(),8),
                     @B_id_2, @op,@Plata,0, NDS10sum, NDS18sum,
                     @Our_2, 'ДатаПрод='+CONVERT(varchar,@ND_2,4)+
                             ', №накл='+cast(@NNAk_2 as varchar(4))+', ДатаОпл='+CONVERT(varchar,getdate(),4)
              from #Temp001
              
              insert into #TableNC 
              select @DatNom_2,@Plata,NDS0,NDS10,NDS18
              from #Temp001 
            end
            
            if @Ck=3
            begin
              Insert into Ck_ (nd, tm, B_ID, Op,Plata , NDS0, NDS10, NDS18,Our_ID, Remark)
              values (CONVERT(varchar,getdate(),4) ,CONVERT(varchar,getdate(),8),
                     @B_id_2, @op,@Plata,0, 0, 0,
                     @Our_2, 'Розничные чеки') 
                     
               insert into #TableNC 
              select @DatNom_2,@Plata,0,0,0
              from #Temp001 
            end
            
            delete #Temp001

          end
                  

          set @Plata=0
                                    
        end
        else 
         /*если переплата > Долга по накл 
               закрыть накл по переплате и закрыть накл с долгом*/
           if @Plata>@Sp_2-@Fact_2
          begin  
                                
             Insert into Kassa2(nd,tm,Oper,Act,SourDate,Nnak,Plata,Fam,P_ID,B_ID,V_ID,Ncod,
                Remark,RashFlag,LostFlag,LastFlag,Op,Bank_ID,Our_ID,BankDay,
                Actn,Ck,Thr,ThrFam,DocNom,OrigRecn,ForPrint,SourDatNom,StNom,FromBank_ID,B_idPlat)  
                                          
            values (CONVERT(varchar,getdate(),104) ,CONVERT(varchar,getdate(),8),-2,
                    'ВЫ', @ND_2,@NNAk_2,@Sp_2-@Fact_2,@Fam,0,@B_id_2,0,0,
                    @Remark,
                    0,0,0,@op, @Bank_id,@Our_2,@BankDay,@Actn,@ck,@thr,@ThrFam,0,0,0,@DatNom_2,0,0,@B_id)
                    
            if @Ck>0
            begin
              set @pl_=@Sp_2-@Fact_2
                   
              insert into #Temp001
              EXEC CalcNsdSumPay @B_id, @pl_ , @DatNom_2
              
              if @Ck=1
              begin 
               Insert into Ck_ (nd, tm, B_ID, Op,Plata , NDS0, NDS10, NDS18,Our_ID, Remark)
              select CONVERT(varchar,getdate(),4) ,CONVERT(varchar,getdate(),8),
                     @B_id_2, @op,@pl_,0, NDS10sum, NDS18sum,
                     @Our_2, 'ДатаПрод='+CONVERT(varchar,@ND_2,4)+
                             ', №накл='+cast(@NNAk_2 as varchar(4))+', ДатаОпл='+CONVERT(varchar,getdate(),4)
              from #Temp001
              
              insert into #TableNC 
              select @DatNom_2,@pl_,NDS0,NDS10,NDS18
              from #Temp001 
            end
            
            if @Ck=3
            begin
              Insert into Ck_ (nd, tm, B_ID, Op,Plata , NDS0, NDS10, NDS18,Our_ID, Remark)
              values (CONVERT(varchar,getdate(),4) ,CONVERT(varchar,getdate(),8),
                     @B_id_2, @op,@pl_,0, 0, 0,
                     @Our_2, 'Розничные чеки')
              insert into #TableNC
               
              select @DatNom_2,@pl_,0,0,0
              from #Temp001 
            end
            
            delete #Temp001
            end             
            set @Plata=@Plata-(@Sp_2-@Fact_2)                
          end 
      end 
      else
        if @Plata<0 
        begin
          if @Plata+@Fact_2<0
          begin  
            insert into #TableNC VALUES (@DatNom_2,-@Fact_2,0,0,0)                             
            Insert into Kassa2(nd,tm,Oper,Act,SourDate,Nnak,Plata,Fam,P_ID,B_ID,V_ID,Ncod,Remark,
                  RashFlag,LostFlag,LastFlag,Op,Bank_ID,Our_ID,BankDay,
                  Actn,Ck,Thr,ThrFam,DocNom,OrigRecn,ForPrint,SourDatNom,StNom,FromBank_ID,B_idPlat)  
                                       
            values (CONVERT(varchar,getdate(),104) ,CONVERT(varchar,getdate(),8),-2,
                    'ВЫ', @ND_2,@NNAk_2,-@Fact_2,@Fam,0,@B_id_2,0,0,
                    @Remark,
                    0,0,0,@op, @Bank_id,@Our_2,@BankDay,@Actn,@ck,@thr,@ThrFam,0,0,0,@DatNom_2,0,0,@B_id)
            set @Plata=@Plata+@Fact_2
          end
          else
            if @Plata+@Fact_2>=0
            begin
              insert into #TableNC VALUES (@DatNom_2,@Plata,0,0,0) 
              Insert into Kassa2(nd,tm,Oper,Act,SourDate,Nnak,Plata,Fam,P_ID,B_ID,V_ID,Ncod,Remark,
                    RashFlag,LostFlag,LastFlag,Op,Bank_ID,Our_ID,BankDay,
                    Actn,Ck,Thr,ThrFam,DocNom,OrigRecn,ForPrint,SourDatNom,StNom,FromBank_ID,B_idPlat)  
                                         
              values (CONVERT(varchar,getdate(),104) ,CONVERT(varchar,getdate(),8),-2,
                      'ВЫ', @ND_2,@NNAk_2,@Plata,@Fam,0,@B_id_2,0,0,
                      @Remark,
                      0,0,0,@op, @Bank_id,@Our_2,@BankDay,@Actn,@ck,@thr,@ThrFam,0,0,0,@DatNom_2,0,0,@B_id)
              set @Plata=0
            end 
        end      
      FETCH NEXT FROM @CURSOR INTO  @DatNom_2,@ND_2,@NNAk_2, @Fact_2, @Sp_2,@Our_2,@Fam,@B_id_2
    END
    CLOSE @CURSOR
  
  drop table #Table2; 

  set @Pay=@Plata
  
  if @Plata > 0 
  begin
    if @NNak_2 > 0 
    begin
      
      insert into Kassa2(nd,tm,Oper,Act,SourDate,Nnak,Plata,Fam,P_ID,B_ID,V_ID,Ncod,Remark,
                       RashFlag,LostFlag,LastFlag,Op,Bank_ID,Our_ID,BankDay,
                       Actn,Ck,Thr,ThrFam,DocNom,OrigRecn,ForPrint,SourDatNom,StNom,FromBank_ID,B_idPlat)  
                                         
              values (CONVERT(varchar,getdate(),104) ,CONVERT(varchar,getdate(),8),-2,
                       'ВЫ', @ND_2,@NNAk_2,@Plata,@Fam,0,@B_id_2,0,0,
                       @Remark,
                       0,0,0,@op, @Bank_id,@Our_2,@BankDay,@Actn,@ck,@thr,@ThrFam,0,0,0,@DatNom_2,0,0,@B_id)
      set @Plata = 0               
    end                   
  end
 --разблокировка точек 
/*   DECLARE @Overdue money, @Dis bit
  
    if @master=0 
    begin
      set @Dis=(select disab from Def where tip=1 and pin=@B_id);
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
      
    end */
      
  select *,@Pay
  from #TableNC

END