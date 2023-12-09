CREATE PROCEDURE dbo.PayNaklOver @B_id int, @master int, @Plata money, @Remark varchar(60), @op int,
                                 @Bank_id int, @BankDay datetime, @Pay money OUTPUT, @DCK int=0, @Actn tinyint=0, @POAgent int=0,
                                 @DCKMaster int=-1, @DatNomPay int=0, @RealOper int=0, @NDInp datetime=null, @INBank bit=0,
                                 @Commiss bit=0, @PKO varchar(20)='', @DCKMasterList varchar(100)='', @DovID int=0,@ksid int = 0 out with recompile
AS
begin

  --set transaction isolation level read committed; 
  
  declare @DatNom_2 int,@NNak_2 int,@ND_2 datetime,@Fact_2 money, @B_id_2 int,@Sp_2 money,
          @Our_2 int, @Fam varchar(40), @DCKtek int
  declare @ND datetime, @TM char(8)
  declare @KolError int
  declare @TekPin int
  declare @datnom int
  declare @gpName varchar(40),@Srok int, @Our_ID int, @brAg_id int
  declare @DepID int
  declare @AllContract bit, @AllNet bit;
  declare @StartPlata money
  declare @ag_id int
  declare @SkipDover bit
  
  set @StartPlata = @Plata
  
  if @bankday is not null set @bankday=cast(floor(cast(@bankday as decimal(38,19))) as datetime)
  
  --set @DovID = 0
  set @KolError = 0
  set @ag_id=@op-1000
  set @SkipDover = 0
  set @SkipDover=(select SkipDover from agentlist where ag_id=@ag_id)          
    
  if @B_id = 0 set @B_id=isnull((select pin from defcontract where dck=@Dck),0)

  set @AllContract = 0;
  
  create table #DCKMaster (DCK int); 
  if isnull(@DCKMasterList,'') <> '' 
  begin
    insert into #DCKMaster 
    select K from dbo.Str2intarray(@DCKMasterList) 
    set @AllContract = 1;
  end  
  if (@DCKMaster > 0)
  begin
     insert into #DCKMaster (DCK) values (@DCKMaster); 
     set @AllContract = 1;
  end;
  else set @DCKMaster=-1; 
  
  if @POAgent>0 and @PKO<>'пусто,опл не пройдет'
  begin
    if @master=0 set @master=isnull((select master from def where pin=@b_id),0) 
    if @master<>@b_id set @master=0
    if @master>0 set @DCKMaster=isnull((select dckmaster from defcontract where dck=@DCK),0) 
    if @DCKMaster = 0 set @DCKMaster=-1 
    if (@DCKMaster > 0)
    begin
      insert into #DCKMaster (DCK) values (@DCKMaster); 
      set @AllContract = 1;
    end
    else set @AllContract = 0;

    if @PKO<>'' and @DovID=0 set @DovID=isnull((select max(DovID) from Dover where DovNom=@PKO and DovStat=1 and ag_id=@op-1000),0);
  end
  
  
  
  if @POAgent > 0 and @DovID=0 and @SkipDover=0
  begin
    insert into MobAgents.Mess(ag_id,  pin,  dck,  ND,  tm,  Remark,  MessType,  data0) 
    values (@ag_id,  @B_ID,  @dck,  dbo.today(),  dbo.[time](), cast(@Plata as varchar(15)),  6, 0);
    
    set @Plata = 0
    set @KolError = 1
  end
  
  if @master > 0 set @AllNet = 1;
  else           set @AllNet = 0;
  
 
  create table #TempTable (DatNom int, ND datetime, NNak int,  Sp money, fact money, Our_id int,
                           Fam varchar(40), B_id int, DCK int);
  
   /*курсор по закрытию накл*/
  DECLARE @CURSOR CURSOR 
   
  if @Plata > 0 
  begin 
    SET @CURSOR  = CURSOR SCROLL
    FOR SELECT DatNom,Nd,NNAk,Fact,Sp,Our_id,Fam, B_id, DCK FROM #TempTable order by DatNom --ND+Srok
  end
  else
  if @Plata < 0 
  begin
    SET @CURSOR  = CURSOR SCROLL
    FOR SELECT DatNom,Nd,NNAk,Fact,Sp,Our_id,Fam, B_id, DCK FROM #TempTable order by DatNom desc
  end
  
  BEGIN TRY
  begin transaction trPayNaklOver;      
  
    if @DatNomPay <> 0 
    begin
      insert into  #TempTable (DatNom,ND,NNak, Sp, fact,Our_id,Fam, B_id, DCK)
      select DatNom, dbo.DatNomInDate(nc.DatNom), 
             cast(RIGHT(nc.DatNom,4) as int),SP+Izmen ,Fact,Ourid,
             cast(A.gpName as varchar(40)),B_id, DCK
      from NC  cross apply (select d.gpName, d.pin from def d where d.pin=nc.B_id) A     
      where datnom=@DatNomPay   
    end
    else                     
    if @Plata > 0   
    begin
    /*Находим их незакрытые накл*/
      insert into  #TempTable (DatNom,ND,NNak, Sp, fact,Our_id,Fam, B_id, DCK)
      select DatNom, dbo.DatNomInDate(nc.DatNom), 
             cast(RIGHT(nc.DatNom,4) as int),SP+Izmen ,Fact,Ourid,
             cast(A.gpName as varchar(40)),B_id, DCK
      from NC
      cross apply
      (select d.gpName, d.pin from def d where d.pin=nc.B_id) A 
       where      (B_id = @B_id or (B_id in (select pin from Def where Master = @Master) and @AllNet = 1)) 
             and  (DCK = @DCK or   (DCK in (select dck from DefContract where Actual=1 and DckMaster in (select DCK from #DCKMaster)) and @AllContract = 1))
             and SP+Izmen>Fact and actn = 0  and Tara = 0 and Frizer = 0 
       order by DatNom
    end
    else
    if @Plata < 0
    begin
      insert into  #TempTable (DatNom,ND,NNak, Sp, fact,Our_id,Fam, B_id, DCK)
      /*select SourDatNom,SourDate, NNak,0,sum(Plata),Our_id,
             cast(Fam as varchar(40)),B_id, DCK
      from Kassa1
      where oper=-2 and Plata>0 and act='ВЫ' and (B_id=@B_id or (B_id in (select pin from Def where Master=@B_id) and @AllNet = 1)) 
            and  (DCK=@DCK or @AllContract=1) 
      group by SourDatNom,SourDate, NNak,Our_id,Fam,B_id, DCK      
      order by SourDatNom desc*/
      
      select DatNom, dbo.DatNomInDate(nc.DatNom), 
             cast(RIGHT(nc.DatNom,4) as int),SP+Izmen, Fact, Ourid,
             cast(A.gpName as varchar(40)),B_id, DCK
      from NC
      cross apply
        (select d.gpName, d.pin from def d where d.pin=nc.B_id) A 
        where       (B_id=@B_id or (B_id in (select pin from Def where Master=@B_id) and @AllNet = 1)) 
               and  (DCK = @DCK or   (DCK in (select dck from DefContract where DckMaster in (select DCK from #DCKMaster)) and @AllContract = 1))
               and Fact>0 and actn=0 and Tara=0 and Frizer=0 
        order by DatNom 
    
    end
  
    open @CURSOR 

    FETCH NEXT FROM @CURSOR INTO  @DatNom_2, @ND_2, @NNAk_2, @Fact_2, @Sp_2, @Our_2, @Fam, @B_id_2, @DCKtek
        
    while @@FETCH_STATUS = 0 and @Plata!=0
    begin
      set @DepID=(select DepID from agentlist where ag_id=(select c.ag_id from defcontract c where c.dck=@DCKtek))          
      if @Plata > 0
      begin 
        /* если переплата <= Долга по накл 
        закрыть накл по переплате и закрыть накл с долгом*/
        if @Plata <= @Sp_2 - @Fact_2
        begin
                                      
          insert into Kassa1(nd,tm,Oper,Act,SourDate,Nnak,Plata,Fam,P_ID,B_ID,V_ID,Ncod,Remark,
                             RashFlag,LostFlag,LastFlag,Op,Bank_ID,Our_ID,BankDay,
                             Actn,Ck,Thr,ThrFam,DocNom,OrigRecn,ForPrint,SourDatNom,StNom,FromBank_ID, DCK, DepID, RealOper)  
                                     
          values (CONVERT(varchar,getdate(),104) ,CONVERT(varchar,getdate(),8),-2,
                  'ВЫ', @ND_2,@NNAk_2,@Plata,@Fam,0,@B_id_2,0,0,
                  @Remark,
                  0,0,0,@op, @Bank_id,@Our_2,@BankDay,@Actn,0,0,'',0,@DovID,0,@DatNom_2,0,0, @DCKtek, @DepID, @RealOper)
          
          set @ksid=SCOPE_IDENTITY()
          if @@Error<>0 set @KolError=@KolError + 1        
          set @Plata=0
                                    
        end
        else 
 
         /*если переплата > Долга по накл 
               закрыть накл по переплате и закрыть накл с долгом*/
          if (@Plata>@Sp_2-@Fact_2) and (@Sp_2-@Fact_2<>0)
          begin
                                    
            insert into Kassa1(nd,tm,Oper,Act,SourDate,Nnak,Plata,Fam,P_ID,B_ID,V_ID,Ncod,
                Remark,RashFlag,LostFlag,LastFlag,Op,Bank_ID,Our_ID,BankDay,
                Actn,Ck,Thr,ThrFam,DocNom,OrigRecn,ForPrint,SourDatNom,StNom,FromBank_ID, DCK, DepID, RealOper)  
                                          
            values (CONVERT(varchar,getdate(),104) ,CONVERT(varchar,getdate(),8),-2,
                    'ВЫ', @ND_2,@NNAk_2,@Sp_2-@Fact_2,@Fam,0,@B_id_2,0,0,
                    @Remark,
                    0,0,0,@op, @Bank_id,@Our_2,@BankDay,@Actn,0,0,'',0,@DovID,0,@DatNom_2,0,0, @DCKtek, @DepID, @RealOper)
                    
            set @ksid=SCOPE_IDENTITY()        
            if @@Error<>0 set @KolError=@KolError + 1        
            set @Plata=@Plata-(@Sp_2-@Fact_2)  
          end 
      end 
      else
        if @Plata < 0 
        begin
          if (@Plata+@Fact_2 < 0) 
          begin                   
            if @DatNomPay>0 set @Fact_2 = -@Plata            
            insert into Kassa1(nd,tm,Oper,Act,SourDate,Nnak,Plata,Fam,P_ID,B_ID,V_ID,Ncod,Remark,
                  RashFlag,LostFlag,LastFlag,Op,Bank_ID,Our_ID,BankDay,
                  Actn,Ck,Thr,ThrFam,DocNom,OrigRecn,ForPrint,SourDatNom,StNom,FromBank_ID, DCK, RealOper)  
                                       
            values (CONVERT(varchar,getdate(),104) ,CONVERT(varchar,getdate(),8),-2,
                    'ВЫ', @ND_2,@NNAk_2,-@Fact_2,@Fam,0,@B_id_2,0,0,
                    @Remark,
                    0,0,0,@op, @Bank_id,@Our_2,@BankDay,@Actn,0,0,'',0,@DovID,0,@DatNom_2,0,0, @DCKtek, @RealOper)
            if @@Error<>0 set @KolError=@KolError + 1        
             
            set @Plata=@Plata+@Fact_2
          end
          else
            if @Plata+@Fact_2 >= 0
            begin
              insert into Kassa1(nd,tm,Oper,Act,SourDate,Nnak,Plata,Fam,P_ID,B_ID,V_ID,Ncod,Remark,
                    RashFlag,LostFlag,LastFlag,Op,Bank_ID,Our_ID,BankDay,
                    Actn,Ck,Thr,ThrFam,DocNom,OrigRecn,ForPrint,SourDatNom,StNom,FromBank_ID, DCK, DepID, RealOper)  
                                         
              values (CONVERT(varchar,getdate(),104) ,CONVERT(varchar,getdate(),8),-2,
                      'ВЫ', @ND_2,@NNAk_2,@Plata,@Fam,0,@B_id_2,0,0,
                      @Remark,
                      0,0,0,@op, @Bank_id,@Our_2,@BankDay,@Actn,0,0,'',0,@DovID,0,@DatNom_2,0,0, @DCKtek, @DepID, @RealOper)
              if @@Error<>0 set @KolError=@KolError + 1        
              set @Plata=0
            end 
        end      
      FETCH NEXT FROM @CURSOR INTO  @DatNom_2,@ND_2,@NNAk_2, @Fact_2, @Sp_2,@Our_2,@Fam,@B_id_2, @DCKTek
    end --while
    close @CURSOR
  
    drop table #TempTable; 

    if @Plata > 0 
    begin
      set @NNak_2=isnull(@NNak_2,0)
      
      if @NNak_2 <= 0
      begin 
        select @DatNom_2 = c.datnom,@ND_2 = c.nd,@NNAk_2 = cast(RIGHT(c.DatNom,4) as int),
               @Fact_2 = c.fact, @Sp_2 = c.sp,@Our_2=c.ourid,@Fam = c.fam,@B_id_2 = c.b_id,
               @gpName=cast(d.gpName as varchar(40)), @DCKTek = c.DCK
        from NC c join Def d on c.B_ID=d.pin
        where c.datnom = (select max(datnom) from nc 
                          where
                            (B_id = @B_id or (B_id in (select pin from Def where Master = @Master) and @AllNet = 1)) 
                            and  (DCK = @DCK or   (DCK in (select dck from DefContract where DckMaster in (select DCK from #DCKMaster)) and @AllContract = 1))
                            and SP>0 and actn = 0  and Tara = 0 and Frizer = 0 
                            ) 
      end  
      if @NNak_2 > 0 
      begin
        set @DepID=(select DepID from agentlist where ag_id=(select c.ag_id from defcontract c where c.dck=@DCKtek))      
        insert into Kassa1(nd,tm,Oper,Act,SourDate,Nnak,Plata,Fam,P_ID,B_ID,V_ID,Ncod,Remark,
                           RashFlag,LostFlag,LastFlag,Op,Bank_ID,Our_ID,BankDay,
                           Actn,Ck,Thr,ThrFam,DocNom,OrigRecn,ForPrint,SourDatNom,StNom,FromBank_ID, DCK, DepID, RealOper)  
                                         
        values (CONVERT(varchar,getdate(),104) ,CONVERT(varchar,getdate(),8),-2,
                       'ВЫ', @ND_2,@NNAk_2,@Plata,@Fam,0,@B_id_2,0,0,
                       @Remark,
                       0,0,0,@op, @Bank_id,@Our_2,@BankDay,@Actn,0,0,'',0,@DovID,0,@DatNom_2,0,0, @DCKTek, @DepID, @RealOper)
        if @@Error<>0 set @KolError=@KolError + 1                 
        set @Plata = 0               
      end                 
      else -- вставка пустой накладной для проведения аванса
      begin
        if @op<10000 
        begin
          if @master>0  set @TekPin=@master
          else set @TekPin=@B_id
      
          set @DCKTek = (select min(DCK) from DefContract where pin=@TekPin and ContrTip=2 and Actual=1)
        
          if @DCKTek>0 
          begin        
            set @DepID=(select DepID from agentlist where ag_id=(select c.ag_id from defcontract c where c.dck=@DCKtek))      
            set @ND=convert(char(10), getdate(),104);
            set @TM=convert(char(8), getdate(),108);
                      
            select @gpName=gpName from Def where pin=@TekPin 
            
            select @Our_ID=Our_ID,@Srok=Srok,@brAg_id=Ag_id from defcontract where DCK=@DCKTek
      
            set @datnom=1+isnull((select max(datnom) from Nc where Nd=@ND),dbo.InDatNom(0,@ND));  
      
            insert into NC (ND,datnom,B_ID,Fam,Tm,OP,SP,SC,Extra,Srok,OurID,Frizer,ag_id,stfnom,stfdate,
    	                    Remark,Printed,BoxQty,WEIGHT,Actn,CK,Tara,
                            RefDatnom, Done, Izmen, RemarkOp, DayShift,Comp, DCK, B_ID2)
                    values (@ND,@datnom,@TekPin,left(@gpName,35),convert(char(8), getdate(),108),@op,0,0,
    	                     0,@Srok,@Our_ID,0,@brAg_id,'',0, 'для предоплаты',0,0,0,0,0,
                             0,0,0, 0.0, 'для предоплаты',0, '', @DCKTek,0);
                             
            if @@Error<>0 set @KolError=@KolError + 1  
            insert into Kassa1(nd,tm,Oper,Act,SourDate,Nnak,Plata,Fam,P_ID,B_ID,V_ID,Ncod,Remark,
                               RashFlag,LostFlag,LastFlag,Op,Bank_ID,Our_ID,BankDay,
                               Actn,Ck,Thr,ThrFam,DocNom,OrigRecn,ForPrint,SourDatNom,StNom,FromBank_ID, DCK, DepID, RealOper)  
                                         
                       values (CONVERT(varchar,getdate(),104) ,CONVERT(varchar,getdate(),8),-2,
                              'ВЫ', @ND, dbo.INNnak(@DatNom),@Plata,@gpName,0,@TekPin,0,0,
                               @Remark,  0,0,0,@op, @Bank_id, @Our_ID, @BankDay,@Actn,0,0,'',0,@DovID,0,@DatNom,0,0, @DCKTek, @DepID, @RealOper)
            if @ksid=0 set @ksid=SCOPE_IDENTITY();                   
            if @@Error<>0 set @KolError=@KolError + 1             
            set @Plata = 0        
          end
        end
      end
    end
       
    --Разнесенная сумма подотчет,  если POAgent>0
    
    if (@POAgent > 0) and (@StartPlata - @Plata <> 0)
    begin
      declare @AgentFam varchar(150)
      select @AgentFam=fio/*, @Our_ID=our_id */from Person where p_id=@POAgent
      select @Our_ID=Our_ID from Deps where DepID=isnull((select DepID from agentlist where ag_id=@op-1000),0)
     
      insert into Kassa1(nd,tm,Oper,Act,SourDate,Nnak,Plata,Fam,P_ID,B_ID,V_ID,Ncod,Remark,
                         RashFlag,LostFlag,LastFlag,Op,Bank_ID,Our_ID,BankDay,
                         Actn,Ck,Thr,ThrFam,DocNom,OrigRecn,ForPrint,SourDatNom,StNom,FromBank_ID, DCK, DepID, RealOper, NDInp,INBank)  
                                         
                  values (CONVERT(varchar,getdate(),104) ,CONVERT(varchar,getdate(),8),59,
                         'ВЫ', CONVERT(varchar,getdate(),104), 0, @StartPlata - @Plata, left(@AgentFam, 40), @POAgent, 0,0,0,
                         'От пок. '+cast(@B_ID as varchar(6))+' '+cast(@Fam as varchar(45)),1,1,0, @op, 0, @Our_ID, CONVERT(varchar,getdate(),104),
                          0,0,0,'',0,@DovID,1, 0,@POAgent*100+1,0,0, @DepID, @RealOper, @NDInp, @INBank)
      if @@Error<>0 set @KolError=@KolError + 1   
      
      if @DovID>0 and @DovID>1000000 update Dover set DovStat=2, DCK=@DCK, NDUse=dbo.today(), SumUse=@StartPlata - @Plata where DovID=@DovID
      if @DovID>0 and @DovID<1000000 update Dover2PrintLog set DovStat=2, DCK=@DCK, NDUse=dbo.today(), SumUse=@StartPlata - @Plata where DPLID=@DovID
      if @@Error<>0 set @KolError=@KolError + 1                           
    end
    
    --Разнесенная сумма - комиссия банка
    if (@commiss = 1) and (@StartPlata - @Plata <> 0)
    begin
          
      insert into Kassa1(nd,tm,Oper,Act,SourDate,Nnak,Plata,Fam,P_ID,B_ID,V_ID,Ncod,Remark,
                         RashFlag,LostFlag,LastFlag,Op,Bank_ID,Our_ID,BankDay,
                         Actn,Ck,Thr,ThrFam,DocNom,OrigRecn,ForPrint,SourDatNom,StNom,FromBank_ID, DCK, DepID, RealOper, NDInp,INBank)  
                                         
                  values (CONVERT(varchar,getdate(),104) ,CONVERT(varchar,getdate(),8),110,
                         'ВЫ', CONVERT(varchar,getdate(),104), 0, @StartPlata - @Plata, 'Факторинг(Комиссия банка)', 0,0,0,0,
                         'Документ #'+cast(@DatNomPay as varchar(10)),1,1,0, @op, @Bank_id, @Our_ID, CONVERT(varchar,getdate(),104),
                          0,0,0,'',0,@DovID,1, 0,0,0,0,0, @RealOper, @NDInp, @INBank)
      if @@Error<>0 set @KolError=@KolError + 1                             
    end
      
    
    --разблокировка точек новая
    create table #NeedDCK (dck int)
    
    declare @Tod datetime
     
    set @Tod=dbo.today()
     
    if @master = 0 
    begin
      insert into #NeedDCK (dck)
      select c.dck from defcontract c where c.pin=@B_id and c.actual=1 and c.contrtip=2 and c.Disab=1
    end
    else
    begin
      insert into #NeedDCK (dck)
      select c.dck from defcontract c where c.actual=1 and c.contrtip=2 and c.pin in (select pin from def where master=@master) and c.Disab=1
    end;
    
    select c.dck as dck into #Temp001
    from nc c join #NeedDCK n on c.dck=n.dck
    where 
        c.srok>0
        and c.SP-isnull(c.Fact,0)+isnull(c.Izmen,0)>0
        and c.ND+2+c.Srok<@Tod
        and c.Actn=0 and c.Tara=0 and c.Frizer=0
        and c.ourid<>6

      
    update DefContract set Disab=0, Debit=0 where dck in 
     (select dck from #NeedDCK
      except
      select dck from #Temp001)
      
    insert into dbo.EnabLog (CompName, B_ID, Enab, CheckDate, OP, Comment, DCK) 
    select 'tdmsql', c.pin, 0, @Tod, @OP, 'Оплата долга', c.dck 
    from DefContract c where c.dck in 
     (select dck from #NeedDCK 
      except
      select dck from #Temp001)
      
    drop table #Temp001;
      
    select c.dck as dck into #Temp002 
    from nc c join #NeedDCK n on c.dck=n.dck
    where 
        c.srok>0
        and c.SP-isnull(c.Fact,0)+isnull(c.Izmen,0)>0
        and c.ND+17+c.Srok<@Tod
        and c.Actn=0 and c.Tara=0 and c.Frizer=0
 
          
    update DefContract set Debit=0 where Debit=1 and dck in 
     (select dck from #NeedDCK
      except
      select dck from #Temp002)

           
    drop table #Temp002;
    drop table #NeedDCK;
   
    --разблокировка точек 
   -- declare @Overdue money, @Dis bit, @Tod datetime, @NDOver int
    
   /* set @Tod=dbo.today()
     
    if @master = 0 
    begin
      set @Dis = (select disab from Def where pin=@B_id);
      if @Dis = 1
      begin
        /*set @Overdue=(select isnull(sum(nc.SP-isnull(nc.Fact,0)+isnull(NC.Izmen,0)),0)
                      from nc
                      where nc.b_id=@b_id and nc.srok>0
                      and nc.SP-isnull(nc.Fact,0)+isnull(NC.Izmen,0)>1
                      and nc.ND+2+nc.Srok<GetDate()
                      and nc.Actn=0 and nc.Tara=0 and NC.Frizer=0
                      and nc.SP>0)
        */              
                      
      *//*  select   @NDOver=isnull(cast(max(@Tod - (ND+Srok)) as int),0), 
                 @Overdue=isnull(sum(nc.SP+ISNULL(nc.izmen,0)-nc.Fact),0) 
            from nc
            where nc.b_id=@b_id and nc.srok>0 
                  and isnull(RefDatNom,0)=0
                  and nc.SP-isnull(nc.Fact,0)+isnull(NC.Izmen,0)>1
                  and nc.ND+nc.Srok+2 < @Tod 
                  and nc.Actn=0 and nc.Tara=0 and NC.Frizer=0
                       
             
        if @Overdue<=0
        begin
          update Def set Disab=0, Debit=0 where pin=@b_id
          update DefContract set Disab=0 where pin=@b_id and ContrTip=2
          insert into dbo.EnabLog (CompName, B_ID, Enab, CheckDate, OP, Comment) 
          select 'tdmsql', @b_id, 0, getdate(),0, 'Сброшена сумма с КПК'
        end
        else if @NDOver<17 update Def set Debit=0 where pin=@b_id

      end
    end
    else
    begin
      select pin into #Temp002 from Def where master=@master and Disab=1
      
      --update Def set Disab=0 where master=@master;
      
      select b_id as pin into #Temp001 from nc
      where 
        nc.b_id in (select pin from Def where MASTER=@master) and nc.srok>0
        and nc.SP-isnull(nc.Fact,0)+isnull(NC.Izmen,0)>0
        and nc.ND+2+nc.Srok<GetDate()
        and nc.Actn=0 and nc.Tara=0 and NC.Frizer=0
      order by b_id;
      
      /*update Def set Disab=1 where pin in (select pin from #Temp001)
      drop table #Temp001;*/
      
 /*    update Def set Disab=0, Debit=0 where pin in 
     (select pin from #Temp002 
      except
      select pin from #Temp001)
      
     update DefContract set Disab=0 where pin in 
     (select pin from #Temp002 
      except
      select pin from #Temp001) 
      
     insert into dbo.EnabLog (CompName, B_ID, Enab, CheckDate, OP, Comment) 
     select 'tdmsql', pin, 0, getdate(),0, 'Сброшена сумма с КПК (сеть)' 
     from Def where pin in 
     (select pin from #Temp002 
      except
      select pin from #Temp001)
      
      drop table #Temp001;
      
      select b_id as pin into #Temp003 from nc
      where 
        nc.b_id in (select pin from Def where MASTER=@master) and nc.srok>0
        and nc.SP-isnull(nc.Fact,0)+isnull(NC.Izmen,0)>0
        and nc.ND+17+nc.Srok<GetDate()
        and nc.Actn=0 and nc.Tara=0 and NC.Frizer=0
      order by b_id;
          
      update Def set Debit=0 where Debit=1 and pin in 
     (select pin from #Temp002 
      except
      select pin from #Temp003)

           
      /*
      update Def set Disab=0 where pin in (select pin from #Temp002)*/
   *//*   drop table #Temp002;
      drop table #Temp003; 
      
    end 
  */  */
  if @KolError = 0 COMMIT ELSE ROLLBACK;
  
  END TRY
  BEGIN CATCH 
         --    SELECT ERROR_NUMBER() AS ErrorNumber, ERROR_MESSAGE() AS ErrorMessage
    insert into ProcErrors(errnum, errmess, procname, errline) select ERROR_NUMBER(), ERROR_MESSAGE(), object_name(@@procid), ERROR_LINE()
    IF (XACT_STATE())<>1
    BEGIN
      ROLLBACK TRANSACTION;
      set @Plata=@StartPlata
    END;
    ELSE
    BEGIN
      COMMIT TRANSACTION;   
    END;
  END CATCH;      
    
  set @Pay = @Plata
  select @Pay, @ksid
end