create procedure CalcAddSellAndBack @day0 datetime, @day1 datetime
AS
begin
  -- Все доппродажи в одну таблицу:
  create table #a (datnom int, op int, tekid int, hitag int, kol decimal(10,3));

  insert into #a(datnom, op, tekid,hitag,kol)
  select c.datnom, c.op, v.id, v.hitag, sum(v.newkol) as Kol
  from 
    ncedit C inner join nvEdit V on v.ncid=c.ncid
  where 
    C.nd between @Day0 and @Day1 and v.kol=0 and v.newkol>0
  group by c.datnom, v.id, c.op, v.id, v.hitag;

  -- Все возвраты в другую таблицу:
  create table #b(DatNom int, tekid int, kol_b decimal(10,3));
  insert into #B(DatNom,tekid,kol_b)
  select nc.RefDatNom as datnom, nv.tekid, sum(-nv.kol) as kol_b
  from nv inner join nc on nc.datnom=nv.datnom
  where 
    nc.refdatnom>0 and nc.nd between @day0 and @day1+2
    and nv.kol<0
  group by nc.RefDatNom, nv.tekid

  select #a.op, u.fio, #a.hitag, nm.[name], sum(#a.kol) as kol, sum(#b.kol_b) as kol_b 
  from 
    #a left join #b on #b.datnom=#a.datnom and #b.tekid=#a.tekid
    inner join Nomen nm on nm.hitag=#a.hitag
    inner join UsrPwd U on u.uin=#a.Op
  group by #a.op, u.fio, #a.hitag, nm.[name]
  order by #a.op, nm.[name]
end;