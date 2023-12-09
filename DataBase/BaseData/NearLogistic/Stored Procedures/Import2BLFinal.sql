
CREATE PROCEDURE [NearLogistic].Import2BLFinal @mhid int, @NotSorted bit
AS
BEGIN
  declare @PointA int, @PointB int, @distanceA int, @distanceB int, @PointBase int, @UnloadID int
  
  declare CPoints cursor LOCAL Fast_forward for
  
  select iif(isnull(d.point_id,0)=0, e.point_id, d.point_id) as pointA,  m.distance from NearLogistic.MarshRequests m left join dbo.def d on m.PinTo=d.pin 
                                               left join NearLogistic.MarshRequests_Free f on m.ReqID=f.mrfid
                                               left join NearLogistic.MarshRequestsDet e on f.mrfid=e.mrfid and e.action_id=6
  where m.mhid=@mhid 
  order by m.ReqOrder
  
  
  select @UnloadId=max(UnloadID)+1 from NearLogistic.distance_history
  
  open CPoints
  
  fetch next from CPoints 
  into @PointA, @DistanceA
  
  set @PointBase = @PointA
  
  exec [NearLogistic].set_distance @pointA, @pointBase, @distanceA, @UnloadId, @mhid
  
    /*if @PointA<>@PointBase and not exists(select 1 from NearLogistic.distance where (PointA=@PointA and PointB=@PointBase) or (PointA=@PointBase and PointB=@PointA))
    begin
      insert into  NearLogistic.distance
      (
       pointA,
       pointB,
       distance
       ) 
      values (
       @pointA,
       @pointBase,
       @distanceA
       )
     END
     else
     begin  
       UPDATE NearLogistic.distance set distance=@distanceA where (PointA=@PointA and PointB=@PointBase) or (PointA=@PointBase and PointB=@PointA)
     end  */
  
  
  while @@FETCH_STATUS = 0 
  begin
    set @PointB = @PointA  
    set @distanceB = @distanceA
      
    fetch next from CPoints 
    into @PointA, @DistanceA

    exec [NearLogistic].set_distance @pointA, @pointB, @distanceB, @UnloadId, @mhid   
    
   /* if @PointA<>@PointB and not exists(select 1 from NearLogistic.distance where (PointA=@PointA and PointB=@PointB) or (PointA=@PointB and PointB=@PointA))
    begin
      print 'insert'+cast(@PointA as  varchar)+' _ '+cast(@PointB as  varchar)+ '='+cast(@distanceB as  varchar);
      insert into  NearLogistic.distance
      (
       pointA,
       pointB,
       distance
       ) 
      values (
       @pointA,
       @pointB,
       @distanceB
       )
     END
     else
     begin  
       print 'update '+ cast(@PointA as  varchar)+' _ '+cast(@PointB as  varchar)+ '='+cast(@distanceB as  varchar);
       UPDATE NearLogistic.distance set distance=@distanceB where (PointA=@PointA and PointB=@PointB) or (PointA=@PointB and PointB=@PointA)
     end  */
  
  end;
  
  exec [NearLogistic].set_distance @pointA, @pointBase, @distanceB, @UnloadId, @mhid    
  
 /* if @PointA<>@PointBase and not exists(select 1 from NearLogistic.distance where (PointA=@PointA and PointB=@PointBase) or (PointA=@PointBase and PointB=@PointA))
    insert into  NearLogistic.distance
    (
     pointA,
     pointB,
     distance
     ) 
    values (
     @pointA,
     @PointBase,
     @distanceB
     );
    else UPDATE NearLogistic.distance set distance=@distanceB where (PointA=@PointA and PointB=@PointBase) or (PointA=@PointBase and PointB=@PointA)
   */ 
    
  close CPoints;
  deallocate CPoints;
  
  if @NotSorted = 1
  UPDATE 
     NearLogistic.MarshRequests  
  SET 
     ReqOrder = 0
  WHERE mhid=@mhid;
  
  --delete from NearLogistic.MarshRequests where mhid=@mhid and ReqID=-1 and ReqType=-1;
END