CREATE function NearLogistic.CheckCoord(@pin int, @tip int =0)
returns BIT 
as
begin
declare @isCoord bit, @posx numeric(12,5)

set @isCoord = 1

--проверка x координты
if @tip = 6 

  select @posx=ISNULL((
  	select p.Posx
	from nearlogistic.marshrequestsdet t
	join nearlogistic.marshrequests_points p on p.point_id=t.point_id
	where t.mrfid=@pin and t.action_id=6
	),0)
else select @posx=(
  select d.Posx from def d where d.pin=@pin)

if @posx = 0 set @isCoord = 0 else 
begin
  --проверка y координты
  if @tip = 6 

    select @posx=ISNULL((
   	 select p.Posy
  	 from nearlogistic.marshrequestsdet t
	 join nearlogistic.marshrequests_points p on p.point_id=t.point_id
	 where t.mrfid=@pin and t.action_id=6
	),0)
  else select @posx=(
    select d.Posy from def d where d.pin=@pin)
  if @posx = 0 set @isCoord = 0
end

return @isCoord

end