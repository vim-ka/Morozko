CREATE PROCEDURE db_FarLogistic.FillTempData_debug 
@MarshID int
AS
BEGIN
declare @tranname varchar(12)
set @tranname=N'FillTempData_debug'
begin tran @tranname
	declare @erReg int 
	set @erReg=0
	
	if not exists(select * from db_FarLogistic.dlMarsh where dlMarshID=@MarshID) 
	set @erReg=1
	
	
  if @erReg=0
	begin
		delete from db_FarLogistic.dlTmpMarshCost where MarshID=@MarshID
	set @erReg=@erReg+@@ERROR
	end
	
	if @erReg=0
	begin
		--insert into db_FarLogistic.dlTmpMarshCost (MarshID, WorkID, KM, CasherID, Cost, NewCost, PalCount, DotsCount, palWeight, isFix, PalKMCost, dotCost, minKMCost, minKM, DepID)
		select 	z.[MarshID],
						z.[WorkID],
						z.[Distance],
						z.[CasherID],
						case when z.[WorkID]=0 then 0 else
						case when z.[Fix]=1 then z.PalKMCost else
						case when z.[Distance]<=z.[minKM] then z.[minCost] else 
						z.[Distance]*z.[Pal]*z.[PalKMCost]+(z.[Cnt]-2)*z.[dotCost] end end end,
						case when z.[WorkID]=0 then 0 else
						case when z.[Fix]=1 then z.PalKMCost else
						case when z.[Distance]<=z.[minKM] then z.[minCost] else 
						z.[Distance]*z.[Pal]*z.[PalKMCost]+(z.[Cnt]-2)*z.[dotCost] end end end,
						z.[Pal],
						z.[Cnt],
						z.[Wei],
						z.[Fix],
						z.[PalKMCost],
						z.[dotCost],
						z.[minCost],
						z.[minKM],
						z.DepID
		from (
		select 	@MarshID [MarshID],
						x.[WorkID],
						case when x.[WorkID]=0 then -1 else  x.[CasherID] end [CasherID],
						(	select sum(s.Distance) 
							from db_FarLogistic.GetDistanceTable(@MarshID, x.[WorkID]) s)/1000 [Distance],
						isnull(
						(	select sum(j.FCount) 
							from db_FarLogistic.dlJorney j
							join db_FarLogistic.dlJorneyInfo ji on ji.idreq=j.IDReq
							where ji.MarshID=@MarshID
										and j.NumberWorks=x.[WorkID]
										and j.IDdlPointAction in (2,3)),0) [Pal],
						isnull(
						(	select sum(j.FWeight) 
							from db_FarLogistic.dlJorney j
							join db_FarLogistic.dlJorneyInfo ji on ji.idreq=j.IDReq
							where ji.MarshID=@MarshID
										and j.NumberWorks=x.[WorkID]
										and j.IDdlPointAction in (2,3)),0) [Wei],
						isnull(
						(	select count(*) 
							from db_FarLogistic.dlJorney j
							join db_FarLogistic.dlJorneyInfo ji on ji.idreq=j.IDReq
							where ji.MarshID=@MarshID
										and j.NumberWorks=x.[WorkID]
										and j.NumbForRace>0),0) [Cnt],
						(select t.flgFix from db_FarLogistic.GetTariff(@MarshID, x.[Workid]) t) [Fix],
						(select t.tCost from db_FarLogistic.GetTariff(@MarshID, x.[Workid]) t) [PalKMCost],
						(select case when t.flgFix=1 then t.tCost else t.minCost end from db_FarLogistic.GetTariff(@MarshID, x.[Workid]) t) [minCost],
						(select case when t.flgFix=1 then 0 else t.dotCost end from db_FarLogistic.GetTariff(@MarshID, x.[Workid]) t) [dotCost],
						(select case when t.flgFix=1 then 0 else t.minKM end from db_FarLogistic.GetTariff(@MarshID, x.[Workid]) t) [minKM],
						x.DepID
		from (
		select 	distinct j.NumberWorks [WorkID],
						ji.CasherID,
						ji.DepID
		from db_FarLogistic.dlJorney j
		join db_FarLogistic.dlJorneyInfo ji on ji.IDReq=j.IDReq
		where ji.MarshID= @MarshID 
					and j.NumbForRace>0
					and not ji.JorneyTypeID in (3,4)
		union all 
		select 0,0,0) x
		left join def d on d.pin=x.[CasherID]
		) z
	
	set @erReg=@erReg+@@ERROR
	end
	
	if @erReg=0
	begin
		delete from db_FarLogistic.dlPairDistanceDrv where MarshID=@MarshID
	set @erReg=@erReg+@@ERROR
	end
	
	if @erReg=0
	begin
		insert into db_FarLogistic.dlPairDistanceDrv(MarshID, IDDrv, FinishPointNumber, KM)
		select tc.MarshID, m.IDdlDrivers, 1, tc.KM+tc.delta
		from db_FarLogistic.dlTmpMarshCost tc
		join db_FarLogistic.dlMarsh m on m.dlMarshID=tc.MarshID
		where tc.MarshID=@MarshID
	set @erReg=@erReg+@@ERROR
	end
	
	if @erReg=0
	begin
		commit tran @tranname
		select cast(0 as bit) [res], cast('' as varchar(255)) [mes]
	end
	else
	begin
		rollback tran @tranname
		select cast(1 as bit) [res], cast('Ошибки в результате вычислений' as varchar(255)) [mes]
	end
END