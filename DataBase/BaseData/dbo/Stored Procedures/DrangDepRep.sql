CREATE procedure DrangDepRep @day0 datetime, @day1 datetime
as
begin
  -- Доход по дням и маршрутам:
  create table #M(Nd datetime, Marsh int, Expense decimal(12,2), 
    Dohod decimal(10,2), Marja decimal(10,2), Dots int, Logist varchar(50), Pilot varchar(60), Speditor varchar(60));

  insert into #M
  select m.nd, m.marsh, dbo.TransCost(m.marsh,m.Nd) as Expense, 
    m.Dohod, m.Marja, m.Dots, L.Fam as Logist, P.Fio as Pilot, P2.Fio as Speditor
  from Marsh M left join Lgs L on L.lgsid=M.Lgsid
    left join Person P on P.trid<=7 and p.p_id=m.n_driver
    left join Person P2 on p2.p_id=m.N_Sped
  where m.nd between @day0 and @day1 and m.Dots>1 and m.marsh<>99
  group by m.nd, m.marsh, m.Dohod, m.Marja, m.Dots, L.Fam, p.Fio, P2.Fio;
  
  create index TempMarshIdx on #M(nd,Marsh);
  
  -- Отгрузки по дням, маршрутам и накладным:
  create table #X(DepName varchar(50), 
    Nd datetime, Marsh int, Driver varchar(50),
    Weight decimal(10,1),
    B_ID int, BrFam varchar(50),
    NaklCount int);

 insert into #X 
 select 
   D.DName as DepName, 
   m.ND, m.Marsh, m.Driver, m.Weight, 
   nc.B_ID, max(nc.Fam) as BrFam,
   COUNT(nc.B_ID) as NaklCount
 from 
   marsh m inner join NC on NC.nd=m.nd and nc.marsh=m.marsh
   inner join def on def.tip=1 and def.pin=nc.b_id
   inner join agents a on a.ag_id=def.brag_id
   inner join supervis s on s.sv_id=a.sv_id
   inner join deps d on d.depid=s.depid
 where m.nd between @day0 and @day1 and m.Dots>1 and m.marsh<>99
 group by  D.DName, 
   m.ND, m.Marsh, m.Driver, m.Weight, nc.B_ID 
   
select #x.DepName, #M.Logist, #X.Nd, #X.Marsh, #X.Driver, #x.Weight,
  #X.B_ID, #X.BrFam, #X.NaklCount, #M.Expense, #M.Dohod, #M.Marja, 
  #M.Dots, #M.Pilot, #M.Speditor
from #X, #M
where #M.Nd=#X.nd and #M.Marsh=#X.Marsh
order by #x.DepName, #X.Nd, #X.Marsh

end;