CREATE PROCEDURE NearLogistic.Export2BM @mhid varchar(200), @sTm char(8), @PLID varchar(3)='1'
AS
BEGIN
declare @tm datetime
set @tm=cast(@sTm as datetime)

select --cast(mr.mrID as varchar) as Nom1,
       REPLICATE('0', 7-len(cast(mr.mrID as varchar)))+cast(mr.mrID as varchar)+REPLICATE('0', 7-len(cast(isnull(DefTo.pin,0) as varchar)))+cast(isnull(DefTo.pin,0) as varchar) as Nom, 
       1 as Priority,
       iif(mr.pinFrom = 0 or mr.ReqType=0, 'База', left(DefFrom.gpName,50)) as GetDescr,
       iif(mr.pinFrom = 0 or mr.ReqType=0, left(f.OurAddrFiz,50), left(DefFrom.gpAddr,50)) as GetAddr,
       iif(mr.pinFrom = 0 or mr.ReqType=0, f.PosX, DefFrom.PosX) as GetXCoord,
       iif(mr.pinFrom = 0 or mr.ReqType=0, f.PosY, DefFrom.PosY) as GetYCoord,
       mr.[Weight_] as Weight ,
       mr.Volume_ as Volume,
       isnull(left(DefTo.gpName,50),'???') as PutDescr,
       isnull(left(DefTo.gpAddr,80),'???') as PutAddr,
       DefTo.PosX as PutXCoord,
       DefTo.PosY as PutYCoord,
       '' as GetBeg,
       '' as GetEnd, 
       convert(varchar,'',108) /*iif(@tm is null,0.34375,@tm)*/ as  PutBeg,
       iif(TRY_CONVERT(datetime,defto.tmpost) is null,'00:01',
       iif(convert(varchar,DefTo.tmPost,108)='24:00','00:01',convert(varchar,DefTo.tmPost,108))) as PutEnd,       
       '' as Doc,
       '1' as CarType,
       mr.Cost_ as  Cost,
       'Авто' as Carn,
       mr.PinTo,
       mr.Pinfrom
         
from [NearLogistic].MarshRequests mr left join Def DefFrom on mr.PinFrom=DefFrom.pin
                                     left join Def DefTo on DefTo.pin=iif(mr.ReqType=0 and mr.PINFrom<>0 ,mr.PINFrom, mr.pinTo) 
                                     join SkladPlace f on f.plid=cast(@PLID as int)
where mr.mhid in (select k from dbo.Str2intarray(@mhid)) and mr.ReqType<>-2 

union

select --cast(mr.mrID as varchar) as Nom1,
       REPLICATE('0', 7-len(cast(mr.mrID as varchar)))+cast(mr.mrID as varchar)+REPLICATE('0', 7-len(cast(isnull(PointTo.point_id,0) as varchar)))+cast(isnull(PointTo.point_id,0) as varchar) as Nom, 
       1 as Priority,
       iif(mr.pinFrom = 0 or mr.ReqType=0, 'База', left(PointFrom.point_name,50)) as GetDescr,
       iif(mr.pinFrom = 0 or mr.ReqType=0, left(f.OurAddrFiz,50), left(PointFrom.point_adress,50)) as GetAddr,
       iif(mr.pinFrom = 0 or mr.ReqType=0, f.PosX, PointFrom.PosX) as GetXCoord,
       iif(mr.pinFrom = 0 or mr.ReqType=0, f.PosY, PointFrom.PosY) as GetYCoord,
       mr.[Weight_] as Weight ,
       mr.Volume_ as Volume,
       iif(isnull(left(PointTo.point_name,50),'???')='','???',isnull(left(PointTo.point_name,50),'???')) as PutDescr,
       isnull(left(PointTo.point_adress,80),'???') as PutAddr,
       PointTo.PosX as PutXCoord,
       PointTo.PosY as PutYCoord,
       '' as GetBeg,
       '' as GetEnd, 
       convert(varchar,'',108) /*iif(@tm is null,0.34375,@tm)*/ as  PutBeg,
       iif(TRY_CONVERT(datetime,PointTo.tmDeliv) is null,'00:01',
       iif(convert(varchar,PointTo.tmDeliv,108)='24:00','00:01',convert(varchar,PointTo.tmDeliv,108))) as PutEnd,       
       '' as Doc,
       '1' as CarType,
       mr.Cost_ as  Cost,
       'Авто' as Carn,
       0,
       -1
         
from [NearLogistic].MarshRequests_free mrf join [NearLogistic].marshrequestsdet mrdet on mrf.mrfid=mrdet.mrfid 
                                           join [NearLogistic].MarshRequests mr on mr.ReqID=mrf.mrfID
                                           left join [NearLogistic].marshrequests_points PointFrom on mrdet.point_id=PointFrom.point_id and mrdet.action_id=5
                                           join [NearLogistic].marshrequests_points PointTo on mrdet.point_id=PointTo.point_id and mrdet.action_id=6
                                           join SkladPlace f on f.plid=cast(@PLID as int)
where mr.mhid in (select k from dbo.Str2intarray(@mhid)) and mr.mhid<>666





      

END