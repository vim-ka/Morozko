CREATE PROCEDURE [NearLogistic].NaklList_filter_del 
@NeedDay datetime, 
@marsh int =-1, 
@reg_id varchar(3)='', 
@isGroup bit =0
AS
BEGIN
  declare @n0 int 
 declare @n1 int 
 declare @sqlmass varchar(1000) 
 declare @sql varchar(5000)
  declare @nlMt int
 declare @MtName varchar(20)
 declare @MtClName varchar(20) 
 declare @Vis varchar(20)
 declare @tsql varchar(max)
  declare @sum varchar(200)
 declare @ss varchar(200)
 
 set @n0=dbo.InDatNom(1,@NeedDay)
  set @n1=@n0+9999
 set @tsql=''
 set @sum=''
 set @ss=''
 
 if OBJECT_ID('tempdb.dbo.#NaklList') is not null
  drop table [#NaklList]
  
 create table [#NaklList] (RowID int IDENTITY)

  set @sqlmass=''
  
  declare crMassType cursor for 
 select nlMt, MtName, MtClName  
 from [NearLogistic].nlMassType
    
 open crMassType
   
 fetch next from crMassType into @nlMt, @MtName, @MtClName  

 while @@fetch_status=0 
 begin
  if @sum=''
   set @sum='sum('+@MtClName+') as '+@MtClName+',sum('+@MtClName
  else
   set @sum='sum('+@MtClName+') as '+@MtClName+','+@sum+'+'+@MtClName
  
  if @ss=''
   set @ss=@MtClName
  else
   set @ss=@ss+'+'+@MtClName
   
  set @tsql=''
  set @tsql='alter table [#NaklList] add '+@MtClName+' float not null default 0'
    exec(@tsql)
   
  if @nlMt=5 
  set @sqlmass=@sqlmass+' SUM(case when G.nlMt='+cast(@nlMt as varchar(10)) +' then v.kol*(case when VI.[WEIGHT]>0 then VI.[WEIGHT] else nm.Brutto end) else 0 end)'+
             +'+isnull((select sum(z.zakaz*nm.netto) as DopWeight from nvzakaz z join nomen nm on z.hitag=nm.hitag where z.done=0 and z.datnom=v.datnom),0) as '+@MtClName +','
  else
  set @sqlmass=@sqlmass+' SUM(case when G.nlMt='+cast(@nlMt as varchar(10)) +' then v.kol*(case when VI.[WEIGHT]>0 then VI.[WEIGHT] else nm.Brutto end) else 0 end) as '+@MtClName +','
 fetch next from crMassType into @nlMt, @MtName, @MtClName  
 end 
 
  close crMassType 
  deallocate crMassType

alter table [#NaklList] add [Marsh] int,
              Reg_ID varchar(3),
              Printed bit,
              Done bit,
              NNak int,
              B_ID int,
              brName varchar(100),
              Addr varchar(200),
              Remark varchar(100),
              Sp money,
              Nac money,
              NomZ int,
              Ag_id int,
              InMarsh bit,
              MarshOld int,
              Tomorrow bit,
              tmpPost varchar(100),
              DepID int,
              VMaster int 
  
if @NeedDay = DATEADD(Day, datediff(day,0,getdate()),0)
     set @Vis='TDVI' 
else set @Vis='VISUAL' 

  set @sql='select '+@sqlmass+
  
 'c.Marsh,
  D.Reg_ID,
  c.Printed,
  c.Done,
  v.DatNom%10000 as NNak,
  case when c.B_Id2>0 then c.b_id2 else c.B_ID end as B_ID,
  D.gpName as brname,
  D.GpAddr as Addr,
  c.Remark,
  round(sum(v.Price*v.kol*100/(nm.nds+100)),2) as Sp,
  round(sum(case when c.stip<>4 then (v.Price-v.Cost)*v.kol*100/(NM.nds+100) 
                                else case when x.nds=0 then v.Price*(v.kol-v.kol_b)*x.ourperc/100 else v.Price*(v.kol-v.kol_b)*x.ourperc/(NM.nds+100) end end),2) as Nac,
  
  
  c.Marsh2 as NomZ,
  d.brAg_id as Ag_Id,
  cast(case when c.Marsh=0 then 0 else 1 end as bit) as InMarsh,
  0 as MarshOld,
  c.Tomorrow,
  ''до ''+D.TmPost as tmPost,
  s.DepID,
  case when D.vMaster=0 then D.pin else D.vMaster end as VMaster
 from nv v
  inner join nc c on c.datnom=v.Datnom
  inner join Def D on D.pin=case when c.B_Id2>0 then c.b_id2 else c.B_ID end 
  left join Agents A on A.ag_id=D.brAg_ID
  left join SuperVis S on S.SV_ID=A.SV_ID
  inner join '+ @Vis +' VI on VI.ID=v.TekID 
  inner join Nomen NM on NM.hitag=v.Hitag
  inner join gr G on NM.ngrp=G.ngrp
  inner join SkladList Sl on Sl.SkladNo=v.sklad
  --left join (select top 1 * from DefconAppendix E) x on iif(D.Master>0, D.Master, D.pin)=x.BrMaster and VI.dck=x.dck
  left join (select dck,BrMaster, NDS, sum(OurPerc) as OurPerc from DefconAppendix group by dck,BrMaster, NDS) x on iif(D.Master>0, D.Master, D.pin)=x.BrMaster and VI.dck=x.dck
  left join (select z.datnom, sum(z.zakaz*nm.netto) as DopWeight from nvzakaz z join nomen nm on z.hitag=nm.hitag where z.done=0 group by z.datnom) DW on DW.datnom=v.datnom
 where
  v.datnom between '+ cast(@n0 as varchar(10)) +' and '+ cast(@n1 as varchar(10)) +'  
  and (c.Sp>0 or (c.SP=0 and c.actn=1))
 and c.marsh='+case when @marsh=-1 then 'c.marsh' else cast(@marsh as varchar) end+' '+'
 and d.reg_id='+case when @reg_id='' then 'd.reg_id' else ''''+@reg_id+'''' end+'
 group by
  c.Marsh,D.Reg_ID, c.Printed,c.Done, dbo.InNnak(v.DatNom),v.datnom,
  case when c.B_Id2>0 then c.b_id2 else c.B_ID end,
  D.gpName, D.GpAddr, c.Remark,
  c.Sp,c.Sp-c.Sc, c.Marsh2, d.brAg_id,
  cast(case when c.Marsh=0 then 0 else 1 end as bit), 
  c.Tomorrow, ''до ''+D.tmPost, s.DepID,
  case when D.vMaster=0 then D.pin else D.vMaster end order by NNak'
 exec('insert into [#NaklList] '+@sql)
 
 if @isGroup=0
 begin
  set @sql=''
  set @sql='select *,'+@ss+' as sumS from [#NaklList] order by Reg_ID, nNak'
  exec(@sql)
 end
 else
 begin
  set @sql=''
  set @sql='select '+@sum+') as WSum,Reg_id,count(Reg_id) as cnt,sum(sp) as sumsp,sum(nac) as sumnac, sum(nac-(sp-nac)*0.2) as sumDOH from [#NaklList] group by Reg_id'
  set @sql='select x.*,r.place,case when exists(select * from nc n inner join def d on d.pin=n.b_id where n.nd='''+cast(@NeedDay as varchar)+''' and (n.sp>0 or (n.sp=0 and n.actn=1)) and d.reg_id=x.reg_id and n.marsh=0) then cast(0 as bit) else cast(1 as bit) end [isEmpty] from ('+@sql+') x inner join [NearLogistic].[Regions] r on r.Reg_id=x.Reg_ID'
  exec(@sql)
 end
 drop table [#NaklList]
END