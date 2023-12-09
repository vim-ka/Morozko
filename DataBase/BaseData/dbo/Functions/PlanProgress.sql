CREATE FUNCTION dbo.PlanProgress(@pl_kol int, @f_kol int, @pl_weight decimal(10,3), @f_weight decimal(10,3), @pl_rub decimal(10,2), @f_rub decimal(10,2))
-- Хитрая функция, используется в процедуре MarketRequestCalc.
-- Вычисляет наименьшее из трех частных @f_kol/@pl_kol, F_weight/@pl_weight, @f_rub/@pl_rub
RETURNS int
as
begin
  declare @k1 int, @k2 int, @k3 int, @rez int;
  set @rez=777;

  set @k1 = case 
    when @pl_kol=0 and @f_kol<=0 then 777
    when @pl_kol=0 and @f_kol>0 then @f_kol
    else @f_kol/@pl_kol
  end;
  if @k1<0 set @k1=0;

  set @k2 = case 
    when @pl_weight=0 and @f_weight<=1 then 777
    when @pl_weight=0 and @f_weight>0 then 100 -- @f_weight
    else @f_weight/@pl_weight
  end;
  if @k2<0 set @k2=0;

  set @k3 = case 
    when @pl_rub=0 and @f_rub<=1 then 777
    when @pl_rub=0 and @f_rub>0 then @f_rub
    else @f_rub/@pl_rub
  end;
  if @k3<0 set @k3=0;

  
  set @rez=@k1;
  if @rez>@k2 set @rez=@k2;
  if @rez>@k3 set @rez=@k3;

  return @rez;
end