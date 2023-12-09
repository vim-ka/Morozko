CREATE procedure Fill_Splan
as
declare @Hitag int
declare @sfid int
declare @smid int
declare @StartDate datetime
declare @dep_id int 
declare @sv_id int 
declare @ag_id int
declare @b_id int
declare @NetFlag bit
declare @WeightLimit decimal(10,3)
declare @QtyLimit int
declare @RubLimit int
declare @WeightFact decimal(10,3)
declare @QtyFact int
declare @RubFact int
declare @StartDatNom int
declare @Master int
 
begin
  truncate table Splan_Fact; -- таблица Splan_Fact содержит в спебе подробный план и выполнение.

  -- пока вот подробный план:
  insert into Splan_Fact(smid,StartDate,hitag,dep_id,sv_id,ag_id,b_id,NetFlag,WeightLimit,QtyLimit,RubLimit)
  select 
    sm.smid, sm.StartDate, t.hitag,
    case when sw.lvl=0 then pin else 0 end as dep_id,
    case when sw.lvl=1 then pin else 0 end as sv_id,
    case when sw.lvl=2 then pin else 0 end as ag_id,
    case when sw.lvl=3 then pin else 0 end as b_id,
    sw.NetFlag,
    t.WeightLimit,
    t.QtyLimit,
    t.RubLimit
  from 
    splan_main sm
    inner join SPlan_who sw on sw.Smid=sm.smid
    inner join Splan_what t on t.smid=sm.smid
  where 
    sm.Activ=1 and sm.FinishDate>getdate()-1
  
  -- А как он исполнен:
  declare CR cursor fast_forward  
  for select sfid,smid,StartDate,Hitag,dep_id,sv_id,ag_id,b_id,NetFlag,WeightLimit,QtyLimit,RubLimit
  from Splan_Fact order by sfid;
  
  open CR; 
  fetch next from CR into @sfid,@smid,@StartDate,@Hitag,@dep_id,@sv_id,@ag_id,@b_id,@NetFlag,@WeightLimit,@QtyLimit,@RubLimit;
  WHILE (@@FETCH_STATUS=0)  BEGIN
    set @StartDatNom=dbo.InDatNom(0, @StartDate);
    set @QtyFact=0
    set @RubFact=0
    set @WeightFact=0
    
    if @dep_id>0 begin
      select @WeightFact=sum(NV.kol*case when v.weight>0 then v.weight else nm.netto end),
        @QtyFact=sum(NV.Kol),
        @RubFact=sum(nv.kol*nv.price*(1.0+nc.extra/100))
      from 
        nv inner join nc on NC.datnom=nv.datnom
        inner join Nomen nm on nm.hitag=nv.hitag
        inner join Visual V on V.id=nv.tekid
        inner join Def d on d.pin=nc.b_id and d.tip=1
        inner join Agents A on A.ag_id=D.brag_id
        inner join SuperVis S on S.SV_ID=A.SV_ID
      where 
        nv.DatNom > @StartDatNom
        and nv.Hitag=@Hitag
        and nc.Frizer=0 and nc.Tara=0 and nc.actn=0
        and S.DepID=@dep_id;
    end;
    else if @sv_id>0 begin
      select @WeightFact=sum(NV.kol*case when v.weight>0 then v.weight else nm.netto end),
        @QtyFact=sum(NV.Kol),
        @RubFact=sum(nv.kol*nv.price*(1.0+nc.extra/100))
      from 
        nv inner join nc on NC.datnom=nv.datnom
        inner join Nomen nm on nm.hitag=nv.hitag
        inner join Visual V on V.id=nv.tekid
        inner join Def d on d.pin=nc.b_id and d.tip=1
        inner join Agents A on A.ag_id=D.brag_id
      where 
        nv.DatNom > @StartDatNom
        and nv.Hitag=@Hitag
        and nc.Frizer=0 and nc.Tara=0 and nc.actn=0
        and A.SV_ID = @sv_id;
    end;
    else if @ag_id>0 begin
      select @WeightFact=sum(NV.kol*case when v.weight>0 then v.weight else nm.netto end),
        @QtyFact=sum(NV.Kol),
        @RubFact=sum(nv.kol*nv.price*(1.0+nc.extra/100))
      from 
        nv inner join nc on NC.datnom=nv.datnom
        inner join Nomen nm on nm.hitag=nv.hitag
        inner join Visual V on V.id=nv.tekid
        inner join Def d on d.pin=nc.b_id and d.tip=1
      where 
        nv.DatNom > @StartDatNom
        and nv.Hitag=@Hitag
        and nc.Frizer=0 and nc.Tara=0 and nc.actn=0
        and d.brag_ID = @ag_id;
    end;
    else if @b_id>0 and @NetFlag=0 begin
      select @WeightFact=sum(NV.kol*case when v.weight>0 then v.weight else nm.netto end),
        @QtyFact=sum(NV.Kol),
        @RubFact=sum(nv.kol*nv.price*(1.0+nc.extra/100))
      from 
        nv inner join nc on NC.datnom=nv.datnom
        inner join Nomen nm on nm.hitag=nv.hitag
        inner join Visual V on V.id=nv.tekid
      where 
        nv.DatNom > @StartDatNom
        and nv.Hitag=@Hitag
        and nc.Frizer=0 and nc.Tara=0 and nc.actn=0
        and nc.b_id = @b_id;
    end;
    
    else if @b_id>0 and @NetFlag=1 begin
      set @Master=(select def.Master from Def where tip=1 and pin=@b_id);
      if @Master=0 set @Master=@B_ID;
      update Splan_Fact set B_ID=@Master where sfid=@sfid;
      
      select @WeightFact=sum(NV.kol*case when v.weight>0 then v.weight else nm.netto end),
        @QtyFact=sum(NV.Kol),
        @RubFact=sum(nv.kol*nv.price*(1.0+nc.extra/100))
      from 
        nv inner join nc on NC.datnom=nv.datnom
        inner join Nomen nm on nm.hitag=nv.hitag
        inner join Visual V on V.id=nv.tekid
        inner join Def d on d.pin=nc.b_id and d.tip=1
      where 
        nv.DatNom > @StartDatNom
        and nv.Hitag=@Hitag
        and nc.Frizer=0 and nc.Tara=0 and nc.actn=0
        and d.master=@Master or (d.master=0 and d.pin=@Master);
    end;

    update Splan_Fact set WeightFact=@WeightFact,
      QtyFact=@QtyFact,
      RubFact=@RubFact
      where sfid=@sfid;
      
	fetch next from CR into @sfid,@smid,@StartDate,@Hitag,@dep_id,@sv_id,@ag_id,@b_id,@NetFlag,@WeightLimit,@QtyLimit,@RubLimit;
  END; --  WHILE (@@FETCH_STATUS=0)  
  close Cr;
  deallocate Cr;
end