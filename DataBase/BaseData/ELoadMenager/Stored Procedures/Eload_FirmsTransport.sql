CREATE PROCEDURE ELoadMenager.Eload_FirmsTransport
@day0 datetime,
@day1 datetime,
@firmsgroup int
AS
BEGIN
  declare @dn0 int
  declare @dn1 int
  set @dn0 = dbo.InDatNom(0000, @day0)
  set @dn1 = dbo.InDatNom(9999, @day1)
  
	create table #nkls(datnom int, massa numeric(10, 3), b_id int)
  insert into #nkls
	select c.datnom, 
  case when dbo.DatNomInDate(c.datnom) = dbo.today() then isnull(sum(v.kol*(iif(vi.weight>0,vi.weight, isnull(n.brutto,0)))),0)
  else isnull(sum(v.kol*(iif(vis.weight>0,vis.weight, isnull(n.brutto,0)))),0) end massa, c.b_id
  from dbo.nc c
  inner join dbo.nv v on v.datnom = c.datnom
  inner join dbo.FirmsConfig fc on fc.Our_id=c.OurID
  inner join nomen n on v.hitag = n.hitag
  left join tdvi vi on v.tekid = vi.id 
  left join visual vis on v.tekid = vis.id

  where
  c.datnom >= @dn0 and c.datnom <= @dn1
  and fc.FirmGroup=iif(@firmsgroup=-1,fc.FirmGroup,@firmsgroup)
  group by c.datnom, c.b_id
  
  select
--  nc.datnom,
  m.nd "Дата", m.Marsh "Маршрут",
  round(NearLogistic.Marsh1CalcFact(m.mhid), 2) "Оплата",
  round(isnull(m.Weight, 0) + isnull(m.dopWeight, 0), 2) "Общий вес, кг",
  round(sum(#nkls.massa), 2) "Вес Рест, кг", count(#nkls.b_id) "Кол-во точек Рест",
--  nc.b_id,
  round(NearLogistic.Marsh1CalcFact(m.mhid) / (isnull(m.Weight, 0) + isnull(m.dopWeight, 0)), 2) "Коэфф., руб/кг",
  m.direction "Направление", round(sum(#nkls.massa) * (NearLogistic.Marsh1CalcFact(m.mhid) / (isnull(m.Weight, 0) + isnull(m.dopWeight, 0))), 2) "Сумма, руб."
  from 
  dbo.marsh m
  inner join dbo.nc nc on nc.nd = m.nd and nc.marsh = m.marsh
  inner join #nkls on #nkls.datnom = nc.datnom
  inner join dbo.defcontract dc on dc.dck = nc.dck
--  inner join dbo.def d on d.pin = dc.pin
--  inner join dbo.Raions r on r.Rn_id = d.Rn_ID
--  inner join dbo.Obl o on o.Obl_ID = d.Obl_ID
  where
  m.Marsh not in (0, 99)
--  and dc.Our_id in (10, 18)
  and nc.RefDatnom = 0
  and nc.Tara = 0 and nc.Frizer = 0
--and m.marsh = 82
  group by m.nd, m.Marsh, m.mhid, m.Weight, m.dopWeight,   m.direction --, nc.b_id --, nc.datnom
  having (isnull(m.Weight, 0) + isnull(m.dopWeight, 0)) > 0
  order by 1, 2
--  select * from #nkls
 drop table #nkls
END