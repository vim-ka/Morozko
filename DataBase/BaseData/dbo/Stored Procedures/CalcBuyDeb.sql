CREATE PROCEDURE dbo.CalcBuyDeb @ND datetime
AS
BEGIN

 select a.b_id,a.balance,b.overd from
(select NC.b_id, (IsNull(sum(nc.Sp),0)-IsNull(sum(Ks.Sum),0)+IsNull(Sum(Iz.Sm),0)) as Balance
       
from NC

left join

(select sum(Plata) as Sum, ks.B_Id,ks.SourDatNom 
from Kassa1 ks
where nd<@ND and (ks.Act='ВЫ' or ks.Act='ВО')  and oper=-2 
group by ks.B_Id,ks.SourDatNom ) ks on ks.B_id=nc.B_Id and ks.SourDatNom=nc.DatNom

left join

(select sum(Izmen) as Sm,B_ID,DatNom
from NCIzmen iz
where iz.Datnom>501010000 and  iz.nd<@ND
group by iz.B_Id,DatNom) iz on iz.B_id=nc.B_Id and iz.DatNom=nc.DatNom
where nc.nd<@ND and Frizer!=1 and Actn!=1 and Tara!=1

group by nc.B_Id) a 

inner join

(select NC.b_id, (IsNull(sum(nc.Sp),0)-IsNull(sum(Ks.Sum),0)+IsNull(Sum(Iz.Sm),0)) as Overd
       
from NC

left join
(select sum(Plata) as Sum, ks.B_Id,ks.SourDatNom 
from Kassa1 ks
where nd<@ND and (ks.Act='ВЫ' or ks.Act='ВО')  and oper=-2 
group by ks.B_Id,ks.SourDatNom ) ks on ks.B_id=nc.B_Id and ks.SourDatNom=nc.DatNom

left join

(select sum(Izmen) as Sm,B_ID,DatNom
from NCIzmen iz
where iz.Datnom>501010000 and  iz.nd<@ND
group by iz.B_Id,DatNom) iz on iz.B_id=nc.B_Id and iz.DatNom=nc.DatNom
where nc.nd<@ND and Frizer!=1 and Actn!=1 and Tara!=1
      and nc.nd+srok+2<@ND

group by nc.B_Id) b on a.b_id=b.b_id
order by a.b_id
END