CREATE procedure dbo.FillBigPriceList
as
begin
  create table #t (b_id int, hitag int, datnom bigint);
 
  insert into #t 
  select nc.b_id, nv.hitag, max(nv.datnom) 
  from 
    nc 
    inner join nv on nv.datnom=nc.datnom
  where 
    nc.nd>=dbo.today()-122 and nc.nd<dbo.today()
    and nc.b_id>0
    and nv.kol>0 and nv.price>0 
  group by nc.b_id, nv.hitag;

  truncate table dbo.bigpricelist;

  drop index BigPriceList_idx ON MorozData.dbo.BigPriceList
  drop index BigPriceList_idx2 ON MorozData.dbo.BigPriceList;
 
  insert into bigpricelist(hitag,b_id,price,isWeight,Comp,Op,Saved)
  select 
    #t.hitag, 
    #t.b_id, 
    max(iif(nm.flgWeight=1 and v.weight>0, nv.Price/v.weight, nv.Price)) as Price,
    nm.flgWeight,
    nc.Comp,
    nc.op,
    nc.nd
  from
    #t
    inner join nc on nc.datnom=#t.datnom 
    inner join nv on nv.datnom=#t.datnom and nv.hitag=#t.hitag
    inner join visual v on v.id=nv.tekid
    inner join nomen nm on nm.hitag=#t.hitag
  group by #t.hitag, #t.b_id, 
    nm.flgWeight, nc.Comp, nc.op, nc.nd;

  CREATE CLUSTERED INDEX BigPriceList_idx
    ON MorozData.dbo.BigPriceList (Hitag, B_ID)
    ON [PRIMARY];
  
  CREATE INDEX BigPriceList_idx2
    ON MorozData.dbo.BigPriceList (Saved)
    ON [PRIMARY];

END