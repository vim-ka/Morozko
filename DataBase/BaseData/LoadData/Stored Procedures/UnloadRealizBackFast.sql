CREATE PROCEDURE [LoadData].UnloadRealizBackFast @DateStart datetime, @DateEnd datetime, @Our_id int
AS
BEGIN

 --возвраты из программы продаж (A2)
 select pp.nd, pp.tm, pp.vk, pp.vkishod, pp.b_id,pp.hitag, SUM(pp.kol) kol,SUM(pp.sm) sm,pp.flag  
 from 
 (select c.nd,c.tm, c.datnom as vk, c.refdatnom as vkishod, 
        case when isnull(f.master,0)>0 then f2.upin else f.upin end as b_id, 
        v.hitag, 
        case when isnull(s.weight,0)=0 then -v.kol else -v.kol*s.weight end as kol, 
        -v.kol*v.price as sm, 
        case when isnull(c.Remark,'')='' then 1 else 0 end as flag 
 from nc c join nv v on c.datnom=v.datnom 
           join def f on c.b_id=f.pin           
           join visual s on v.tekid=s.id 
           left join def f2 on f.master=f2.pin 
 where c.nd>=@DateStart and c.nd<=@DateEnd and c.sp<0 and c.OurId=@Our_id) pp 
 group by pp.nd,pp.tm, pp.vk, pp.vkishod,pp.b_id,pp.hitag,pp.flag 
 order by pp.vk
 
END