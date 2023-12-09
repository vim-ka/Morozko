CREATE PROCEDURE CalcVedomPost @day1 datetime, @day2 datetime, @params int, @backprint int
AS
Declare @p1 int;
Declare @p2 int;
declare @nd datetime;
BEGIN

set @nd=dbo.today();

IF @backprint=0
BEGIN
  IF @params <= 2
  
   select c.date,
          c.pin,
          c.ncom,
          v.brName,
          c.doc_date,
          c.doc_nom,
          c.summacost,
          round(sum(iif(n.nds = 10, i.cost*i.kol/11,0)),2) nds10,
          round(sum(iif(n.nds = 18, 1.8*i.cost*i.kol/11.8,0)),2) nds18
   from comman c inner join def v ON c.pin=v.pin 
                 inner join inpdet i on c.ncom=i.ncom
                 inner join nomen n on i.hitag = n.hitag
   where (c.date between @day1 and @day2)
         --and (  (v.refncod = 0  and @params<>1) 
         --    or (v.refncod <> 0 and @params=1))   
         and ((LOWER(v.brName) LIKE '%/холод%' and @params=2)
              or (LOWER(v.brName) NOT LIKE '%/холод%' and @params<>2))
   group by c.date,
            c.pin,
            c.ncom,
            v.brName,
            c.doc_date,
            c.doc_nom,
            c.summacost
   order by c.date, v.brName;
  
  ELSE
  IF @params=3
     select c.date,
          c.pin,
          c.ncom,
          v.brName,
          c.doc_date,
          c.doc_nom,
          c.summacost,
          round(sum(iif(n.nds = 10, i.cost*i.kol/11,0)),2) nds10,
          round(sum(iif(n.nds = 18, 1.8*i.cost*i.kol/11.8,0)),2) nds18
   from comman c inner join def v ON c.pin=v.pin 
                 inner join inpdet i on c.ncom=i.ncom
                 inner join nomen n on i.hitag = n.hitag
   where (c.date between @day1 and @day2)
         --and v.refncod = 0 and (LOWER(v.fam) NOT LIKE '%/холод%')
         and ((select sum(c3.summacost + c3.izmen - c3.plata + c3.remove + c3.corr) from comman c3
        where c3.ncod=v.ncod and c3.date + c3.srok < @nd) <> 0)
   group by c.date,
            c.pin,
            c.ncom,
            v.brName,
            c.doc_date,
            c.doc_nom,
            c.summacost
   order by c.date, v.brName;
   
END ELSE
BEGIN
 
IF @params <= 2
  
   select c.date,
          c.pin, 
          c.ncom,
          v.brName,
          c.doc_date,
          c.doc_nom,
          c.summacost,
          round(sum(iif(n.nds = 10, i.cost*i.kol/11,0)),2) nds10,
          round(sum(iif(n.nds = 18, 1.8*i.cost*i.kol/11.8,0)),2) nds18
   from comman c inner join def v ON c.pin=v.pin 
                 inner join inpdet i on c.ncom=i.ncom
                 inner join nomen n on i.hitag = n.hitag
   where (c.date between @day1 and @day2)
        -- and (  (v.refncod = 0  and @params<>1) 
        --     or (v.refncod <> 0 and @params=1))   
         and ((LOWER(v.brName) LIKE '%/холод%' and @params=2)
              or (LOWER(v.brName) NOT LIKE '%/холод%' and @params<>2))
   group by c.date,
            c.pin,
            c.ncom,
            v.brName,
            c.doc_date,
            c.doc_nom,
            c.summacost
   order by  c.pin, c.date;
  
  ELSE
  IF @params=3
     select c.date,
          c.pin,
          c.ncom,
          v.brName,
          c.doc_date,
          c.doc_nom,
          c.summacost,
          round(sum(iif(n.nds = 10, i.cost*i.kol/11,0)),2) nds10,
          round(sum(iif(n.nds = 18, 1.8*i.cost*i.kol/11.8,0)),2) nds18
   from comman c inner join def v ON c.ncod=v.ncod 
                 inner join inpdet i on c.ncom=i.ncom
                 inner join nomen n on i.hitag = n.hitag
   where (c.date between @day1 and @day2)
       --  and v.refncod = 0 and (LOWER(v.fam) NOT LIKE '%/холод%')
         and ((select sum(c3.summacost + c3.izmen - c3.plata + c3.remove + c3.corr) from comman c3
        where c3.ncod=v.ncod and c3.date + c3.srok < @nd) <> 0)
   group by c.date,
            c.pin,
            c.ncom,
            v.brName,
            c.doc_date,
            c.doc_nom,
            c.summacost
   order by  c.pin, c.date;
   
 /* ELSE
  
   select c.*, v.*, 
   round((select sum(i.cost*i.kol)/11 from inpdet i, nomen n 
   where n.hitag = i.hitag and n.nds = 10 and i.ncom = c.ncom),2) nds10,
   round((select 1.8*sum(i.cost*i.kol)/11.8 from inpdet i, nomen n 
   where n.hitag = i.hitag and n.nds = 18 and i.ncom = c.ncom),2) nds18
   from comman c inner join vendors v ON c.ncod=v.ncod 
   where (c.date between @day1 and @day2) --and (c.ncod <> @ncod) 
   order by c.ncod, date;
   */ 
END


END