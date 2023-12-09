CREATE PROCEDURE dbo.CalcVendMonth  @ND datetime
AS
BEGIN
  Declare @DatNom int, @DatNom2 int, @SDate varchar(5)
  
  
 
  set @DatNom =dbo.InDatNom(0,DATEADD(day,-day(@ND)+1,@ND))
  set @DatNom2 = dbo.InDatNom(0,DATEADD(day,-day(DATEADD(MONTH,1,@ND))+1,DATEADD(MONTH,1,@ND)))
  set @SDate=cast(Month(@ND) as Varchar)+'.'+Cast(Right(Year(@ND),2) as varchar)
  if len(@Sdate)=4 
    set @SDate='0'+@SDate;
--  select cast(Month(@ND) as Varchar)+'.'+Cast(YEAR(@ND) as varchar),@DatNom,@DatNom2
 insert into VendMonthSel
 select v.ncod ncod, @SDate ,
         v.hitag hitag,
         isnull(sum(nv.price*nv.kol*(1+nc.extra/100))/sum(nv.kol+0.01),0) price,
         
         isnull(sum(nv.cost*nv.kol*(1+nc.extra/100))/sum(nv.kol+0.01),0) cost,
         
         (select isnull(sum(n.kol),0) kol from nv n where n.DatNom>=@DatNom and n.DatNom<@DatNom2
         and n.hitag = v.hitag) as kol
  from visual v 
  LEFT OUTER JOIN nv ON v.id=nv.tekid 
  left outer join nc on nv.DatNom = nc.DatNom
  where v.ncod in (select vend.ncod from vendors vend where actual=1) and v.datepost>='20050101'
  group by v.hitag, v.ncod
  
  /*delete from VendMonthSel 
  where (Sale=0 or Sale is Null)*/
  
END