CREATE PROCEDURE [LoadData].CheckRealiz @DateStart datetime, @DateEnd datetime, @our_id int, @datnom int=0 --, @FastBack bit=0
AS
BEGIN
  set transaction isolation level read uncommitted
  declare @datnomStart int, @datnomEnd int
  
  set @datnomStart = dbo.InDatNom(0,@DateStart)
  set @datnomEnd = dbo.InDatNom(9999,@DateEnd)
  

  if @datnom = 0 --выгрузка за период
  
  select  t.vk,
          t.hitag,
          t.kol,
          t.tm,
          t.nd,
          t.b_id,
          isnull(t.stfnom,'') as stfnom,
          isnull(t.stfdate,'')as stfdate,
          t.price as cena,
          t.cost as seb,
          t.sm,
          t.nds
  from
  (select c.datnom as vk,
          c.tm,
          c.nd,
          case when isnull(d.master,0)>0 then f.upin else d.upin end as b_id,
          c.stfnom,
          c.stfdate,
          v.hitag,
          v.price*(1+c.extra/100) as price,
          v.cost,
          v.price*(1+c.extra/100)*(v.kol+
                  isnull((select sum(r.kol) from nv r join nc c1 on r.datnom=c1.datnom and v.tekid=r.tekid                                         
                                            where c1.refdatnom=c.datnom
                                            and isnull(c1.remark,'')='' and v.datnom=c1.refdatnom),0)
          ) as sm,
          (iif(isnull(s.weight,0)=0, v.kol, v.kol*s.weight)+
                  isnull((select sum(iif(isnull(i.weight,0)=0, r.kol,r.kol*i.weight)) from nv r join nc c1 on r.datnom=c1.datnom 
                                                      join visual i on r.tekid=i.id  
                  where c1.refdatnom=c.datnom
                  and isnull(c1.remark,'')='' and v.datnom=c1.refdatnom and r.tekid=v.tekid),0)
          ) as kol,
          n.nds
   from nc c join nv v on c.datnom=v.datnom
             join visual s on v.tekid=s.id 
             join def d on c.b_id=d.pin
             left join def f on d.master=f.pin
             join nomen n on v.hitag=n.hitag
 where c.datnom>=@datnomStart and c.Datnom<=@datnomEnd and c.ourid=@our_id and c.Sp>0 and c.Actn<>1 and c.Frizer<>1 and c.Tara<>1 and c.STip not in (2,3,4)
/* where c.datnom in
(1610140116		,
1610140598		,
1610140604		,
1610140660		,
1610174682		,
1610174695		,
1610174736		,
1610174875		,
1610174876		)
*/

 
  ) t
  order by vk, hitag
  
  else --выгрузка выбранного возврата
  
  select  t.vk,
          t.hitag,
          t.kol,
          t.tm,
          t.nd,
          t.b_id,
          isnull(t.stfnom,'') as stfnom,
          isnull(t.stfdate,'')as stfdate,
          t.price as cena,
          t.cost as seb,
          t.sm,
          t.nds 
  from
  (select c.datnom as vk,
          c.tm,
          c.nd,
          case when isnull(d.master,0)>0 then f.upin else d.upin end as b_id,
          c.stfnom,
          c.stfdate,
          v.hitag,
          v.price*(1+c.extra/100) as price,
          v.cost,
          v.price*(v.kol+
                  isnull((select sum(r.kol) from nv r join nc c1 on r.datnom=c1.datnom and v.tekid=r.tekid                                         
                                            where c1.refdatnom=c.datnom
                                            and isnull(c1.remark,'')='' and v.datnom=c1.refdatnom),0)
          ) as sm,
          (iif(isnull(s.weight,0)=0, v.kol, v.kol*s.weight)+
                  isnull((select sum(iif(isnull(i.weight,0)=0, r.kol, r.kol*i.weight)) from nv r join nc c1 on r.datnom=c1.datnom 
                                                                                           join visual i on r.tekid=i.id
                  where c1.refdatnom=c.datnom
                  and isnull(c1.remark,'')='' and v.datnom=c1.refdatnom and r.tekid=v.tekid),0)
          ) as kol,
          n.nds
   from nc c join nv v on c.datnom=v.datnom
             join visual s on v.tekid=s.id
             join def d on c.b_id=d.pin
             left join def f on d.master=f.pin
             join nomen n on v.hitag=n.hitag
  where c.datnom=@datnom and c.Sp>0 and  c.Actn<>1 and c.Frizer<>1 and c.Tara<>1 and c.STip not in (2,3,4)
  ) t
  order by vk, hitag
  

  
  
END