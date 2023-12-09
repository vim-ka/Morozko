CREATE PROCEDURE LoadData.UnloadComm @DateStart datetime, @DateEnd datetime, @our_id int, @Ncom int=0
AS
BEGIN
  
  if @Ncom = 0 --выгрузка за период
  select 1 as VID,
       c.[date] as DATE,
       c.[time] as TIME, 
       c.ncom as CODE,
       c.our_id as CODE_O,
       c.doc_nom as inpsfnom,  
       c.doc_date as inpsfdate,
       c.tn_nom as inptnnom,
       c.tn_date as inptndate,
       (select d.upin from def d where d.ncod=c.ncod) as CODE_K,
       c.DCK as CODE_D,
       i.hitag as CODE_N,
       iif(isnull(i.weight,0)=0, i.kol, i.weight*i.kol) as KOL,
       i.cost as CENA,
       i.summacost as SUM,
       i.sklad as CODE_S,
       f.brINN
  from comman c join inpdet i on c.ncom=i.ncom
                left join defcontract d on c.dck=d.dck
                left join Def f on c.pin=f.pin
  where d.our_id=@our_id and c.[date]>=@DateStart and c.[date]<=@DateEnd 
  and d.ContrTip=1 -- только поставки с кодом договора 1 (поставщик) 
  and iif(isnull(i.weight,0)=0, i.kol, i.weight*i.kol)>0 and d.BnFlag=1
  order by c.[date],c.ncom 
  
  else --выгрузка выбранного поступления
  
  select 1 as VID,  
       c.[date] as DATE,
       c.[time] as TIME, 
       c.ncom as CODE,
       c.our_id as CODE_O,
       c.doc_nom as inpsfnom,  
       c.doc_date as inpsfdate,
       c.tn_nom as inptnnom,
       c.tn_date as inptndate,
       (select d.upin from def d where d.ncod=c.ncod) as CODE_K,
       c.DCK as CODE_D,
       i.hitag as CODE_N,
       iif(isnull(i.weight,0)=0, i.kol, i.weight*i.kol) as KOL,
       i.cost as CENA,
       i.summacost as SUM,
       i.sklad as CODE_S,
       f.brINN
  from comman c join inpdet i on c.ncom=i.ncom
                left join defcontract d on c.dck=d.dck
                left join Def f on c.pin=f.pin
  where c.ncom=@Ncom and iif(isnull(i.weight,0)=0, i.kol, i.weight*i.kol)>0 

END