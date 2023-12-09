CREATE PROCEDURE [ELoadMenager].Eload_BuhStat
@nd1 datetime,
@nd2 datetime,
@our_id int,
@isGroup bit
AS
BEGIN
	declare @dn1 int
  declare @dn2 int
  
  set @dn1 = dbo.InDatNom(0000, @nd1)
	set @dn2 = dbo.InDatNom(9999, @nd2)       
  
  select t.mainparent [КодКатегории],
       t.MainParentName [Категория],
       sum(sm) [Сумма продажи, руб.],
       sum(sc) [Сумма закупки, руб.],
       sum(Ves) [Вес, кг],
       ost.ostatki [Остатки, кг]
  from (select g.mainparent,
           		 (select grpname from gr where ngrp = g.mainparent) as MainParentName,
           		 g.grpname,
           		 sum((v.kol - v.kol_b)*v.price) as sm,
           		 sum((v.kol - v.kol_b)*v.cost) as sc,
           		 sum((v.kol - v.kol_b)*(case when s.weight > 0 then s.weight else n.netto end)) as Ves 
        from nv v 
        left join nomen n on v.hitag = n.hitag 
        left join gr g on g.ngrp = n.ngrp 
        left join (select id, isnull(weight, 0) as weight from visual) s on s.id = v.tekid
        join nc c on c.datnom = v.datnom
        join FirmsConfig fc on fc.our_id=c.gpOur_ID
      	where c.DatNom between @dn1 and @dn2 
             	and v.kol>0 
              and n.ngrp<>0 
              and (fc.Our_id=iif(@isGroup=1,fc.Our_id,@our_id) or @our_id=-1)
              and (fc.FirmGroup=iif(@isGroup=1,@our_id,fc.FirmGroup) or @our_id=-1)
              and g.AgInvis=0 
        group by g.grpname, g.mainparent) t
  left join (select r.mainparent, 
  					 sum(d.mornrest *( case when d.weight > 0 then d.weight else n.netto end)) as ostatki
  					 from MorozArc.dbo.ArcVI d, nomen n, gr r 
  					 where d.hitag = n.hitag 
  								 and r.ngrp = n.ngrp 
        					 and d.workdate=@nd2 
        		 group by r.mainparent) ost on t.MainParent = ost.MainParent
  group by t.MainParent,
           t.MainParentName,
           ost.ostatki  
END