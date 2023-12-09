CREATE PROCEDURE dbo.PayComman @Ncod int,@Plata money,
                 @Bank_id int, @BankDay datetime, @Our_id int,
                 @Remark varchar(60),@OP int,@Pay money OUTPUT, @DCK int=0, @pin int=0 
     
AS
BEGIN
   DECLARE @Ncom int, @ND datetime, @Dolg money, @Fam varchar(40)
   
   if @DCK=0 set @DCK=(select min(DCK) from DefContract where ContrTip=1 and pin=@Ncod)
   if isnull(@pin,0)=0 set @pin=isnull((select max(pin) from Def where Ncod=@Ncod),0)
   if @bankday is not null set @bankday=cast(floor(cast(@bankday as decimal(38,19))) as datetime)     
   create table #TmpTable (Ncom int,Fam varchar(50),Dolg money, ND datetime);
  
   /*Находим незакрытые комиссии*/
   insert into  #TmpTable (Ncom,Fam,Dolg,ND)
   select c.Ncom,v.Fam,c.summacost+c.izmen+c.remove+c.corr-c.plata as Dolg, c.Date as ND
   from comman c left join defcontract d on c.dck=d.dck 
                 join vendors v on c.ncod=v.ncod   
   where c.ncod=v.ncod and c.ncod=@Ncod and c.DCK=@DCK
         and c.summacost+c.izmen+c.remove+c.corr-c.plata>0 and c.Ncom>0 and d.ContrTip=1
   order by c.Ncom       
                        
      
    /*курсор по закрытию комиссий*/
    DECLARE @CURSOR CURSOR 
    SET @CURSOR  = CURSOR SCROLL
    FOR SELECT Ncom,Fam,Dolg,ND FROM #TmpTable order by Ncom

    OPEN @CURSOR 

    FETCH NEXT FROM @CURSOR INTO  @Ncom,@Fam,@Dolg,@ND
        
    WHILE @@FETCH_STATUS = 0
    BEGIN
             
      if @Plata>0
      begin
      /* если переплата <= Долга по накл 
        закрыть накл по переплате и закрыть накл с долгом*/
        if @Plata<=@Dolg
        begin
                                  
          insert into Kassa1(nd,tm,Oper,Act,SourDate,Nnak,Plata,Fam,P_ID,B_ID,V_ID,Ncod,Remark,
                RashFlag,LostFlag,LastFlag,Op,Bank_ID,Our_ID,BankDay,
                Actn,Ck,Thr,ThrFam,DocNom,OrigRecn,ForPrint,SourDatNom,StNom,FromBank_ID,DCK,pin)  
                                     
          values (CONVERT(varchar,getdate(),104) ,CONVERT(varchar,getdate(),8),-1,
                  'ВЫ', @ND,@Ncom,@Plata,@Fam,0,0,0,@Ncod,@Remark,
                   1,0,0,@Op, @Bank_id,@Our_id,@BankDay,0,0,0,'',0,0,0,0,0,0,@DCK,@pin)
          set @Plata=0
                                    
        end
        else
         /*если переплата > Долга по накл 
               закрыть накл по переплате и закрыть накл с долгом*/
          if @Plata>@Dolg
          begin
                                    
            insert into Kassa1(nd,tm,Oper,Act,SourDate,Nnak,Plata,Fam,P_ID,B_ID,V_ID,Ncod,Remark,
                RashFlag,LostFlag,LastFlag,Op,Bank_ID,Our_ID,BankDay,
                Actn,Ck,Thr,ThrFam,DocNom,OrigRecn,ForPrint,SourDatNom,StNom,FromBank_ID,DCK,pin)  
                                     
            values (CONVERT(varchar,getdate(),104) ,CONVERT(varchar,getdate(),8),-1,
                  'ВЫ', @ND,@Ncom,@Dolg,@Fam,0,0,0,@Ncod,@Remark,
                   1,0,0,@Op,@Bank_id,@Our_id,@BankDay,0,0,0,'',0,0,0,0,0,0,@DCK,@pin)
            set @Plata=@Plata-@Dolg
          end 
      end       
      FETCH NEXT FROM @CURSOR INTO  @Ncom,@Fam,@Dolg,@ND
    END
    CLOSE @CURSOR
    
    set @Pay=@Plata
    select @Pay
END