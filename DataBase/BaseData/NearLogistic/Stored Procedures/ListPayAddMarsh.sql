CREATE PROCEDURE [NearLogistic].ListPayAddMarsh @mhid int, @ListNo int, @OplataSum money, @SecondDriver bit=0
AS
BEGIN

  declare @ttID int, @ND datetime 
  select @ttID=ttID, @ND=ND from NearLogistic.nlListPay where ListNo=@ListNo
  
  insert into 
  NearLogistic.nlListPayDet (ListNo,mhid,Nd,Marsh,OplataSum,OplataOther,Dist,DistPay,DrvPay,[weight],Dots,
                DotsPay,SpedPay,PercWorkPay,Peni,BrDolg,Podotchet,nlTariffParamsID,drID,SpedDrID,
                v_id,ScanND,dopWeight,Direction,v_idTr,vetPay,wayPay,SecondDriver,TimeGo, TimeBack) 
  select @ListNo,@mhid,Nd,Marsh,@OplataSum,0,Dist,DistPay,DrvPay,[weight],Dots,DotsPay,SpedPay,PercWorkPay,Peni,
       0,0,iif(@ttID<>5 and @SecondDriver=0, nlTariffParamsIDDrv,nlTariffParamsIDSpd),iif(@SecondDriver=0, drID,SpedDrID),
       SpedDrID,v_id,ScanND,dopWeight,Direction,v_idTr,iif(@ttID in (4,5),0.0, VetPay),iif(@ttID in (4,5),0.0, wayPay),@SecondDriver, TimeGo, TimeBack
  from marsh m where m.mhid=@mhid  

  if @ttID<>5 
  begin
    if @SecondDriver=0 update marsh set ListNo=@ListNo, mstatus=4 where mhid=@mhid
    else update marsh set ListNoSped=@ListNo, mstatus=4 where mhid=@mhid
    if @ttID=4 
    begin
      insert into HRmain.dbo.AdditonalExtra (AdditonalExtraDate,AdditonalExtraP_ID,AdditonalExtraPersID,
                           AdditonalExtraFIO,AdditonalExtraSUM,AdditonalExtraRemark,
                           AdditionalExtraTypeID) 
      select @ND,p.P_ID,p.HRPersID,p.FIO,@OplataSum,'Рейс №'+cast(m.marsh as char(3))+' от '+convert(varchar,m.ND,104), 0
      from marsh m 
      join drivers d on m.drID=d.drID
      join person p on d.p_id=p.p_id
      where m.mhid=@mhid 
    end
  end
  else
  begin
    update marsh set ListNoSped=@ListNo, mstatus=4 where mhid=@mhid
    insert into HRmain.dbo.AdditonalExtra (AdditonalExtraDate,AdditonalExtraP_ID,AdditonalExtraPersID,
                        AdditonalExtraFIO,AdditonalExtraSUM,AdditonalExtraRemark,
                        AdditionalExtraTypeID) 
    select @ND,p.P_ID,p.HRPersID,p.FIO,@OplataSum,'Рейс №'+cast(m.marsh as char(3))+' от '+convert(varchar,m.ND,104),0
     from marsh m 
     join drivers d on m.SpedDrID=d.drID
     join person p on d.p_id=p.p_id
     where m.mhid=@mhid 
  end
END