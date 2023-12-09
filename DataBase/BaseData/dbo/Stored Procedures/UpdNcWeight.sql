CREATE procedure dbo.UpdNcWeight @day0 datetime, @day1 datetime
as
declare @Nn0 bigint, @Nn1 bigint
begin
  set @Nn0=dbo.InDatNom(1,@day0);
  set @Nn1=dbo.InDatNom(99999,@day1);
  
  create table #w(datnom bigint, weight decimal(10,3));
 
  insert into #w(datnom, weight)
    select nv.DatNom, sum(nv.kol*(case when v.weight>0 then v.weight else N.netto END)) as Weight 
    from nv inner join Visual v on V.id=nv.TekID
    inner join Nomen N on N.hitag=v.hitag
    where nv.datnom between @Nn0 and @Nn1  
    group by nv.datnom;
      
  create clustered index w_idx on #w(DatNom);
  
  update NC 
    set NC.Weight=#w.weight
    from NC inner join #W on #W.datnom=nc.datnom;

  drop table #w;
end;