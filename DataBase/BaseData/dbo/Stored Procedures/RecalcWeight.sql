CREATE PROCEDURE dbo.RecalcWeight @ND datetime,@Marsh int
AS
BEGIN
  declare @Ves float,@vesOv float, @KolDots int, @KolDotsFact int
  set @Ves=(select Sum(IsNull(T.AllW,0))as  Allw
            from (select 
                  CASE
                    when C.Netto>0 then Sum(Kol*C.Netto)
                    when IsNull(B.Weight,0)>0 and C.Netto=0 then Sum(Kol*B.Weight)
                    when IsNull(B.Weight,0)=0 and C.Netto=0 then Sum(Kol*IsNull(D.Weight,0))
                  end as AllW
              from NV
              join
              (select DatNom from NC
              where ND=@Nd and marsh=@Marsh and (Sp>0 or actn=1))A on A.datnom=nv.DatNom
              left join
              (select id,weight from tdvi)B on B.id=TekId
              left join
              (select id,weight from Visual)D on D.id=TekId
              left join
              (select case
                        when Brutto>=Netto then brutto
                        else netto
                      end as Netto,hitag from Nomen)C on C.hitag=nv.hitag 
              group by C.Netto,B.Weight,D.Weight)T)
    
    
    set @vesOv=(select SUM(IsNull(V.allw,0))as Allw
              from (select 
                  CASE
                    when C.Netto>0 then Sum(Kol*C.Netto)
                    when IsNull(B.Weight,0)>0 and C.Netto=0 then Sum(Kol*B.Weight)
                    when IsNull(B.Weight,0)=0 and C.Netto=0 then Sum(Kol*IsNull(D.Weight,0))
                  end as AllW
              from NV
              join
              (select DatNom, refdatNom from NC
              where ND=@Nd+1 and (Sp<0) and 
               refdatNom in (Select DatNom from NC
               where ND=@Nd and marsh=@Marsh and (Sp>0 or actn=1) ))A on A.datnom=nv.DatNom
              left join
              (select id,weight from tdvi)B on B.id=TekId
              left join
              (select id,weight from Visual)D on D.id=TekId
              left join
              (select case
                        when Brutto>=Netto then brutto
                        else netto
                      end as Netto,hitag from Nomen)C on C.hitag=nv.hitag 
               group by C.Netto,B.Weight,D.Weight)V)
   
    set @KolDots=ISNULL((select Dots from Marsh where ND=@Nd and Marsh=@Marsh),0)             
    
    set @KolDotsFact=ISNULL((select count(distinct n.b_id)
                     from nc n left join
                     (select d.datnom,sum(d.kol-d.kol_b) as kol from nv d group by d.datnom) v on v.datnom=n.datnom
                     where n.marsh=@Marsh and n.nd=@Nd and v.kol>0),0)          
              
              
  select @Ves+@vesOv as Ves,@vesOv as VesOv,
  (select Count(ldId) from DrangLog
   where act='EMW' and MarshND=@ND and SourMarsh=@Marsh) as CountEdit,
   @KolDots as KolDots, @KolDotsFact as KolDotsFact
END