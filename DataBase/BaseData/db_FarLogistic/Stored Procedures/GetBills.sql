CREATE PROCEDURE db_FarLogistic.GetBills
@isArch bit =0 
AS
if @isArch=0
begin
	select 	b.RealBillID,
					b.dlGroupBillID,
					m.dlMarshID,
					m.dt_beg_fact,
					dr.Surname+' '+left(dr.Firstname,1)+'.'+left(dr.Middlename,1)+'.' fio,
					b.CasherID,
					d.brName,
					s.Routes,        
					b.GivenDate,
					b.ForPay,
					b.UnLoaded
	from db_FarLogistic.dlGroupBill b
	left join db_FarLogistic.dlDef d on d.id=b.CasherID
	left join db_FarLogistic.GroupInStr() s on s.MarshID=b.MarshID and s.WorkID=b.WorkID
	left join db_FarLogistic.dlMarsh m on m.dlMarshID=b.MarshID
	left join db_FarLogistic.dlDrivers dr on dr.id=m.IDdlDrivers
	where datediff(day,b.GivenDate,getdate())<=7
	order by 1 desc
end
else
begin
	select 	b.RealBillID,
					b.dlGroupBillID,
					m.dlMarshID,
					m.dt_beg_fact,
					dr.Surname+' '+left(dr.Firstname,1)+'.'+left(dr.Middlename,1)+'.' fio,
					b.CasherID,
					d.brName,
					s.Routes,        
					b.GivenDate,
					b.ForPay,
					b.UnLoaded
	from db_FarLogistic.dlGroupBill b
	left join db_FarLogistic.dlDef d on d.id=b.CasherID
	left join db_FarLogistic.GroupInStr() s on s.MarshID=b.MarshID and s.WorkID=b.WorkID
	left join db_FarLogistic.dlMarsh m on m.dlMarshID=b.MarshID
	left join db_FarLogistic.dlDrivers dr on dr.id=m.IDdlDrivers
	order by 1 desc
end