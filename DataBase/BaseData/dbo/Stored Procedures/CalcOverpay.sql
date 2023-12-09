CREATE PROCEDURE dbo.CalcOverpay
AS
BEGIN
 
 -- SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED; 

  create table #TempTable (DatNom bigint, ND datetime, NNAk int, B_Id int,
                         Sp money,Sc money,fact money,CountNC int, 
                         BankDay datetime, Bank_id int, our_id int,
                         Fam varchar(40), dck int, dckmaster int, kassid int);
                          
 insert into  #TempTable (DatNom, ND, NNAk, B_Id, Sp,Sc,fact,CountNC,BankDay, Bank_id,
                           our_id,Fam, dck, dckmaster, kassid)
 select distinct DatNom,
       dbo.DatNomInDate(nc.DatNom),
       dbo.InNnak(nc.DatNom),
       nc.B_id,SP,SC,Fact-(SP+Izmen) as Fact,
       IsNull(A.CountNC,0),
       B.BankDay,
       B.Bank_id,
       ourId,
       cast(D.gpName as varchar(40)),
       nc.dck,
       iif(isnull(r.dckmaster,0) = 0, r.dck, r.dckmaster) as dckmaster,
       B.Kassid
 from NC join DefContract r on nc.dck=r.Dck
        left join
        (select count(c.DatNom) as CountNC,
                iif(isnull(t.dckmaster,0)=0,t.dck,t.dckmaster) as dckmaster
         from NC c join DefContract t on c.dck=t.Dck
         where c.SP+c.Izmen>c.Fact and c.Tara!=1 and c.Frizer!=1 and c.Actn!=1
         group by iif(isnull(t.dckmaster,0)=0,t.dck,t.dckmaster)) A on A.dckmaster=iif(isnull(r.dckmaster,0)=0,r.dck,r.dckmaster)
        left join
        (select Bank_id, ks.SourDatnom,
                case when Bank_id = 0 then convert(varchar,getdate(),4) 
                     else BankDay
                end as BankDay,
                ks.kassid
         from Kassa1 ks where ks.kassid=(select max(k1.Kassid) as KassId from Kassa1 k1 where k1.sourdatnom=ks.sourdatnom) 

         ) B on B.SourDatnom = nc.DatNom
   
        left join Def d on D.pin=nc.B_id
  
 where Fact-(SP+Izmen)>=0.01 and Tara!=1 and Frizer!=1 and Actn!=1 
       and nc.datnom>=09010100000 and nc.B_id!=3434 and isnull(r.Factoring,0)=0
       and IsNull(A.CountNC,0)>0  and isnull(r.Degust,0)=0
 order by DatNom
  
  create Table #Tmp(B_id int,DatNom bigint)
    
  DECLARE @DatNom bigint,@NNak int,@ND datetime, @Fact money, @B_id int,@Count int ,
          @BankDay datetime, @Bank_id int, @Pay money, @our_Id int, @Fam varchar(40), @dck int, @dckmaster int, @kassid int

 /*внешний курсор по переплатам*/         
  DECLARE @CURSOR CURSOR 
  SET @CURSOR  = CURSOR SCROLL
  FOR SELECT DatNom,ND,NNak,Fact,B_id,CountNC,
          IsNull(BankDay,dbo.today()), Bank_id, our_id, fam, dck, dckmaster,kassid FROM #TempTable
          where CountNC>0 order by datnom
          

  OPEN @CURSOR 

  FETCH NEXT FROM @CURSOR INTO  @DatNom, @ND, @NNAk, @Fact, @B_id, @Count, @BankDay, 
                                @Bank_id, @our_Id, @Fam, @dck, @dckmaster, @kassid
  WHILE @@FETCH_STATUS = 0
  BEGIN   
    set @Pay=0
    if @Count>0 /*если есть не закрытые накладные*/
    begin
      insert into #tmp values(@B_id,@DatNom)
      
      execute PayNakl @B_id,0,@Fact,'компенсация отрицательного сальдо',0,0,@BankDay,@Pay output,@dck, -1, @kassid --@dckmaster
 
      if @Fact-@Pay<>0
        insert into Kassa1(Oper,Act,SourDate,Nnak,Plata,Fam,P_ID,B_ID,V_ID,Ncod,Remark,
                RashFlag,LostFlag,LastFlag,Op,Bank_ID,Our_ID,BankDay,
                Actn,Ck,Thr,ThrFam,DocNom,OrigRecn,ForPrint,SourDatNom,StNom,FromBank_ID, dck)  
             
        values (-2,'ВЫ', @ND,@NNAk,-(@Fact-@Pay),@Fam,0,@B_id,0,0,
                  'компенсация отрицательного сальдо',
                  0,0,0,0, 0,@our_Id,CONVERT(varchar,getdate(),4) ,0,0,0,'',0,@kassid,0,@DatNom,0,0, @dck)
    end
    
    FETCH NEXT FROM @CURSOR INTO  @DatNom, @ND, @NNAk, @Fact, @B_id, @Count,@BankDay,
                                  @Bank_id, @our_Id, @Fam, @dck, @dckmaster, @kassid
  END
  
  CLOSE @CURSOR 
 
END