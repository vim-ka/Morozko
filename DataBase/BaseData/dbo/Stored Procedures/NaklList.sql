CREATE PROCEDURE dbo.NaklList @DateStart datetime, @DateEnd datetime, @pin int, @master int, @DCK int 
AS
BEGIN
  
  declare @AllContract bit, @AllNet bit, @DateTek date
  declare @dn0 bigint, @dn1 bigint
  
  if @DCK > 0 set @AllContract = 0; 
  else set @AllContract = 1;
  
  if @master > 0 set @AllNet = 1;
  else set @AllNet = 0;
  
  set @DateTek = convert(varchar, GETDATE(), 4)
  set @dn0 = dbo.InDatNom(00000, @DateStart)
  set @dn1 = dbo.InDatNom(99999, @DateEnd)  
 
  --SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED; 
  
  --begin transaction NaklList;

  select cast(RIGHT(NC.DatNom,4) as int)as DatNumber,
       nc.OurId,
       nc.Extra,
       nc.ND,
       nc.Frizer,
       nc.DatNom as Id,
       nc.Ck,
       nc.SP,
       nc.Srok,
       IsNull(nc.Back,0) as Back,
       case when Actn=0 then IsNull(nc.Fact,0)
             else IsNull(nc.Fact,0)+IsNull(nc.SP,0)
             end as Fact,
       IsNull(CC.Plata,0) as Plata,
       df.gpName +' '+dc.ContrName as gpName,
       case when IsNull(nc.Actn,0)=0 then
                 (IsNull(nc.SP,0)+ISNULL(nc.izmen,0) -IsNull(nc.Fact,0))
                 else 0 end as Duty,
       IsNull(nc.izmen ,0) as izmen,
       nc.B_Id,
       nc.DatNom,
       dc.Ag_id as brAg_id,
       IsNull(nc.Actn,0) as Actn,
       nc.ND+nc.Srok+3 as DSrok,
       nc.Fam,
       nc.ND+nc.Srok+1 as prSrok,
       nc.DCK
from nc join DefContract dc on dc.DCK=nc.dck
        join Def df on dc.pin=df.pin
        left join
        (select SourDatNom,Sum(Plata) as Plata, DCK from Kassa1 where nd=@DateTek group by SourDatNom, DCK) CC on nc.DCK=CC.DCK and nc.DatNom=CC.SourDatNom
where (nc.B_id=@pin or (nc.B_id in (select pin from Def where Master=@master) and @AllNet = 1))
      and (nc.DCK=@DCK  or (nc.DCK in (select dck from DefContract where DCKMaster=@DCK)) or @AllContract=1)
      and nc.DatNom>=@dn0 and nc.DatNom<=@dn1 and Tara=0 and Frizer=0
       
order by nc.nd desc, DatNumber desc

--commit transaction NaklList;

END