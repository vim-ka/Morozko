-- добавляет новую номенклатуру определенного поставщика
CREATE PROCEDURE AddNomen @VendorsID int, @Hit int output
AS
BEGIN
    select @Hit=IsNull(min(nom.hh),0) from
    (select
      case when ROW_NUMBER() OVER(ORDER BY hitag) in (select hitag from Nomen) then 0
      else  ROW_NUMBER() OVER(ORDER BY hitag)
      end hh
    from Nomen) nom
    where nom.hh>0
    if @Hit=0 set @Hit=(select max(hitag)+1 from Nomen);

    INSERT INTO Nomen (hitag,LastVendorsID)
    VALUES (@Hit,@VendorsID);

    select @Hit; 
END