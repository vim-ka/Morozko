CREATE PROCEDURE NearLogistic.PrintActDoingWork
@nd1 datetime,
@nd2 datetime,
@groupType int -- 0 -За выбранный период,1 -понеделно,2 -понедельно с детализацией
AS
BEGIN
if @groupType=0
begin
  select c.CrID,c.crName,c.UrArrd,c.FactAddr,c.CrBIK,c.CrRs,c.crCs,c.crInn,c.crKpp,
         c.NDS,b.BName,round(sum(o.OplataSum),2) as Oplata,
         null VedNo,cast(null as datetime) ND,null Marsh,cast(null as datetime) [NDMarsh],cast(null as varchar(500)) Driver,cast(null as varchar(500)) Model,
         cast(null as varchar(500)) RegNom
  from NearLogistic.nlListPayDet o 
  join Marsh m on o.mhid=m.mhid
  left join Vehicle v on m.v_id=v.v_id
  left join Carriers c on v.crID=c.crID
  left join BankList b on c.Bank_id=b.BnK
  where c.PhysPerson = 0 and c.crID<>7 and  m.nd between @nd1 and @nd2
  group by c.CrID,c.crName,c.UrArrd,c.FactAddr,c.CrBIK,c.CrRs,c.crCs,c.crInn,c.crKpp,c.NDS,b.BName
end

if @groupType=1
begin
  select c.CrID,c.crName,c.UrArrd,c.FactAddr,c.CrBIK,c.CrRs,c.crCs,c.crInn,c.crKpp,
         c.NDS,b.BName,round(sum(o.OplataSum),2) as Oplata,o.ListNo [VedNo],s.ND,
         null Marsh,cast(null as datetime) [NDMarsh],cast(null as varchar(500)) Driver,cast(null as varchar(500)) Model,
         cast(null as varchar(500)) RegNom
  from NearLogistic.nlListPayDet o 
  join Marsh m on o.mhid=m.mhid
  left join Vehicle v on m.v_id=v.v_id
  left join Carriers c on v.crID=c.crID
  left join BankList b on c.Bank_id=b.BnK
  left join NearLogistic.nlListPay s on o.ListNo=s.ListNo
  where c.PhysPerson = 0 and c.crID<>7 and  m.nd between @nd1 and @nd2
  group by o.ListNo,s.ND,c.CrID,c.crName,c.UrArrd,c.FactAddr,c.CrBIK,c.CrRs,c.crCs,c.crInn,c.crKpp,c.NDS,b.BName
  order by c.CrID
end

if @groupType=2
begin
  select c.CrID,c.crName,c.UrArrd,c.FactAddr,c.CrBIK,c.CrRs,c.crCs,c.crInn,c.crKpp,
         c.NDS,b.BName,round(o.OplataSum,2) as Oplata,o.ListNo [VedNo],s.ND,o.Marsh,
         m.Nd [NDMarsh],m.Driver,v.Model,v.RegNom
  from NearLogistic.nlListPayDet o 
  join Marsh m on o.mhid=m.mhid   
  left join Vehicle v on m.v_id=v.v_id
  left join Carriers c on v.crID=c.crID
  left join BankList b on c.Bank_id=b.BnK
  left join NearLogistic.nlListPay s on o.ListNo=s.ListNo
  where c.PhysPerson = 0 and c.crID<>7 and  m.nd between @nd1 and @nd2
  order by c.CrID, o.ListNo
end
END