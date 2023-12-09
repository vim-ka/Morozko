create procedure ListNakl @ND datetime
as
declare @n0 int
declare @n1 int 
begin 
set @n0=dbo.InDatNom(1,@ND)
set @n1=(select max(DatNom) from NC where datnom<=@n0+9998);

end;