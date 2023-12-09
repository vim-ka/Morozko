CREATE PROCEDURE dbo.NdsReportFirms @FirmId int, @ND1 datetime, @ND2 datetime, @Param tinyint,
                 @BnFlg tinyint
AS
BEGIN
   SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
   create table #TempDef(pin int)
   
   if @BnFlg=1 --Бел накл
   begin
     insert into #TempDef (pin)
     select distinct B_id
     from NC
     where (BankId>0 or CK>0) and nd>=@ND1 and nd<=@ND2 
           and Sp!=0 and Sc!=0 and Frizer!=1 and Actn!=1 and Tara!=1
   end
   else 
     if @BnFlg=2 --Нал с чеком+Безнал
     begin
      /*  insert into #TempDef (pin)
       select distinct B_id
       from NC
       where (BankId!=0 or CK!=0) and nd>=@ND1 and nd<=@ND2 
                  and Sp!=0 and Sc!=0 and Frizer=0 and Actn=0 and Tara=0*/
     
         insert into #TempDef (pin)
         select pin
         from Def
         where tip=1 and (TovChk=1 OR bnflg=1)

     end
       
   
  create table #TempTable (Datnom int,B_id int,fam varchar(120),CountNak int,CountBNak int, 
      BSum money,PSum money, Allsum money,NDS10 money,NDS10_ money,NDS18 money,NDS18_ money,
      NDS0 money,NDS0_ money,SP money,Bank tinyint, Chk tinyint, Master int)
      
  create table #TempTable2 (B_id int,master int,fam varchar(120),CountNak int,bezNDS money, 
                           nds money, PSum money, CountBNak int, bezNDS_ money, nds_ money,
                           BSum money, Allsum money )

