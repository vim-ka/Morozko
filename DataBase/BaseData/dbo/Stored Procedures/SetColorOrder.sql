CREATE PROCEDURE dbo.SetColorOrder
@mp int,
@hitag int,
@depid int,
@clr int,
@ord int,
@op int
AS
BEGIN
  if @mp=-1
  begin
		insert into MtPrior(hitag,depid,op,clr,ord)
    values (@hitag,@depid,@op,@clr,@ord)
  end
  else
  begin
		update MtPrior set clr=@clr, ord=@ord, op=@op
    where mp=@mp
  end
END