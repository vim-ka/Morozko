CREATE PROCEDURE dbo.CalcVendOrder 
AS
BEGIN
  Declare @ND datetime, @DatNom1 bigint, @DatNom2 bigint, @DatNom3 bigint, @DatNom4 bigint,
    @Nd1 datetime, @Nd2 datetime, @Nd3 datetime, @Nd4 datetime,
    @m1 int,@m2 int, @m3 int 
  
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
         v.ncod,
         v.DCK,
         v.hitag,
         p.PLID
  into #Temp
  from visual v join vendors e on v.ncod=e.ncod 
                join skladlist s on v.sklad=s.skladno
                join skladgroups g on s.skg=g.skg
                join skladplace p on g.PLID=p.PLID  
  where e.actual=1 and v.datepost>='20170101' and v.ncod<>694
  
  
 -- drop table #salesperiod
  select n.tekid as id,
         MONTH(c.nd) as m,
         isnull(sum(n.price*n.kol*(1+c.extra/100))/sum(n.kol+0.01),0) as price,
         isnull(sum(n.cost*n.kol*(1+c.extra/100))/sum(n.kol+0.01),0) as cost,
         case when m.flgWeight=1 then isnull(sum(i.weight*n.kol),0) else isnull(sum(n.kol),0) end as kol
  into #salesperiod
  from nc c join nv n  with (INDEX(NV_Datnom_idx)) on c.datnom=n.datnom 
            join nomen m on n.hitag=m.hitag
            join visual i on n.tekid=i.id
  where n.DatNom>=@DatNom1 and n.DatNom<@DatNom4
  group by n.tekid,MONTH(c.nd), m.flgWeight
  
   select
       distinct
       t.ncod,
       t.DCK,
       t.hitag,
       isnull((select avg(s.price) from #salesperiod s where s.id=t.id),0) as price,
       isnull((select avg(s.cost) from #salesperiod s where s.id=t.id),0) as cost,
       isnull((select sum(s.kol) from #salesperiod s where s.m=@m1 and s.id=t.id),0) as kol1,
       isnull((select sum(s.kol) from #salesperiod s where s.m=@m2 and s.id=t.id),0) as kol2,
       isnull((select sum(s.kol) from #salesperiod s where s.m=@m3 and s.id=t.id),0) as kol3,
       t.PLID
  into #sls
  from #Temp t
  
  select a.hitag, isnull(count(distinct a.WorkDate),0) DOst1 into #TDOst1
  from MorozArc.dbo.ArcVI a where a.WorkDate>=@Nd2 and a.WorkDate<@Nd3
  group by a.hitag
   
  select a.hitag, isnull(count(distinct a.WorkDate),0) DOst2 into #TDOst2
  from MorozArc.dbo.ArcVI a where a.WorkDate>=@Nd3 and a.WorkDate<@Nd4
  group by a.hitag
  
  insert into vendOrder (Ncod,DCK,Hitag,SPrice,SCost,Month2,Month1,CurrMonth,DOstMonth1,DOstCurrMonth, PLID)
  select distinct
       t.ncod,
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
  from #sls t left join  #TDOst1 a1 on a1.hitag = t.hitag
              left join  #TDOst2 a2 on a2.hitag = t.hitag
  --where t.hitag=26776            
       /*outer apply   
       (select isnull(count(distinct a.WorkDate),0) DOst2 from MorozArc.dbo.ArcVI a where a.WorkDate>=@Nd2 and a.WorkDate<@Nd3
        and a.hitag = t.hitag) a1
      
      outer apply   
       (select isnull(count(distinct a.WorkDate),0) DOst2 from MorozArc.dbo.ArcVI a where a.WorkDate>=@Nd3 and a.WorkDate<@Nd4
        and a.hitag = t.hitag) a2*/
        
  group by t.ncod,
           t.dck,
           t.hitag,
           a1.Dost1, 
           a2.Dost2,
           t.PLID
 
  
 /* insert into vendOrder (Ncod,DCK,Hitag,SPrice,SCost,Month2,Month1,CurrMonth,DOstMonth1,DOstCurrMonth, PLID)
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
  select v.ncod ncod,
       v.DCK DCK,
       v.hitag hitag,
       (select isnull(sum(n.price*n.kol*(1+c.extra/100))/sum(n.kol+0.01),0) 
        from nv n, nc c where n.datnom=c.datnom and n.DatNom>=@DatNom1 and n.DatNom<@DatNom4
        and  n.tekid=v.id) as price,
       (select isnull(sum(n.cost*n.kol*(1+c.extra/100))/sum(n.kol+0.01),0)
        from nv n , nc c where n.datnom=c.datnom and n.DatNom>=@DatNom1 and n.DatNom<@DatNom4
        and  n.tekid=v.id) as cost,
       (select isnull(sum(n.kol),0) kol from nv n where n.DatNom>=@DatNom1 and n.DatNom<@DatNom2
        and  n.tekid=v.id) as kol1,
       (select isnull(sum(n.kol),0) kol from nv n where n.DatNom>=@DatNom2 and n.DatNom<@DatNom3
        and  n.tekid=v.id) as kol2,
       (select isnull(sum(n.kol),0) kol from nv n where n.DatNom>=@DatNom3 and n.DatNom<@DatNom4
        and n.tekid=v.id) as kol3,
        p.PLID
  from visual v join vendors e on v.ncod=e.ncod 
                join skladlist s on v.sklad=s.skladno
                join skladgroups g on s.skg=g.skg
                join skladplace p on g.PLID=p.PLID  
  where e.actual=1 and v.datepost>='20080101'
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
  
  --delete from vendOrder where (Month1=0 or Month1 is Null) and (Month2=0 or Month2 is Null) and (CurrMonth=0 or CurrMonth is Null) 
  --                            and ncod not in (574,717,701,822,872,868,1205)
                   
  
  update vendOrder set DOstCurrMonth=isnull(DOstCurrMonth,0),
                       CurrMonth=isnull(CurrMonth,0),
                       DOstMonth1=isnull(DOstMonth1,0),
                       Month1=isnull(Month1,0)
                                     
                              
  if Day(@ND)>=15
  update vendOrder set AvgTempSale=(case when DOstCurrMonth = 0 then CurrMonth else CurrMonth/DOstCurrMonth end);   
  else
  update vendOrder set AvgTempSale=(case when (DOstMonth1+DOstCurrMonth) = 0 then (Month1+CurrMonth) else (Month1+CurrMonth)/(DOstMonth1+DOstCurrMonth) end);    --(dbo.DaysInMonth(DATEADD(MONTH,-1,@ND))+Day(@ND))
  
  
  --Расчет реализации--
  
   update Comman set realiz= Tab.Realiz  
  from Comman
  left join
    (select T.Ncom,Isnull( Sum(Realiz),0)  as Realiz 
    from
        (select  IsNull(B.Ncom,F.Ncom) as Ncom,
               Sum((1-Fact/Sp)*((A.Kol-A.Kol_B)*A.Price)) as Realiz
               
        from Nc join NV A with(nolock, index(NV_Datnom_idx)) on A.DatNom=nc.Datnom
                left join (select vi.Ncod,id,Ncom from Visual vi)B on B.id=A.tekid
                left join (select vi.Ncod,id,Ncom from tdVi vi)F on F.id=A.tekid
        where SP+Izmen-Fact>0.01 and Sp>0 and actn=0 and tara=0 and frizer=0  
              and SP<>0
        group by B.Ncom,F.Ncom) T
  group by T.Ncom) Tab on Tab.Ncom=Comman.Ncom
  /*update comman set realiz=0
  select z.ncom,sum(z.realiz) as realiz into #TempRealiz from
  (select nv.DatNom,v.ncod,v.ncom,
         (nv.kol-nv.kol_b)*nv.cost*(1-(select nc.fact/nc.sp from nc where nc.datnom=nv.datnom and nc.sp<>0 and nc.sp is not null)) as realiz
  from nv, visual v 
  where nv.kol>0 and nv.TekID=v.id and
  (select nc.fact/nc.sp from nc where nc.datnom=nv.datnom and nc.sp<>0 and nc.sp is not null)<>1) z
  group by z.ncom

  update comman set realiz=(select isnull(t.realiz,0) from #TempRealiz t where t.ncom=comman.ncom)
  update comman set realiz=0 where realiz is null
  drop table #TempRealiz*/
  
  
  /*update Comman set realiz= Tab.Realiz  
  from Comman
  left join
    (select T.Ncom,Isnull( Sum(Realiz),0)  as Realiz 
    from
        (select  IsNull(B.Ncom,F.Ncom) as Ncom,
               Sum((1-Fact/Sp)*(A.Kol*A.Price)) as Realiz
               
        from Nc 
        left join
        (select tekid,Kol-Kol_b as Kol,Cost, datnom,hitag,Price 
         from NV)A on A.DatNom=nc.Datnom
        left join
        
         (select vi.Ncod,id,Ncom from Visual vi)B on B.id=A.tekid
          
        left join
         (select vi.Ncod,id,Ncom from tdVi vi)F on F.id=A.tekid
        where SP+Izmen-Fact>0.01 and Sp>0 and actn=0 and tara=0 and frizer=0  
        and SP<>0
          and B_id not in (select pin from def where tip=1 and bonus=1)
          
        group by B.Ncom,F.Ncom)T
  group by T.Ncom) Tab on Tab.Ncom=Comman.Ncom*/
  
END