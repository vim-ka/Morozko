CREATE procedure SaveSPE
  @day0 datetime,
  @day1 datetime
as
declare @n0 int, @n1 int  
begin
  set @n0=dbo.indatnom(1,@day0)
  set @n1=dbo.indatnom(9999,@day1)
  select nv.datnom, sum(nv.kol*nv.price*(1.0+nc.extra/100)*c.koeff) as SPE
  into #t001
  from nc inner join nv on nv.datnom=nc.datnom
  inner join Nomen nm on nm.hitag=nv.hitag
  inner join NomenCat c on c.ncid=nm.ncid
  where nv.datnom between @n0 and @n1
  group by nv.datnom
  order by nv.datnom;
  
  update NC set NC.SPE=(select #t001.spe from #t001 where #t001.datnom=nc.datnom)
  where nc.datnom between @n0 and @n1
  
  select count(*) from #t001
end
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Табл.NC прописывается поле SPE - сумма в ценах продажи с учетом корректирующих
коэффициентов Koeff из табл. NomenCat', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'SaveSPE';

