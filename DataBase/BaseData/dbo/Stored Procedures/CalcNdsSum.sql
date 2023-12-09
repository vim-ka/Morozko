CREATE PROCEDURE dbo.CalcNdsSum @b_idIn int, @date1 datetime, @master int
AS
BEGIN
  create table #TempTable (KassId int,SourDatNom int ,SourDate datetime, DatNumber int, Plata money,
                         Ck bit, Remark varchar(80), Sp money,OurId int,NDSf bit, Nds10 money,
                         Nds18 money,Nds0 money);
                         
declare @AllNet bit 
                        
if @master > 0 set @AllNet = 1;
else set @AllNet = 0;  

if @master > 0
                        
   insert into  #TempTable (KassId,SourDatNom,SourDate, DatNumber, Plata,
                            Ck,Remark, Sp,OurId,NDSf,Nds10,Nds18,Nds0)
   select ks.KassId,
         ks.SourDatNom,
         ks.SourDate,
         cast(RIGHT(ks.SourDatNom,4) as int)as DatNumber,
         ks.Plata, 
         ISNULL(ks.Ck,0) as Ck,
         ks.Remark,
         D.Sp,
         ks.Our_id,
         case when isnull(f.Nds,0)=1 
           then 'TRUE'
           else 'FALSE'
         end as NDSf,
         case when isnull(f.Nds,0)=1  then 
           case when D.Sp < ks.Plata then
                (select ROUND((IsNull(sum(Price*(Kol-Kol_B)),0)*(1+D.Extra/100)/D.Sp)*D.Sp,3) from NV
                 join (select nds,Hitag from Nomen)A on A.Hitag=NV.Hitag 
                 where Nds=10 and DatNom=ks.SourDatNom) 
                when (D.Sp>=ks.Plata) and (D.Sp!=0) then
                 (select ROUND((IsNull(sum(Price*(Kol-Kol_B)),0)*(1+D.Extra/100)/D.Sp)*ks.Plata,3) from NV
                 join (select nds,Hitag from Nomen)A on A.Hitag=NV.Hitag 
                 where Nds=10 and DatNom=ks.SourDatNom) 
            else 0
          end       
         else 0
        end as  Nds10, 
        case when isnull(f.Nds,0)=1 then
          case  when D.Sp<ks.Plata then
             (select ROUND((IsNull(Sum(Price*(Kol-Kol_B)),0)*(1+D.Extra/100)/D.Sp)*D.Sp,3) from NV
              join (select nds,Hitag from Nomen)A on A.Hitag=NV.Hitag 
              where Nds=18 and DatNom=ks.SourDatNom) 
           when (D.Sp>=ks.Plata) and (D.Sp!=0) then
              (select ROUND((IsNull(Sum(Price*(Kol-Kol_B)),0)*(1+D.Extra/100)/D.Sp)*ks.Plata,3) from NV
              join (select nds,Hitag from Nomen)A on A.Hitag=NV.Hitag 
               where Nds=18 and DatNom=ks.SourDatNom) 
           else 0
          end 
          else 0
          end as Nds18,
         case 
         when isnull(f.Nds,0)=1 then
         case  when D.Sp<ks.Plata then
              (select ROUND((IsNull(Sum(Price*(Kol-Kol_B)),0)*(1+D.Extra/100)/D.Sp)*D.Sp,3) from NV
               join (select nds,Hitag from Nomen where nds=0)A on A.Hitag=NV.Hitag
               where DatNom=SourDatNom)
         when (D.Sp>=ks.Plata) and (D.Sp!=0) then
              (select ROUND((IsNull(Sum(Price*(Kol-Kol_B)),0)*(1+D.Extra/100)/D.Sp)*ks.Plata,3) from NV
               join (select nds,Hitag from Nomen where nds=0)A on A.Hitag=NV.Hitag
               where DatNom=SourDatNom)
          else 0
         end            
       else 0 
       end as Nds0
from Kassa1 ks cross apply (select c.Sp,c.Extra,c.DatNom from NC c where c.datnom=ks.sourdatnom) D
               left join FirmsConfig f on ks.Our_id=f.Our_id
