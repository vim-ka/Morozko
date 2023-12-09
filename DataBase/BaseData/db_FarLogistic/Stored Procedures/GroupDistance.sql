CREATE PROCEDURE [db_FarLogistic].GroupDistance
@IDMarsh int,
@Work int,
@KM int
AS
BEGIN
  declare @TranName varchar(8)
  select @TranName = 'GrDist'
  
  BEGIN TRAN @TranName
  
  declare @PCost money
  declare @CasherID int  
  declare @PriceKM money
  
  select @PriceKM=sum(e.PriceKM)
  from db_FarLogistic.dlExpence e
  where e.IDVehTYpe=(select v.dlVehTypeID
  										from db_FarLogistic.dlMarsh m
                      left join db_FarLogistic.dlVehicles v on v.dlVehiclesID=m.IDdlVehicles
                      where m.dlMarshID=@IDMarsh and e.DateStart<(select isnull(m.dt_beg_fact, getdate())))
  
  if @Work<>0
  begin
  select @PCost=sum(ji.Cost)
  from db_FarLogistic.dlJorneyInfo ji
  left join db_FarLogistic.dlJorney j on j.IDReq=ji.IDReq and j.IDdlPointAction=2
  where j.NumberWorks=@Work and ji.MarshID=@IDMarsh
  
  if @PCost=0
  set @PCost=@KM*@PriceKM+
  									(select count(j.IDdlDelivPoint)-2
                    from db_FarLogistic.dlJorney j 
                    left join db_FarLogistic.dlJorneyInfo ji on ji.IDReq=j.IDReq
                    where j.NumberWorks=@Work and ji.MarshID=@IDMarsh)*1500
                    
  select @CasherID= a.casherid from(
  select  distinct a.CasherID 
  from db_FarLogistic.dlJorneyInfo a 
  left join db_FarLogistic.dlJorney b on b.IDReq=a.IDReq and b.IDdlPointAction=2 
  where a.MarshID=@IDMarsh and b.NumberWorks=@Work) a
  
  end
  if @Work=0
  set @PCost=@KM*@PriceKM
  
  if exists(select * from db_FarLogistic.dlTmpMarshCost m where m.MarshID=@IDMarsh and m.WorkID=@Work)
  begin
  	update db_FarLogistic.dlTmpMarshCost set 
    db_FarLogistic.dlTmpMarshCost.KM=@KM,
    db_FarLogistic.dlTmpMarshCost.Cost=@PCost,
    db_FarLogistic.dlTmpMarshCost.CasherID=@CasherID
    where db_FarLogistic.dlTmpMarshCost.MarshID=@IDMarsh and db_FarLogistic.dlTmpMarshCost.WorkID=@Work
  end
  else
  begin
  	insert into db_FarLogistic.dlTmpMarshCost values(
    @IDMarsh,
    @Work,
    @KM,
    @PCost,
    case when @Work=0 then -1 else @CasherID end,
		null,
		null,
		null
    )
  end
  
  if @@ERROR = 0 
  COMMIT TRAN @TranName
  ELSE ROLLBACK TRAN @TranName
END