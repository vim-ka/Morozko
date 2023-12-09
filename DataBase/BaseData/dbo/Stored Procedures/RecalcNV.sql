CREATE PROCEDURE dbo.RecalcNV
AS
BEGIN
  declare @costsell decimal(15,5), @pricesell decimal(12,2), @datnom int, @tekid int, @weight decimal(10,3)
  

  declare c1 cursor local fast_forward
  
  for
  select distinct v1.cost/i1.weight as costsell,v1.price/i1.weight as pricesell,j.datnom, j.tekid, j.weight
  from nv_join j join tdvi i on j.tekid=i.id
               join visual i1 on j.reftekid=i1.id
               join nv v on j.datnom=v.datnom and j.tekid=v.tekid
               join nv v1 on j.refdatnom=v1.datnom and j.reftekid=v1.tekid
  where (abs(v.price/i.weight-v1.price/i1.weight)>1.0 or abs(v.cost/i.weight-v1.cost/i1.weight)>1.0) and i.weight<>0 and i1.weight<>0
  
  union
  
  select distinct v1.cost/i1.weight as costsell,v1.price/i1.weight as pricesell,j.datnom, j.tekid, j.weight
  from nv_join j join visual i on j.tekid=i.id
               join visual i1 on j.reftekid=i1.id
               join nv v on j.datnom=v.datnom and j.tekid=v.tekid
               join nv v1 on j.refdatnom=v1.datnom and j.reftekid=v1.tekid
  where (abs(v.price/i.weight-v1.price/i1.weight)>1.0 or abs(v.cost/i.weight-v1.cost/i1.weight)>1.0) and i.weight<>0 and i1.weight<>0
  
  open c1;
  fetch next from c1 into @costsell, @pricesell, @datnom, @tekid, @weight;
  
  while (@@FETCH_STATUS=0)
  begin
    insert into nv_161028 (datnom, tekid, oldprice, newprice, oldcost, newcost)
    select @datnom, @tekid, v.price, @pricesell*@weight, v.cost,@costsell*@weight
    from nv v where v.datnom=@datnom and v.tekid=@tekid
  
    update nv set cost=@costsell*@weight, price=@pricesell*@weight
    where datnom=@datnom and tekid=@tekid
  
    exec [dbo].RecalcNCSumm @datnom
    
    fetch next from c1 into @costsell, @pricesell, @datnom, @tekid, @weight;
  end
  
  close c1;
  deallocate c1;
  
END