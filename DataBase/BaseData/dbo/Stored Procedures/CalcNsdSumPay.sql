CREATE PROCEDURE dbo.CalcNsdSumPay @b_idIn int, @Plata money, @DatNom int
AS
BEGIN
  create table #TempTable (DatNom int ,SDate datetime, DatNumber int, Sp money,
                          Sp_B money,Ourid int,NDSf bit, Nds10 money,Nds18 money,Nds0 money);
  insert into  #TempTable (DatNom, SDate, DatNumber, Sp, Sp_B,Ourid,NDSf, Nds10,Nds18,Nds0)
  
select nc.DatNom,nc.ND,cast(RIGHT(nc.DatNom,4) as int)as DatNumber,
       nc.Sp, nc.Sp+ISNULL(nc.Back,0),Ourid,
   case 
          when Ourid in (select Our_id from FirmsConfig where Nds=1)then 'TRUE'
          else 'FALSE'
   end as NDSf,
   case 
          when Ourid in (select Our_id from FirmsConfig where Nds=1) then 
              (select  ROUND((IsNull(Sum(Price*(Kol-Kol_B)),0)*(1+Extra/100)/(nc.Sp /*+ISNULL(nc.Back,0)*/ ))*@Plata,2) from NV
               join
                 (select nds,Hitag from Nomen where Nds=10)A on A.Hitag=NV.Hitag 
                  where DatNom=nc.DatNom)
          else 0
   end as  Nds10, 
   case 
           when Ourid in (select Our_id from FirmsConfig where Nds=1) then 
              (select ROUND((IsNull(Sum(Price*(Kol-Kol_B)),0)*(1+Extra/100)/(nc.Sp /*+ISNULL(nc.Back,0)*/ ))*@Plata,2) from NV
               join
                 (select nds,Hitag from Nomen )A on A.Hitag=NV.Hitag 
                  where DatNom=nc.DatNom and A.Nds=18)
          else 0
   end as Nds18,
   case 
          when Ourid in (select Our_id from FirmsConfig where Nds=1) then
              (select ROUND((IsNull(Sum(Price*(Kol-Kol_B)),0)*(1+Extra/100)/(nc.Sp /*+ISNULL(nc.Back,0)*/ ))*@Plata,2) from NV
               join
                  (select nds,Hitag from Nomen)A on A.Hitag=NV.Hitag
               where DatNom=nc.DatNom and A.Nds=0) else 0 
   end as Nds0
from NC
where  B_id=@b_idIn and nc.DatNom=@DatNom  and Actn!=1  

 DECLARE @DatNomUp int,@Nds10 money,@Nds18 money,@Nds0 money,@corr money
 DECLARE @CURSOR CURSOR 
  SET @CURSOR  = CURSOR SCROLL
  FOR SELECT DatNom,Nds10,Nds18,Nds0 FROM #TempTable

  OPEN @CURSOR 

  FETCH NEXT FROM @CURSOR INTO  @DatNomUp,@Nds10,@Nds18,@Nds0
  set @corr=@Plata-(@Nds10+@Nds18+@Nds0)                
  if (@corr!=0) set @Nds18=@Nds18+@corr 
   

  WHILE @@FETCH_STATUS = 0
  BEGIN

    Update #TempTable set Nds18=@Nds18
    where DatNom=@DatNomUP  
    FETCH NEXT FROM @CURSOR INTO @DatNomUp,@Nds10,@Nds18,@Nds0
    set @corr=@Plata-(@Nds10+@Nds18+@Nds0)                
    if (@corr!=0) set @Nds18=@Nds18+@corr
     
  END
  
  CLOSE @CURSOR 
  
 select *,Round((NDS10-NDS10*100/110),2)as NDS10sum,
          Round((NDS18-NDS18*100/118),2)as NDS18sum 
  FROM #TempTable 

END