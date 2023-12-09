

CREATE PROCEDURE [MobAgents].MobSaveMessOLD @ag_id int
AS
BEGIN
  declare @ND datetime 
  declare @datnom int
  declare @FirmGroup int
  declare @Our_id int
 
  set @Our_id=isnull((select p.our_id 
                      from person p join agentlist a on p.p_id=a.p_id
                      where a.ag_id=@ag_id),7)
  
  set @ND=dbo.today()
  set @datnom=dbo.InDatNom(0,@ND)
  set @FirmGroup=(select f.FirmGroup from FirmsConfig f where f.Our_id=@Our_id)
  
  --пока для 7 группы сообщения "14" не показываем
  set  @FirmGroup=iif(@FirmGroup=7,0,@FirmGroup)
  
  create table #NeedDCK (dck int)
  
  insert into #NeedDCK (dck)
  select c.dck from defcontract c where c.ag_id=@ag_id or c.ag_id in (select b.add_ag_id from agaddbases b where b.ag_id=@ag_id and b.add_ag_id<>0)
  union
  select b.add_dck from agaddbases b where b.ag_id=@ag_id and b.add_dck<>0

  select c.* into #ncTemp from nc c where c.nd>=@ND-1 and c.dck in (select dck from #NeedDCK)
  


  --Накладные за последний час
  select 0 as MessType, dbo.InNnak(c.datnom) as Nnak,c.nd, c.tm,c.b_id,c.fam,c.sp,sum(a.Massa) as weight,
         0 as Marsh, '' as Phone, '' as ATime, 0 as Hitag, '' as GName, 0 as Qty
  from #ncTemp c left join (select n.datnom,n.kol*nm.netto as Massa from nv n, nomen nm where n.hitag=nm.hitag) a on a.datnom=c.datnom
  where --c.dck in (select dck from #NeedDCK) and
        c.nd=@ND and c.sp>0
        and c.tm>CONVERT([varchar],getdate()-0.042,(8))
  group by dbo.InNnak(c.datnom),c.tm,c.fam,c.sp, c.b_id, c.nd
  
UNION 
  --Доставка накладных
  select 1 as MessType, dbo.InNnak(c.datnom) as Nnak,c.nd, c.tm,c.b_id,c.fam,c.sp,c.weight,
         m.Marsh, r.Phone, m.awaytime as ATime, 0 as Hitag, '' as GName, 0 as Qty
  from marsh m join #ncTemp c on m.nd=c.nd and m.marsh=c.marsh
               left join Drivers r on m.DrID=r.DrID 
  where m.awaytime>=@ND-0.2083 and m.DelivCancel=0 
        --and c.dck in (select dck from #NeedDCK) 
  
UNION
  --Накладные, переведенные на завтра #Доставка по ремарке
  select 2 as MessType, dbo.InNnak(c.datnom) as Nnak,c.nd, c.tm,c.b_id,c.fam,c.sp, c.weight,
         0 as Marsh, '' as Phone, '' as ATime, 0 as Hitag, '' as GName, 0 as Qty
  from #ncTemp c
  where c.nd=@ND and c.tomorrow=1 
        --and c.dck in (select dck from #NeedDCK)
  
UNION  
  --Отмененные накладные Уточните по дате доставки
  select 3 as MessType,  dbo.InNnak(c.datnom) as Nnak,c.nd, c.tm, c.b_id, c.fam,c.sp,c.weight,
         0 as marsh, '' as Phone, '' as ATime, 0 as Hitag, '' as GName, 0 as Qty
  from #ncTemp c
  where c.delivcancel=1
  and c.datnom>@datnom
      --and c.dck in (select dck from #NeedDCK)

UNION  
   -- Частично отменена доставка по накладным: Уточните по дате доставки 
  select 4 as MessType, dbo.InNnak(c.datnom) as Nnak,c.nd, c.tm,c.b_id,c.fam,c.sp, c.weight,
         0 as Marsh, '' as Phone, '' as ATime, v.hitag as Hitag, n.name as GName, v.kol as Qty
  from #ncTemp c join nv v on c.datnom=v.datnom
                 join nomen n on v.hitag=n.hitag  
  where c.datnom>@datnom and v.DelivCancel=1
        --and c.dck in (select dck from #NeedDCK)
UNION    
--**********************Неуд. спрос*************************
  select 5 as MessType, 0 as Nnak,s.nd, s.tm,s.b_id,d.gpName as fam, s.Qty*s.Price as sp, s.Ves as weight,
         0 as Marsh, '' as Phone, '' as ATime, s.hitag as Hitag, n.name as GName, s.Qty as Qty
  from NotSat s join nomen n on s.hitag=n.hitag   
                join Def d on s.b_id=d.pin
  where s.ND=@ND and s.ag_id=@ag_id
        and s.dck in (select dck from #NeedDCK)
UNION    
--******************Клиент в блоке - отказ*********************  
  select 6 as MessType, 0 as Nnak,m.nd, m.tm,m.pin as b_id,d.gpName as fam, 0 as sp, 0 as weight,
         0 as Marsh, '' as Phone, '' as ATime, 0 as Hitag, '' as  GName, 0 as Qty
  from [MobAgents].Mess m join Def d on m.pin=d.pin
  where m.ND=@ND and m.ag_id=@ag_id and m.MessType=0
        and m.tm>CONVERT([varchar],getdate()-0.042,(8))
UNION    
--*****************Сегоднящние выплаты*********************  
  select 7 as MessType, 0 as Nnak,k.nd, k.tm,k.pin as b_id, k.Remark as fam, k.plata as sp, 0 as weight,
         0 as Marsh, '' as Phone, '' as ATime, 0 as Hitag, '' as  GName, 0 as Qty
  from Kassa1 k 
  where k.ND=@ND and k.OP=1000+@ag_id and k.oper=59
        --and k.tm>CONVERT([varchar],getdate()-0.042,(8))
        
UNION 
--*****************Отмена рейсов********************* Перенос на завтра 
  select 8 as MessType, dbo.InNnak(c.datnom) as Nnak,c.nd, c.tm,c.b_id,c.fam,c.sp,c.weight,
         m.Marsh, r.Phone, m.awaytime as ATime, 0 as Hitag, '' as GName, 0 as Qty
  from marsh m join #ncTemp c on m.nd=c.nd and m.marsh=c.marsh
               left join Drivers r on m.DrID=r.DrID 
  where m.ND>=@ND-1 and m.DelivCancel=1 
        --and c.dck in (select dck from #NeedDCK) and       
  
UNION    
--******************Запрет продажи товара*********************  
  select 9 as MessType, 0 as Nnak,m.nd, m.tm,m.pin as b_id,d.gpName as fam, 0 as sp, 0 as weight,
         0 as Marsh, '' as Phone, '' as ATime, 0 as Hitag, m.Remark as  GName, 0 as Qty
  from [MobAgents].Mess m join Def d on m.pin=d.pin
  where m.ND=@ND and m.ag_id=@ag_id and m.MessType=1
     --   and m.tm>CONVERT([varchar],getdate()-0.042,(8))  
     
UNION
  --*****************Накладные не попавшие в развоз************ Накладные поедут завтра
  select 10 as MessType, dbo.InNnak(c.datnom) as Nnak,c.nd, c.tm,c.b_id,c.fam,c.sp,sum(a.Massa) as weight,
         0 as Marsh, '' as Phone, '' as ATime, 0 as Hitag, '' as GName, 0 as Qty
  from #ncTemp c join (select n.datnom,n.kol*nm.netto as Massa from nv n, nomen nm where n.hitag=nm.hitag and n.kol-n.kol_b>0) a on a.datnom=c.datnom
  where c.nd=@ND-1 and c.sp>0 and c.marsh=0 
        --and c.dck in (select dck from #NeedDCK)
  group by dbo.InNnak(c.datnom),c.tm,c.fam,c.sp, c.b_id, c.nd     
  
UNION
  --*****************Не набрано на складе************
  select 11 as MessType, dbo.InNnak(c.datnom) as Nnak,c.nd, c.tm,c.b_id,c.fam,c.sp,0 as weight,
         0 as Marsh, v.Remark as Phone, v.tmEnd as ATime, v.hitag as Hitag, n.name as GName, v.zakaz as Qty
  from #ncTemp c join nvzakaz v on c.datnom=v.datnom
            join nomen n on v.hitag=n.hitag
  where  v.nd=@ND and v.id=0 and v.done=1  
        -- and c.dck in (select dck from #NeedDCK)
        
UNION    
--******************Отказ в наборе документов*********************  
  select 12 as MessType, dbo.InNnak(cast(m.data0 as int)) as Nnak,m.nd, m.tm,m.pin as b_id,d.gpName as fam, 0 as sp, 0 as weight,
         0 as Marsh, '' as Phone, '' as ATime, 0 as Hitag, m.Remark as GName, 0 as Qty
  from [MobAgents].Mess m join Def d on m.pin=d.pin
  where m.ND=@ND and m.ag_id=@ag_id and m.MessType=2

UNION    
--******************Отказ в обработке накладных********************* Позиция отсутствует - замените 
  select 13 as MessType, dbo.InNnak(c.datnom) as Nnak,c.nd, c.tm,c.b_id,c.fam,c.sp, c.weight,
         0 as Marsh, '' as Phone, '' as ATime, 0 as Hitag, '' as GName, 0 as Qty
  from #ncTemp c
  where c.nd=@ND and c.done=0 and c.sp>0 and c.sp<1500
        --and c.dck in (select dck from #NeedDCK)
        
UNION    
--******************Новые поставки*********************  
  select 14 as MessType, 0 as Nnak, c.[date] as nd, c.[Time] as tm, 0 as b_id, d.brName as fam, 0 as sp, 0 as weight,
         0 as Marsh, '' as Phone, '' as ATime, i.hitag as Hitag, n.name as  GName, 0 as Qty
  from Comman c join Inpdet i on c.ncom=i.ncom
                join nomen n on i.hitag=n.hitag
                join Def d on c.pin=d.pin
                join FirmsConfig f on c.Our_id=f.Our_id
  where c.[Date]=@ND and f.FirmGroup=@FirmGroup
        and c.[Time]>CONVERT([varchar],getdate()-0.2,(8))        
        
UNION    
--*******  сообщения о перебросе точек на 33 код Тыщика с просрочкой больше 31 дня  
  select 15 as MessType, 0 as Nnak, m.nd as nd, '' as tm, d.pin as b_id, d.gpName as fam, 0 as sp, 0 as weight,
         0 as Marsh, '' as Phone, '' as ATime, 0 as Hitag, '' as  GName, 0 as Qty
         
  from MoveDotsLog m left join DefContract c on m.dck=c.dck
                     left join Def d on c.pin=d.pin   
  where m.ND=@ND and (m.ag_id=@ag_id or m.sv_ag_id=@ag_id) and m.TakeOff = 1

UNION    
--*******  сообщения о возврате точек с 33 кода Тыщика, если просрочка меньше 31 дня  
  select 16 as MessType, 0 as Nnak, m.nd as nd, '' as tm, d.pin as b_id, d.gpName as fam, 0 as sp, 0 as weight,
         0 as Marsh, '' as Phone, '' as ATime, 0 as Hitag, '' as  GName, 0 as Qty
  from MoveDotsLog m left join DefContract c on m.dck=c.dck
                     left join Def d on c.pin=d.pin   
                     
  where m.ND=@ND and (m.ag_id=@ag_id or m.sv_ag_id=@ag_id) and m.TakeOff = 0
  
 
  order by MessType, nd,tm,NNak

  drop table #NeedDCK

END