CREATE PROCEDURE NearLogistic.PrintWayList_Self
@mhid int
AS
begin
set nocount off
declare @org varchar(300)
select @org=OurName+', '+OurADDR+', тел. '+Phone+', ОГРН '+OGRN+' от '+convert(varchar,OGRNDate,104)
from dbo.FirmsConfig 
where Our_id=2

if object_id('tempdb..#defDots') is not null drop table #defDots

select top 5 * 
into #defDots
from (
select rank() OVER (ORDER BY d.gpAddr) as rank, 
    d.gpAddr, 
       mr.mhid 
       from def d 
join [NearLogistic].MarshRequests mr on d.pin=mr.pinto and mr.mhid=@mhid) x

select  top 1 m.nd, m.marsh, m.weight, m.boxqty, m.driver, m.sped, m.done, m.Closed, m.Dist, 
     m.DistPay, m.Dohod, m.SpedPAy, m.LgsId, m.Hours, m.HoursPay, m.Marja, m.Dots, 
     m.DotsPay, m.Minuts, m.TimePlan, m.TimeStart, m.TimeFinish, m.MarshDay, 
     m.N_Driver, m.N_Sped, m.Vehicle, m.MaxWeight, m.v_id, ff.ftname, m.FuelCode,
     m.fuel0, m.Fuel1, m.FuelAdd, m.Km0, m.Km1, m.TimeGo, m.TimeBack, v.Model, 
     v.RegNom, m.Bill, v.FuelSpend, v.Owner, v.FuelCard, v.DriverDoc,v.RegTsSer, v.RegTsNom,
        Dr.Fio DriverName,        
        t1.gpAddr  as addr1,
        t2.gpAddr  as addr2,
        t3.gpAddr  as addr3,
        t4.gpAddr  as addr4,
        t5.gpAddr  as addr5,
        @org [org]
from dbo.marsh m
left outer join Vehicle V on V.V_ID=M.V_ID
left join Drivers Dr on dr.drid=m.drid
left join ffueltip ff on ff.ftID=v.ftid
left join (select P_id,Fio from Person) A on A.P_id=m.N_Driver
left join #defDots t1 on m.mhid=t1.mhid and t1.rank=1
left join #defDots t2 on m.mhid=t2.mhid and t2.rank=2
left join #defDots t3 on m.mhid=t3.mhid and t3.rank=3
left join #defDots t4 on m.mhid=t4.mhid and t4.rank=4
left join #defDots t5 on m.mhid=t5.mhid and t5.rank=5    
where m.mhid=@mhid

if object_id('tempdb..#defDots') is not null drop table #defDots
set nocount on
end