CREATE procedure AgentZarp3temp @day0 datetime, @period int
as
declare @day1 datetime
declare @n0 int, @n1 int
declare @SebestKoeff float
begin
  set @SebestKoeff=1.2
  set @Day1=@Day0+@Period-1
  set @n0=dbo.indatnom(1,@day0)
  set @n1=dbo.indatnom(9999,@day1)

  
-- Какие накладные участвуют в расчете?
select SourDatNom,sum(Plata) as Plata
into #KASSA
from Kassa1 
where OPER=-2 and Act='ВЫ' and b_id=7295
and ND between @day0 and @day1
group by SourDatNom

CREATE CLUSTERED INDEX NcTmpIdx ON #KASSA(SourDatNom)


-- частичные коэффициенты по всем оплачиваемым за период накладным:

create table #ncp(datnom int, b_id int, ncid tinyint, PartSP decimal(20,12));
insert into #ncp
  select nc.datnom, nc.b_id, nm.ncid, sum(nv.kol*nv.price*(1.0+nc.extra/100)/nc.sp) as PartSP
  from Nc inner join #Kassa K on K.sourdatnom=nc.datnom and nc.b_id=7295
  inner join nv on nv.datnom=nc.datnom
  inner join Nomen nm on nm.hitag=nv.hitag
  inner join def d on d.pin=nc.b_id and d.tip=1
  and NC.Frizer=0 and NC.Actn=0 and NC.Tara=0 and nc.sp<>0
  group by nc.datnom, nc.b_id, nm.ncid
  order by nc.datnom, nm.ncid;
  
create index NcP_IDX on #ncp(datnom, ncid);


-- доход и плата за период:
select #ncp.b_id, #ncp.datnom, nc.sp, nc.DeltaSpecSc, #ncp.PartSp,  #ncp.ncid,
  round(sum(case when (nc.sp=0 or nc.sp is null) then K.Plata*#ncp.PartSP 
  else K.Plata*#ncp.PartSP*(nc.sp-(1.0*(nc.sc+isnull(nc.DeltaSpecSc,0))))/NC.sp END),5) as PartDohod,
  round(sum(case when (nc.sp=0 or nc.sp is null) then K.Plata*#ncp.PartSP 
  else K.Plata*#ncp.PartSP*(nc.sp-(@SebestKoeff*(nc.sc+isnull(nc.DeltaSpecSc,0))))/NC.sp END),5) as PartDohod02,
  sum(K.Plata*#ncp.PartSP) as PartPlata 
from #Kassa K inner join NC on NC.Datnom=K.SourDatnom and NC.Frizer=0 and NC.Actn=0 and NC.Tara=0
inner join #ncp on #ncp.datnom=NC.datnom
group by #ncp.B_ID, #ncp.datnom, nc.sp,nc.DeltaSpecSc, #ncp.PartSp,  #ncp.ncid
order by #ncp.B_ID, #ncp.datnom, nc.sp,nc.DeltaSpecSc, #ncp.PartSp,  #ncp.ncid

end;