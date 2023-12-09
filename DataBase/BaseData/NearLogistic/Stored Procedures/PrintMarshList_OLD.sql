CREATE PROCEDURE [NearLogistic].PrintMarshList_OLD  @ND datetime, @Marsh int with recompile
AS
BEGIN

declare @mhid int
declare @datnom1 int, @datnom2 int

set @datnom1= dbo.InDatNom(0,@ND)
set @datnom2= dbo.InDatNom(9999,@ND)

set @mhid=(select mhid from Marsh where nd=@ND and marsh=@Marsh)

select c.B_id,
       A.gpName as Fam,
       A.Reg_id,
       A.GpAddr,
       A.gpPhone,
       sum(D.KolBox) as KolBox,
       max(c.RemarkOp) as RemOp,
       max(c.Remark) as Rem,
       sum(c.Sp) as Duty,
       A.TmPost,
       A.PosX,
       A.PosY,
       IsNull(E.KolTara,0) as Tara,
       min(c.DatNom) as DNom,
       count(c.Datnom) as CountNak,
       IsNull(F.TaraBKol,0) as TaraBKol,
       min(K.SkgName)as SkgName,
       case when max(c.SertifDoc)>0 then 1 else 0 end as Sertif,
       A.tmWork,
       A.tmDin,
       B.AgPhone,
       cast(min(TimeArrival) as varchar) as TimeArrival,
       c.Marsh2,
       IsNull(S.Sert,0) as Sert,
       case
        when isnull(A.wostamp,0)<>0 then 'Без печати'
                                    else ''
       end as WOStamp,
       case when A.NDCoord is null then '' else 'сверены' end CoordSver,
       A.Fmt,
       stuff((select ', '+case when isnull(n.stfnom,'')='' then cast(dbo.InNNak(n.datnom) as varchar(6))
                                                           else n.stfnom end 
              +(case when n.Printed>1 then '-Д' else '' end)                                             
       from nc n where n.b_id=c.b_id and n.nd=@ND and n.Marsh=@Marsh
       for xml path('')),1,2,'') as listNaks
from NC c  left join Def A on A.pin=c.B_id
           left join 
           (select c.pin, max(c.Ag_id) as Ag_id,
            (select p.Phone from person p where p.p_id=(select a.p_id from agentlist a where a.ag_id=max(c.Ag_id))) as AgPhone             
            from DefContract c where c.ContrTip=2 and c.Actual=1 group by c.pin) B on B.pin=c.b_id
           left join
           (select v.DatNom, 
                   sum(v.Kol*B.Weight) + sum(v.Kol*C.Netto) as AllW,
                   sum(v.Kol*1.0/C.MinP) as KolBox,
                   min(v.sklad) as Sk
            from NV v left join tdvi B on B.id=v.TekId
                      left join
                      (select case when Brutto>=Netto then brutto
                                                      else netto
                       end as Netto,hitag,MinP from Nomen) C on C.hitag=v.hitag
            where v.datnom>@datnom1 and v.datnom<@datnom2           
            group by v.DatNom ) D on D.DatNom=c.DatNom
           left join (select sum(Kol) as KolTara,B_id from TaraDet group by B_id)E on E.B_id=c.B_Id
           left join (select A.SkgName,SkladNo from SkladList sl left join (select skgName,skg from SkladGroups) A on A.skg=sl.skg) K on K.SkladNo=D.Sk
           left join (select B_id, case when sum(Kol)<0 then 0
                                                  else Sum(kol) end as TaraBKol
                      from TaraDet
                      where selldate<=@ND-30 and datnom is not null
                      group by B_id) F on F.b_id=c.B_id
           left join (select Count(Marsh2) as Sert, mhid from MarshSertif group by mhid) S on S.mhid=@mhid
where c.DatNom>=@Datnom1 and c.DatNom<=@Datnom2 and c.Marsh=@Marsh and exists(select v.nvid from nv v where v.datnom=c.datnom and v.kol>0)
group by c.B_id,A.gpName,A.Reg_id,A.GpAddr,A.gpPhone,A.TmPost,A.PosX,
         A.PosY,c.Marsh2,E.KolTara,F.TaraBKol,A.tmWork,A.tmDin,B.AgPhone,S.Sert,A.wostamp,A.NDCoord, A.Fmt
order by Marsh2,DNom

END