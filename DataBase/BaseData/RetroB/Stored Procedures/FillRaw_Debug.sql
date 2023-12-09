CREATE procedure [RetroB].FillRaw_Debug @vedID int
as
declare @day0 datetime, @day1 datetime
begin
  delete from [retrob].Rb_RAW where vedID=@vedID;

  select @day0=day0, @day1=day1 from [retrob].rb_Vedom where vedID=@vedID;

  -- Дергаю все выплаты:
  create table #k (datnom int, Pay decimal(12,2));
  
  insert into #k 
  select k.sourdatnom, sum(k.Plata) as Pay
  from dbo.kassa1 k 
  where 
    k.oper=-2 and k.actn=0
    and   
    (
      (k.bankday is null and k.nd between @day0 and @day1 )
      or (k.bankday is not null and k.bankday between @day0 and @day1)
    ) 
  group by k.sourdatnom  
  create index temp_rbcalcK_idx on #k(DatNom);
   
  -- Теперь список расходных накладных:
  
  create table #t(DatNom int);
  
  insert into #t
    select datnom from nc 
    where b_id>0 
    and nd between @day0 and @day1 
    and Actn=0 and Frizer=0 and Tara=0
  UNION
    select distinct #k.datnom 
    from #k inner join nc on nc.datnom=#k.datnom
    where nc.Actn=0 and nc.Frizer=0 and nc.tara=0;
    
  create index temp_rbcalcT_idx on #t(datnom);
  
  create table #R(  
    [datnom] int NOT NULL,
    tekid int,
    [b_id] int NULL,
    [Master] int NULL,
    [Kol] int NULL,
    [Cost] decimal(15, 5) NULL,
    [Nds] decimal(4, 1),
    [Price] decimal(15, 5) NULL,
    [PayKoeff] decimal(15, 10) default 0,
    [Ncod] int NOT NULL,
    [Hitag] int NOT NULL,
    [Ngrp] int NOT NULL,
    [MainParent] int NOT NULL,
    [DCK] int NULL,
    [Ag_ID] int NULL,
    [Sv_ID] int NULL,
    [DepID] smallint NULL, Our_ID smallint );

  insert into #R(datnom, tekid, b_id,master,Hitag, Kol,Cost,Nds,Price,
    PayKoeff, Ncod, Ngrp, MainParent, dck, ag_id, sv_id, depid, Our_ID) 
  select
    nv.DatNom, nv.tekid, nc.b_id, def.master,
    nv.hitag,
    sum(nv.kol) as Kol,
    sum(nv.kol*nv.cost)/sum(nv.kol) as Cost,
    nm.nds,
    sum(nv.kol*nv.Price*(1.0+nc.extra/100.0))/sum(nv.kol) as Price,
    iif(nc.sp=0, 1.0,  #k.Pay/nc.sp) as PayKoeff,
    v.ncod,
    nm.ngrp, gr.MainParent,
    nc.dck, dc.ag_id, A.sv_ag_id,  A.DepID, NC.OurID  
  from
    #t
    inner join nv on nv.datnom=#t.datnom
    inner join nc on nc.datnom=nv.datnom and nc.b_id>0
    left join Defcontract DC on DC.DCK=nc.DCK and nc.dck>0
    left join agentlist A on A.ag_id=dc.ag_id and DC.ag_id>0
    inner join Nomen nm on nm.hitag=nv.hitag
    inner join visual v on v.id=nv.tekid
    inner join gr on gr.Ngrp=nm.ngrp
    inner join def on def.pin=nc.b_id
    left join #k on #K.datnom=#t.datnom
  group by
    nv.DatNom, nv.tekid, nc.b_id, def.master,
    nm.nds,  
    v.ncod, nv.hitag, nm.ngrp, gr.MainParent,nc.sp,nc.extra, #k.pay,
    nc.dck, dc.ag_id, A.sv_ag_id,  A.DepID, nc.OurID
  having sum(nv.kol)<>0
  order by nv.DatNom;

select top 100 * from #r;
select count(*) from #r;


/*

  insert into [retrob].Rb_RAW(vedId, datnom, tekid, b_id,master,Hitag, Kol,Cost,Nds,Price,
    PayKoeff, Ncod, Ngrp, MainParent, dck, ag_id, sv_id, depid, Our_ID) 
  SELECT @vedID,datnom, tekid, b_id,master,Hitag, Kol,Cost,Nds,Price,
    isnull(PayKoeff,0) as PayKoeff, Ncod, Ngrp, MainParent, dck, ag_id, sv_id, depid, Our_ID
  from #R;
*/

end