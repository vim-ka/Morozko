CREATE PROCEDURE NearLogistic.PrintNabList @ND datetime, @Marsh int
AS
BEGIN
  declare @DatNom1 int, @DatNom2 int

  set @DatNom1=dbo.InDatNom(0,@ND)
  set @DatNom2=dbo.InDatNom(9999,@ND)

 select B.Skg,B.SkgName,f.Sklad,F.Hitag,
        case
          when F.Ves<>0 then F.NAme+' '+cast(Cast(ROUND(F.Ves,2) as float) as varchar)+'кг'
          else F.NAme
        end as Name,
        case  
           when F.MinP=1 then F.kol
           else F.kol / F.MinP*1.0
        end as Upak,
        case
          when (F.kol % F.MinP*1.0)=0 then Cast(Cast(F.kol/F.MinP as int) as Varchar)
          when (F.kol % F.MinP)>0 and (Cast(F.kol/F.MinP as int)=0) then 
              '+'+Cast(Cast(F.kol*1.0%F.MinP as int) as varchar)
          when (F.kol % F.MinP)>0 then 
             Cast(Cast(F.kol/F.MinP as int) as varchar)+'+'+
             Cast(Cast(F.kol%f.MinP as int) as varchar)         
         end as Kols,
         F.MinP,
         case
           when F.Ves>0 then (F.Ves*F.kol)
           when F.Netto>0 then (F.kol*F.Netto)
         end as weight,S.gpName,
         --S.reg_id, 
         R.SkladReg as reg_id,
         dbo.InNnak(nc.datNom)as NNak,
         
         case when isnull(nc.stfnom,'')=''
              then cast(dbo.InNNak(nc.datnom) as varchar)
              else nc.stfnom end as NNakStr,
         Marsh2,
         nc.Printed,
         IsNull(np.PalletNo,0) as PalletNo,
         nc.Datnom,
         case
           when IsNull(np.PalletNo,0)=0 then '0'
           when IsNull(np.PalletNo,0)=IsNull(np2.PalletNo,0) then cast(IsNull(np.PalletNo,0)as varchar)
           else cast(IsNull(np2.PalletNo,0)as varchar)+'-'+cast(IsNull(np.PalletNo,0)as varchar)
         end as sPalNo,
         S.Fmt,
         S.gpAddr
       
 from NC join Def S on S.pin=B_id
         cross apply (select v.Sklad,v.DatNom,v.hitag,E.Name,E.Netto,E.MinP,
               case
                  when E.flgWeight=1 and (IsNull(B.Weight,0)>0) then IsNull(B.Weight,0)
                  when E.flgWeight=1 and (IsNull(D.Weight,0)>0) then IsNull(D.Weight,0) 
                  else 0
               end as Ves, 
               --v.Kol
               iif(e.flgWeight=1,iif(e.netto=0,v.kol,isnull(d.weight,b.weight) / e.netto), v.kol) [kol]
               from NV v left join tdvi B on B.id=v.TekId
                         left join Visual D on D.id=v.TekId
                         left join (select hitag,Name,
                                  case
                                   when Brutto>=Netto then brutto
                                   else Netto
                                  end as Netto,MinP,flgWeight from Nomen) E on E.hitag=v.hitag   
               where v.kol>0 and v.DatNom=nc.DatNom) F 
         left join (select SkladNo,sl.Skg,sg.skgName 
                    from SkladList sl join SkladGroups sg on sg.skg=sl.skg)B on B.SkladNo=F.Sklad
         left join (select distinct datNom,PalletNo,Skg from NcPalletNom n
                    where pnId =(select max(pnId) from NcPalletNom where datNom=n.datNom and Skg=n.Skg)
                                )Np on Np.DatNom=nc.DatNom and Np.skg=B.skg
         left join (select distinct datNom,PalletNo,Skg from NcPalletNom n
                     where pnId =(select min(pnId) from NcPalletNom where datNom=n.datNom and Skg=n.Skg)
                   )Np2 on Np2.DatNom=nc.DatNom and Np2.skg=B.skg
         left join [dbo].Regions R on R.reg_id=S.reg_id                                       
 where nc.datnom>=@datnom1 and nc.DatNom<=@datnom2 and Marsh=@Marsh and exists(select v.nvid from nv v where v.datnom=nc.datnom and v.kol>0)
 order by Marsh2 desc,nc.Datnom,F.Sklad,PalletNo,F.Name
 
END