where ks.Nd=@date1 and ks.Act='ВЫ' and ks.B_id in (select pin from Def where Master=@master)-- or (ks.B_id in (select pin from Def where Master=@master) and @AllNet = 1)) 
      and ks.Actn!=1 --and ks.remark<>'компенсация отрицательного сальдо'  --and our_Id=7 

 else 
 
   insert into  #TempTable (KassId,SourDatNom,SourDate, DatNumber, Plata,
                         Ck , Remark, Sp,OurId,NDSf,Nds10,Nds18,Nds0)
                               
   select ks.KassId,
         ks.SourDatNom,
         ks.SourDate,
         cast(RIGHT(ks.SourDatNom,4) as int)as DatNumber,
         ks.Plata, 
         ISNULL(ks.Ck,0) as Ck,
         ks.Remark,
         D.Sp,
         ks.Our_id,
         case when isnull(f.Nds,0)=1 
           then 'TRUE'
           else 'FALSE'
         end as NDSf,
         case when isnull(f.Nds,0)=1  then 
           case when D.Sp < ks.Plata then
                (select ROUND((IsNull(sum(Price*(Kol-Kol_B)),0)*(1+D.Extra/100)/D.Sp)*D.Sp,3) from NV
                 join (select nds,Hitag from Nomen)A on A.Hitag=NV.Hitag 
                 where Nds=10 and DatNom=ks.SourDatNom) 
                when (D.Sp>=ks.Plata) and (D.Sp!=0) then
                 (select ROUND((IsNull(sum(Price*(Kol-Kol_B)),0)*(1+D.Extra/100)/D.Sp)*ks.Plata,3) from NV
                 join (select nds,Hitag from Nomen)A on A.Hitag=NV.Hitag 
                 where Nds=10 and DatNom=ks.SourDatNom) 
            else 0
          end       
         else 0
        end as  Nds10, 
        case when isnull(f.Nds,0)=1 then
          case  when D.Sp<ks.Plata then
             (select ROUND((IsNull(Sum(Price*(Kol-Kol_B)),0)*(1+D.Extra/100)/D.Sp)*D.Sp,3) from NV
              join (select nds,Hitag from Nomen)A on A.Hitag=NV.Hitag 
              where Nds=18 and DatNom=ks.SourDatNom) 
           when (D.Sp>=ks.Plata) and (D.Sp!=0) then
              (select ROUND((IsNull(Sum(Price*(Kol-Kol_B)),0)*(1+D.Extra/100)/D.Sp)*ks.Plata,3) from NV
              join (select nds,Hitag from Nomen)A on A.Hitag=NV.Hitag 
               where Nds=18 and DatNom=ks.SourDatNom) 
           else 0
          end 
          else 0
          end as Nds18,
         case 
         when isnull(f.Nds,0)=1 then
         case  when D.Sp<ks.Plata then
              (select ROUND((IsNull(Sum(Price*(Kol-Kol_B)),0)*(1+D.Extra/100)/D.Sp)*D.Sp,3) from NV
               join (select nds,Hitag from Nomen where nds=0)A on A.Hitag=NV.Hitag
               where DatNom=SourDatNom)
         when (D.Sp>=ks.Plata) and (D.Sp!=0) then
              (select ROUND((IsNull(Sum(Price*(Kol-Kol_B)),0)*(1+D.Extra/100)/D.Sp)*ks.Plata,3) from NV
               join (select nds,Hitag from Nomen where nds=0)A on A.Hitag=NV.Hitag
               where DatNom=SourDatNom)
          else 0
         end            
       else 0 
       end as Nds0
from Kassa1 ks cross apply (select c.Sp,c.Extra,c.DatNom from NC c where c.datnom=ks.sourdatnom) D
               left join FirmsConfig f on ks.Our_id=f.Our_id
where ks.Nd>=@date1 and ks.Nd<=@date1 and ks.Act='ВЫ' and ks.B_id=@b_idIn
      and ks.Actn!=1-- and ks.remark<>'компенсация отрицательного сальдо'  
 
 DECLARE @corr money,@KassId int,@Plata money,@Nds10 money,@Nds18 money,@Nds0 money, @NDS bit
 
 set @corr = 0
 
 
 DECLARE @CURSOR CURSOR 
  SET @CURSOR  = CURSOR SCROLL
  FOR SELECT KassId,Plata,Round(Nds10,2),Round(Nds18,2),Round(Nds0,2), NDSf FROM #TempTable

  OPEN @CURSOR 

  FETCH NEXT FROM @CURSOR INTO @KassId,@Plata,@Nds10,@Nds18,@Nds0, @NDS
  set @corr=@Plata-(@Nds10+@Nds18+@Nds0)                
  if (@corr!=0) --and (@NDS=1) 
  begin
    if @Nds18+@corr>0 set @Nds18=@Nds18+@corr;
  end; 
  
  update #TempTable set Nds18=@Nds18 where KassId=@KassId  

  WHILE @@FETCH_STATUS = 0
  BEGIN
    FETCH NEXT FROM @CURSOR INTO @KassId,@Plata,@Nds10,@Nds18,@Nds0, @NDS
    set @corr=@Plata-(@Nds10+@Nds18+@Nds0)                
    if (@corr!=0) --and (@NDS=1)
    set @Nds10=@Nds10+@corr
    
    update #TempTable set Nds10=@Nds10  where KassId=@KassId  
  END
  
  CLOSE @CURSOR 

select @corr,KassId,SourDatNom,SourDate, DatNumber, Plata,Ck , Remark, 
       Sp,OurId,NDSf,
       Round(Nds10,2) as Nds10,
       Round(Nds18,2) as Nds18,
       Round(Nds0,2) as Nds0,
       Round((NDS10-NDS10*100/110),2)as NDS10sum,
       Round((NDS18-NDS18*100/118),2)as NDS18sum 
 FROM #TempTable  
 order by KassId
END