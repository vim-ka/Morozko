CREATE procedure AddSellToOldNV
  @datnom int, @tekid int, @Hitag int, @Price decimal(10,2),
  @Cost decimal(12,5), @Kol int, @sklad int, @Remark varchar(30)
as BEGIN
  -- Новая строка в существующей накладной:
  INSERT INTO NV(DATNOM,TEKID,HITAG,PRICE,COST,KOL,KOL_B,SKLAD,
    BASEPRICE,REMARK,TIP,MEAS,DELIVCANCEL)
  VALUES(@DATNOM,@TEKID,@HITAG,@PRICE,@COST,@KOL,0,@SKLAD,
    @PRICE,@REMARK,0,2,0);
  -- Подправляю продажи в полном архиве склада:  
  update Visual set Sell=Sell+@Kol, Now=Now-@Kol where ID=@TekID;
  -- Подправляю текущий склад:  
  update TdVi set Morn=Morn-@Kol where ID=@TekID;
end;
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Добавляет доп.продажу в старую накладную
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'AddSellToOldNV';

