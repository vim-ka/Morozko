CREATE PROCEDURE [LoadData].UnloadReVal @NDStart datetime, @NDEnd datetime, @Our_ID int
AS
BEGIN
 /*select distinct 
         n.nd,
         n.datnom as vk,
         n.SP,
         --n.NewSP
         c.SP as NewSP
    
  from ncedit n join nvedit v on n.datnom=v.datnom
                join nc c on n.datnom=c.datnom
  where n.ND>=@NDStart and n.ND<=@NDEnd and c.OurID=@Our_ID
        and dbo.DatNomInDate(n.datnom)<>n.ND
        and v.price<>v.newprice
        --and n.NewSP<>0 -- пока заглушка
        --and n.SP<>n.NewSP
        and n.SP<>c.SP*/
        
select  distinct 
         n.datnom as vk,
         n.SP,
         --n.NewSP
         s.sm as NewSP
  from ncedit n join nvedit v on n.datnom=v.datnom
                join nc c on n.datnom=c.datnom
                join 
                
   (select t.datnom, sum(t.sm) as sm from              
  (select c.datnom,
          v.price*(1+c.extra/100)*(v.kol+
                  isnull((select sum(r.kol) from nv r join nc c1 on r.datnom=c1.datnom and v.tekid=r.tekid                                         
                                            where c1.refdatnom=c.datnom
                                            and isnull(c1.remark,'')='' and v.datnom=c1.refdatnom),0)
          ) sm
          
   from nc c join nv v on c.datnom=v.datnom
             join visual s on v.tekid=s.id 
   where c.ourid=@our_id and c.Sp>0 and  c.Actn<>1 and c.Frizer<>1 and c.Tara<>1 and c.STip not in (2,3,4)
   
   ) t  group by t.datnom) s   on n.datnom=s.datnom
  where n.ND>=@NDStart and n.ND<=@NDEnd and n.Our_ID=@Our_ID
        and dbo.DatNomInDate(n.datnom)<>n.ND
        and v.price<>v.newprice
        and s.sm<>0 -- пока заглушка
        --and n.SP<>n.NewSP
        and n.SP<>s.sm
        and c.refdatnom=0 

        
END