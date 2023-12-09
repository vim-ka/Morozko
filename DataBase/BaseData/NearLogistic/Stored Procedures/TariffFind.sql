CREATE PROCEDURE NearLogistic.TariffFind @mhid int, @force bit=0
AS
BEGIN
  declare @TeknlTariffParamsIDDrv int
  declare @TeknlTariffParamsIDSpd int
  declare @weight float
  declare @SecondDriver bit, @SpedDrID int, @ListNo int, @ListNoSped int
  declare @msg varchar(500)
  set @msg=''
  
  select @TeknlTariffParamsIDDrv = isnull(m.nlTariffParamsIDDrv,0), 
         @TeknlTariffParamsIDSpd = isnull(m.nlTariffParamsIDSpd,0)
  from marsh m where m.mhID=@mhid  
  
  if exists(select 1 from dbo.marsh x where x.mhid=@mhid and isnull(x.v_id,0)<>0)
  begin
  if (@TeknlTariffParamsIDDrv) = 0 or (@TeknlTariffParamsIDSpd = 0) or (@force = 1)
  begin
    declare @Sped bit, @ttID int, @nlVehCapacityID int, @CalcDist float, @CrID int, @JurType bit 

    select @ttID = c.ttID, 
           @nlVehCapacityID = v.nlVehCapacityID,
           @CalcDist = iif(isnull(m.dist,0)<>0,m.Dist,isnull(m.CalcDist,0)),
           @Sped = iif( (m.SpedDrID<>0) and (isnull(s.trId,0) not in (16)), 1, 0),
           @CrID = c.crID,
           @weight = m.weight,
           @SecondDriver=0,-- iif(isnull(s.trId,0)=6, 1, 0),
           @SpedDrID=m.SpedDrID,
           @ListNo=m.ListNo,
           @ListNoSped=m.ListNoSped
    from [dbo].marsh m join vehicle v on m.v_id=v.v_id
                       join carriers c on v.crID=c.crID
                       left join Drivers s on m.SpedDrID=s.DrID
    where m.mhid = @mhid
    
    --Возьмем @nlVehCapacityID не по транспорту, а по загрузке рейса
    select @nlVehCapacityID=n.nlVehCapacityID from [NearLogistic].nlVehCapacity n where n.WeightMin<@weight and @weight<=n.WeightMax
    
    print cast(@nlVehCapacityID as varchar)
     
    if (@TeknlTariffParamsIDDrv = 0) or (@force = 1)
    begin
      set @TeknlTariffParamsIDDrv = isnull((select d.nlTariffParamsID 
                                     from [NearLogistic].nlTariffs t join [NearLogistic].nlTariffsDet d on t.nlTariffsID=d.nlTariffsID
                                     where t.ttID=@ttID and @CalcDist between t.DistStart and t.DistEnd and t.withSped=@Sped
                                           and d.nlVehCapacityID=@nlVehCapacityID), 0)
      
      if @ListNo=0 update [dbo].marsh set nlTariffParamsIDDrv = @TeknlTariffParamsIDDrv where mhid = @mhid
   
    end  
  
    if ((@TeknlTariffParamsIDSpd = 0) and (@SpedDrID > 0)) or ((@SpedDrID > 0) and (@force = 1))
    begin
      if @crID = 7 or @crID = 698  set @JurType = 0; else set @JurType = 1
      
      set @TeknlTariffParamsIDSpd = isnull((select d.nlTariffParamsID 
                                    from [NearLogistic].nlTariffs t join [NearLogistic].nlTariffsDet d on t.nlTariffsID=d.nlTariffsID
                                    where ((t.ttID=5 and @SecondDriver=0) or (t.ttID=4 and @SecondDriver=1 and t.withSped=@Sped)) 
                                          and @CalcDist between t.DistStart and t.DistEnd 
                                          and t.JurType=@JurType and d.nlVehCapacityID=@nlVehCapacityID), 0) 
  
      if @ListNoSped=0 update [dbo].marsh set nlTariffParamsIDSpd = @TeknlTariffParamsIDSpd where mhid = @mhid
  
    end;
    
    if (@TeknlTariffParamsIDSpd > 0) and (@SpedDrID = 0)
      update [dbo].marsh set nlTariffParamsIDSpd = 0 where mhid = @mhid
    
  end;
  end
  else
  update m set m.nlTariffParamsIDDrv=0,
  			 			 m.nlTariffParamsIDSpd=0
  from dbo.marsh m
  where m.mhid=@mhid
  
  select @msg=t.TariffName  
  from dbo.marsh m
  left join [NearLogistic].nlTariffsDet d on d.nlTariffParamsID=m.nlTariffParamsIDDrv
  left join [NearLogistic].nlTariffs t on t.nlTariffsID=d.nlTariffsID
  where m.mhid=@mhid
  
  insert into NearLogistic.MarshRequestsOperationsLog(op,mhid,mhid_old,ids,ids_,operationType,remark) 
  values(0,@mhid,0,'','',6,iif(@force=1,'Принудительно - ','Вручную - ')+isnull(@msg,''))
  
 /* select @ttID as ttID,@Sped as Sped, @CalcDist as CalcDist, @JurType as JurType, @nlVehCapacityID as nlVehCapacityID, 
         @TeknlTariffParamsIDSpd as TeknlTariffParamsIDSpd, @TeknlTariffParamsIDDrv as TeknlTariffParamsIDDrv,
         @weight as weight, @SecondDriver as SecondDriver   */
  
           
END