CREATE PROCEDURE [NearLogistic].PrintMarshList  @ND datetime, @Marsh int with recompile
AS
BEGIN

declare @mhid int
declare @datnom1 int, @datnom2 int

set @datnom1= dbo.InDatNom(0,@ND)
set @datnom2= dbo.InDatNom(9999,@ND)

set @mhid=(select mhid from Marsh where nd=@ND and marsh=@Marsh)

select v.DatNom, 
       sum(v.Kol*B.Weight) + 
       sum(v.Kol*(case when Brutto>=Netto then brutto else netto end)) as AllW,
       sum(v.Kol*1.0/n.MinP) as KolBox,
       min(v.sklad) as Sk,
       min(A.SkgName) as SkgName
into #NVTemp       
from NC c join NV v on c.datnom=v.datnom
          left join tdvi B on B.id=v.TekId
          left join Nomen n on n.hitag=v.hitag
          left join SkladList sl on sl.SkladNo=v.Sklad
          left join SkladGroups A on A.skg=sl.skg
where c.DatNom>=@Datnom1 and c.DatNom<=@Datnom2 and c.Marsh=@Marsh and v.kol>0
group by v.DatNom

create index NvTempIdx on #NVTemp(Datnom)

select c.B_id,
       A.gpName as Fam,
       A.Reg_id,
       A.DstAddr as GpAddr,
       A.gpPhone,
       sum(D.KolBox) as KolBox,
       max(c.RemarkOp) as RemOp,
       max(c.Remark) as Rem,
       sum(c.Sp) as Duty,
       A.TmPost,
       A.PosX,
       A.PosY,
       0 as Tara,
       min(c.DatNom) as DNom,
       count(distinct c.Datnom) as CountNak,
       0 as TaraBKol,
       min(D.SkgName) as SkgName,
       case when max(c.SertifDoc)>0 then 1 else 0 end as Sertif,
       A.tmWork,
       A.tmDin,
       max(p.Phone) as AgPhone,
       cast(min(TimeArrival) as varchar) as TimeArrival,
       min(c.Marsh2) as Marsh2,
       IsNull((select Count(Marsh2) from MarshSertif where mhid=@mhid),0) as Sert,
       case
        when isnull(A.wostamp,0)<>0 then 'Без печати'
                                    else ''
       end as WOStamp,
       case when A.NDCoord is null then '' else 'сверены' end CoordSver,
       A.Fmt,
       max(c.ourid) as OurID,
       stuff((select ', '+case when isnull(n.stfnom,'')='' then cast(dbo.InNNak(n.datnom) as varchar(6))
                                                           else n.stfnom end 
              +(case when n.Printed>1 then '-Д' else '' end)                                             
       from nc n where n.b_id=c.b_id and n.nd=@ND and n.Marsh=@Marsh
       for xml path('')),1,2,'') as listNaks,
       m.Dover,
       iif(fc.FirmGroup=10,'Р','') as Prfx
from NC c left join Def A on A.pin=c.B_id
          left join agentlist l on c.ag_id=l.ag_id
          left join person p on l.p_id=p.p_id
          left join #NVTemp D on c.datnom=d.datnom
          cross apply
          (select count(distinct  pl.datnom) as Dover  from nc c1 join Dover2PrintLog pl on c1.datnom=pl.datnom
           where c1.DatNom>=@Datnom1 and c1.DatNom<=@Datnom2 and c1.Marsh=@Marsh) m
           left join firmsconfig fc on c.ourid=fc.Our_ID
          /* (select v.DatNom, 
                   sum(v.Kol*B.Weight) + 
                   sum(v.Kol*(case when Brutto>=Netto then brutto
                                                      else netto
                       end)) as AllW,
                   sum(v.Kol*1.0/n.MinP) as KolBox,
                   min(v.sklad) as Sk,
                   A.SkgName
            from NV v left join tdvi B on B.id=v.TekId
                      left join Nomen n on n.hitag=v.hitag
                      left join SkladList sl on sl.SkladNo=v.Sklad
                      left join SkladGroups A on A.skg=sl.skg
            where v.datnom=c.datnom
            group by v.DatNom, A.SkgName) D */
           --left join (select sum(Kol) as KolTara,B_id from TaraDet group by B_id)E on E.B_id=c.B_Id
           /*left join (select B_id, case when sum(Kol)<0 then 0
                                                  else Sum(kol) end as TaraBKol
                      from TaraDet
                      where selldate<=@ND-30 and datnom is not null
                      group by B_id) F on F.b_id=c.B_id*/
where c.DatNom>=@Datnom1 and c.DatNom<=@Datnom2 and c.Marsh=@Marsh
group by c.B_id,A.gpName,A.Reg_id,A.DstAddr,A.gpPhone,A.TmPost,A.PosX,
         A.PosY,c.Marsh2,A.tmWork,A.tmDin,A.wostamp,A.NDCoord, A.Fmt, m.Dover,fc.FirmGroup
order by Marsh2,DNom

END