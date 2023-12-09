CREATE PROCEDURE db_FarLogistic.GetRequests
@isArch bit=0 
AS
BEGIN
  if @isArch=0 
	begin
		select 	ji.[IDReq],
						ji.[CasherID],
						ji.[VendorID],
						ji.[Cost],
						ji.[JorneyTypeID],
						ji.BasisIDReq,						
						r.[Date],
						r.[Count],
						r.[Race],
						r.[Weight],
						r.[Group],
						cast('' as varchar(50)) [msg]
		from db_FarLogistic.dlJorneyInfo ji
		left join db_FarLogistic.ReqInfo() r on r.IDReq=ji.IDReq
		where ji.isCancel=0 
					and isnull(ji.MarshID,-1)=-1
					and (case when r.[Group]=-1 then getdate() else (r.Date) end) between dateadd(d,-6,getdate()) and dateadd(d,6,getdate())
					and ji.[IDReq]>0
		order by r.[Group], r.[Date]
	end
	else
	begin
		select 	ji.[IDReq],
						ji.[CasherID],
						ji.[VendorID],
						ji.[Cost],
						ji.[JorneyTypeID],
						ji.BasisIDReq,						
						r.[Date],
						r.[Count],
						r.[Race],
						r.[Weight],
						r.[Group],
						case when ji.isCancel=1 then 'Отменена' else 
						case when isnull(ji.MarshID,-1)=-1 then 'не обработана' else 'обработана,№'+cast(ji.MarshID as varchar(7)) end end [msg]
		from db_FarLogistic.dlJorneyInfo ji
		left join db_FarLogistic.ReqInfo() r on r.IDReq=ji.IDReq
		where ji.[IDReq]>0
		order by r.[Group], r.[Date]
	end
END