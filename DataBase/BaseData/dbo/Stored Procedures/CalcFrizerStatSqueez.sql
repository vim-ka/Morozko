CREATE procedure CalcFrizerStatSqueez @Comp varchar(20), @Day0 Datetime, @Day1 datetime,
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
  

  -- Выдерну все холодильники, игнорируя агентов, супервайзеров и отделы:
  create table #o( gpName varchar (100), gpAddr varchar(200),
    Pin int, BrName varchar(100),
    Nom int not null primary key, Dck int,
    Invnom varchar(20), Fabnom varchar(15), Nname varchar(60), DateSell datetime);
  -- Начну с сетевых покупателей:
  if (@FrizerDay0 is null) or (@FrizerDay0=0)
    insert into #o  
    select 
      M.gpName, m.gpAddr,
      def.[Master] as Pin, M.brName, 
      f.nom,f.dck, f.InvNom, f.FabNom, f.Nname, f.DateSell
    from 
      frizer  f 
      inner join DefContract DC on DC.DCK=f.dck
      inner join Def on Def.pin=DC.pin and def.[Master]>0
      inner join Def M on M.pin=Def.[Master]
      inner join CFS_Params Z on Z.Ncod=F.Ncod and Z.Comp=@Comp and Z.IsFrizVendor=1
    where 
      f.dck>0 and f.tip=0;
  else
    insert into #o  
    select 
      M.gpName, m.gpAddr,
      def.[Master] as Pin, M.brName, 
      f.nom,f.dck, f.InvNom, f.FabNom, f.Nname, f.DateSell
    from 
      frizer  f 
      inner join DefContract DC on DC.DCK=f.dck
      inner join Def on Def.pin=DC.pin and def.[Master]>0
      inner join Def M on M.pin=Def.[Master]
      inner join CFS_Params Z on Z.Ncod=F.Ncod and Z.Comp=@Comp and Z.IsFrizVendor=1
    where 
      f.dck>0 and f.tip=0
      and f.datesell between @FrizerDay0 and @FrizerDay1;

  -- Теперь одиночные покупатели:
  if (@FrizerDay0 is null) or (@FrizerDay0=0)
    insert into #o  
    select 
      def.gpName, def.gpAddr,
      def.Pin, def.brName, 
      f.nom,f.dck, f.InvNom, f.FabNom, f.Nname, f.DateSell
    from 
      frizer  f 
      inner join DefContract DC on DC.DCK=f.dck
      inner join Def on Def.pin=DC.pin and isnull(def.[Master],0)=0
      inner join CFS_Params Z on Z.Ncod=F.Ncod and Z.Comp=@Comp and Z.IsFrizVendor=1
    where 
      f.dck>0 and f.tip=0;
  else
    insert into #o  
    select 
      def.gpName, def.gpAddr,
      def.Pin, def.brName, 
      f.nom,f.dck, f.InvNom, f.FabNom, f.Nname, f.DateSell
    from 
      frizer  f 
      inner join DefContract DC on DC.DCK=f.dck
      inner join Def on Def.pin=DC.pin and isnull(def.[Master],0)=0
      inner join CFS_Params Z on Z.Ncod=F.Ncod and Z.Comp=@Comp and Z.IsFrizVendor=1
    where 
      f.dck>0 and f.tip=0
      and f.datesell between @FrizerDay0 and @FrizerDay1;

  -- OK, готов список холодильников с указанием точек.

  -- Теперь надо вычислить все продажи по точкам для поставщиков из списка:
  create table #s(Pin INT, SP decimal(12,2), SC decimal(12,2), ScWoNds decimal(12,2));
  
  insert into #s  
  select 
    case when isnull(def.[master],0)=0 then def.pin else def.[master] end as Pin,
    isnull(sum(nv.price*nv.kol*(1.0+nc.extra/100)),0) as SP,
    isnull(sum(nv.cost*nv.kol),0) as SC,
    isnull(sum(nv.cost*nv.kol*100.0/(100.0+nm.nds)),0) as ScWoNds
  from
    nv inner join nc on nc.datnom=nv.datnom
    inner join DefContract DC on DC.DCK=nc.DCK and dc.contrtip=2
    inner join Def on Def.pin=dc.Pin and Def.tip=1
    inner join Visual Vi on Vi.id=nv.TekID
    inner join CFS_Params Z on Z.Ncod=Vi.Ncod and Z.Comp=@Comp and Z.IsFrizVendor=0    
    inner join Nomen nm on nm.hitag=nv.hitag
  where 
    nv.DatNom between @n0 and @n1
    and  nc.tara=0 and nc.frizer=0
  group by case when isnull(def.[master],0)=0 then def.pin else def.[master] end;
  
  create index s_pin_idx on #s(pin);
  
  select distinct
    #o.*, #s.sp, #s.sc, #s.scwonds
  from 
    #o left join #s on #s.pin=#o.pin
  order by #o.pin, #o.nname

end