CREATE procedure Guard.SaveComment @ND datetime, @ag_id int, @b_id int, @Comment varchar(40)
as
BEGIN
  if exists(select * from guard.PlanComments where nd=@nd and ag_id=@ag_id and b_id=@b_id) 
  BEGIN
    if @Comment='' delete from guard.PlanComments where nd=@nd and ag_id=@ag_id and b_id=@b_id;
    else update guard.PlanComments set Comment=@Comment where nd=@nd and ag_id=@ag_id and b_id=@b_id;
  END;
  else 
    if @Comment<>'' insert into guard.PlanComments(nd,ag_id,b_id,Comment) values(@nd,@ag_id,@b_id,@Comment);
end;