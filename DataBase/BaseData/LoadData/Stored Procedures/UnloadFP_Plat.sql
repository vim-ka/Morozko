CREATE PROCEDURE LoadData.UnloadFP_Plat @plat_num int, @rs_code int, @nd datetime, @pin int, @plat_sum numeric(12, 2), @our_id int, @comment varchar(512), @vid int, @other int
AS
BEGIN
  declare @i int
  select @i = count(*) from finplan.fpPlat where plat_num = @plat_num and rs_code = @rs_code and pin = @pin and our_id = @our_id
  if @i = 0
  	insert into FinPlan.fpPlat(plat_num, rs_code, nd, pin, plat_sum, our_id, comment, vid, other)
    values(@plat_num, @rs_code, @nd, @pin, @plat_sum, @our_id, @comment, @vid, @other)
END