CREATE procedure CalcFrizerStat @Comp varchar(20), @Day0 Datetime, @Day1 datetime
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
end