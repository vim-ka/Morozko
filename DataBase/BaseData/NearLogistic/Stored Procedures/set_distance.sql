
CREATE procedure NearLogistic.set_distance
@p1 int, @p2 int, @distance int, @UnloadID int=0, @mhid int=0
as 
begin
 if @p1<>@p2 and @distance>0
  begin
   delete from nearlogistic.distance where (pointa=@p1 and pointb=@p2) or (pointa=@p2 and pointb=@p1)
  insert into nearlogistic.distance (pointa, pointb, distance)
   values(@p1, @p2, @distance)
   insert into nearlogistic.distance_history (pointa, pointb, distance, UnloadID, mhid)
   values(@p1, @p2, @distance, @UnloadID, @mhid)
  end
end