if @BnFlg=1
begin
  insert into  #TempTable (Datnom,B_id,master,fam,NDS10,NDS10_ ,NDS18,NDS18_,NDS0,NDS0_,sp)
  select distinct nc.Datnom,NC.B_id,C.master,C.Name,
       
       (select (IsNull(Sum(Price*Kol),0))  from NV
        join
       (select nds,Hitag from Nomen)C on C.Hitag=NV.Hitag 
        where DatNom=nc.Datnom and nc.SP>0 and Nds=10 )*(1+nc.Extra/100)as NDS10,
         
         (select (IsNull(Sum(Price*Kol),0))  from NV
        join
       (select nds,Hitag from Nomen)C on C.Hitag=NV.Hitag 
        where DatNom=nc.Datnom and nc.SP<0 and Nds=10 )*(1+nc.Extra/100) as NDS10_,
       
        (select (IsNull(Sum(Price*Kol),0)) from NV
        join
       (select nds,Hitag from Nomen)C on C.Hitag=NV.Hitag 
        where DatNom=nc.Datnom and nc.SP>0 and Nds=18 )*(1+nc.Extra/100)  as NDS18,
         
       (select (IsNull(Sum(Price*Kol),0))  from NV
        join
       (select nds,Hitag from Nomen)C on C.Hitag=NV.Hitag 
        where DatNom=nc.Datnom and nc.SP<0 and Nds=18  )*(1+nc.Extra/100) as NDS18_,
        
       (select (IsNull(Sum(Price*Kol),0)) from NV
        join
       (select nds,Hitag from Nomen)C on C.Hitag=NV.Hitag 
        where DatNom=nc.Datnom and nc.SP>0 and Nds=0 )*(1+nc.Extra/100)  as NDS0,
         
       (select (IsNull(Sum(Price*Kol),0))  from NV
        join
       (select nds,Hitag from Nomen)C on C.Hitag=NV.Hitag 
        where DatNom=nc.Datnom and nc.SP<0 and Nds=0  )*(1+nc.Extra/100) as NDS0_,
      nc.SP
    from NC  
    left join
    (select pin,master,
         case  
           when master=0 then gpName
           else (select brName from Def where tip=1 and pin=D.master)
         end as Name
        from Def d where tip=1)C on C.pin=nc.B_id
    where nd>=@ND1 and nd<=@ND2 and nc.OurId=@FirmId and 
       B_id in (select pin from #TempDef) and (BankId!=0 or CK!=0)
       and nc.SP!=0
       and Frizer!=1 and Actn!=1 and Tara!=1
    order by B_id 




   insert into #TempTable2 (B_id,master,fam,CountNak, bezNDS, nds, PSum,
                         CountBNak, bezNDS_, nds_ ,BSum, Allsum ) 
        select  tt.B_id,tt.master,fam,B.CountNak,
             case 
               when B.CountNak is not null then 
                       ROUND(SUM(NDS10)/1.1+ SUM(NDS18)/1.18+ Sum(NDS0),2)
               else null  
             end as bezNDS,
             case 
               when B.CountNak is not null then
                      (IsNull(B.PSum,0)-ROUND(SUM(NDS10)/1.1+ SUM(NDS18)/1.18+ Sum(NDS0),2))
               else null
             end as nds,
             case
               when B.CountNak is not null then IsNull(B.PSum,0)
               else null
             end as PSum ,A.CountBNak,
              case 
               when A.CountBNak is not null then
                      ROUND(SUM(NDS10_)/1.1+ SUM(NDS18_)/1.18+ Sum(NDS0_),2)
               else null
             end as bezNDS_,
              case
               when A.CountBNak is not null then
                 (IsNull(A.BSum,0)-ROUND(SUM(NDS10_)/1.1+ SUM(NDS18_)/1.18+ Sum(NDS0_),2))
               else null
             end as nds_,
             case
               when A.CountBNak is not null then IsNull(A.BSum,0)
               else null
             end as BSum, IsNull(A.BSum,0)+IsNull(B.PSum,0) as Allsum 

        from #TempTable tt
        left join
        (select count(Datnom)as CountNak,Sum(Sp)as PSum,B_id,OurId
         from NC 
         where nd>=@ND1 and nd<=@ND2 and (Sp>0) and OurId=@FirmId  and
           B_id in (select pin from #TempDef) and (BankId!=0 or CK!=0)
          and Frizer!=1 and Actn!=1 and Tara!=1
        group by B_id,OurId)B on B.B_id=tt.B_ID 
        left join
        (select count(Datnom)as CountBNak,Sum(Sp)as BSum,B_id,OurId
         from NC 
         where nd>=@ND1 and nd<=@ND2 and (Sp<0)  and OurId=@FirmId and
            B_id in (select pin from #TempDef) and (BankId!=0 or CK!=0)
          and Frizer!=1 and Actn!=1 and Tara!=1
         group by B_id,OurId)A on A.B_id=tt.B_ID 
        group by tt.B_id,master,fam,B.CountNak,A.CountBNak,A.BSum,B.PSum
   
END
  
if @BnFlg=2
begin
  insert into  #TempTable (Datnom,B_id,master,fam,NDS10,NDS10_ ,NDS18,NDS18_,NDS0,NDS0_,sp)
  select distinct nc.Datnom,NC.B_id,C.master,C.Name,
       
       (select (IsNull(Sum(Price*Kol),0))  from NV
        join
       (select nds,Hitag from Nomen)C on C.Hitag=NV.Hitag 
        where DatNom=nc.Datnom and nc.SP>0 and Nds=10 )*(1+nc.Extra/100)as NDS10,
         
         (select (IsNull(Sum(Price*Kol),0))  from NV
        join
       (select nds,Hitag from Nomen)C on C.Hitag=NV.Hitag 
        where DatNom=nc.Datnom and nc.SP<0 and Nds=10 )*(1+nc.Extra/100) as NDS10_,
       
        (select (IsNull(Sum(Price*Kol),0)) from NV
        join
       (select nds,Hitag from Nomen)C on C.Hitag=NV.Hitag 
        where DatNom=nc.Datnom and nc.SP>0 and Nds=18 )*(1+nc.Extra/100)  as NDS18,
         
       (select (IsNull(Sum(Price*Kol),0))  from NV
        join
       (select nds,Hitag from Nomen)C on C.Hitag=NV.Hitag 
        where DatNom=nc.Datnom and nc.SP<0 and Nds=18  )*(1+nc.Extra/100) as NDS18_,
        
       (select (IsNull(Sum(Price*Kol),0)) from NV
        join
       (select nds,Hitag from Nomen)C on C.Hitag=NV.Hitag 
        where DatNom=nc.Datnom and nc.SP>0 and Nds=0 )*(1+nc.Extra/100)  as NDS0,
         
       (select (IsNull(Sum(Price*Kol),0))  from NV
        join
       (select nds,Hitag from Nomen)C on C.Hitag=NV.Hitag 
        where DatNom=nc.Datnom and nc.SP<0 and Nds=0  )*(1+nc.Extra/100) as NDS0_,
      nc.SP
    from NC  
    left join
    (select pin,master,
         case  
           when master=0 then gpName
           else (select brName from Def where tip=1 and pin=D.master)
         end as Name
        from Def d where tip=1)C on C.pin=nc.B_id
    where nd>=@ND1 and nd<=@ND2 and nc.OurId=@FirmId and 
       ((B_id in (select pin from #TempDef) ) or (BankId!=0 or CK!=0))
       and nc.SP!=0
       and Frizer!=1 and Actn!=1 and Tara!=1
    order by B_id 


   insert into #TempTable2 (B_id,master,fam,CountNak, bezNDS, nds, PSum,
                         CountBNak, bezNDS_, nds_ ,BSum, Allsum ) 
        select  tt.B_id,tt.master,fam,B.CountNak,
             case 
               when B.CountNak is not null then 
                       ROUND(SUM(NDS10)/1.1+ SUM(NDS18)/1.18+ Sum(NDS0),2)
               else null  
             end as bezNDS,
             case 
               when B.CountNak is not null then
                      (IsNull(B.PSum,0)-ROUND(SUM(NDS10)/1.1+ SUM(NDS18)/1.18+ Sum(NDS0),2))
               else null
             end as nds,
             case
               when B.CountNak is not null then IsNull(B.PSum,0)
               else null
             end as PSum ,A.CountBNak,
              case 
               when A.CountBNak is not null then
                      ROUND(SUM(NDS10_)/1.1+ SUM(NDS18_)/1.18+ Sum(NDS0_),2)
               else null
             end as bezNDS_,
              case
               when A.CountBNak is not null then
                 (IsNull(A.BSum,0)-ROUND(SUM(NDS10_)/1.1+ SUM(NDS18_)/1.18+ Sum(NDS0_),2))
               else null
             end as nds_,
             case
               when A.CountBNak is not null then IsNull(A.BSum,0)
               else null
             end as BSum, IsNull(A.BSum,0)+IsNull(B.PSum,0) as Allsum 

        from #TempTable tt
        left join
        (select count(Datnom)as CountNak,Sum(Sp)as PSum,B_id,OurId
         from NC 
         where nd>=@ND1 and nd<=@ND2 and (Sp>0) and OurId=@FirmId  and
           ((B_id in (select pin from #TempDef)) or (BankId!=0 or CK!=0))
          and Frizer!=1 and Actn!=1 and Tara!=1
        group by B_id,OurId)B on B.B_id=tt.B_ID 
        left join
        (select count(Datnom)as CountBNak,Sum(Sp)as BSum,B_id,OurId
         from NC 
         where nd>=@ND1 and nd<=@ND2 and (Sp<0)  and OurId=@FirmId and
            ((B_id in (select pin from #TempDef)) or (BankId!=0 or CK!=0))
          and Frizer!=1 and Actn!=1 and Tara!=1
         group by B_id,OurId)A on A.B_id=tt.B_ID 
        group by tt.B_id,master,fam,B.CountNak,A.CountBNak,A.BSum,B.PSum
    
END

if @Param=0
begin 
  select B_id,fam,CountNak, bezNDS, nds, PSum,
       CountBNak, bezNDS_, nds_ ,BSum, Allsum,0 as mas
  from #TempTable2
end
else
begin
   select master as B_id,fam,Sum(CountNak) as CountNak,Sum(bezNDS) as bezNDS, 
        Sum(nds) as nds,Sum(PSum) as PSum,
       Sum(CountBNak) as CountBNak,Sum(bezNDS_) as bezNDS_, Sum(nds_) as nds_,
        Sum(BSum) as BSum, Sum(Allsum) as Allsum,1 as mas
  from #TempTable2
  where master!=0
  group by master,fam
  union
  select B_id,fam,CountNak,bezNDS, nds,PSum,
       CountBNak,bezNDS_, nds_, BSum, Allsum,0 as mas
  from #TempTable2
  where Master=0
  order by B_id
end


END