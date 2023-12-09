CREATE PROCEDURE dbo.PayNakl @B_id int, @master int, @Plata money,@Remark varchar(60), @op int,
              @Bank_id int,@BankDay datetime, @Pay money OUTPUT, @DCK int=0, @DCKMaster int=0, @SerialNom int=0
AS
BEGIN
  DECLARE @DatNom_2 bigint,@NNak_2 int,@ND_2 datetime,@Fact_2 money, @B_id_2 int,@Sp_2 money,
          @Our_2 int, @Fam varchar(40), @DckTek int
  
  create table #Table2 (DatNom bigint,ND datetime, NNAk int,  Sp money,fact money, Our_id int,
                        Fam varchar(40), B_id int, Dck int);
                           
  if @DCK=0 set @DCK=(select min(DCK) from DefContract where ContrTip=2 and pin=@B_id)
  if @B_id=0 set @B_id=(select pin from DefContract where ContrTip=2 and Dck=@Dck)
  if @DCKMaster = 0 set @DCKMaster=-1
  
  if @bankday is not null set @bankday=cast(floor(cast(@bankday as decimal(38,19))) as datetime)
  
  set @SerialNom=isnull(@SerialNom,0);
                        
if @master=0 
begin  
    if @Plata>0 
    begin
     /*Находим их незакрытые накл*/
      insert into  #Table2 (DatNom,ND,NNak, Sp, fact,Our_id,Fam, B_id, Dck)
      select DatNom, dbo.DatNomInDate(nc.DatNom), 
             dbo.InNnak(nc.datnom),            
             SP+Izmen ,Fact,Ourid,
             CAST(A.gpName as varchar(40)),B_id, Dck
      from NC left join def A on A.pin=NC.B_id
      where B_id=@B_id and (DCK = @DCK or DCK in (select dck from DefContract where DckMaster = @DckMaster))
            and SP+Izmen>Fact and actn!=1 and Tara!=1 
            and Frizer!=1 
      order by DatNom
    end
    else
     if @Plata<0
     begin
        insert into  #Table2 (DatNom,ND,NNak, Sp, fact,Our_id,Fam, B_id, Dck)
        select SourDatNom,SourDate, NNak,0,Plata,Our_id,
               CAST(Fam as varchar(40)),B_id,Dck
        from Kassa1
        where oper=-2 and act='ВЫ' and Plata>0 and (B_id=@B_id or DCK = @DCK or DCK in (select dck from DefContract where DckMaster = @DckMaster))
        order by SourDatNom desc
     end
end
else
begin
    if @Plata>0 
    begin
     /*Находим их незакрытые накл*/
      insert into  #Table2 (DatNom,ND,NNak, Sp, fact,Our_id,Fam, B_id, Dck)
      select DatNom, dbo.DatNomInDate(nc.DatNom), 
             dbo.InNnak(nc.DatNom),           
             SP+Izmen ,Fact,Ourid,
             CAST(A.gpName as varchar(40)),B_id,Dck
      from NC left join def A on A.pin=NC.B_id
      where B_id in (select pin from Def where master=@master) 
            and (DCK = @DCK or DCK in (select dck from DefContract where DckMaster = @DckMaster)) and SP+Izmen>Fact and actn!=1 and Tara!=1 
            and Frizer!=1 
      order by DatNom
    end
    else
     if @Plata<0
     begin
        insert into  #Table2 (DatNom,ND,NNak, Sp, fact,Our_id,Fam, B_id,Dck)
        Select SourDatNom,SourDate, NNak,0,Plata,Our_id,
               CAST(Fam as varchar(40)),B_id,Dck
        from Kassa1
        where B_id in (select pin from Def where master=@master)  
           and (DCK = @DCK or DCK in (select dck from DefContract where DckMaster = @DckMaster)) and oper=-2 and act='ВЫ' and Plata>0
        order by SourDatNom desc
     end
