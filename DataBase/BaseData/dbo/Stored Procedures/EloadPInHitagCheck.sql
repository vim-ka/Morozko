CREATE PROCEDURE dbo.EloadPInHitagCheck
@pin_ sql_variant,
@hitag_ sql_variant
AS
BEGIN
  declare @pin int
  declare @hitag int
  set @pin=try_convert(int,@pin_)
  set @hitag=try_convert(int,@hitag_)

  if object_id('tempdb..#def_') is not null drop table #def_
  if object_id('tempdb..#nomen_') is not null drop table #nomen_

  create table #def_ (pin int)
  create nonclustered index idx_def_pin on #def_(pin)

  create table #nomen_ (hitag int)
  create nonclustered index idx_nomen_hitag on #nomen_(hitag)

  if isnull(@pin,0)<>0
    insert into #def_
    values(@pin)
  else
    insert into #def_
    select pin 
    from morozdata.dbo.def
    where cast(pin as varchar)+' '+brName+' '+gpName like '%'+cast(@pin_ as varchar)+'%'

  if isnull(@hitag,0)<>0
    insert into #nomen_
    values(@hitag)
  else
    insert into #nomen_
    select hitag 
    from morozdata.dbo.nomen 
    where cast(hitag as varchar)+' '+Name like '%'+cast(@hitag_ as varchar)+'%'

  select datediff(day,c.nd,getdate()) [Дней],
         convert(varchar,c.nd,104) [Дата],
         c.datnom % 10000 [№Накладной],
         c.ag_id [КодАгента],
         p.fio+', '+isnull(p.phone,'<..>') [Агент],
         sp.fio+', '+isnull(sp.phone,'<..>') [Супервизор],
         c.b_id [КодТочки],
         d.brname [НаименованиеТочки],
         c.dck [КодДоговора],
         dc.contrname [НаименованиеДоговора],
         cast(v.kol as int) [Кол-во],
         iif(n.flgweight=1,isnull(t.weight,s.weight),n.netto) [Вес],
         cast(v.kol_b as int) [Вернули],
         v.hitag [КодТовара],
         n.name [Наименованиетовара]
  from morozdata.dbo.nc c
  left join morozdata.dbo.nv v on v.datnom=c.datnom
  left join morozdata.dbo.nomen n on n.hitag=v.hitag
  left join morozdata.dbo.tdvi t on t.id=v.tekid
  left join morozdata.dbo.visual s on s.id=v.tekid
  left join morozdata.dbo.defcontract dc on dc.dck=c.dck
  left join morozdata.dbo.def d on d.pin=c.b_id
  left join morozdata.dbo.agentlist a on a.ag_id=c.ag_id
  left join morozdata.dbo.person p on a.p_id=p.p_id
  left join morozdata.dbo.agentlist sa on sa.ag_id=a.sv_ag_id
  left join morozdata.dbo.person sp on sp.p_id=sa.p_id
  where c.B_ID in (select pin from #def_) 
        and v.hitag in (select hitag from #nomen_)
        and c.sp>0
        and datediff(day,c.nd,getdate())<=366
  order by c.nd desc

  if object_id('tempdb..#def_') is not null drop table #def_
  if object_id('tempdb..#nomen_') is not null drop table #nomen_
END