CREATE PROCEDURE MobAgents.MobSaveMess @ag_id int
AS
BEGIN
  declare @ND datetime 
  declare @datnom bigint
  declare @FirmGroup int
  declare @Our_id int
  declare @NDToday datetime
  set @NDToday = GETDATE(); 
 
  set @Our_id=isnull((select d.our_id 
                      from deps d join agentlist a on d.DepID=a.DepID
                      where a.ag_id=@ag_id),1)
  
  set @ND=dbo.today()
  set @datnom=dbo.InDatNom(0,@ND)
  set @FirmGroup=(select f.FirmGroup from FirmsConfig f where f.Our_id=@Our_id)
  
  create table #NeedDCK (dck int)
  
  insert into #NeedDCK (dck)
  select c.dck from defcontract c where c.ag_id=@ag_id or c.ag_id in (select b.add_ag_id from agaddbases b where b.ag_id=@ag_id and b.add_ag_id<>0)
  union
  select b.add_dck from agaddbases b where b.ag_id=@ag_id and b.add_dck<>0

  select c.* into #ncTemp from nc c where c.nd>=@ND-1 and c.dck in (select dck from #NeedDCK)
  
   
--************Сообщения о перебросе точек на 33 код Тыщика с просрочкой больше 31 дня**************  
 select 10 as MessType, 0 as Nnak, m.nd as nd, '' as tm, d.pin as b_id, d.gpName as fam, 0 as sp, 0 as weight,
         0 as Marsh, '' as Phone, '' as ATime, 0 as Hitag, '' as  GName, 0 as Qty
         
  from MoveDotsLog m left join DefContract c on m.dck=c.dck
                     left join Def d on c.pin=d.pin   
  where m.ND=@ND and (m.ag_id=@ag_id or m.sv_ag_id=@ag_id) and m.TakeOff = 1

UNION    
--*********Сообщения о возврате точек с 33 кода Тыщика, если просрочка меньше 31 дня*********
  select 20 as MessType, 0 as Nnak, m.nd as nd, '' as tm, d.pin as b_id, d.gpName as fam, 0 as sp, 0 as weight,
         0 as Marsh, '' as Phone, '' as ATime, 0 as Hitag, '' as  GName, 0 as Qty
  from MoveDotsLog m left join DefContract c on m.dck=c.dck
                     left join Def d on c.pin=d.pin   
                     
  where m.ND=@ND and (m.ag_id=@ag_id or m.sv_ag_id=@ag_id) and m.TakeOff = 0

UNION 

--******************Клиент в блоке - отказ*********************  
  select 23 as MessType, 0 as Nnak,m.nd, m.tm,m.pin as b_id,d.gpName as fam, 0 as sp, 0 as weight,
         0 as Marsh, '' as Phone, '' as ATime, 0 as Hitag, m.Remark as  GName, 0 as Qty
  from [MobAgents].Mess m join Def d on m.pin=d.pin
  where m.ND=@ND and m.ag_id=@ag_id and m.MessType=5
        and m.tm>CONVERT([varchar],@NDToday-0.042,(8)) 
        and @ag_id in (55,139,162)
UNION 

