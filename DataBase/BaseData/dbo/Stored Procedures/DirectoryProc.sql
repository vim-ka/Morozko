CREATE PROCEDURE dbo.DirectoryProc
AS
BEGIN
  create table #TempTable (RecId int IDENTITY(1, 1) NOT NULL, 
    pin int,brName varchar(100),brAddr varchar(200), brAg_ID int,Actual bit ,Disab bit,
    LicNo varchar(100),Contact varchar(100),Master int,Buh_ID int,Reg_ID varchar(5),
    LastSver datetime,NeedSver bit,Srok smallint ,Duty money,FullDuty money ,Overdue money,
    NDDolg int,CountFriz int,OurId int,priority int, ContrDate datetime, 
    ContrNum varchar(500), ContrEvalDate datetime, DCK int, ContrName varchar(80));

  declare @ND datetime, @NDY datetime
  declare @dn0 bigint, @AllContract bit
  
  set @ND = dbo.today()
  set @NDY = dateadd(day, -1,  dbo.today())
  set @dn0 = dbo.InDatNom(00000, @ND)

  create table #ncTod(dck int, Duty money, td bit, Izmen money, Fact money)
  create table #kassaTod(dck int, plata money)
  create table #ncIzmTod(dck int, IzmenSP money)
  
  
  create table #TempFrizer(dck int, sPrice money, CountFriz int)
  
  insert into #TempFrizer(dck, sPrice, CountFriz)
  select dck, 
         sum(Price) as SPrice, 
         Count(B_id) as CountFriz
  from Frizer 
  group by dck


 /* insert into #ncTod (pin,Duty,td, Izmen, fact)
    select t.pin, sum(t.sp) as Duty, t.td, sum(t.izmen) as izmen, sum(t.fact) as fact
    from 
    (select case when d.master>0 then d.master 
                                 else d.pin end as pin,
            c.sp,
            iif(c.datnom>=@dn0,1,0) as td,
            c.izmen,
            c.fact
    from nc c join def d on c.b_id=d.pin
    where -- c.DatNom>=@dn0 and c.sp>0 and c.actn=0
         c.Tara=0 and c.Frizer=0 and c.Actn=0 and
        ((c.datnom>=@dn0 and c.sp>0) or (c.nd + c.srok +1 = @ND and (c.SP+ISNULL(c.izmen,0)-c.Fact)>0))
    ) t    
    group by t.pin, t.td
      
    insert into #kassaTod (pin,plata)  
    select t.pin, sum(t.plata) as plata
    from 
    (select case when d.master>0 then d.master 
                              else d.pin end as pin,
         plata as plata
    from kassa1 k join def d on k.b_id=d.pin
    where k.nd>=@ND and k.oper=-2 and k.actn=0) t    
    group by t.pin
    
    insert into #ncIzmTod (pin,IzmenSp)  
    select t.pin, sum(t.IzmenSP) as IzmenSP                                           
    from 
    (select case when d.master>0 then d.master 
                               else d.pin end as pin,
         i.Izmen as IzmenSP
    from ncIzmen i join def d on i.b_id=d.pin
    where i.nd>=@ND) t    
    group by t.pin

  insert into #TempTable 
  select s.pin, 
         s.gpName as brName,
         s.gpAddr, 
         r.Ag_id, 
         s.Actual,
         s.Disab,
         r.ContrNum,
         s.Contact,
         s.Master,
         s.Buh_ID, 
         s.Reg_ID,
         s.LastSver,
         s.NeedSver,
         r.Srok,
         0 as Duty, 
         isnull(b.Debt,0) + isnull(a.Duty,0) - isnull(k.Plata,0) + isnull(i.IzmenSP,0) as FullDuty,
         iif((isnull(b.Overdue,0) - isnull(k.Plata,0) + isnull(i.IzmenSP,0))>0 and isnull(b.Overdue,0)>0,(isnull(b.Overdue,0) - isnull(k.Plata,0) + isnull(i.IzmenSP,0)),0)
         +isnull(ad.Duty,0)+isnull(ad.izmen,0)-isnull(ad.Fact,0) as Overdue,
         iif((isnull(b.Overdue,0) - isnull(k.Plata,0) + isnull(i.IzmenSP,0))>0 and isnull(b.Overdue,0)>0,b.Deep+1,0) as NDDolg,
         c.CountFriz,
         r.Our_Id,
         s.priority,
         r.ContrDate,
         r.ContrNum,
         r.ContrEvalDate,
         r.DCK,
         r.ContrName
  from Def s  join DefContract r on s.pin=r.pin and r.ContrTip=2
              left join (select f.master as pin,
                                max(iif(b.OverDue>0,b.Deep,0)) as Deep,
                                sum(b.Debt) as Debt,
                                sum(b.OverDue) as OverDue 
                         from DailySaldoBr b join def f on f.pin=b.b_id and b.ND=@NDY
                         where f.master>0 and (f.Actual=1)
                         group by f.master
                         ) b on s.pin=b.pin
              left join #ncTod a on s.pin=a.pin and a.td=1
              left join #ncTod ad on s.pin=ad.pin and ad.td=0
              left join #kassaTod k on s.pin=k.pin
              left join #ncIzmTod i on s.pin=i.pin
              left join #TempFrizer c on c.pin=s.pin
  where s.master=s.pin and s.Actual=1 and r.Actual=1
  order by s.master,s.pin

  truncate table #ncTod
  truncate table #kassaTod
  truncate table #ncIzmTod*/
  
  insert into #ncTod (dck,Duty,td,Izmen,fact)
    select t.dck, sum(t.sp) as Duty, t.td, sum(t.izmen), sum(t.fact) 
    from 
    (select d.dck,
            c.sp,
            iif(c.datnom>=@dn0,1,0) as td,
            c.izmen,
            c.fact
    from nc c join defcontract d on c.dck=d.dck
    where --c.DatNom>=@dn0 and c.sp>0 and c.actn=0
        c.Tara=0 and c.Frizer=0 and c.Actn=0 and
        ((c.datnom>=@dn0 and c.sp>0) or (c.nd + c.srok +1 = @ND and (c.SP+ISNULL(c.izmen,0)-c.Fact)>0))
    ) t    
    group by t.dck,t.td
      
    insert into #kassaTod (dck,plata)  
    select t.dck, sum(t.plata) as plata
    from 
    (select d.dck,
            plata as plata
    from kassa1 k join defcontract d on k.dck=d.dck
    where k.nd>=@ND and k.oper=-2 and k.actn=0) t    
    group by t.dck

    insert into #ncIzmTod (dck,IzmenSp)  
    select t.dck, sum(t.IzmenSP) as IzmenSP
    from 
    (select d.dck,
            i.Izmen as IzmenSP
    from ncIzmen i join defcontract d on i.dck=d.dck
    where i.nd>=@ND) t    
    group by t.dck

  insert into #TempTable
  select d.pin,
         d.brName,
         d.gpAddr,
         iif(r.Ag_id in (17,32,33,641),r.PrevAg_ID,r.ag_id) as ag_id,
         d.Actual,
         cast(0 as bit) as Disab,-- r.Disab,
         r.ContrNum,
         d.Contact,
         d.Master,
         d.Buh_ID,
         d.Reg_ID, 
         r.LastSver,
         d.NeedSver,
         r.Srok,
         isnull(b.Debt,0) + isnull(a.Duty,0) - isnull(k.Plata,0) + isnull(i.IzmenSP,0) as Duty,                     
         0 as FullDuty,
         iif((isnull(b.Overdue,0) - isnull(k.Plata,0) + isnull(i.IzmenSP,0))>0 and isnull(b.Overdue,0)>0 ,(isnull(b.Overdue,0) - isnull(k.Plata,0) + isnull(i.IzmenSP,0)),0) 
         +isnull(ad.Duty,0)+ISNULL(ad.izmen,0)-isnull(ad.Fact,0) as Overdue,
         iif((isnull(b.Overdue,0) - isnull(k.Plata,0) + isnull(i.IzmenSP,0))>0 and isnull(b.Overdue,0)>0,b.Deep+1,0) as NDDolg,
         c.CountFriz,
         r.Our_Id,
         d.priority,
         r.ContrDate as Contrdate,
         r.ContrNum as ContrNum,
         r.ContrEvalDate as ContrEvalDate,
         r.DCK,
         r.ContrName
  from Def d join DefContract r on d.pin=r.pin and r.ContrTip=2 
             left join DailySaldoDCK b on r.dck=b.dck and b.ND=@NDY
             left join #ncTod a on r.dck=a.dck and a.td=1
             left join #ncTod ad on r.dck=ad.dck and ad.td=0
             left join #kassaTod k on r.dck=k.dck
             left join #ncIzmTod i on r.dck=i.dck
             left join  #TempFrizer c on r.dck=c.dck
  where /*d.master<>d.pin and*/ d.Actual=1 and r.Actual=1
  order by d.pin


  select 
       RecID,
       cast(0 as bit) as mrk,
       brAg_ID as ag_id,
       pin,
       brName,
       brAddr,
       Actual,
       Disab,
       isnull(LicNo,'') as LicNo,
       isnull(Contact,'') as Contact, 
       Master,
       Buh_ID,
       Reg_ID,
       isnull(LastSver,'') as LastSver,
       NeedSver,
       isnull(Srok,0) as Srok,
       Duty, 
       isnull(FullDuty,0) as FullDuty,
       isnull(Overdue,0) as OverDue, 
       NDDolg,
       isnull(CountFriz, 0) as CountFriz, 
       OurId as Our_ID,
       Priority,
       ContrDate, 
       ContrNum,
       isnull(ContrEvalDate,'') as ContrEvalDate,
       DCK,
       ContrName,  
       cast(0 as bit) as Wostamp,
       cast(LastSver as datetime) ExpSverka,
       0 as Tip
  from #TempTable
  order by pin

END