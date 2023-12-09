CREATE procedure dbo.CalcAddSellBrief @day0 datetime, @day1 datetime
-- Сводка по добиваниям накладных
AS
declare @DT datetime, @FirstDay datetime, @LastDay datetime
begin
  set @DT=dbo.today();
  if @day0<@DT set @FirstDay=@day0 else set @FirstDay=null;
  if @day1<@DT set @LastDay=@day1 else set @LastDay=dateadd(day,-1,@dt);

  -- Отчет требуется разбить по отделам.
  -- И для каждого отдела вывести оператора, покупателя, товары (название,цена,колич.)
  -- Хронология не нужна, т.е. надо свернуть данные.
  select e.depid, deps.DName, e.b_id, e.gpname, e.op, e.hitag, e.name,
    sum(e.kol) Kol, sum(e.SP) SP, sum(e.SWeight) SWeight
  from (
    select 
      a.depid, nc.b_id, def.gpname, C.OP, V.Hitag, nm.name,
      sum(v.newkol) as Kol, sum(v.newkol*v.NewPrice) as SP,
      sum(v.newkol*iif(vi.weight=0, nm.netto, vi.weight)) as SWeight
    from
      ncedit C 
      inner join nvedit V on v.ncid=C.ncid
      inner join tdvi vi on vi.id=V.ID
      inner join NC on NC.nd=C.nd and NC.datnom=C.DatNom
      inner join Def on Def.pin=nc.b_id
      inner join Defcontract DC on dc.dck=nc.DCK
      inner join agentlist A on a.ag_id=nc.ag_id
      inner join Deps on Deps.depid=a.depid
      inner join nomen nm on nm.hitag=V.Hitag
    where 
      C.nd=@DT and @DT between @day0 and @day1
      and v.kol=0 and v.newkol>0
    group by a.depid, nc.b_id, def.gpname, C.OP, V.Hitag, nm.name
  
  
    UNION ALL
  
    select 
      a.depid, nc.b_id, def.gpname, C.OP, V.Hitag, nm.name,
      sum(v.newkol) as Kol, sum(v.newkol*v.NewPrice) as SP,
      sum(v.newkol*iif(vi.weight=0, nm.netto, vi.weight)) as SWeight
    from
      ncedit C 
      inner join nvedit V on v.ncid=C.ncid
      inner join Visual vi on vi.id=V.ID
      inner join NC on NC.nd=C.nd and NC.datnom=C.DatNom
      inner join Def on Def.pin=nc.b_id
      inner join Defcontract DC on dc.dck=nc.DCK
      inner join agentlist A on a.ag_id=nc.ag_id
      inner join Deps on Deps.depid=a.depid
      inner join nomen nm on nm.hitag=V.Hitag
    where 
      @FirstDay is not null
      and C.nd between @FirstDay and @LastDay
      and v.kol=0 and v.newkol>0
    group by a.depid, nc.b_id, def.gpname, C.OP, V.Hitag, nm.name
  ) E 
  inner join Deps on Deps.depid=e.depid  
  group by e.depid, deps.DName, e.b_id, e.gpname, e.op, e.hitag, e.name
  order by e.depid, e.b_id, e.hitag, e.name, e.op
END