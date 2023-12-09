CREATE PROCEDURE [LoadData].UnloadCommBack @DateStart datetime, @DateEnd datetime, @our_id int
AS
BEGIN
 select i.nd as DATE,
       itm.tm as TIME,
       0 as VID,
       izm.izmID as CODE, 
       d.our_id as CODE_O,
       iif(d.contrtip=1, f.upin, fnew.upin) as CODE_K,
       i.dck as CODE_D,
       0 as CODE_PR,
       0 as KOM,
       v.hitag as CODE_N,
       iif(isnull(i.WEIGHT,0)<>0, i.weight-i.newweight, i.kol-i.newkol) as KOL,
       i.cost as CENA, 
       (i.kol-i.newkol)*i.cost as SUM,
       i.sklad as CODE_S,
       --i.izmID,
       iif(i.ncom < 0, 0, i.ncom) as CODE_COMM
from izmen i left join defcontract d on i.dck=d.dck 
             left join visual v on i.id=v.id
             left join def f on f.ncod=d.pin
             left join def fnew on fnew.pin=d.pin
             join 
            (select d.nd, d.dck, MIN(d.tm) as tm from izmen d where d.nd>=@DateStart and d.nd<=@DateEnd and d.act='Снят' group by d.nd, d.dck ) itm on itm.nd=i.nd and itm.dck=i.dck 
            join
            (select d.nd, d.dck, MIN(d.izmID) as izmid from izmen d where d.nd>=@DateStart and d.nd<=@DateEnd and  d.act='Снят' group by d.nd, d.dck ) izm on izm.nd=i.nd and izm.dck=i.dck
where i.nd>=@DateStart and i.nd<=@DateEnd and i.act='Снят' and d.our_id=@our_id and ServiceFlag=0
      and d.ContrTip=1
/*group by i.nd,
         d.our_id,
         iif(d.contrtip=1, f.upin, fnew.upin),
         i.dck,
         v.hitag,
         i.weight,
         i.newweight,
         i.kol,
         i.newkol,
         i.cost,
         i.sklad,
         i.ncom*/
order by code
END