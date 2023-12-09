CREATE PROCEDURE [NearLogistic].NaklList_del @NeedDay datetime, @marsh int =-1, @reg_id varchar(5)=''
AS
BEGIN
  declare @n0 int, @n1 int, @sqlmass varchar(1000), @sql varchar(5000),
          @nlMt int, @MtName varchar(20), @MtClName varchar(20), @Vis varchar(20)
  set @n0=dbo.InDatNom(1,@NeedDay)
  set @n1=dbo.InDatNom(9999,@NeedDay)


  set @sqlmass=''
  
  declare crMassType cursor for 
 select nlMt, MtName, MtClName  
 from [NearLogistic].nlMassType
    
 open crMassType
   
 fetch next from crMassType into @nlMt, @MtName, @MtClName  

 while @@fetch_status=0 
 begin
     if @nlMt=5 
     set @sqlmass=@sqlmass+' SUM(case when G.nlMt='+cast(@nlMt as varchar(10)) +' then v.kol*(case when VI.[WEIGHT]>0 then VI.[WEIGHT] else nm.Brutto end) else 0 end)'+
                          +'+isnull((select sum(z.zakaz*nm.netto) as DopWeight from nvzakaz z join nomen nm on z.hitag=nm.hitag where z.done=0 and z.datnom=c.datnom),0) as '+@MtClName +','
     else
     set @sqlmass=@sqlmass+' SUM(case when G.nlMt='+cast(@nlMt as varchar(10)) +' then v.kol*(case when VI.[WEIGHT]>0 then VI.[WEIGHT] else nm.Brutto end) else 0 end) as '+@MtClName +','
     fetch next from crMassType into @nlMt, @MtName, @MtClName  
 end 
 
  close crMassType 
  deallocate crMassType
  
if @NeedDay = DATEADD(Day, datediff(day,0,getdate()),0)
     set @Vis='TDVI' 
else set @Vis='VISUAL' 

  set @sql='select '+@sqlmass+
  
 'c.Marsh,
  D.Reg_ID,
  c.Printed,
  c.Done,
  dbo.InNnak(c.DatNom)as NNak,
  case when c.B_Id2>0 then c.b_id2 else c.B_ID end as B_ID,
  D.gpName as brname,
  D.GpAddr as Addr,
  c.Remark,
  isnull(round(sum(v.Price*v.kol*100/(nm.nds+100)),2),0) as Sp,  --c.Sp,
  --round(sum((v.Price-v.Cost)*v.kol*100/(nm.nds+100)),2) as Nac,--c.Sp-c.Sc as Nac,
  
  isnull(round(sum(case when c.stip<>4 then (v.Price-v.Cost)*v.kol*100/(NM.nds+100) 
                                else case when x.nds=0 then v.Price*(v.kol-v.kol_b)*x.ourperc/100 else v.Price*(v.kol-v.kol_b)*x.ourperc/(NM.nds+100) end end),2),0) as Nac,
  
  
  c.Marsh2 as NomZ,
  d.brAg_id as Ag_Id,
  cast(case when c.Marsh=0 then 0 else 1 end as bit) as InMarsh,
  0 as MarshOld,
  c.Tomorrow,
  ''до ''+D.TmPost as tmPost,
  s.DepID,
  case when D.vMaster=0 then D.pin else D.vMaster end as VMaster,
  c.Stip,
  c.gpOur_id
 from nc c
  inner join nv v on c.datnom=v.Datnom
  inner join Def D on D.pin=case when c.B_Id2>0 then c.b_id2 else c.B_ID end 
  inner join DefContract Ct on Ct.dck=c.dck
  left join Agentlist A on A.ag_id=Ct.Ag_ID
  left join Agentlist S on S.Ag_ID=A.sv_ag_id
  left join '+ @Vis +' VI on VI.ID=v.TekID 
  left join Nomen NM on NM.hitag=v.Hitag
  left join gr G on NM.ngrp=G.ngrp
  left join SkladList Sl on Sl.SkladNo=v.sklad
  --left join (select top 1 * from DefconAppendix E) x on iif(D.Master>0, D.Master, D.pin)=x.BrMaster and VI.dck=x.dck
  left join (select dck,BrMaster, NDS, sum(OurPerc) as OurPerc from DefconAppendix group by dck,BrMaster, NDS) x on iif(D.Master>0, D.Master, D.pin)=x.BrMaster and VI.dck=x.dck
  left join (select z.datnom, sum(z.zakaz*nm.netto) as DopWeight from nvzakaz z join nomen nm on z.hitag=nm.hitag where z.done=0 group by z.datnom) DW on DW.datnom=c.datnom
 where
  c.datnom between '+ cast(@n0 as varchar(10)) +' and '+ cast(@n1 as varchar(10)) +'  
  and (c.Sp>0 or (c.SP=0 /*and c.actn=1*/)) and c.Done=1
 and c.marsh='+case when @marsh=-1 then 'c.marsh' else cast(@marsh as varchar) end+' '+'
 and d.reg_id='+case when @reg_id='' then 'd.reg_id' else ''''+@reg_id+'''' end+'
    and g.nlMT<>0
 group by
  c.Marsh,D.Reg_ID, c.Printed,c.Done, dbo.InNnak(c.DatNom),v.datnom,c.DatNom,
  case when c.B_Id2>0 then c.b_id2 else c.B_ID end,
  D.gpName, D.GpAddr, c.Remark,
  c.Sp,c.Sp-c.Sc, c.Marsh2, d.brAg_id,
  cast(case when c.Marsh=0 then 0 else 1 end as bit), 
  c.Tomorrow, ''до ''+D.tmPost, s.DepID,
  case when D.vMaster=0 then D.pin else D.vMaster end, c.Stip, c.gpOur_id order by NNak'
  --print @sql
  exec(@sql)


