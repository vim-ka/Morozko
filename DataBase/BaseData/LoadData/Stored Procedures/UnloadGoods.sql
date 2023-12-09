CREATE PROCEDURE [LoadData].UnloadGoods @nd1 datetime, @nd2 datetime, @Our_ID int=7
AS
BEGIN
  
   set nocount on
   
   declare @FirmGroup int
   set @FirmGroup=(select FirmGroup from FirmsConfig where Our_ID=@Our_ID)

   create table #Goods (
       hitag int,
       StartRest money default 0,
       Inpt money default 0,
       Back_sell money default 0,
       Ispr money default 0, 
       Compl money default 0,
       Trans money default 0,
       IzmC money default 0,
       ---
       Sell money default 0,
       Back_vend money default 0,
       Ispr_ money default 0,
       Compl_ money default 0,
       Trans_ money default 0,
       IzmC_ money default 0,
       EndRest money default 0
   )
   
   select i.* into #izment 
   from izmen i where i.nd>=@nd1 and i.nd<=@nd2
   
   insert into #Goods(hitag, StartRest) 
   select t.hitag, sum(t.cost*t.MornRest)
   from MorozArc.dbo.ArcVI t join MorozData.dbo.FirmsConfig f on t.Our_ID=f.Our_id
                             join MorozData.dbo.DefContract d on t.dck=d.dck  
   where t.workdate=@nd1 and f.FirmGroup=@FirmGroup 
         and d.Contrtip=1       
   group by t.Hitag    
      
   insert into #Goods(hitag, Sell, Back_Sell) 
   select v.hitag, sum(iif(v.kol>0, (v.cost*v.kol),0)),sum(iif(v.kol<0, (v.cost*v.kol),0))
   from nc c join nv v on c.datnom=v.datnom   
             join MorozData.dbo.FirmsConfig f on c.OurID=f.Our_id     
   where c.ND>=@nd1 and c.ND<=@nd2 
         and c.stip<>4 and f.FirmGroup=@FirmGroup 
   group by v.hitag       
   
   insert into #Goods(hitag, Inpt) 
   select v.hitag, sum(v.cost*v.kol)
   from comman c join inpdet v on c.ncom=v.ncom
                 join DefContract d on c.dck=d.dck
                 join MorozData.dbo.FirmsConfig f on c.Our_ID=f.Our_id
   where c.[Date]>=@nd1 and c.[Date]<=@nd2 
         and d.Contrtip=1 and f.FirmGroup=@FirmGroup
   group by v.hitag       
   
   
   insert into #Goods(hitag, IzmC, IzmC_) 
   select m.hitag, sum(iif((m.newkol*m.newcost-m.kol*m.cost)>0, (m.newkol*m.newcost - m.kol*m.cost),0)), sum(iif((m.newkol*m.newcost-m.kol*m.cost)<0, (m.newkol*m.newcost-m.kol*m.cost),0))
    from #izment m join DefContract d on m.dck=d.dck
                   join MorozData.dbo.FirmsConfig f on d.Our_ID=f.Our_id   
    where m.ND>=@nd1 and m.ND<=@nd2 and m.Act='ИзмЦ'       
          and d.ContrTip=1 and f.FirmGroup=@FirmGroup
    group by m.hitag      
   
   insert into #Goods(hitag, Ispr, Ispr_) 
   select m.hitag, sum(iif((m.newkol*m.newcost-m.kol*m.cost)>0, (m.newkol*m.newcost - m.kol*m.cost),0)), sum(iif((m.newkol*m.newcost-m.kol*m.cost)<0, (m.newkol*m.newcost-m.kol*m.cost),0))
    from #izment m join DefContract d on m.dck=d.dck
                   join MorozData.dbo.FirmsConfig f on d.Our_ID=f.Our_id   
    where m.ND>=@nd1 and m.ND<=@nd2 and m.Act in ('Испр', 'ИспВ')
          and f.FirmGroup=@FirmGroup  
          and d.ContrTip=1
   group by m.hitag       
          
   insert into #Goods(hitag, Back_Vend) 
   select m.hitag, sum(m.newkol*m.newcost-m.kol*m.cost)
   from #izment m join DefContract d on m.dck=d.dck
                  join MorozData.dbo.FirmsConfig f on d.Our_ID=f.Our_id     
   where m.ND>=@nd1 and m.ND<=@nd2 and m.Act='Снят' 
         and f.FirmGroup=@FirmGroup      
         and d.ContrTip=1
   group by m.hitag      
   
   insert into #Goods(hitag, Compl_) 
   select m.hitag, -sum(m.kol*m.cost)
   from #izment m join DefContract d on m.dck=d.dck
                  join MorozData.dbo.FirmsConfig f on d.Our_ID=f.Our_id      
   where m.ND>=@nd1 and m.ND<=@nd2 and m.Act='div-'       
         and d.ContrTip=1
         and f.FirmGroup=@FirmGroup
   group by m.hitag   
   
   insert into #Goods(hitag, Compl) 
   select m.newhitag, sum(m.newkol*m.newcost)
   from #izment m join DefContract d on m.dck=d.dck
                  join MorozData.dbo.FirmsConfig f on d.Our_ID=f.Our_id    
   where m.ND>=@nd1 and m.ND<=@nd2 and m.Act='div+'       
         and d.ContrTip=1
         and f.FirmGroup=@FirmGroup
   group by m.newhitag   
   
   insert into #Goods(hitag, Trans) 
   select m.newhitag, sum(m.newkol*m.newcost)
   from #izment m join DefContract d on m.dck=d.dck
                  join MorozData.dbo.FirmsConfig f on d.Our_ID=f.Our_id    
   where m.ND>=@nd1 and m.ND<=@nd2 and m.Act='Tran'       
         and d.ContrTip=1
         and f.FirmGroup=@FirmGroup
   group by m.newhitag 
   
   insert into #Goods(hitag, Trans_) 
   select m.hitag, -sum(m.kol*m.cost)
   from #izment m join DefContract d on m.dck=d.dck
                  join MorozData.dbo.FirmsConfig f on d.Our_ID=f.Our_id   
   where m.ND>=@nd1 and m.ND<=@nd2 and m.Act='Tran'       
         and d.ContrTip=1
         and f.FirmGroup=@FirmGroup
   group by m.hitag 
   
   
   select #Goods.hitag,
       nomen.nds,
       sum(StartRest) as StartRest,
       sum(Inpt) as Inpt,
       -sum(Back_sell) as Back_sell,
       sum(Ispr) as Ispr, 
       sum(Compl) as Compl,
       sum(Trans) as Trans,
       sum(IzmC) as IzmC,
       ---
       sum(Sell) as Sell,
       -sum(Back_vend) as Back_vend,
       -sum(Ispr_) as Ispr_,
       -sum(Compl_) as Compl_,
       -sum(Trans_) as Trans_,
       -sum(IzmC_) as IzmC_,
       
       sum(StartRest)+
       sum(Inpt)+
       (-sum(Back_sell))+
       sum(Ispr)+
       sum(Compl)+
       sum(Trans)+
       sum(IzmC)+
       ---
       (-sum(Sell))+
       sum(Back_vend)+
       sum(Ispr_)+
       sum(Compl_)+
       sum(Trans_)+
       sum(IzmC_) as EndRest
       
   from #Goods join nomen on #Goods.hitag=nomen.hitag
   where nomen.hitag<>25518 --вирт. копеку не грузим
   group by #Goods.hitag, Nomen.nds
   order by #Goods.hitag

  --drop table #Goods
  --drop table #izment
   set nocount off
END