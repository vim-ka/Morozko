CREATE PROCEDURE dbo.PayNaklOver_ved @B_id int, @master int, @Plata money, @Remark varchar(60), @op int,
                                 @Bank_id int, @BankDay datetime, @Pay money OUTPUT, @DCK int=0, @Actn tinyint=0, @POAgent int=0,
                                 @DCKMaster int=-1, @DatNomPay int=0, @RealOper int=0, @NDInp datetime=null, @INBank bit=0,
                                 @Commiss bit=0, @PKO varchar(20)='', @DovID int with recompile
AS
begin

  --set transaction isolation level snapshot; 
  
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
  if @bankday is not null set @bankday=cast(floor(cast(@bankday as decimal(38,19))) as datetime)
  
  declare @traname varchar(15)
  set @traname='PayNaklOver_ved'
  begin tran @traname      
  
  set @StartPlata = @Plata
  
  --set @DovID = 0
  set @KolError = 0
    
  if @B_id = 0 set @B_id=isnull((select pin from defcontract where dck=@Dck),0)
  if @DCKMaster = 0 set @DCKMaster=-1
  
  if @POAgent > 0 and @PKO='пусто,опл не пройдет'
  BEGIN
    set @Plata = 0
    set @KolError = 1
  END
  
  set @AllContract = 1;
  
  if @POAgent>0 and @PKO<>'пусто,опл не пройдет'
  begin
    if @master=0 set @master=isnull((select master from def where pin=@b_id),0) 
    if @master<>@b_id set @master=0
    if @master>0 set @DCKMaster=isnull((select dckmaster from defcontract where dck=@Dck),0) 
    if @DCKMaster = 0 set @DCKMaster=-1 
    if @PKO<>'' set @DovID=isnull((select max(DovID) from Dover where DovNom=@PKO and DovStat=1),0)
    set @AllContract = 0;
  end
  
  if @master > 0 set @AllNet = 1;
  else           set @AllNet = 0;
  
  if (@DCKMaster > 0) /*or (@DCK > 0)*/ set @AllContract = 0;
  
 
  create table #TempTable (DatNom int, ND datetime, NNak int,  Sp money, fact money, Our_id int,
                           Fam varchar(40), B_id int, DCK int);
  
   /*курсор по закрытию накл*/
  DECLARE @CURSOR CURSOR 
   
  if @Plata > 0 
  begin 
    SET @CURSOR  = CURSOR SCROLL
    FOR SELECT DatNom,Nd,NNAk,Fact,Sp,Our_id,Fam, B_id, DCK FROM #TempTable order by DatNom
  end
  else
  if @Plata < 0 
  begin
    SET @CURSOR  = CURSOR SCROLL
    FOR SELECT DatNom,Nd,NNAk,Fact,Sp,Our_id,Fam, B_id, DCK FROM #TempTable order by DatNom desc
  end
  
 -- BEGIN TRY
  
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
             cast(A.gpName as varchar(40)),B_id, nc.DCK
      from NC join DefContract d on nc.dck=d.dck
      cross apply
      (select d.gpName, d.pin from def d where d.pin=nc.B_id) A 
       where (B_id = @B_id or (B_id in (select pin from Def where Master = @Master) and @AllNet = 1)) 
             and  (nc.DCK = @DCK or nc.DCK in (select dck from DefContract where DckMaster = @DckMaster) or @AllContract = 1)
             and SP+Izmen>Fact and actn = 0  and Tara = 0 and Frizer = 0 
             and ISNULL(d.degust,0)=0
       order by DatNom
    end
    else
    if @Plata < 0
    begin
      insert into  #TempTable (DatNom,ND,NNak, Sp, fact,Our_id,Fam, B_id, DCK)
       
      select DatNom, dbo.DatNomInDate(nc.DatNom), 
             cast(RIGHT(nc.DatNom,4) as int),SP+Izmen, Fact, Ourid,
             cast(A.gpName as varchar(40)),B_id, DCK
      from NC
      cross apply
        (select d.gpName, d.pin from def d where d.pin=nc.B_id) A 
        where (B_id=@B_id or (B_id in (select pin from Def where Master=@B_id) and @AllNet = 1)) 
               and  (DCK = @DCK or DCK in (select dck from DefContract where DckMaster = @DckMaster) or @AllContract = 1) and Fact>0 and actn=0 and Tara=0 and Frizer=0 
        order by DatNom 
    
    end
  
    open @CURSOR 

    FETCH NEXT FROM @CURSOR INTO  @DatNom_2, @ND_2, @NNAk_2, @Fact_2, @Sp_2, @Our_2, @Fam, @B_id_2, @DCKtek
        
    while @@FETCH_STATUS = 0 and @Plata!=0
    begin
      set @DepID=(select DepID from agentlist where ag_id=(select c.ag_id from defcontract c where c.dck=@DCKtek))          
      if @Plata > 0
      begin 
        if @Plata <= @Sp_2 - @Fact_2
        begin
                                      
          insert into Kassa1(nd,tm,Oper,Act,SourDate,Nnak,Plata,Fam,P_ID,B_ID,V_ID,Ncod,Remark,
                             RashFlag,LostFlag,LastFlag,Op,Bank_ID,Our_ID,BankDay,
                             Actn,Ck,Thr,ThrFam,DocNom,OrigRecn,ForPrint,SourDatNom,StNom,FromBank_ID, DCK, DepID, RealOper,pin)  
                                     
          values (CONVERT(varchar,getdate(),104) ,CONVERT(varchar,getdate(),8),-2,
                  'ВЫ', @ND_2,@NNAk_2,@Plata,@Fam,0,@B_id_2,0,0,
                  @Remark,
                  0,0,0,@op, @Bank_id,@Our_2,@BankDay,@Actn,0,0,'',0,@DovID,0,@DatNom_2,0,0, @DCKtek, @DepID, @RealOper, @B_id_2)
          
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
                Actn,Ck,Thr,ThrFam,DocNom,OrigRecn,ForPrint,SourDatNom,StNom,FromBank_ID, DCK, DepID, RealOper, pin)  
                                          
            values (CONVERT(varchar,getdate(),104) ,CONVERT(varchar,getdate(),8),-2,
                    'ВЫ', @ND_2,@NNAk_2,@Sp_2-@Fact_2,@Fam,0,@B_id_2,0,0,
                    @Remark,
                    0,0,0,@op, @Bank_id,@Our_2,@BankDay,@Actn,0,0,'',0,@DovID,0,@DatNom_2,0,0, @DCKtek, @DepID, @RealOper, @B_id_2)
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
                  Actn,Ck,Thr,ThrFam,DocNom,OrigRecn,ForPrint,SourDatNom,StNom,FromBank_ID, DCK, RealOper, pin)  
                                       
            values (CONVERT(varchar,getdate(),104) ,CONVERT(varchar,getdate(),8),-2,
                    'ВЫ', @ND_2,@NNAk_2,-@Fact_2,@Fam,0,@B_id_2,0,0,
                    @Remark,
                    0,0,0,@op, @Bank_id,@Our_2,@BankDay,@Actn,0,0,'',0,@DovID,0,@DatNom_2,0,0, @DCKtek, @RealOper,@B_id_2)
            if @@Error<>0 set @KolError=@KolError + 1        
             
            set @Plata=@Plata+@Fact_2
          end
          else
            if @Plata+@Fact_2 >= 0
            begin
              insert into Kassa1(nd,tm,Oper,Act,SourDate,Nnak,Plata,Fam,P_ID,B_ID,V_ID,Ncod,Remark,
                    RashFlag,LostFlag,LastFlag,Op,Bank_ID,Our_ID,BankDay,
                    Actn,Ck,Thr,ThrFam,DocNom,OrigRecn,ForPrint,SourDatNom,StNom,FromBank_ID, DCK, DepID, RealOper, pin)  
                                         
              values (CONVERT(varchar,getdate(),104) ,CONVERT(varchar,getdate(),8),-2,
                      'ВЫ', @ND_2,@NNAk_2,@Plata,@Fam,0,@B_id_2,0,0,
                      @Remark,
                      0,0,0,@op, @Bank_id,@Our_2,@BankDay,@Actn,0,0,'',0,@DovID,0,@DatNom_2,0,0, @DCKtek, @DepID, @RealOper, @B_id_2)
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
                  join DefContract a on c.dck=a.dck
        where c.B_id=@B_id and c.actn=0 and c.Tara=0 and c.Frizer=0 and c.datnom = (select max(datnom) from nc where b_id=@B_id and sp>0) 
              and isnull(a.Degust,0)=0 
      end  
      if @NNak_2 > 0 
      begin
        set @DepID=(select DepID from agentlist where ag_id=(select c.ag_id from defcontract c where c.dck=@DCKtek))      
        insert into Kassa1(nd,tm,Oper,Act,SourDate,Nnak,Plata,Fam,P_ID,B_ID,V_ID,Ncod,Remark,
                           RashFlag,LostFlag,LastFlag,Op,Bank_ID,Our_ID,BankDay,
                           Actn,Ck,Thr,ThrFam,DocNom,OrigRecn,ForPrint,SourDatNom,StNom,FromBank_ID, DCK, DepID, RealOper, pin)  
                                         
        values (CONVERT(varchar,getdate(),104) ,CONVERT(varchar,getdate(),8),-2,
                       'ВЫ', @ND_2,@NNAk_2,@Plata,@Fam,0,@B_id_2,0,0,
                       @Remark,
                       0,0,0,@op, @Bank_id,@Our_2,@BankDay,@Actn,0,0,'',0,@DovID,0,@DatNom_2,0,0, @DCKTek, @DepID, @RealOper, @B_id_2)
        if @@Error<>0 set @KolError=@KolError + 1                 
        set @Plata = 0               
      end                 
      else -- вставка пустой накладной для проведения аванса
      begin
        if @op<10000 
        begin
          if @master>0  set @TekPin=@master
          else set @TekPin=@B_id
      
           -- set @DCKTek = (select min(DCK) from DefContract where pin=@TekPin and ContrTip=2 and Actual=1 and isnull(Degust,0)=0 )
           
           set @DCKTek = 
           (select e.dck from 
           (select row_number() over(order by Degust, Actual desc) AS Row, DCK from DefContract where pin=@TekPin and ContrTip=2) e
           where e.Row=1)
        
          if @DCKTek>0 
          begin        
            set @DepID=(select DepID from agentlist where ag_id=(select c.ag_id from defcontract c where c.dck=@DCKtek))      
            set @ND=convert(char(10), getdate(),104);
            set @TM=convert(char(8), getdate(),108);
                      
            select @gpName=gpName from Def where pin=@TekPin 
            
            select @Our_ID=Our_ID,@Srok=Srok,@brAg_id=Ag_id from defcontract where DCK=@DCKTek
      
            set @datnom=1+isnull((select max(datnom) from Nc where Nd=@ND),dbo.InDatNom(0,@ND));  
      
            insert into NC (ND,datnom,B_ID,Fam,Tm,OP,SP,SC,Extra,Srok,OurID,Pko,Man_ID, 
                            BankId,TovChk,Frizer,ag_id,stfnom,stfdate,tomorrow,qtyFriz,
    	                      Remark,Printed,Marsh,BoxQty,WEIGHT,Actn,CK,Tara,
                            RefDatnom,MarshDay,Sk50prn, Done, Izmen, RemarkOp, DayShift,Comp, Sk50present, DCK, B_ID2)
                    values (@ND,@datnom,@TekPin,left(@gpName,35),convert(char(8), getdate(),108),@op,0,0,
     	                      0,@Srok,@Our_ID,0,0/*@Man_ID*/
                           
                           , 0,0,0,@brAg_id,0,0,0,0,
 
         	                 'для предоплаты',0,0,0,0,0,0,0,0,0,0, 0, 0.0, 'для предоплаты',0, '', 0, @DCKTek,0);
             if @@Error<>0 set @KolError=@KolError + 1  
             insert into Kassa1(nd,tm,Oper,Act,SourDate,Nnak,Plata,Fam,P_ID,B_ID,V_ID,Ncod,Remark,
                               RashFlag,LostFlag,LastFlag,Op,Bank_ID,Our_ID,BankDay,
                               Actn,Ck,Thr,ThrFam,DocNom,OrigRecn,ForPrint,SourDatNom,StNom,FromBank_ID, DCK, DepID, RealOper, pin)  
                                         
                       values (CONVERT(varchar,getdate(),104) ,CONVERT(varchar,getdate(),8),-2,
                              'ВЫ', @ND, dbo.INNnak(@DatNom),@Plata,@gpName,0,@TekPin,0,0,
                               @Remark,  0,0,0,@op, @Bank_id, @Our_ID, @BankDay,@Actn,0,0,'',0,@DovID,0,@DatNom,0,0, @DCKTek, @DepID, @RealOper, @TekPin)
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
      select @AgentFam=fio, @Our_ID=our_id from Person where p_id=@POAgent
     
      insert into Kassa1(nd,tm,Oper,Act,SourDate,Nnak,Plata,Fam,P_ID,B_ID,V_ID,Ncod,Remark,
                         RashFlag,LostFlag,LastFlag,Op,Bank_ID,Our_ID,BankDay,
                         Actn,Ck,Thr,ThrFam,DocNom,OrigRecn,ForPrint,SourDatNom,StNom,FromBank_ID, DCK, DepID, RealOper, NDInp,INBank, pin)  
                                         
                  values (CONVERT(varchar,getdate(),104) ,CONVERT(varchar,getdate(),8),59,
                         'ВЫ', CONVERT(varchar,getdate(),104), 0, @StartPlata - @Plata, left(@AgentFam, 40), @POAgent, 0,0,0,
                         'От пок. '+cast(@B_ID as varchar(6))+' '+cast(@Fam as varchar(45)),1,1,0, @op, 0, @Our_ID, CONVERT(varchar,getdate(),104),
                          0,0,0,'',0,@DovID,1, 0,@POAgent*100+1,0,0,0, @RealOper, @NDInp, @INBank, @POAgent)
      if @@Error<>0 set @KolError=@KolError + 1   
      
      if @DovID>0 update Dover set DovStat=2, DCK=@DCK, NDUse=dbo.today(), SumUse=@StartPlata - @Plata where DovID=@DovID
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
   
    
  if @KolError = 0 
  begin
  	COMMIT tran @traname 
    set @Pay=@StartPlata
  end
  ELSE 
  	ROLLBACK tran @traname; 
     
    
 /* END TRY
  BEGIN CATCH 
  	IF (XACT_STATE())<>1 or @KolError <> 0
    BEGIN
      ROLLBACK TRAN @traname
      set @Pay=@StartPlata
    END;
    ELSE
    BEGIN
      COMMIT TRAN @traname;   
    END;  
  END CATCH;*/
end