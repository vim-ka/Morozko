CREATE procedure dbo.CalcSourCost @idlist varchar(5000)
AS
BEGIN
  create table #t(id int, startid int, Weight0 decimal(10,3), Weight1 decimal(10,3), Cost0 decimal(12,5), CalcCost decimal(12,5), CalcCost1kg decimal(12,5))
  insert into #t(id) select K from dbo.Str2intarray(@idlist);

  update #t set #t.startid=v.startid from #t inner join tdvi v on v.id=#t.id;
  update #t set cost0=i.cost, weight0=i.weight  from #t inner join inpdet i on i.id=#t.startid;
  update #t set cost0=i.cost, weight0=i.weight  from #t inner join tdvi i on i.id=#t.startid where cost0 is null;

  if exists(select * from #t where startid is null) begin
    update #t set #t.startid=v.startid from #t inner join visual v on v.id=#t.id where #t.startid is null;
    update #t set cost0=i.cost, weight0=i.weight  from #t inner join visual i on i.id=#t.startid where #t.startid is null;
  end;

  update #t set weight1=v.weight from #t inner join tdvi v on v.id=#t.id;
  if exists(select * from #t where weight1 is null) 
    update #t set weight1=v.weight from #t inner join visual v on v.id=#t.id  where #t.weight1 is null;
    
  if exists(select * from #t where cost0 is null) 
    update #t set cost0=v.cost from #t inner join visual v on v.id=#t.startid  where #t.cost0 is null;

  if exists(select * from #t where weight0 is null) 
    update #t set weight0=v.weight from #t inner join visual v on v.id=#t.startid  where #t.weight0 is null;

  update #t set Calccost=Cost0 where weight0=0;
  update #t set Calccost=cost0*weight1/weight0 where weight1<>0 and weight0<>0;
  update #t set Calccost1kg=cost0/weight0 where weight0<>0;

  select id, CalcCost, CalcCost1kg  from #t order by id;


END