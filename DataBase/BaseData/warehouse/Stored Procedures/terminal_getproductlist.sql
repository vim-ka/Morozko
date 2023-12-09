CREATE procedure warehouse.terminal_getproductlist
@reqid int,
@type int, --тип 0- накладная, 1- возврат, 2- приход, 3 - проверка товара
@rowid int,
@sklads varchar(max) =''
as
begin
	set nocount on
  declare @reg varchar(3)
  declare @hitag int
  if object_id('tempdb..#skl') is not null drop table #skl
	create table #skl (sklad int)
	create nonclustered index skl_idx on #skl(sklad)
  if isnull(@sklads,'')='' insert into #skl select skladno from dbo.skladlist where upweight=1 or @type<>0
	else insert into #skl select value from string_split(@sklads,',')
    
  if object_id('tempdb..#product') is not null drop table #product
  create table #product (reqid int not null, rowid int not null, hitag int not null, name varchar(100), descr varchar(500),
  											 qty DECIMAL(15,3) not null, zakaz_kg decimal(15,3) not null, gain_kg decimal(15,3), barcode varchar(20), barcodeminp varchar(20),
                         sklad int, done bit, remark varchar(100), iscancel bit not null default 0, flgweight bit not null default 0, capt varchar(50),
                         quality int, dater datetime, withoutDate bit, minp int, shelflife int, srokh datetime, mhid int)
  create nonclustered index product_idx on #product(reqid)                         
  create nonclustered index product_idx1 on #product(rowid)
  
  if @type=0
  begin
  --набор накладной
 		select @reg=iif(c.mhid>0 and m.mhid is not null, cast(m.marsh as varchar),s.sregname)
    from dbo.nc c 
    join dbo.def d on d.pin=c.b_id
    join dbo.regions r on r.reg_id=d.reg_id
    join warehouse.skladreg s on s.sregionid=r.sregionID
    left join dbo.marsh m on m.mhid=c.mhid
    where c.datnom=@reqid
  
    insert into #product 
    select z.datnom, z.nzid, z.hitag, n.name, 
    			 /*iif(n.flgWeight=1, '[В]', '[Ш]')*/ --ед. изм.
           '[' + u.UnitName + ']'
           + '[' + cast(n.hitag as varchar) + ']' 
           + '[~' + convert(varchar, n.netto, 0) + 'кг]'
           + '[' + iif(len(isnull(n.barcode, '')) = 0, 'НЕТ ШК', n.barcode) + ']' 
           + '[М' + convert(varchar, isnull(mp.weight, 0), 0) + ']',

    			 z.zakaz, 
           --z.zakaz * n.netto, 
           --z.curWeight, 
           dbo.getQTY(z.hitag, z.UnID, z.zakaz, 1),       --в КГ
           z.confKol, --набрано
           n.barcode, n.barcodeMinP, z.skladno, z.done, z.remark, 
           cast(iif(patindex('%@Cancel',z.comp)<>0 and z.done=1,1,0) as bit),
           n.flgWeight, '['+@reg+'] ' + cast(z.datnom % 10000 as varchar) [capt],1, null, 0, n.minp, n.ShelfLife, null, 0
    from dbo.nvzakaz z 
    join #skl on #skl.sklad = z.skladNo
    join dbo.nomen n on n.hitag = z.hitag
    left join warehouse.sklad_max_piece mp on mp.sklad = z.skladno and mp.hitag = z.hitag
    LEFT JOIN units u ON z.unID = u.UnID
    where z.datnom = @reqid and z.nzid = iif(@rowid = 0, z.nzid, @rowid)
  end
  -------------------------------------------------------------------------------------------------------------------------------------------------
  if @type=1
  begin
  --обработка возврата
  	if @rowid>0
    select @hitag=hitag from dbo.reqreturndet where id=@rowid
  
    insert into #product 
    select r.reqretid, r.id, r.hitag, n.name, 
    			 --iif(n.flgWeight=1, '[В]', '[Ш]')
           '[' + cast(n.hitag as varchar) + ']' 
           + '[~' +convert(varchar, n.netto, 0) + 'кг]'
           + '[' + iif(len(isnull(n.barcode, '')) = 0, 'НЕТ ШК', n.barcode) + ']',
    			 r.kol, r.fact_weight, r.fact_weight2, n.barcode, n.barcodeMinP, r.Sklad, r.done, '', 
           iif(r.done=1 and r.fact_kol2=0 and r.fact_weight2=0, 1, 0),
           n.flgWeight, cast(t.reqnum as varchar) [capt], r.rqID, r.fact_srokh, r.non_srokh, n.minp, n.ShelfLife, null,t.mhid
    from dbo.reqreturndet r 
    join dbo.ReqReturn t on t.reqnum=r.reqretid 
    join dbo.nomen n on n.hitag=r.hitag
    where r.reqretid = @reqid 
    			and r.hitag = iif(@rowid=0, r.hitag, @hitag)
  end
  
  if @type=2
  begin
  --обработка прихода
  	select @hitag = prihodrdethitag from dbo.prihodreqdet where prihodrdetid=@rowid  
  	insert into #product
    select d.prihodrid, d.prihodrdetid, d.prihodrdethitag, n.name,
    			 --iif(n.flgWeight=1, '[В]', '[Ш]')
           '[' + cast(n.hitag as varchar) + ']'
           + '[~'+convert(varchar, n.netto, 0) + 'кг]' 
           + '['+iif(len(isnull(n.barcode, '')) = 0, 'НЕТ ШК', n.barcode) +']' 
           + iif(n.minp=1, '', '[П' + cast(n.minp as varchar) + ']'),
           cast(warehouse.get_qty_from_str(d.prihodrdetkolstr_plan,n.minp,n.flgWeight) as int), 
           warehouse.get_qty_from_str(d.prihodrdetkolstr_plan,n.minp,n.flgWeight), 
           iif(d.sklad_done=0, 0, iif(n.flgweight = 1, isnull(d.prihodrdetweigth, 0)*d.prihodrdetkol, d.prihodrdetkol)), n.barcode, 
           n.barcodeMinP, d.prihodrdetskladid, d.sklad_done, '', iif(d.sklad_done=0 and d.prihodrdetkol=0 and d.prihodrdetweigth=0,1,0),
           n.flgWeight, cast(d.prihodrid as varchar) [capt], 1, d.prihodrdetdate, 0, n.minp, n.ShelfLife, d.prihodrdetsrokh, 0
    from dbo.prihodreqdet d
    join dbo.nomen n on n.hitag=d.prihodrdethitag
    where d.prihodrid=@reqid
    			and d.prihodrdethitag=iif(@rowid=0,d.prihodrdethitag,@hitag)
  end
  
  if @type=3
  begin
  --обработка проверки товара
  	insert into #product
    select v.datnom, v.nvid, v.hitag, n.name,
    			 --iif(n.flgWeight=1, '[В]', '[Ш]')
           '[' + cast(n.hitag as varchar) + ']' + '[~' + convert(varchar,n.netto,0) + 'кг]'
           + '['+iif(len(isnull(n.barcode, '')) = 0, 'НЕТ ШК', n.barcode) + ']' 
           + iif(n.minp=1, '', '[П' + cast(n.minp as varchar) + ']'), 
           v.kol, 
           --v.kol*iif(n.flgweight=1, isnull(t.weight,s.weight), n.netto), 
           dbo.getQTY(v.hitag, v.UnID, v.kol, 1),       --в КГ
           iif(n.flgWeight=1, m.kol/1000.0, m.kol), 
           n.barcode, n.barcodeMinP, v.sklad, 
           /*
           cast(iif(n.flgweight=1, iif(isnull(t.weight, s.weight)*v.kol-m.kol/1000.0 = 0, 1, 0),
                                   iif(m.kol-v.kol=0, 1, 0)) as bit), 
           */
           cast((iif(m.kol - dbo.getQTY(v.hitag, v.UnID, v.kol, 1) = 0, 1, 0)) as bit),   --done
          
           '', 0, n.flgweight,
           cast(v.datnom % 10000 as varchar) + ', ' + cast(c.b_id as varchar) + '#' + c.fam,
           0, null, 0, n.minp, n.shelflife, null, c.mhid
    from dbo.nc c 
    join dbo.nv v with (nolock, index(nv_datnom_idx)) on v.datnom=c.datnom
    join #skl on #skl.sklad=v.sklad
    join dbo.nomen n on n.hitag=v.hitag
    left join dbo.tdvi t on t.id=v.tekid
    left join dbo.visual s on s.id=v.tekid
    left join (select mhid,datnom,hitag,sum(kol) [kol] 
                 from warehouse.sklad_mobiletermdata 
                group by mhid,datnom,hitag) m 
           on m.mhid=c.mhid and m.datnom=v.datnom and m.hitag=v.hitag
    where v.datnom=@reqid and v.kol>0 and c.sp>0
    			and v.nvid=iif(@rowid=0,v.nvid,@rowid)
  end
  
  select * from #product order by done,name 
  if object_id('tempdb..#product') is not null drop table #product
  if object_id('tempdb..#skl') is not null drop table #skl
  set nocount off
end