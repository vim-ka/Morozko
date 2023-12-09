CREATE PROCEDURE LoadData.UnloadFP_RS @rs_code int, @nd datetime, @plat_sum numeric(12, 2), @our_id int
AS
BEGIN
  declare @i int
  select @i = count(*) from finplan.fpRS where rs_code = @rs_code and our_id = @our_id AND nd = @nd
  if @i = 0
  	insert into FinPlan.fpRS(rs_code, nd, plat_sum, our_id)
    values(@rs_code, @nd, @plat_sum, @our_id)
END