end
    
     /*курсор по закрытию накл*/
    DECLARE @CURSOR CURSOR 
    SET @CURSOR  = CURSOR SCROLL
    FOR SELECT DatNom,Nd,NNAk,Fact,Sp,Our_id,Fam, B_id,Dck FROM #Table2 order by Datnom

    OPEN @CURSOR 

    FETCH NEXT FROM @CURSOR INTO  @DatNom_2,@ND_2,@NNAk_2, @Fact_2, @Sp_2,@Our_2,@Fam,@B_id_2,@DckTek
        
    WHILE @@FETCH_STATUS = 0 and @Plata!=0
    BEGIN
             
      if @Plata>0
      begin 
      /* если переплата <= Долга по накл 
        закрыть накл по переплате и закрыть накл с долгом*/
        if @Plata<=@Sp_2-@Fact_2
        begin
                                   
          Insert into Kassa1(/*nd,tm,*/Oper,Act,SourDate,Nnak,Plata,Fam,P_ID,B_ID,V_ID,Ncod,Remark,
                RashFlag,LostFlag,LastFlag,Op,Bank_ID,Our_ID,BankDay,
                Actn,Ck,Thr,ThrFam,DocNom,OrigRecn,ForPrint,SourDatNom,StNom,FromBank_ID,Dck)  
                                     
          values (/*CONVERT(varchar,getdate(),4) ,CONVERT(varchar,getdate(),8),*/-2,
                  'ВЫ', @ND_2,@NNAk_2,@Plata,@Fam,0,@B_id_2,0,0,
                  @Remark,
                  0,0,0,@op, @Bank_id,@Our_2,@BankDay,0,0,0,'',0,@SerialNom,0,@DatNom_2,0,0,@DckTek)
          set @Plata=0
                                    
        end
        else 
         /*если переплата > Долга по накл 
               закрыть накл по переплате и закрыть накл с долгом*/
            if @Plata>@Sp_2-@Fact_2
          begin
                                    
             Insert into Kassa1(/*nd,tm,*/Oper,Act,SourDate,Nnak,Plata,Fam,P_ID,B_ID,V_ID,Ncod,
                Remark,RashFlag,LostFlag,LastFlag,Op,Bank_ID,Our_ID,BankDay,
                Actn,Ck,Thr,ThrFam,DocNom,OrigRecn,ForPrint,SourDatNom,StNom,FromBank_ID,Dck)  
                                          
            values (/*CONVERT(varchar,getdate(),4) ,CONVERT(varchar,getdate(),8),*/-2,
                    'ВЫ', @ND_2,@NNAk_2,@Sp_2-@Fact_2,@Fam,0,@B_id_2,0,0,
                    @Remark,
                    0,0,0,@op, @Bank_id,@Our_2,@BankDay,0,0,0,'',0,@SerialNom,0,@DatNom_2,0,0,@DckTek)
            set @Plata=@Plata-(@Sp_2-@Fact_2)                
          end 
      end 
      else
        if @Plata<0 
        begin
          if @Plata+@Fact_2<0
          begin                               
            Insert into Kassa1(/*nd,tm,*/Oper,Act,SourDate,Nnak,Plata,Fam,P_ID,B_ID,V_ID,Ncod,Remark,
                  RashFlag,LostFlag,LastFlag,Op,Bank_ID,Our_ID,BankDay,
                  Actn,Ck,Thr,ThrFam,DocNom,OrigRecn,ForPrint,SourDatNom,StNom,FromBank_ID,Dck)  
                                       
            values (/*CONVERT(varchar,getdate(),4) ,CONVERT(varchar,getdate(),8),*/-2,
                    'ВЫ', @ND_2,@NNAk_2,-@Fact_2,@Fam,0,@B_id_2,0,0,
                    @Remark,
                    0,0,0,@op, @Bank_id,@Our_2,@BankDay,0,0,0,'',0,@SerialNom,0,@DatNom_2,0,0,@DckTek)
            set @Plata=@Plata+@Fact_2
          end
          else
            if @Plata+@Fact_2>=0
            begin
              Insert into Kassa1(/*nd,tm,*/Oper,Act,SourDate,Nnak,Plata,Fam,P_ID,B_ID,V_ID,Ncod,Remark,
                    RashFlag,LostFlag,LastFlag,Op,Bank_ID,Our_ID,BankDay,
                    Actn,Ck,Thr,ThrFam,DocNom,OrigRecn,ForPrint,SourDatNom,StNom,FromBank_ID,Dck)  
                                         
              values (/*CONVERT(varchar,getdate(),4) ,CONVERT(varchar,getdate(),8),*/-2,
                      'ВЫ', @ND_2,@NNAk_2,@Plata,@Fam,0,@B_id_2,0,0,
                      @Remark,
                      0,0,0,@op, @Bank_id,@Our_2,@BankDay,0,0,0,'',0,@SerialNom,0,@DatNom_2,0,0,@DckTek)
              set @Plata=0
            end 
        end      
      FETCH NEXT FROM @CURSOR INTO  @DatNom_2,@ND_2,@NNAk_2, @Fact_2, @Sp_2,@Our_2,@Fam,@B_id_2,@DckTek
    END
    CLOSE @CURSOR
  
  drop table #Table2; 
  
  /* if @Plata > 0 
  begin
    if @NNak_2 > 0 
    begin
      insert into Kassa2(nd,tm,Oper,Act,SourDate,Nnak,Plata,Fam,P_ID,B_ID,V_ID,Ncod,Remark,
                       RashFlag,LostFlag,LastFlag,Op,Bank_ID,Our_ID,BankDay,
                       Actn,Ck,Thr,ThrFam,DocNom,OrigRecn,ForPrint,SourDatNom,StNom,FromBank_ID)  
                                         
              values (CONVERT(varchar,getdate(),4) ,CONVERT(varchar,getdate(),8),-2,
                       'ВЫ', @ND_2,@NNAk_2,@Plata,@Fam,0,@B_id_2,0,0,
                       @Remark,
                       0,0,0,@op, @Bank_id,@Our_2,@BankDay,0,0,0,'',0,0,0,@DatNom_2,0,0)
      set @Plata = 0               
    end                 
    
  end*/

 --разблокировка точек 
 /*  DECLARE @Overdue money, @Dis bit
  
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
        
        set @Dis=(select disab from DefContract where dck=@DCK);
        if @Dis=1
        begin
        set @Overdue=(select isnull(sum(nc.SP-isnull(nc.Fact,0)+isnull(NC.Izmen,0)),0) from nc
                      where nc.dck=@dck and nc.srok>0
                      and nc.SP-isnull(nc.Fact,0)+isnull(NC.Izmen,0)>1
                      and nc.ND+2+nc.Srok<GetDate()
                      and nc.Actn=0 and nc.Tara=0 and NC.Frizer=0
                      and nc.SP>0)
             
        if not (@Overdue>0) update DefContract set Disab=0 where dck=@DCK

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
    */  
    set @Pay=@Plata

END