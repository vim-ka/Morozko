CREATE PROCEDURE [NearLogistic].PrintWorkList @ND datetime, @Marsh int
AS
BEGIN
 select nc.B_id,
        A.gpName as Fam,
        A.GpAddr,
        A.gpPhone,
        sum(D.KolBox)as KolBox,
        Marsh2,
        min(nc.DatNom) as DNom,
        min(K.SkgName)as SkgName,
        count(nc.Datnom) as CountNak,
        stuff((select ', '+case when isnull(n.stfnom,'')='' then cast(dbo.InNNak(n.datnom) as varchar(6))
                                                          else n.stfnom end 
             +(case when n.Printed>1 then '-Д' else '' end)                                             
        from nc n where n.b_id=nc.b_id and n.nd=@ND
        for xml path('')),1,2,'') as listNaks,
        A.Fmt,
        stuff((select ', '+n.Remark                                 
        from nc n where n.b_id=nc.b_id and n.nd=@ND and n.Marsh=@Marsh
        for xml path('')),1,2,'') as Remarks

        
from NC nc left join Def A on A.pin=nc.B_id
           left join (select nv.DatNom, sum(Kol*1.0/C.MinP)as KolBox, min(sklad)as Sk
                      from NV join (select DatNom from NC where ND=@ND) A on A.datnom=nv.DatNom
                              left join Nomen C on C.hitag=nv.hitag
                      group by nv.Datnom)D on D.DatNom=nc.DatNom
           left join (select A.SkgName,sl.SkladNo 
                      from SkladList sl left join SkladGroups A on A.skg=sl.skg
                     )K on K.SkladNo=D.Sk
                     
where ND=@ND and Marsh=@Marsh and exists(select v.nvid from nv v where v.datnom=nc.datnom and v.kol>0)
group by nc.B_id, A.gpName, A.GpAddr, A.gpPhone, Marsh2, A.Fmt
order by Marsh2, DNom

END