--******************Предварительная доставка накладных*****************************************
  select 25 as MessType, dbo.InNnak(c.datnom) as Nnak,c.nd, c.tm,c.b_id,c.fam,c.sp,c.weight,
         m.Marsh, r.Phone, m.awaytime as ATime, 0 as Hitag, '' as GName, 0 as Qty
  from marsh m join #ncTemp c on m.nd=c.nd and m.mhid=c.mhid
               left join Drivers r on m.DrID=r.DrID 
  where m.MStatus in (1,2) and m.DelivCancel=0 
        and (c.dck in (select dck from #NeedDCK) /*and @ag_id=809) or @ag_id<>809*/)
UNION  
--****************************Доставка накладных*****************************************
  select 30 as MessType, dbo.InNnak(c.datnom) as Nnak,c.nd, c.tm,c.b_id,c.fam,c.sp,c.weight,
         m.Marsh, r.Phone, m.awaytime as ATime, 0 as Hitag, '' as GName, 0 as Qty
  from marsh m join #ncTemp c on m.nd=c.nd and m.mhid=c.mhid
               left join Drivers r on m.DrID=r.DrID 
  where m.awaytime>=@ND-0.2083 and m.DelivCancel=0 
        and (c.dck in (select dck from #NeedDCK) /*and @ag_id=809) or @ag_id<>809*/) 
UNION 
--*****************************Отмена рейсов********************************************* 
  select 40 as MessType, dbo.InNnak(c.datnom) as Nnak,c.nd, c.tm,c.b_id,c.fam,c.sp,c.weight,
         m.Marsh, r.Phone, m.awaytime as ATime, 0 as Hitag, '' as GName, 0 as Qty
  from marsh m join #ncTemp c on m.nd=c.nd and m.mhid=c.mhid
               left join Drivers r on m.DrID=r.DrID 
  where m.ND>=@ND-1 and m.DelivCancel=1 
        and (c.dck in (select dck from #NeedDCK) /*and @ag_id=809) or @ag_id<>809*/)       
UNION
--***********************Накладные не попавшие в развоз***********************************
  select 50 as MessType, dbo.InNnak(c.datnom) as Nnak,c.nd, c.tm,c.b_id,c.fam,c.sp,sum(a.Massa) as weight,
         0 as Marsh, '' as Phone, '' as ATime, 0 as Hitag, '' as GName, 0 as Qty
  from #ncTemp c join (select n.datnom,n.kol*nm.netto as Massa from nv n, nomen nm where n.hitag=nm.hitag and n.kol-n.kol_b>0) a on a.datnom=c.datnom
  where c.nd=@ND-1 and c.sp>0 and c.mhid=0 
          and (c.dck in (select dck from #NeedDCK) /*and @ag_id=809) or @ag_id<>809*/)
        --and c.dck in (select dck from #NeedDCK)
  group by dbo.InNnak(c.datnom),c.tm,c.fam,c.sp, c.b_id, c.nd             
UNION

--*****************Накладные, переведенные на завтра*************************************** 
  select 60 as MessType, dbo.InNnak(c.datnom) as Nnak,c.nd, c.tm,c.b_id,c.fam,c.sp, c.weight,
         0 as Marsh, '' as Phone, '' as ATime, 0 as Hitag, '' as GName, 0 as Qty
  from #ncTemp c
  where c.nd=@ND and c.DayShift>0 and c.sp>0
        --and c.dck in (select dck from #NeedDCK)
  
UNION  
/*--****************************Отмененные накладные****************************************
  select 70 as MessType,  dbo.InNnak(c.datnom) as Nnak,c.nd, c.tm, c.b_id, c.fam,c.sp,c.weight,
         0 as marsh, '' as Phone, '' as ATime, 0 as Hitag, '' as GName, 0 as Qty
  from #ncTemp c
  where c.delivcancel=1
  and c.nd>=@ND-1
      --and c.dck in (select dck from #NeedDCK)

UNION  
--********** Частично отменена доставка по накладным**********
  select 80 as MessType, dbo.InNnak(c.datnom) as Nnak,c.nd, c.tm,c.b_id,c.fam,c.sp, c.weight,
         0 as Marsh, '' as Phone, '' as ATime, v.hitag as Hitag, n.name as GName, v.kol as Qty
  from #ncTemp c join nv v /*with(index (nv_datnom_idx))*/ on c.datnom=v.datnom
                 join nomen n on v.hitag=n.hitag  
  where c.nd>=@ND-1 and v.DelivCancel=1
        --and c.dck in (select dck from #NeedDCK)
UNION                 */
--**************Накладные за последний час********************
  select 90 as MessType, dbo.InNnak(c.datnom) as Nnak,c.nd, c.tm,c.b_id,c.fam,c.sp,sum(a.Massa) as weight,
         0 as Marsh, '' as Phone, '' as ATime, 0 as Hitag, '' as GName, 0 as Qty
  from #ncTemp c left join (select n.datnom,n.kol*nm.netto as Massa from nv n, nomen nm where n.hitag=nm.hitag) a on a.datnom=c.datnom
                 left join (select z.datnom from nvzakaz z) z on z.datnom=c.datnom
  where --c.dck in (select dck from #NeedDCK) and
        c.nd=@ND and (c.sp>0 or (c.sp=0 and isnull(z.datnom,0)>0))
        and c.tm>CONVERT([varchar],@NDToday-0.042,(8))
  group by dbo.InNnak(c.datnom),c.tm,c.fam,c.sp, c.b_id, c.nd
  
UNION    

--************** Удаленные накладные********************
  select 95 as MessType, dbo.InNnak(c.datnom) as Nnak, c.nd, c.tm,c.b_id,c.fam,0 as sp,0 as weight,
         0 as Marsh, '' as Phone, '' as ATime, 0 as Hitag, '' as GName, 0 as Qty
  from #ncTemp c join dbo.nv v  on c.DatNom = v.DatNom
  where c.fam not like '%Перемещена%'
  group by c.DatNom,c.B_ID,c.nd,c.fam, c.tm
  having sum(v.Kol-Kol_B)=0 

UNION  

--************** Добивка накладные********************
  select 97 as MessType, dbo.InNnak(c.datnom) as Nnak, c.nd, c.tm,c.b_id,c.fam,v.newprice*v.newkol as sp,
           v.newkol*iif(n.flgWeight=1,t.Weight, 0) as weight,
           0 as Marsh, '' as Phone, '' as ATime, v.hitag as Hitag, n.name as GName, v.newkol as Qty
  from #ncTemp c join dbo.nvedit v  on c.DatNom = v.DatNom
                 join nomen n on v.hitag=n.hitag
                 join tdvi t on v.ID=t.ID   
  where c.datnom>=@datnom and v.kol=0 and v.newkol>0

UNION 
--**********************Неуд. спрос*************************
  select 100 as MessType, 0 as Nnak,s.nd, s.tm,s.b_id,d.gpName as fam, s.Qty*s.Price as sp, s.Ves as weight,
         0 as Marsh, '' as Phone, '' as ATime, s.hitag as Hitag, n.name as GName, s.Qty as Qty
  from NotSat s join nomen n on s.hitag=n.hitag   
                join Def d on s.b_id=d.pin
  where s.ND=@ND and s.ag_id=@ag_id
        and s.dck in (select dck from #NeedDCK)
UNION    
--******************Клиент в блоке - отказ*********************  
  select 110 as MessType, 0 as Nnak,m.nd, m.tm,m.pin as b_id,d.gpName as fam, 0 as sp, 0 as weight,
         0 as Marsh, '' as Phone, '' as ATime, 0 as Hitag, '' as  GName, 0 as Qty
  from [MobAgents].Mess m join Def d on m.pin=d.pin
  where m.ND=@ND and m.ag_id=@ag_id and m.MessType=0
        and m.tm>CONVERT([varchar],@NDToday-0.083,(8))
UNION    
--*****************Сегоднящние выплаты*********************  
  select 120 as MessType, 0 as Nnak,k.nd, k.tm,k.pin as b_id, k.Remark as fam, k.plata as sp, 0 as weight,
         0 as Marsh, '' as Phone, '' as ATime, 0 as Hitag, '' as  GName, 0 as Qty
  from Kassa1 k 
  where k.ND=@ND and k.OP=1000+@ag_id and k.oper=59
        --and k.tm>CONVERT([varchar],getdate()-0.042,(8))
        
UNION        
--******************Проведение денег без доверенности*********************  
/*  select 125 as MessType, 0 as Nnak, m.nd, m.tm, m.pin as b_id, d.gpName as fam, cast(m.Remark as money) as sp, 0 as weight,
         0 as Marsh, '' as Phone, '' as ATime, 0 as Hitag, '' as  GName, 0 as Qty
  from [MobAgents].Mess m join Def d on m.pin=d.pin
  where m.ND=@ND and m.ag_id=@ag_id and m.MessType=6
 
  
UNION    */
--******************Запрет продажи товара*********************  
  select 130 as MessType, 0 as Nnak,m.nd, m.tm,m.pin as b_id,d.gpName as fam, 0 as sp, 0 as weight,
         Data0 as Marsh, u.fio as Phone, '' as ATime, 0 as Hitag, m.Remark as  GName, 0 as Qty
  from [MobAgents].Mess m join Def d on m.pin=d.pin
                          left join netspec2_main n on m.Data0=n.nmid
                          left join usrPwd u on n.op=u.uin    
  where m.ND=@ND and m.ag_id=@ag_id and m.MessType=1
     --   and m.tm>CONVERT([varchar],getdate()-0.042,(8))  
  
UNION
  --*****************Не набрано на складе************
  select 140 as MessType, dbo.InNnak(c.datnom) as Nnak,c.nd, c.tm,c.b_id,c.fam,c.sp,0 as weight,
         0 as Marsh, v.Remark as Phone, v.tmEnd as ATime, v.hitag as Hitag, n.name as GName, v.zakaz as Qty
  from #ncTemp c join nvzakaz v on c.datnom=v.datnom
            join nomen n on v.hitag=n.hitag
  where  v.nd=@ND and v.id=0 and v.done=1  
        -- and c.dck in (select dck from #NeedDCK)
        
UNION    
--******************Отказ в наборе документов*********************  
  select 150 as MessType, dbo.InNnak(cast(m.data0 as int)) as Nnak,m.nd, m.tm,m.pin as b_id,d.gpName as fam, 0 as sp, 0 as weight,
         0 as Marsh, '' as Phone, '' as ATime, 0 as Hitag, m.Remark as GName, 0 as Qty
  from [MobAgents].Mess m join Def d on m.pin=d.pin
  where m.ND=@ND and m.ag_id=@ag_id and m.MessType=2

UNION    
--******************Отказ в обработке накладных*********************
  select 160 as MessType, dbo.InNnak(c.datnom) as Nnak,c.nd, c.tm,c.b_id,c.fam,c.sp, c.weight,
         0 as Marsh, '' as Phone, '' as ATime, 0 as Hitag, '' as GName, 0 as Qty
  from #ncTemp c
  where c.nd=@ND and c.done=0 and c.sp>0 and c.sp<1500
        --and c.dck in (select dck from #NeedDCK)
        
UNION    
--***********************Новые поставки*********************  
  select 170 as MessType, 0 as Nnak, c.[date] as nd, c.[Time] as tm, 0 as b_id, d.brName as fam, 0 as sp, 0 as weight,
         0 as Marsh, '' as Phone, '' as ATime, i.hitag as Hitag, n.name as  GName, 0 as Qty
  from Comman c join Inpdet i on c.ncom=i.ncom
                join nomen n on i.hitag=n.hitag
                join Def d on c.pin=d.pin
                join FirmsConfig f on c.Our_id=f.Our_id
  where c.[Date]=@ND and f.FirmGroup=@FirmGroup
        and c.[Time]>CONVERT([varchar],@NDToday-0.2,(8)) 

UNION    
--***********************Переоценки***************************  
  select 180 as MessType, 0 as Nnak, i.nd as nd, i.tm as tm, 0 as b_id, '' as fam,
        round(iif(n.flgWeight=1,i.price/i.weight, i.price),2) as sp,
        round(iif(n.flgWeight=1,i.newprice/i.newweight, i.newprice),2) as weight,
        iif(n.flgWeight=1,1,0) as Marsh, '' as Phone, '' as ATime, i.hitag as Hitag, n.name as  GName, 0 as Qty
  from Izmen i join DefContract c on i.dck=c.dck
                join nomen n on i.hitag=n.hitag
                join Def d on c.pin=d.pin
                join FirmsConfig f on c.Our_id=f.Our_id
  where i.[ND]>=@ND and f.FirmGroup=@FirmGroup and Act='ИзмЦ' and i.price<>i.newprice 
        --and c.[Time]>CONVERT([varchar],getdate()-0.2,(8))                
        
UNION    
--******************Невозможность подбора*********************  
  select 190 as MessType, 0 as Nnak,m.nd, m.tm,m.pin as b_id, d.gpName + ' Договор '+ isnull(dc.ContrName,'') as fam, 0 as sp, 0 as weight,
         0 as Marsh, m.Remark as Phone, '' as ATime, Data0 as Hitag, n.name as  GName, 0 as Qty
  from [MobAgents].Mess m join Def d on m.pin=d.pin
                          left join nomen n on m.Data0=n.hitag
                          left join DefContract dc on dc.dck=m.dck
  where m.ND=@ND and m.ag_id=@ag_id and m.MessType=3
     --   and m.tm>CONVERT([varchar],getdate()-0.042,(8)) 
     
UNION    
--******************Слишком малый заказ *********************  
  select 195 as MessType, 0 as Nnak,m.nd, m.tm,m.pin as b_id,d.gpName as fam, 0 as sp, 0 as weight,
         0 as Marsh, m.Remark as Phone, '' as ATime, Data0 as Hitag, n.name as  GName, 0 as Qty
  from [MobAgents].Mess m join Def d on m.pin=d.pin
                          left join nomen n on m.Data0=n.hitag
  where m.ND=@ND and m.ag_id=@ag_id and m.MessType=4
     --   and m.tm>CONVERT([varchar],getdate()-0.042,(8))                 
     
UNION  
  
--******************Новые заявки на возврат*********************  
 /*select 200 as MessType, r.rk as Nnak, CONVERT(varchar(8), r.nd, 112) as nd, CONVERT(varchar(8), r.nd, 108) as tm, 0 as b_id,r.Content as fam,0 as sp, 0 as weight,
         0 as Marsh, '' as Phone, '' as ATime, 0 as Hitag, '' as GName, 0 as Qty
  from Requests r 
  where r.nd>=@ND and r.Tip2=142 and r.ag_id=@ag_id and r.rs=1
        and CONVERT(varchar(8), r.nd, 108)>CONVERT([varchar],getdate()-0.082,108)

select 200 as MessType, r.rk as Nnak, CONVERT(varchar(8), r.nd, 112) as nd, CONVERT(varchar(8), r.nd, 108) as tm, 0 as b_id,r.Content as fam,s.sp as sp, d.fact_weight as weight,
         0 as Marsh, '' as Phone, '' as ATime, d.hitag as Hitag, o.name as GName, d.kol as Qty
         
 from Requests r join ReqReturn n on r.rk=n.reqnum
                 join ReqreturnDet d on r.rk=d.reqretid   
                 join nomen o on d.hitag=o.hitag
                 join 
                 (select t.reqretid, sum(t.tovprice*t.kol) as sp
                  from ReqreturnDet t
                  group by t.reqretid) s on r.rk=s.reqretid
                 
    where r.nd>=@ND and r.Tip2=142 and r.ag_id=@ag_id and r.rs=1 
           and CONVERT(varchar(8), r.nd, 108)>CONVERT([varchar],getdate()-0.3,108)

*/        

select 200 as MessType, r.rk as Nnak, CONVERT(varchar(8), r.nd, 112) as nd, CONVERT(varchar(8), r.nd, 108) as tm, n.pin as b_id,e.gpName as fam,s.sp as sp, d.fact_weight as weight,
         0 as Marsh, cast(d.tovprice as varchar) as Phone, '' as ATime, d.hitag as Hitag, o.name as GName, d.kol as Qty
         
 from Requests r join ReqReturn n on r.rk=n.reqnum
                 join ReqreturnDet d on r.rk=d.reqretid   
                 join def e on n.pin=e.pin
                 join nomen o on d.hitag=o.hitag
                 join 
                 (select t.reqretid, sum(t.tovprice*t.kol) as sp
                  from ReqreturnDet t
                  group by t.reqretid) s on r.rk=s.reqretid
                 
 where r.nd>=@ND and r.Tip2=142 and r.ag_id=@ag_id  and r.rs not in (6,7) 
       --and CONVERT(varchar(8), r.nd, 108)>CONVERT([varchar],getdate()-0.3,108)
       and DATEDIFF(hh, r.nd, @NDToday)<8

UNION

--******************Заявки на возврат - согласована и передана логистам*********************  

select 203 as MessType, r.rk as Nnak, CONVERT(varchar(8), r.nd, 112) as nd, CONVERT(varchar(8), r.nd, 108) as tm, n.pin as b_id,e.gpName as fam,s.sp as sp, d.fact_weight as weight,
         0 as Marsh, cast(d.tovprice as varchar) as Phone, '' as ATime, d.hitag as Hitag, o.name as GName, d.kol as Qty
         
 from Requests r join ReqReturn n on r.rk=n.reqnum
                 join ReqreturnDet d on r.rk=d.reqretid   
                 join def e on n.pin=e.pin
                 join nomen o on d.hitag=o.hitag
                 join 
                 (select t.reqretid, sum(t.tovprice*t.kol) as sp
                  from ReqreturnDet t
                  group by t.reqretid) s on r.rk=s.reqretid
                 
 where r.nd>=@ND and r.Tip2=197 and r.ag_id=@ag_id  --and r.rs=1 
       --and CONVERT(varchar(8), r.nd, 108)>CONVERT([varchar],getdate()-0.6,108)
       and DATEDIFF(hh, r.nd, @NDToday)<16
       and n.mhid=0
 
UNION

--******************Заявки на возврат - включена в рейс*********************  
 select 205 as MessType, r.rk as Nnak, CONVERT(varchar(8), r.nd, 112) as nd, CONVERT(varchar(8), r.nd, 108) as tm, 0 as b_id,e.gpName as fam,s.sp as sp, 0 as weight,
         a.marsh as Marsh, i.Phone as Phone, '' as ATime, 0 as Hitag, '' as GName, 0 as Qty
         
 from Requests r join ReqReturn n on r.rk=n.reqnum
                 join def e on n.pin=e.pin  
                 join 
                 (select t.reqretid, sum(t.tovprice*t.kol) as sp
                  from ReqreturnDet t
                  group by t.reqretid) s on r.rk=s.reqretid
                  join [NearLogistic].MarshRequests m on m.ReqType=1 and r.rk=m.ReqID
                  join marsh a on m.mhid=a.mhid
                  left join Drivers i on a.DrID=i.DrID
    where r.nd>=@ND and r.Tip2=197 and r.ag_id=@ag_id 
          --and CONVERT(varchar(8), r.nd, 108)<CONVERT([varchar],getdate()-0.6,108)  
          and DATEDIFF(hh, r.nd, @NDToday)<16

UNION          
--******************Заявки на возврат - исполнена*********************  

 select 207 as MessType, r.rk as Nnak, CONVERT(varchar(8), r.nd, 112) as nd, CONVERT(varchar(8), r.nd, 108) as tm, 0 as b_id,e.gpName as fam,s.sp as sp, 0 as weight,
         0 as Marsh, '' as Phone, '' as ATime, 0 as Hitag, '' as GName, 0 as Qty
         
 from Requests r  join ReqReturn n on r.rk=n.reqnum
                  join def e on n.pin=e.pin
                  join
                 (select t.reqretid, sum(t.tovprice*t.kol) as sp
                  from ReqreturnDet t
                  group by t.reqretid) s on r.rk=s.reqretid
   where r.nd>=@ND and r.Tip2=194 and r.ag_id=@ag_id and r.rs=6 
         --and CONVERT(varchar(8), r.nd, 108)<CONVERT([varchar],getdate()-0.6,108)       
         and DATEDIFF(hh, r.nd, @NDToday)<16

UNION    
--******************Отклонение заявки на  возврат*********************  
 select 210 as MessType, r.rk as Nnak, CONVERT(varchar(8), r.nd, 112) as nd, CONVERT(varchar(8), r.nd, 108) as tm, 0 as b_id,r.Content as fam,0 as sp, 0 as weight,
         0 as Marsh, RemarkExec as Phone, '' as ATime, 0 as Hitag, '' as GName, 0 as Qty
  from Requests r 
  where r.nd>=@ND and r.Tip2=142 and r.ag_id=@ag_id and r.rs=7
        --and CONVERT(varchar(8), r.nd, 108)>CONVERT([varchar],getdate()-0.6,108)
        and DATEDIFF(hh, r.nd, @NDToday)<16        
        
UNION    
--******************Сообщение о продажах по категории*********************  
select 220 as MessType, g.ngrp as Nnak, @ND as nd, '' as tm, 0 as b_id,g.grpname as fam,sum(v.kol*v.price*(1+c.extra/100)) as sp, 
         sum(v.kol*iif(n.flgWeight=1,t.Weight, n.netto)) as weight, 
         0 as Marsh, g1.grpname as Phone, '' as ATime, 0 as Hitag, '' as GName, 0 as Qty
from #ncTemp c join nv v on c.datnom=v.datnom
               join nomen n on v.hitag=n.hitag
               join gr g on iif(dbo.GetGrOnlyParent(n.ngrp) is null, n.ngrp,dbo.GetGrOnlyParent(n.ngrp))=g.ngrp
               join gr g1 on n.ngrp=g1.ngrp
               join tdvi t on v.TekID=t.ID
where c.nd=@ND and c.ag_id=@ag_id and c.sp>0 and g.ngrp in (3,71,85,47,83,6,38) --пока только эти категории
      and CONVERT(time, @NDToday)>'18:00:00' and CONVERT(time, @NDToday)<'20:00:00'
group by g.ngrp,g.grpName,g1.grpname

UNION    
--******************Сообщение о продажах по поставщику*********************  
select 220 as MessType, t.ncod as Nnak, @ND as nd, '' as tm, 0 as b_id,e.fam as fam,sum(v.kol*v.price*(1+c.extra/100)) as sp, 
         sum(v.kol*iif(n.flgWeight=1,t.Weight, n.netto)) as weight, 
         0 as Marsh, '' as Phone, '' as ATime, 0 as Hitag, '' as GName, 0 as Qty
from #ncTemp c join nv v on c.datnom=v.datnom
               join nomen n on v.hitag=n.hitag
               join tdvi t on v.TekID=t.ID
               join vendors e on t.Ncod=e.Ncod
where c.nd=@ND and c.ag_id=@ag_id and c.sp>0 and t.ncod in (551) 
      and CONVERT(time, @NDToday)>'18:00:00' and CONVERT(time, @NDToday)<'20:00:00'
group by t.ncod,e.fam

UNION    
--******************Сообщение об исполенных предзаказах*********************  
select 230 as MessType, d.pin as Nnak, c.ND as nd, '' as tm, d.pin as b_id,d.gpName as fam,0 as sp, 
         c.Weight as weight, 
         0 as Marsh, '' as Phone, '' as ATime, n.hitag as Hitag, n.name as GName, c.Qty as Qty
from PreOrder c join nomen n on c.hitag=n.hitag
                join defcontract dc on c.dck=dc.dck 
                join def d on dc.pin=d.pin            
where c.nd>=@ND-20 and c.ag_id=@ag_id and c.POstatus=3

UNION                 
--*************************Добей остаток товара*****************************
  select 240 as MessType, dbo.InNnak(c.datnom) as Nnak,c.nd, c.tm,c.b_id,c.fam,c.sp,sum(a.Massa) as weight,
         0 as Marsh, '' as Phone, '' as ATime, a.hitag  as Hitag, a.name as GName, iif(a.flgWeight=0,t.morn-t.sell+t.isprav-t.remov,0) as Qty
  from #ncTemp c left join (select n.datnom,n.hitag,nm.name,n.kol*nm.netto as Massa,n.TekID, nm.flgWeight from nv n, nomen nm where n.hitag=nm.hitag) a on a.datnom=c.datnom
                 left join (select z.datnom from nvzakaz z) z on z.datnom=c.datnom
                 join tdvi t on a.TekID=t.ID
  where c.nd=@ND and (c.sp>0 or (c.sp=0 and isnull(z.datnom,0)>0))
        and c.tm>CONVERT([varchar],@NDToday-0.042,(8))
        and t.morn-t.sell+t.isprav-t.remov>0 
        and t.morn-t.sell+t.isprav-t.remov<=3
  group by dbo.InNnak(c.datnom),c.tm,c.fam,c.sp, c.b_id, c.nd,
           a.flgWeight,t.morn,t.sell,t.isprav,t.remov, a.name,a.hitag    

 
  order by MessType, nd, Marsh, tm, NNak

  drop table #NeedDCK

END