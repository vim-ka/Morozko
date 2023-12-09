create procedure RecalcTodaySell
AS
begin
  create table #t(tekid int, sell int);
  
  insert into #t
    select nv.tekid, sum(nv.kol)
    from nc inner join nv on nv.datnom=nc.DatNom
    where nc.nd=dbo.today()
    group by nv.tekid;
  
  update tdvi set sell=isnull(#t.sell,0)
  from tdvi left join #t on #t.tekid=tdvi.ID;

  drop table #t;
end;