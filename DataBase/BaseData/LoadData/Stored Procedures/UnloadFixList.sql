CREATE PROCEDURE [LoadData].UnloadFixList @DateStart datetime, @DateEnd datetime, @Our_id int
AS
BEGIN
  /*****************************накладные исправленные - реестр***************************/

 select i.ncid as IDIspr, 
        i.nd as DATEISPR, 
        c.ND as DATE,  
        c.TM as TIME,  
        case when isnull(f.master,0)>0 then f2.upin else f.upin end as CODE_K,  
        c.datnom as CODE,
        i.sp,
        i.newsp,
        u.fio
  
 from ncedit i join nc c on i.datnom=c.datnom
               join def f on c.b_id=f.pin 
               join usrPwd u on i.op=u.uin
               left join def f2 on f.master=f2.pin
 where i.nd>=@DateStart and i.nd<=@DateEnd and c.OurId=@Our_id and c.Actn<>1 and c.Frizer<>1 and c.Tara<>1 and
       c.nd<>i.nd
 order by i.ncid
 
END