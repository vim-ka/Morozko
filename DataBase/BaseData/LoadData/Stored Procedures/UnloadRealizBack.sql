CREATE PROCEDURE LoadData.UnloadRealizBack @DateStart datetime, @DateEnd datetime, @our_id int, @datnom int=0, @FastBack bit=0, @pin int=0
AS
BEGIN
  declare @datnomStart int, @datnomEnd int
  
  set @datnomStart = dbo.InDatNom(0,@DateStart)
  set @datnomEnd = dbo.InDatNom(9999,@DateEnd)
   /*кол-во для возврта весового товара должно быть дробное*/ 

  if @datnom = 0 --выгрузка за период
  
    select nd, tm, vk, iif(isnull(nrefdatnom,0)>0,nrefdatnom, vkishod) as vkishod,b_id,hitag,SUM(kol) kol,SUM(sm) sm,SUM(seb) seb, flag, docnom, docdate,stfnom,stfdate, brINN
         
    from
    (select c.nd,
            c.tm,
            c.datnom as vk, 
            c.refdatnom as vkishod,
            c.docnom,
            c.docdate,
            c.stfdate,
            c.stfnom,
            iif((dc.NeedCK=1 or dc.BnFlag=1),iif(isnull(f.master,0)>0,f2.upin, f.upin),59579) as b_id,
            v.hitag,
            iif((dc.NeedCK=1 or dc.BnFlag=1),f.brINN, '366402584177') as brINN,
            case when isnull(s.weight,0)=0 then -v.kol
                 when isnull(s.weight,0)<>0 and n.flgWeight=0 then -v.kol*round(s.weight/n.netto,2)
                 else -v.kol*s.weight end as kol,
            iif((dc.NeedCK=1 or dc.BnFlag=1),-v.kol*v.price*(1.0+c.Extra/100.0),-round(v.kol*v.cost*1.01,2)) as sm,
            -v.kol*s.cost as seb,
            case when isnull(c.Remark,'')='' then 1 else 0 end as flag,
           (select cr.refdatnom from nc cr where cr.datnom=c.refdatnom and cr.sp>0) as nrefdatnom
  from nc c join nv v with(nolock, index(NV_Datnom_idx)) on c.datnom=v.datnom
            join def f on c.b_id=f.pin         
            join visual s on v.tekid=s.id
            left join def f2 on f.master=f2.pin --and f2.pin<>47900
            left join nomen n on v.hitag=n.hitag
            join defcontract dc on c.dck=dc.dck
  where c.datnom>=@datnomStart and c.datnom<=@datnomEnd and c.Actn<>1 and c.Frizer<>1 and c.Tara<>1 and c.STip not in (2,3,4) and
        c.sp<0 and c.OurId=@our_id and v.kol<>0
         --and (dc.NeedCK=1 or dc.BnFlag=1)
         --and (dc.NeedCK=0 and dc.BnFlag=0)
         and (c.b_id in (select pin from def where master=@pin or pin=@pin) or @pin=0)
         --and c.b_id in (44162)-- (57173,57808,59582,59575,58568,25205,50760,47363,50638)
         and ((isnull(c.Remark,'')='' and @FastBack=1) or (isnull(c.Remark,'')<>'' and @FastBack=0))) pp
  group by nd,tm, vk, docnom, docdate, stfdate, stfnom, vkishod,b_id,hitag,flag,nrefdatnom, brINN
  
  else --выгрузка всех возвратов к выбранной накладной  --выгрузка выбранного возврата 

   select nd, tm, vk, iif(isnull(nrefdatnom,0)>0,nrefdatnom, vkishod) as vkishod,b_id,hitag,SUM(kol) kol,SUM(sm) sm,SUM(seb) seb, flag, docnom, docdate,stfnom,stfdate, brINN
         
    from
    (select c.nd,
            c.tm,
            c.datnom as vk, 
            c.refdatnom as vkishod,
            c.docnom,
            c.docdate,
            c.stfdate,
            c.stfnom,
            iif((dc.NeedCK=1 or dc.BnFlag=1),iif(isnull(f.master,0)>0,f2.upin, f.upin),59579) as b_id,
            v.hitag,
            iif((dc.NeedCK=1 or dc.BnFlag=1),f.brINN, '366402584177') as brINN,
            case when isnull(s.weight,0)=0 then -v.kol
                 when isnull(s.weight,0)<>0 and n.flgWeight=0 then -v.kol*round(s.weight/n.netto,2)
                 else -v.kol*s.weight end as kol,
            iif((dc.NeedCK=1 or dc.BnFlag=1),-v.kol*v.price*(1.0+c.Extra/100.0),-round(v.kol*v.cost*1.01,2)) as sm,
            -v.kol*s.cost as seb,
            case when isnull(c.Remark,'')='' then 1 else 0 end as flag,
           (select cr.refdatnom from nc cr where cr.datnom=c.refdatnom and cr.sp>0) as nrefdatnom
  from nc c join nv v with(nolock, index(NV_Datnom_idx)) on c.datnom=v.datnom
            join def f on c.b_id=f.pin         
            join visual s on v.tekid=s.id
            left join def f2 on f.master=f2.pin --and f2.pin<>47900
            left join nomen n on v.hitag=n.hitag
            join defcontract dc on c.dck=dc.dck
  where c.refdatnom=@datnom and c.Actn<>1 and c.Frizer<>1 and c.Tara<>1 and c.STip not in (2,3,4) and
        c.sp<0 and c.OurId=@our_id and v.kol<>0
        and (c.b_id in (select pin from def where master=@pin or pin=@pin) or @pin=0)
         --and c.b_id in (44162)-- (57173,57808,59582,59575,58568,25205,50760,47363,50638)
         and ((isnull(c.Remark,'')='' and @FastBack=1) or (isnull(c.Remark,'')<>'' and @FastBack=0))) pp
  group by nd,tm, vk, docnom, docdate, stfdate, stfnom, vkishod,b_id,hitag,flag,nrefdatnom, brINN
  
 /* select nd, tm, vk, vkishod,b_id,hitag,SUM(kol) kol,SUM(sm) sm,SUM(seb) seb, flag, docnom, docdate,stfnom,stfdate 
  from
  (select c.nd,
          c.tm,
          c.datnom as vk,
          c.refdatnom as vkishod,
          c.docnom,
          c.docdate,
          c.stfdate,
          c.stfnom,
          case when isnull(f.master,0)>0 then f2.upin else f.upin end as b_id,
          v.hitag,
          case when isnull(s.weight,0)=0 then -v.kol
               when isnull(s.weight,0)<>0 and n.flgWeight=0 then -v.kol*round(s.weight/n.netto,2)
               else -v.kol*s.weight end as kol,
          -v.kol*v.price*(1.0+c.Extra/100.0) as sm,
          -v.kol*s.cost as seb,
          case when isnull(c.Remark,'')='' then 1 else 0 end as flag
  from nc c join nv v on c.datnom=v.datnom
            join def f on c.b_id=f.pin         
            join visual s on v.tekid=s.id
            left join def f2 on f.master=f2.pin 
            left join nomen n on v.hitag=n.hitag
  where c.datnom=@datnom and c.sp<0 and c.OurId=@our_id and v.kol<>0) pp
  group by nd,tm, vk, docnom, docdate, stfdate, stfnom, vkishod,b_id,hitag,flag*/
END