create procedure nearlogistic.set_day_code_for_buyer
@b_id int, @nd datetime as 
begin
  set nocount on
  declare @max_liter_id int, @liter_id int, @exists bit =0

  select @liter_id=liter_id
  from nearlogistic.day_code_buyer
  where nd=@nd and b_id=@b_id

  set @exists=cast(iif(@liter_id is null,0,1) as bit)

  if @liter_id is null
  begin
    select @max_liter_id=max(liter_id)
    from nearlogistic.day_code_buyer
    where nd=@nd
    
    set @liter_id=isnull(@max_liter_id+1,1)
  end

  if @exists=0
  insert into nearlogistic.day_code_buyer(b_id,nd,liter_id) 
                                   values(@b_id,@nd,@liter_id)
  set nocount off
end