/*end
else
begin
 select
  c.Marsh,
  D.Reg_ID,
  c.Printed,
  c.Done, 
  dbo.InNnak(v.DatNom)as NNak,
  case when c.B_Id2>0 then c.b_id2 else c.B_ID end as B_ID,
  D.gpName as brname,
  D.GpAddr as Addr, 
  c.Remark,
  --round(sum(v.Price*v.kol*100/(nm.nds+100)),2) as Sp,--c.Sp,
  --round(sum((v.Price-v.Cost)*v.kol*100/(nm.nds+100)),2) as Nac,--c.Sp-c.Sc as Nac,
  
  round(sum(v.Price*v.kol*100/(nm.nds+100)),2) as Sp,  
  round(sum(case when c.stip<>4 then (v.Price-v.Cost)*v.kol*100/(NM.nds+100) 
                                else case when x.nds=0 then v.Price*(v.kol-v.kol_b)*x.ourperc/100 else v.Price*(v.kol-v.kol_b)*x.ourperc/(NM.nds+100) end end),2) as Nac,
  
  
  c.Marsh2 as NomZ, 
  d.brAg_id as Ag_Id,
  cast(case when c.Marsh=0 then 0 else 1 end as bit) as InMarsh,
  0 as MarshOld, c.Tomorrow, 'до '+D.TmPost as tmPost, s.DepID,
  case when D.vMaster=0 then D.pin else D.vMaster end as VMaster,
  SUM(case when Sl.Skg in (7) then v.kol*(case when VI.[WEIGHT]>0 then VI.[WEIGHT] else nm.Brutto end) else 0 end) as WFish,
  SUM(case when Sl.Skg in (3,29) then v.kol*(case when VI.[WEIGHT]>0 then VI.[WEIGHT] else nm.Brutto end) else 0 end) as WIce,
  SUM(case when Sl.Skg in (11,12,16,17,19) then v.kol*(case when VI.[WEIGHT]>0 then VI.[WEIGHT] else nm.Brutto end) else 0 end) as WBak,
  SUM(case when Sl.Skg in (3,5,7,11,12,16,17,19,29,32) then 0 else v.kol*(case when VI.[WEIGHT]>0 then VI.[WEIGHT] else nm.Brutto end) end) as WOther,
  SUM(case when Sl.Skg in (5,32) then v.kol*(case when VI.[WEIGHT]>0 then VI.[WEIGHT] else nm.Brutto end) else 0 end) as WMilk
 from nv v
  inner join nc c on c.datnom=v.Datnom
  inner join Def D on D.pin=case when c.B_Id2>0 then c.b_id2 else c.B_ID end
  inner join DefContract Ct on Ct.dck=c.dck
  left join Agentlist A on A.ag_id=Ct.Ag_ID
  left join Agentlist S on S.Ag_ID=A.sv_ag_id
  inner join VISUAL VI on VI.ID=v.TekID 
  inner join Nomen NM on NM.hitag=v.Hitag
  inner join SkladList Sl on Sl.SkladNo=v.sklad
  left join (select top 1 * from DefconAppendix E) x on iif(D.Master>0, D.Master, D.pin)=x.BrMaster and VI.dck=x.dck
 WHERE
  v.datnom between @n0 and @n1  
  and (c.Sp>0 or (c.SP=0 and c.actn=1))
 group by
  c.Marsh,D.Reg_ID, c.Printed,c.Done, dbo.InNnak(v.DatNom),
  case when c.B_Id2>0 then c.b_id2 else c.B_ID end,
  D.gpName, D.GpAddr, c.Remark,
  c.Sp,c.Sp-c.Sc, c.Marsh2, d.brAg_id,
  cast(case when c.Marsh=0 then 0 else 1 end as bit), 
  c.Tomorrow, 'до '+D.tmPost, s.DepID,
  case when D.vMaster=0 then D.pin else D.vMaster end

end  */


END