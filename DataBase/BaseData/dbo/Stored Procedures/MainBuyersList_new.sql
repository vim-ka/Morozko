CREATE PROCEDURE dbo.MainBuyersList_new @Actual bit, @Detail Bit=0, @Our_id varchar(50)='', @worker varchar(10)='',
                                          @obl_id int=0, @rn_id int=0, @BnFlag int=2,
                                          @Obl_idList varchar(50)='', @rn_idList varchar(50)='' 
AS
BEGIN
--  SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED; 
  declare @Cnt int
  set @Cnt = 30
  declare @ND datetime, @NDY datetime
  declare @dn0 int, @AllContract bit
  declare @NeedCK int, @Wh bit
  
  set @Wh = 0
  set @NeedCK = -1
  if @BnFlag = 0 set @NeedCK = 0 
  else if @BnFlag = 2 
  begin
    set @NeedCK = 1 
    set @BnFlag = -1 
  end
  else if @BnFlag = 3
  begin
   set @NeedCK = -1  
   set @BnFlag = -1
   set @Wh = 1  
  end 


  set @ND = dbo.today()
  set @NDY = dateadd(day, -1,  dbo.today())
  set @dn0 = dbo.InDatNom(0000, @ND)
  
  create table #tOur_id (Our_id int)
  create table #tContrtip (ContrTip int)
  create table #tWorker (worker bit)
  create table #tObl_id(Obl_id int)
  create table #tRn_id(rn_id int)
  create table #NeedContr(pin int, dck int)

  
  create table #TempFrizer(pin int, sPriceFriz money, sPriceOther money, CountFriz int, CountOther int)
    
  select d.* into #DefTemp from Def d
  
  insert into #TempFrizer(pin, sPriceFriz, sPriceOther, CountFriz, CountOther)
  select B_id, 
         sum(iif(tip=0,Price,0)) as sPriceFriz,
         sum(iif(tip=0,0,Price)) as sPriceOther,
         sum(iif(tip=0,1,0)) as CountFriz,
         sum(iif(tip=0,0,1)) as CountOther
  from Frizer 
  group by B_id
  

  if @Obl_idList<>''
     insert into #tObl_id (Obl_id) 
     select K from dbo.Str2intarray(@Obl_idList)
  else
     insert into #tObl_id (Obl_id) 
     select Obl_id from Obl

  if @Rn_idList<>''
     insert into #tRn_id (Rn_id) 
     select K from dbo.Str2intarray(@Rn_idList)
  else
     insert into #tRn_id (Rn_id) 
     select Rn_id from Raions

  set @AllContract=0
  if isnull(@Our_id,'') = '' 
  begin
    insert into #tOur_id (Our_id)  
    select Our_id from FirmsConfig
    set @AllContract=1
  end   
  else 
     insert into #tOur_id (Our_id) 
     select K from dbo.Str2intarray(@Our_id)
     
  if isnull(@worker,'') = '' 
  begin
    insert into #tWorker (worker)  
    select 0 
    union
    select 1
  end   
  else 
     insert into #tWorker (worker)  
     select K from dbo.Str2intarray(@worker)   
     
     
  insert into #NeedContr (pin, dck)   
  select c.pin, c.dck 
  from defcontract c 
  where c.ContrTip=2 and (c.Actual=@Actual OR c.Actual=1)
        and c.our_id in (select Our_id from #tOur_id) 
        and (c.bnflag=@BnFlag or @BnFlag=-1)   
        and (c.NeedCK=@NeedCK or @NeedCK=-1)   
        and (((c.bnflag=1 or c.NeedCK=1) and @Wh=1) or @Wh=0)   
        
      
  
  create table #ncTod(pin int, Duty money, td bit, Izmen money, Fact money)
  create table #kassaTod(pin int, plata money)
  create table #ncIzmTod(pin int, IzmenSP money)
    
  create table #TempTable (RecId int IDENTITY(1, 1) NOT NULL, 
           pin int,
           [Master] int,
           gpName varchar(255),
           brName varchar(255),
           Oborot money,
           OborotIce money,
           Duty money,                     
           Overdue money,
           NDDolg int,
           CountFriz int,
           CountOb int,
           SPrice money,
           gpAddr varchar(255),
           brAddr varchar(255), 
           brInn varchar(255),
           Disab bit,
           Debit bit,
           Srok int,
           Worker bit,
           brPhone varchar(50),
           Contact varchar(50)
           );
    
  if @Detail=0
  begin
    insert into #ncTod (pin,Duty,td, Izmen, fact)
    select t.pin, sum(t.sp) as Duty, t.td, sum(t.izmen) as izmen, sum(t.fact) as fact
    from 
    (select case when d.master>0 then d.master 
                                 else d.pin end as pin,
            c.sp,
            iif(c.datnom>=@dn0,1,0) as td,
            c.izmen,
            c.fact
    from nc c join #DefTemp d on c.b_id=d.pin
    where -- c.DatNom>=@dn0 and c.sp>0 and c.actn=0
         c.Tara=0 and c.Frizer=0 and c.Actn=0 and
        ((c.datnom>=@dn0 and c.sp>0) or (c.nd + c.srok +1 = @ND and (c.SP+ISNULL(c.izmen,0)-c.Fact)>0))
    
    
    
    ) t    
    group by t.pin, t.td
    -- create index ncTod_tmp_idx on #ncTod(pin);
      
    insert into #kassaTod (pin,plata)  
    select t.pin, sum(t.plata) as plata
    from 
    (select case when d.master>0 then d.master 
                              else d.pin end as pin,
         plata as plata
    from kassa1 k join #DefTemp d on k.b_id=d.pin
    where k.nd>=@ND and k.oper=-2 and k.actn=0) t    
    group by t.pin
    -- create index kassaTod_tmp_idx on #kassaTod(pin);
    
    insert into #ncIzmTod (pin,IzmenSp)  
    select t.pin, sum(t.IzmenSP) as IzmenSP                                           
    from 
    (select case when d.master>0 then d.master 
                               else d.pin end as pin,
         i.Izmen as IzmenSP
    from ncIzmen i join #DefTemp d on i.b_id=d.pin
    where i.nd>=@ND) t    
    group by t.pin
    --  create index ncIzm_tmp_idx on #ncIzmTod(pin);
  
    insert into #TempTable 
    select distinct 
           d.pin,
           d.[Master],
           d.gpName,
           d.brName,
           (select sum(isnull(e.Oborot,0)) from #DefTemp e where e.master=d.pin)+isnull(a.Duty,0) as Oborot,
           (select sum(isnull(e.OborotIce,0)) from #DefTemp e where e.master=d.pin) as OborotIce, 
           isnull(b.Debt,0) + isnull(a.Duty,0) - isnull(k.Plata,0) + isnull(i.IzmenSP,0) as Duty,                     
           iif((isnull(b.Overdue,0) - isnull(k.Plata,0) + isnull(i.IzmenSP,0))>0 and isnull(b.Overdue,0)>0,(isnull(b.Overdue,0) - isnull(k.Plata,0) + isnull(i.IzmenSP,0)),0)
           +isnull(ad.Duty,0)+ISNULL(ad.izmen,0)-isnull(ad.Fact,0) as Overdue,
           iif((isnull(b.Overdue,0) - isnull(k.Plata,0) + isnull(i.IzmenSP,0))>0 and isnull(b.Overdue,0)>0,b.Deep+1,0) as NDDolg,
           (select IsNull(sum(CountFriz),0) from #TempFrizer where pin in (select pin from #DefTemp where MASTER=d.pin) and tip=0)as CountFriz,
           (select IsNull(sum(CountOther),0) from #TempFrizer where pin in (select pin from #DefTemp where MASTER=d.pin) and tip!=0) as CountOb,
           (select IsNull(sum(sPriceFriz+sPriceOther),0) from #TempFrizer where pin in (select pin from #DefTemp where MASTER=d.pin)) as SPrice,
           d.gpAddr,
           d.brAddr, 
           d.brInn,
           d.Disab,
           d.Debit,
           (select avg(e.Srok) from DefContract e where e.pin=d.pin and e.ContrTip=2 and e.Actual=1) as Srok,
           d.worker,
           d.brPhone,
           d.Contact
    from #DefTemp d left join 
               (select f.master as pin,max(case when b.OverDue>0 then b.Deep else 0 end) as Deep,sum(b.Debt) as Debt, sum(b.OverDue) as OverDue 
               from DailySaldoBr b join #DefTemp f on f.pin=b.b_id and b.ND=@NDY
               where f.master>0 and (f.Actual=1 or f.Actual=@Actual)
               group by f.master
               ) b on d.pin=b.pin
               left join #ncTod a on d.pin=a.pin and a.td=1
               left join #ncTod ad on d.pin=ad.pin and ad.td=0
               left join #kassaTod k on d.pin=k.pin
               left join #ncIzmTod i on d.pin=i.pin
               join #tObl_id o on d.Obl_id=o.Obl_id
               join #tRn_id r on d.Rn_id=r.Rn_id
    where  d.Master=d.pin and (d.Actual=@Actual or d.Actual=1)
           and exists(select c.dck from #NeedContr c where c.pin=d.pin) /*or @AllContract=1)*/
           and (d.worker in (select worker from #tWorker))
           --and (d.obl_id=@obl_id or @obl_id=0)
           --and (d.rn_id=@rn_id or @rn_id=0)
    
    insert into #TempTable 
    select distinct 
           d.pin,
           d.[Master],
           d.gpName,
           d.brName,
           d.Oborot+isnull(a.Duty,0) as Oborot,
           d.OborotIce as OborotIce,
           isnull(b.Debt,0) + isnull(a.Duty,0) - isnull(k.Plata,0) + isnull(i.IzmenSP,0) as Duty,                     
           iif((isnull(b.Overdue,0) - isnull(k.Plata,0) + isnull(i.IzmenSP,0))>0 and isnull(b.Overdue,0)>0 ,(isnull(b.Overdue,0) - isnull(k.Plata,0) + isnull(i.IzmenSP,0)),0) 
           +isnull(ad.Duty,0)+ISNULL(ad.izmen,0)-isnull(ad.Fact,0) as Overdue,
           iif((isnull(b.Overdue,0) - isnull(k.Plata,0) + isnull(i.IzmenSP,0))>0 and isnull(b.Overdue,0)>0,b.Deep+1,0) as NDDolg,
           tf.CountFriz as CountFriz,
           tf.CountOther as CountOb,
           tf.sPriceFriz+tf.sPriceOther as SPrice,
           d.gpAddr,
           d.brAddr, 
           d.brInn,
           d.Disab,
           d.Debit,
           (select avg(e.Srok) from DefContract e where e.pin=d.pin and e.ContrTip=2 and e.Actual=1) as Srok,
           d.worker,
           d.brPhone,
           d.Contact
    from #DefTemp d left join DailySaldoBr b on d.pin=b.b_id and b.ND=@NDY
               left join #ncTod a on d.pin=a.pin and a.td=1
               left join #ncTod ad on d.pin=ad.pin and ad.td=0
               left join #kassaTod k on d.pin=k.pin
               left join #ncIzmTod i on d.pin=i.pin
               join #tObl_id o on d.Obl_id=o.Obl_id
               join #tRn_id r on d.Rn_id=r.Rn_id
               left join #TempFrizer tf on tf.pin=d.pin
    where d.Master=0 and (d.Actual=@Actual or d.Actual=1)
          and exists(select c.dck from #NeedContr c where c.pin=d.pin)
          and (d.worker in (select worker from #tWorker))
          --and (d.obl_id=@obl_id or @obl_id=0)
          --and (d.rn_id=@rn_id or @rn_id=0)
    -- order by d.pin
  end
  else
  begin
    insert into #ncTod (pin,Duty,td,Izmen,fact)
    select t.pin, sum(t.sp) as Duty, t.td, sum(t.izmen), sum(t.fact) 
    from 
    (select d.pin,
            c.sp,
            iif(c.datnom>=@dn0,1,0) as td,
            c.izmen,
            c.fact
    from nc c join #DefTemp d on c.b_id=d.pin
    where --c.DatNom>=@dn0 and c.sp>0 and c.actn=0
        c.Tara=0 and c.Frizer=0 and c.Actn=0 and
        ((c.datnom>=@dn0 and c.sp>0) or (c.nd + c.srok +1 = @ND and (c.SP+ISNULL(c.izmen,0)-c.Fact)>0))
    
    ) t    
    group by t.pin,t.td
    -- create index ncTod_tmp_idx on #ncTod(pin);
      
    insert into #kassaTod (pin,plata)  
    select t.pin, sum(t.plata) as plata
    from 
    (select d.pin,
            plata as plata
    from kassa1 k join #DefTemp d on k.b_id=d.pin
    where k.nd>=@ND and k.oper=-2 and k.actn=0) t    
    group by t.pin
    -- create index kassaTod_tmp_idx on #kassaTod(pin);

    insert into #ncIzmTod (pin,IzmenSp)  
    select t.pin, sum(t.IzmenSP) as IzmenSP
    from 
    (select d.pin,
            i.Izmen as IzmenSP
    from ncIzmen i join #DefTemp d on i.b_id=d.pin
    where i.nd>=@ND) t    
    group by t.pin
    --  create index ncIzm_tmp_idx on #ncIzmTod(pin);
     
    insert into #TempTable 
    select distinct 
           d.pin,
           d.[Master],
           d.gpName,
           d.brName,
           d.Oborot+isnull(a.Duty,0) as Oborot,
           d.OborotIce as OborotIce,
           isnull(b.Debt,0) + isnull(a.Duty,0) - isnull(k.Plata,0) + isnull(i.IzmenSP,0) as Duty,                     
           iif((isnull(b.Overdue,0) - isnull(k.Plata,0) + isnull(i.IzmenSP,0))>0 and isnull(b.Overdue,0)>0,(isnull(b.Overdue,0) - isnull(k.Plata,0) + isnull(i.IzmenSP,0)),0)
           +isnull(ad.Duty,0)+ISNULL(ad.izmen,0)-isnull(ad.Fact,0) as Overdue,
           iif((isnull(b.Overdue,0) - isnull(k.Plata,0) + isnull(i.IzmenSP,0))>0 and isnull(b.Overdue,0)>0,b.Deep+1,0) as NDDolg,
           tf.CountFriz as CountFriz,
           tf.CountOther as CountOb,
           tf.sPriceFriz+tf.sPriceOther as SPrice,
           d.gpAddr,
           d.brAddr, 
           d.brInn,
           d.Disab,
           d.Debit,
           (select avg(e.Srok) from DefContract e where e.pin=d.pin and e.ContrTip=2 and e.Actual=1) as Srok,
           d.worker,
           d.brPhone,
           d.Contact
    from #DefTemp d left join DailySaldoBr b on d.pin=b.b_id and b.ND=@NDY
               left join #ncTod a on d.pin=a.pin and a.td=1
               left join #ncTod ad on d.pin=ad.pin and ad.td=0
               left join #kassaTod k on d.pin=k.pin
               left join #ncIzmTod i on d.pin=i.pin
               left join #TempFrizer tf on tf.pin=d.pin
               join #tObl_id o on d.Obl_id=o.Obl_id
               join #tRn_id r on d.Rn_id=r.Rn_id
    where d.Master>0 and (d.Actual=@Actual or d.Actual=1)
          and exists(select c.dck from #NeedContr c where c.pin=d.pin) --or @AllContract=1)
          and (d.worker in (select worker from #tWorker))
          --and (d.obl_id=@obl_id or @obl_id=0)
          --and (d.rn_id=@rn_id or @rn_id=0)
    order by d.master

  end

  select distinct
         pin, 
         brName,
         gpName,
         [Master],
         Oborot,
         OborotIce,
         Duty,                     
         Overdue,
         NDDolg,
         CountFriz,
         CountOb,
         brAddr, 
         gpAddr,
         brInn,
         SPrice,
         brPhone,
         Contact,
         Disab,
         Debit,
         RecId,
         Srok,
         0 as CalcTara,
         '' as Remark,
         0 as FullDocs,
         Cast('20150101' as datetime) as LastSver,
         0 as buh_id,
         worker
         
  from #TempTable
  order by RecId
 
END