CREATE procedure NearLogistic.set_delivery_plan_marsh @dpIDs varchar(500), @marsh int, @op int
as
begin
  update dp set dp.marsh_number=@marsh
  from nearlogistic.delivery_plan dp
  join (select value from string_split(@dpIDs,',')) s on s.value=dp.dpID
end