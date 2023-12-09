CREATE PROCEDURE dbo.MainPartnersList @Detail Bit=0, @Actual bit, @Bonus bit, @Holod bit, @Our_id varchar(50)='', 
                                      @BnFlg smallint=2, @Contrtip varchar(50)='', @Type smallint=0,
                                      @NDay datetime=null 
AS
BEGIN

  declare @nd datetime
  set @nd=dbo.today()
  
  if @NDay is null set @NDay=@nd

  if object_id('tempdb..#tOur_id') is not null drop table #tOur_id
  if object_id('tempdb..#tContrtip') is not null drop table #tContrtip
  if object_id('tempdb..#NeedDCK') is not null drop table #NeedDCK

    create table #tOur_id (Our_id int)
    create table #tContrtip (ContrTip int)

    if @Our_id = '' 
       insert into #tOur_id (Our_id)  
       select Our_id from FirmsConfig
    else 
      insert into #tOur_id (Our_id) 
      select K from dbo.Str2intarray(@Our_id)
    
    if @Contrtip = '' 
      insert into #tContrtip (ContrTip) 
      select Contrtip from DefContractTip
    else
      insert into #tContrtip (ContrTip) 
      select K from dbo.Str2intarray(@Contrtip)
      
   create table #NeedDCK (pin int, dck int, plata money) 
   
   insert into #NeedDCK (pin, dck, plata)
     
   select c.pin, c.dck,isnull(sum(k.plata),0)
   from defcontract c left join kassa1 k on k.oper=-1 and k.ND<=@Nday and k.Nnak = 0 and k.dck=c.dck  
   where c.ContrTip in (select ContrTip from #tContrTip) and c.Our_id in (select Our_id from #tOur_id)
   group by c.pin, c.dck
  


  if @Type=0
  BEGIN   
    if @Detail=0
    begin
      select v.pin as Ncod, 
             v.pin, 
             v.Master, 
             v.brName as fam,
             v.srok,
             0.0 as tnorm, -- v.tnorm,
             cast(0 as bit) as w, --v.w,
             cast(0 as bit) as nds, --v.nds,
             v.bnflg as bnFlag,
             v.contact,
             v.brPhone as Phone,
             cast(v.buh_ID as int) as buh_uin,
             0 as maxdaysOrd,-- v.maxDaysOrd,
             v.LastSver,
             max(c.date) LastInpDay, 
             --isnull(s.must,0) as must,
             isnull(sum(iif(c.date+c.srok<=@nd, c.summacost + c.izmen - c.plata + c.remove + c.corr,0)),0) as must,
             
             isnull(sum(c.summacost + c.izmen /*- c.plata*/ + c.remove + c.corr),0)- 
             (select sum(n.plata) from #NeedDCK n where n.pin=v.pin) /* sum(isnull(k.plata,0))*/
             saldo,
             isnull(g.ostat,0) ostat,
             isnull(g.OstatKG,0) as OstatKG,
             sum(c.realiz) realiz,
             0.0 as MinOrder,-- v.MinOrder
             u.fio,
             max(c.dck) as dck
      from Def v join #NeedDCK ct on ct.pin=v.pin
                 left join comman c on ct.DCK=c.dck and c.[date]<=@Nday
                 left join usrPwd u on v.buh_id=u.uin
                 outer apply
                 (select tv.pin, sum((tv.morn-tv.sell+tv.isprav-tv.remov)*(case when n.flgWeight=1 then tv.weight else n.netto end)) as OstatKG,
                         sum((tv.morn-tv.sell+tv.isprav-tv.remov)*tv.cost) as ostat
                  from tdVi tv join nomen n on tv.hitag=n.hitag 
                               join #NeedDCK e on e.dck=tv.dck                    
                  where tv.pin=v.pin 
                  group  by tv.pin
                  ) g 
                  /*outer apply
                  (select k.ncod, sum(k.plata) as plata from kassa1 k where k.oper=-1 and k.ND<=@Nday and  k.Nnak = 0 and k.ncod = v.ncod and k.dck=ct.dck group by ncod) k -- ncod>0 group by ncod) k on k.ncod = v.ncod*/
                      
      where (v.Master=0 OR v.Master = v.pin) 
            AND (v.actual = @Actual or v.actual = 1)  
           -- and (v.refncod = @Bonus or (v.refncod > 0 and @Bonus=1))
            and (((lower(v.brName) not like '%/холод%') and @Holod=0) or ((lower(v.brName) like '%/холод%') and @Holod=1))
          --  and (v.bnflag=@BnFlg or @BnFlg=2)
  --          and ( or ct.dck=0)
            
      group by v.pin, v.Master, v.brName, v.srok, v.bnflg,v.contact, v.brPhone,
               v.buh_ID, v.LastSver, u.fio, g.ostat, g.ostatkg
      order by v.brName ASC 
    END
    ELSE 
    BEGIN
      select v.pin as Ncod, 
             v.pin, 
             v.Master, 
             v.brName as fam,
             v.srok,
             0.0 as tnorm, -- v.tnorm,
             cast(0 as bit) as w, --v.w,
             cast(0 as bit) as nds, --v.nds,
             v.bnflg as bnFlag,
             v.contact,
             v.brPhone as Phone,
             cast(v.buh_ID as int) as buh_uin,
             0 as maxdaysOrd,-- v.maxDaysOrd,
             v.LastSver,
             max(c.date) LastInpDay, 
             --isnull(s.must,0) as must,
             isnull(sum(iif(c.date+c.srok<=@nd, c.summacost + c.izmen - c.plata + c.remove + c.corr,0)),0) as must,
             
             isnull(sum(c.summacost + c.izmen /*- c.plata*/ + c.remove + c.corr),0)- 
             (select sum(n.plata) from #NeedDCK n where n.pin=v.pin) /* sum(isnull(k.plata,0))*/
             saldo,
             isnull(g.ostat,0) ostat,
             isnull(g.OstatKG,0) as OstatKG,
             sum(c.realiz) realiz,
             0.0 as MinOrder,-- v.MinOrder
             u.fio,
             max(c.dck) as dck
      from Def v join #NeedDCK ct on ct.pin=v.pin
                 left join comman c on ct.DCK=c.dck and c.[date]<=@Nday
                 left join usrPwd u on v.buh_id=u.uin
                 outer apply
                 (select tv.pin, sum((tv.morn-tv.sell+tv.isprav-tv.remov)*(case when n.flgWeight=1 then tv.weight else n.netto end)) as OstatKG,
                         sum((tv.morn-tv.sell+tv.isprav-tv.remov)*tv.cost) as ostat
                  from tdVi tv join nomen n on tv.hitag=n.hitag 
                               join #NeedDCK e on e.dck=tv.dck                    
                  where tv.pin=v.pin 
                  group  by tv.pin
                  ) g 
                  /*outer apply
                  (select k.ncod, sum(k.plata) as plata from kassa1 k where k.oper=-1 and k.ND<=@Nday and  k.Nnak = 0 and k.ncod = v.ncod and k.dck=ct.dck group by ncod) k -- ncod>0 group by ncod) k on k.ncod = v.ncod*/
                      
      where v.Master>0
            AND (v.actual = @Actual or v.actual = 1)  
           -- and (v.refncod = @Bonus or (v.refncod > 0 and @Bonus=1))
            and (((lower(v.brName) not like '%/холод%') and @Holod=0) or ((lower(v.brName) like '%/холод%') and @Holod=1))
          --  and (v.bnflag=@BnFlg or @BnFlg=2)
  --          and ( or ct.dck=0)
            
      group by v.pin, v.Master, v.brName, v.srok, v.bnflg,v.contact, v.brPhone,
               v.buh_ID, v.LastSver, u.fio, g.ostat, g.ostatkg
      order by v.Master
      END

    SELECT 'Ncod' AS Ncod, 
           'pin' AS pin, 
           'Master' AS Master,  
           'Наименование юр.лица' AS fam,
           'Срок консигнации' AS srok,
           'tnorm' AS tnorm, 
           'w' AS w,
           'НДС' AS nds,
           'Безналичный расчет' AS bnflg,
           'Контактное лицо' AS contact,
           'Телефон юр.лица' as Phone,
           'buh_uin' AS buh_uin,
           'maxdaysOrd' as maxdaysOrd,
           'Дата последней сверки дебиторки' AS LastSver,
           'Дата последнего прихода' AS LastInpDay, 
           'must' as must,
           'Сальдо' AS saldo,
           'Остаток' AS ostat,
           'Остаток, кг' as OstatKG,
           'realiz' AS realiz,
           'MinOrder' AS MinOrder,
           'ФИО' as fio,
           'Номер договора' as dck

  end
  else --выгрузка договоров
  begin
  
     select v.pin as ncod,
            v.pin,   
            e.dck,
            e.contrname,
            e.srok,
            e.maxDaysOrder,
            max(c.date) LastInpDay, 
           (select isnull(SUM(cm.summacost + cm.izmen - cm.plata + cm.remove + cm.corr),0) from comman cm where cm.dck=e.dck and cm.date+cm.srok<=CURRENT_TIMESTAMP) must,
           isnull(SUM(c.summacost + c.izmen - c.plata + c.remove + c.corr),0) - isnull((select sum(plata) from kassa1 where kassa1.dck = e.dck and kassa1.Nnak = 0),0) saldo,
           (select sum((tv.morn-tv.sell+tv.isprav-tv.remov)*tv.cost) from tdVi tv where tv.dck=e.dck) ostat,
           isnull((select sum((tv.morn-tv.sell+tv.isprav-tv.remov)*tv.weight) from tdVi tv where isnull(tv.[WEIGHT],0)<>0 and tv.dck=e.dck),0)+
           isnull((select sum((tv.morn-tv.sell+tv.isprav-tv.remov)*n.netto) from tdVi tv, nomen n where isnull(tv.[WEIGHT],0)=0 and tv.dck=e.dck and tv.hitag=n.hitag),0) as ostatKG,
           sum(c.realiz) realiz,
           e.MinOrder MinOrder,
           f.ourName,
           e.our_id
      from Def v join #NeedDCK ct on ct.pin=v.pin
                     left join DefContract e on ct.dck=e.dck
                     left join comman c on e.dck=c.dck
                     left join firmsconfig f on e.our_id=f.our_id
      where e.actual=@Actual 
            --and e.Our_id in (select Our_id from #tOur_id) --and e.contrtip in (select ContrTip from #tContrTip)  
            --and c.dck=e.dck
      group by e.dck, v.pin, e.contrname,e.srok,e.maxDaysOrder,e.MinOrder,   f.ourName,  e.our_id
      order by v.pin
  end
 

END