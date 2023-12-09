CREATE PROCEDURE warehouse.terminal_GetZakazList
@nd datetime,
@skladlist varchar(1000),
@mhid int, -- от 0 до 1000 - регионы, -1 - все накладные, остальные mhid из nc
@Type int, -- 0 необрботанные, 1 все
@nzID int 
with recompile
AS
BEGIN
if @nzID<>0
begin
	select z.nzid,
         z.datnom % 10000 [nNak],
         z.hitag,
         n.name+iif(z.done=1 and z.id=0,' {'+iif(z.zakaz<0,'Разобрать',z.remark)+'}','') [name],
         z.zakaz,
         z.Zakaz*isnull(n.netto,1) [KG],
         isnull(z.curWeight,0) [isKG],
         z.Done,
         0 [color],
         iif(n.flgWeight=1,'[В]','[Ш]')+'['+cast(n.hitag as varchar)+']'+'['+cast(isnull(n.netto,'0') as varchar)+'кг]'+'['+isnull(n.barcode,'<..>')+']' [descr],
         '' [pinName],
         n.flgWeight,
         z.done,
         n.barcode,
         n.barcodeMinP,
         n.minp
  from morozdata.dbo.nvzakaz z
  join morozdata.dbo.nomen n on n.hitag=z.hitag
  where z.nzID=@nzID
  
  return
end

alter database MorozData set compatibility_level = 130

if object_id('tempdb..#skladlist') is not null drop table #skladlist
if object_id('tempdb..#nc') is not null drop table #nc
if object_id('tempdb..#nz') is not null drop table #nz
if object_id('tempdb..#mx') is not null drop table #mx
create table #skladlist (id int)

insert #skladlist
select value 
from string_split(@skladlist,',')

select * 
into #mx
from warehouse.sklad_max_piece

select c.datnom,
			 c.mhid,
       c.b_id,
       d.brName,
       sr.sregName [reg],
       sr.sregionID [ord],
       cast(iif(a.depid=3,1,0) as bit) [isNet]
into #nc       
from morozdata.dbo.nc c
join morozdata.dbo.defcontract dc on dc.dck=c.dck
join morozdata.dbo.agentlist a on a.ag_id=dc.ag_id
join morozdata.dbo.def d on d.pin=c.b_id
join morozdata.dbo.regions r on r.reg_id=d.reg_id
left join morozdata.warehouse.skladreg sr on sr.sregionID=r.sregionID
left join morozdata.dbo.marsh m on m.mhid=c.mhid
where c.nd=@nd
			and c.mhID=iif(@mhid=-1 or @mhid between 0 and 1000 or @mhid=-99 and m.selfship=1,c.mhid,@mhid)
      and sr.sRegionID=iif(@mhid between 0 and 1000,@mhid,sr.sRegionID)

select z.* 
into #nz
from morozdata.dbo.nvzakaz z
join #skladlist s on s.id=z.skladno
join #nc c on c.datnom=z.datnom
where z.done=iif(@type=0,0,z.done)

delete from #nc where not #nc.datnom in (select datnom from #nz)
        
select  row_number() over(order by iif([ord]=0,999,[ord])+iif(x.[isNet]=0,1000,0),[nNak],iif(Zkz<0,0,1),name) [rowID],
				* 
from (
  select z.nzid,
         z.datnom % 10000 [nNak],
         z.hitag [info],
         iif(z.skladno=556,'[БРАК] ','')+n.name+iif(z.done=1 and z.id=0,' {'+iif(z.zakaz<0,'Разобрать',z.remark)+'}','') [name],
         z.zakaz [zkz],
         z.Zakaz*isnull(n.netto,1) [KG],
         isnull(z.curWeight,0) [gain_KG],
         z.Done [marker],
         0 [color],
         iif(n.flgWeight=1,'[В]','[Ш]')+'['+cast(n.hitag as varchar)+']'+'[~'+convert(varchar,n.netto,0)+'кг]'+'['+iif(len(isnull(n.barcode,''))=0,'НЕТ ШК',n.barcode)+']'+'[М'+convert(varchar,isnull(#mx.weight,0),0)+']' [descr],
         iif(c.[isNet]=1,'@','')+'['+c.reg+']'+cast(b_id as varchar)+', '+brName [pinName],
         n.flgWeight,
         z.done,
         n.barcode,
         n.barcodeminp,
         n.minp,
         c.ord,
         c.[isNet]
  from #nz z
  join #nc c on c.datnom=z.datnom
  left join #mx on #mx.sklad=z.skladno and #mx.hitag=z.hitag
  join morozdata.dbo.nomen n on n.hitag=z.hitag  
  ) x

if object_id('tempdb..#skladlist') is not null drop table #skladlist
if object_id('tempdb..#nc') is not null drop table #nc
if object_id('tempdb..#nz') is not null drop table #nz
if object_id('tempdb..#mx') is not null drop table #mx
END