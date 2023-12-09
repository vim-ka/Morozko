CREATE procedure CalcFrizerStatFull @Comp varchar(20), @Day0 Datetime, @Day1 datetime,
  @FrizerDay0 datetime=NULL,  @FrizerDay1 datetime=NULL
as
declare @n0 int
declare @n1 int
begin
  set @n0=dbo.InDatNom(1, @day0)
  set @n1=dbo.InDatNom(9999, @day1)
  -- Часть параметров передается через CFS_Params.
  -- Там Comp - имя компьютера, с которого отправляетсяч запрос,
  -- IsFrizVendor=1 - для списка поставщиков холодильников,
  -- IsFrizVendor=0 - для списка поставщиков товаров,
  -- Ncod - код поставщика холодильников или пищи соответственно.
  
  -- Начну теперь с другого бока. Сначала выдерну все холодильники вместе с
  -- агентами, супервайзерами и отделами:
  create table #o(DepID INT, DName varchar(70), 
    gpName varchar (100),
    gpAddr varchar(200),  
    SvID int, SuperFam varchar(100),
    Ag_id int, AgentFam varchar(100), Pin int, BrName varchar(100),
    Nom int not null primary key, Dck int,
    Invnom varchar(20), Fabnom varchar(15), Nname varchar(60), DateSell datetime);
    

  if (@FrizerDay0 is null) or (@FrizerDay0=0)
    insert into #o  
    select 
      A.DepID, D.DName, Def.gpName, Def.gpAddr, 
      A.sv_ag_id as SvId, PS.Fio as SuperFam,
      DC.ag_id, PA.Fio as AgentFam,  
      DC.pin, Def.brName,
      f.nom,f.dck, f.InvNom, f.FabNom, f.Nname, f.DateSell
    from 
      frizer  f 
      inner join DefContract DC on DC.DCK=f.dck
      inner join Def on Def.pin=DC.pin
      inner join Agentlist A on A.AG_ID=DC.ag_id 
      inner join Person PA on PA.P_ID=A.P_ID
      inner join Agentlist SV on SV.AG_ID=A.sv_ag_id
      inner join Person PS on PS.P_ID=SV.P_ID
      inner join Deps D on D.DepID=A.DepID
      inner join CFS_Params Z on Z.Ncod=F.Ncod and Z.Comp=@Comp and Z.IsFrizVendor=1
    where 
      f.dck>0 and f.tip=0
    order by A.DepID, A.sv_ag_id, Def.pin;
  else
    insert into #o  
    select 
      A.DepID, D.DName, Def.gpName, Def.gpAddr, 
      A.sv_ag_id as SvId, PS.Fio as SuperFam,
      DC.ag_id, PA.Fio as AgentFam,  
      DC.pin, Def.brName,
      f.nom,f.dck, f.InvNom, f.FabNom, f.Nname, f.DateSell
    from 
      frizer  f 
      inner join DefContract DC on DC.DCK=f.dck
      inner join Def on Def.pin=DC.pin
      inner join Agentlist A on A.AG_ID=DC.ag_id 
      inner join Person PA on PA.P_ID=A.P_ID
      inner join Agentlist SV on SV.AG_ID=A.sv_ag_id
      inner join Person PS on PS.P_ID=SV.P_ID
      inner join Deps D on D.DepID=A.DepID
      inner join CFS_Params Z on Z.Ncod=F.Ncod and Z.Comp=@Comp and Z.IsFrizVendor=1
    where 
      f.dck>0 and f.tip=0
      and f.datesell between @FrizerDay0 and @FrizerDay1;




    -- select * from #o order by depId, svid, ag_id, pin -- проверка
  -- OK, готов список холодильников с указанием точек.
  
  

  -- Теперь надо вычислить все продажи по точкам для поставщиков из списка:
  create table #s(Dck INT, SP decimal(12,2), SC decimal(12,2), ScWoNds decimal(12,2));
  
  insert into #s  
  select 
    nc.dck, 
    isnull(sum(nv.price*nv.kol*(1.0+nc.extra/100)),0) as SP,
    isnull(sum(nv.cost*nv.kol),0) as SC,
    isnull(sum(nv.cost*nv.kol*100.0/(100.0+nm.nds)),0) as ScWoNds
  from
    nv inner join nc on nc.datnom=nv.datnom
    inner join Visual Vi on Vi.id=nv.TekID
    inner join CFS_Params Z on Z.Ncod=Vi.Ncod and Z.Comp=@Comp and Z.IsFrizVendor=0    
    inner join Nomen nm on nm.hitag=nv.hitag
  where 
    nv.DatNom between @n0 and @n1
    and  nc.tara=0 and nc.frizer=0
  group by nc.dck;
  create index s_dck_idx on #s(dck);
  -- select * from #s inner join Defcontract DC on DC.dck=#s.dck and DC.pin=25033
  
  
/*  select #o.*, #s.sp, #s.sc, #s.scwonds
  from #o left join #s on #s.dck=#o.dck
  order by #o.DepID, #o.svId, #o.ag_id, #o.pin*/
  
  select  distinct
    #o.*, #s.sp, #s.sc, #s.scwonds
  from 
    #o left join defcontract dc on dc.pin=#o.pin and dc.ContrTip=2
    left join #s on #s.dck=dc.dck
  order by #o.DepID, #o.svId, #o.ag_id, #o.pin, #s.sp desc
  
  
  
  /*
    create table #f(Dck INT, Cnt int);
  
  insert into #f select f.dck, count(dck) as Cnt
    from 
      Frizer f inner join CFS_Params Z on Z.Ncod=F.Ncod
      and Z.Comp=@Comp and Z.IsFrizVendor=1
    where f.dck>0 and F.Tip=0 
    group by Dck;

  create index ftempidx on #f(dck);
  
  -- Считаю продажи по этим договорам, с учетом еще списка постащиков товаров:
  select 
    dc.pin, DC.ag_id, 
    D.BrName, D.gpAddr, D.dstAddr,
    P.Fio as AgentFio,
    #f.cnt, 
    isnull(sum(nv.price*nv.kol*(1.0+nc.extra/100)),0) as SP,
    isnull(sum(nv.cost*nv.kol),0) as SC,
    isnull(sum(nv.cost*nv.kol*100.0/(100.0+nm.nds)),0) as ScWoNds
  from
    nv inner join nc on nc.datnom=nv.datnom
    inner join #f on #f.dck=nc.dck
    inner join Visual Vi on Vi.id=nv.TekID
    inner join CFS_Params Z on Z.Ncod=Vi.Ncod and Z.Comp=@Comp and Z.IsFrizVendor=0    
    inner join defcontract DC on DC.DCK=#f.dck and dc.ContrTip=2
    inner join Def D on D.Pin=DC.pin
    inner join Agentlist A on A.ag_id=dc.ag_id
    inner join Person P on P.P_ID=A.P_ID
    inner join Nomen NM on NM.Hitag=nv.Hitag
  where 
    nv.DatNom between @n0 and @n1
    and  nc.tara=0 and nc.actn=0 and nc.frizer=0
  group by dc.pin, DC.ag_id, D.BrName,P.Fio, #f.cnt,D.gpAddr, D.dstAddr
  order by dc.pin
  */
end