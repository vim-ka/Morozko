CREATE PROCEDURE dbo.CalcVendOrderByND
AS
BEGIN
  Declare @ND datetime
  Declare @DatNom1 bigint
  Declare @DatNom2 bigint
  Declare @DatNom3 bigint
  Declare @DatNom4 bigint
  Declare @Nd1 datetime, @Nd2 datetime, @Nd3 datetime, @Nd4 datetime
  Declare @m1 int,@m2 int, @m3 int 
  
  set @ND=GETDATE()
   
  
  set @DatNom1 = dbo.InDatNom(0,DATEADD(day,-day(DATEADD(MONTH,-2,@ND))+1,DATEADD(MONTH,-2,@ND)))
  set @DatNom2 = dbo.InDatNom(0,DATEADD(day,-day(DATEADD(MONTH,-1,@ND))+1,DATEADD(MONTH,-1,@ND)))
  set @DatNom3 = dbo.InDatNom(0,DATEADD(day,-day(@ND)+1,@ND))
  set @DatNom4 = dbo.InDatNom(0,DATEADD(day,-day(DATEADD(MONTH,1,@ND))+1,DATEADD(MONTH,1,@ND)))
  
  set @Nd1 = DATEADD(day,-day(DATEADD(MONTH,-2,@ND))+1,DATEADD(MONTH,-2,@ND))
  set @Nd2 = DATEADD(day,-day(DATEADD(MONTH,-1,@ND))+1,DATEADD(MONTH,-1,@ND))
  set @Nd3 = DATEADD(day,-day(DATEADD(MONTH, 0,@ND))+1,DATEADD(MONTH, 0,@ND))
  set @Nd4 = DATEADD(day,-day(DATEADD(MONTH, 1,@ND))+1,DATEADD(MONTH, 1,@ND))

  set @ND= dateadd(day,datediff(day,(0),@ND),(0))
  set @Nd1=dateadd(day,datediff(day,(0),@Nd1),(0))
  set @Nd2=dateadd(day,datediff(day,(0),@Nd2),(0))
  set @Nd3=dateadd(day,datediff(day,(0),@Nd3),(0))
  set @Nd4=dateadd(day,datediff(day,(0),@Nd4),(0))
  
  set @m1=month(@ND1)
  set @m2=month(@ND2)
  set @m3=month(@ND3)
  
  truncate table vendOrder
  
 -- drop table #Temp
  select v.id,
         v.ncod ncod,
         v.DCK DCK,
         v.hitag hitag,
         p.PLID
  into #Temp
  from visual v join vendors e on v.ncod=e.ncod 
                join skladlist s on v.sklad=s.skladno
                join skladgroups g on s.skg=g.skg
                join skladplace p on g.PLID=p.PLID  
  where e.actual=1 and v.datepost>='20080101'
  
  
 -- drop table #salesperiod
  select n.tekid as id,
         MONTH(c.nd) as m,
         isnull(sum(n.price*n.kol*(1+c.extra/100))/sum(n.kol+0.01),0) as price,
         isnull(sum(n.cost*n.kol*(1+c.extra/100))/sum(n.kol+0.01),0) as cost,
         case when m.flgWeight=1 then isnull(sum(i.weight),0) else isnull(sum(n.kol),0) end as kol
  into #salesperiod
  from nv n join nc c on n.datnom=c.datnom 
            join nomen m on n.hitag=m.hitag
            join visual i on n.tekid=i.id
  where n.DatNom>=@DatNom1 and n.DatNom<@DatNom4
  group by n.tekid,MONTH(c.nd), m.flgWeight
  
/*  insert into vendOrder (Ncod,DCK,Hitag,SPrice,SCost,Month2,Month1,CurrMonth,DOstMonth1,DOstCurrMonth, PLID)
  select t.ncod,
       t.dck,
       t.hitag, 
       avg(t.price) as  price,
       avg(t.cost) as cost,
       sum(t.kol1) as kol1, 
       sum(t.kol2) as kol2,
       sum(t.kol3) as kol3,
       a1.Dost1, 
       a2.Dost2,
       t.PLID
  from (       
  select t.ncod ncod,
       t.DCK DCK,
       t.hitag hitag,
       (select avg(s.price) from #salesperiod s where s.id=t.id) as price,
       (select avg(s.cost) from #salesperiod s where s.id=t.id) as cost,
       (select sum(s.kol) from #salesperiod s where s.m=@m1 and s.id=t.id) as kol1,
       (select sum(s.kol) from #salesperiod s where s.m=@m2 and s.id=t.id) as kol2,
       (select sum(s.kol) from #salesperiod s where s.m=@m3 and s.id=t.id) as kol3,
        t.PLID
  from #Temp t
  ) t outer apply
       (select isnull(count(distinct a.WorkDate),0) DOst1 from MorozArc.dbo.ArcVI a where a.WorkDate>=@Nd2 and a.WorkDate<@Nd3
        and a.hitag = t.hitag) a1
      outer apply   
       (select isnull(count(distinct a.WorkDate),0) DOst2 from MorozArc.dbo.ArcVI a where a.WorkDate>=@Nd3 and a.WorkDate<@Nd4
        and a.hitag = t.hitag) a2
  group by t.ncod,
           t.dck,
           t.hitag,
           a1.Dost1, 
           a2.Dost2,
           t.PLID
  */
  
 
  
  
END