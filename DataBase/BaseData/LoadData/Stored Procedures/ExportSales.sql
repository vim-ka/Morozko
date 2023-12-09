CREATE procedure LoadData.ExportSales
  @day0 datetime, @day1 datetime,
  @FirmGroups varchar(300)='7'
as

begin

  declare @DN0 int, @DN1 int, @OurIdList varchar(300)
  set @DN0 = dbo.fnDatNom(@day0, 1)
  set @DN1 = dbo.fnDatNom(@day1, 9999)
 
  if object_id('tempdb..#O') is not null drop table #O;
    create table #O(our_ID int);
    insert into #O(our_ID)  -- СПИСОК НАШИХ ФИРМ, КРОМЕ НОМЕРА 0:
      select F.Our_id 
      from FirmsConfig F 
      where F.FirmGroup in (select K from dbo.Str2intarray(@FirmGroups))
      and F.Our_id>0;

  
  select c.dck, sum(c.sp) as spback into #BackNC
  from nc c 
  where c.datnom between @DN0 and @DN1
  and c.sp<0 and c.remark<>'' and c.stip<>4
  group by c.dck;
  
  select k.dck, avg(DATEDIFF(DAY, k.sourdate, iif(k.bank_id>0,k.bankday, K.nd))) as avgSrok into #AvgSrokOplata
  from kassa1 k
  where k.nd between @day0-100 and @day1
  and k.oper=-2
  group by k.dck;
        
  
delete from LoadData.ExpSales where Comp=Host_Name();

INSERT INTO LoadData.ExpSales(Comp,DepID,sv_id,ag_id,b_id,DepName,Super,Agent,
       Klient,SP,SC,InpSC,PercDebit,SrokFact,PDZ7,PercNacenka,PercBack,QtySKU,Nacenka, Back) 
  select host_name(),
    e.DepID, e.sv_id,e.ag_id,e.b_id,
    E.DepName,
    E.Super,
    E.Agent,
    E.Klient,
    E.SP,
    E.SC,
    E.InpSC,
    round(iif(E.SP<1,1, isnull(dbr.Debt,0)/E.SP)*100,2) as PercDebit,
    isnull(ar.avgSrok,0) as SrokFact,
    isnull(dbr.Overdue,0) as PDZ7,
    round(iif(E.InpSC=0,0,100*(E.SP-E.InpSC)/E.InpSC),2) as PercNacenka,
    round(iif(E.SP<1,iif(isnull(bc.spBack,0)=0,0,1),abs(isnull(bc.spBack,0))/E.SP)*100,2) as PercBack,
    E.QtySKU,
    (E.SP-E.InpSC) as Nacenka,
    abs(isnull(bc.spBack,0)) as Back
  from
  (
  select
    deps.DepID,  A1.sv_ag_id as SV_ID, a1.AG_ID, nc.B_ID,dc.dck,
    deps.DName as DepName,
    P2.Fio as Super,
    case when a1.ag_id=17 then P1.Fio+'(закрытые)'
         when a1.ag_id=32 then P1.Fio+'(дебиторка)'
         when a1.ag_id=33 then P1.Fio+'(досудебные)'
    else P1.Fio end as Agent,
    Def.gpName as Klient,
    sum(iif(nc.actn=0,1,0)*(nv.price*(1.0+nc.extra/100)*nv.kol)) as SP,
    sum(nv.cost*nv.kol) as SC,
    
    round(sum(iif(nm.flgWeight=1 or vi.weight>0, nv.kol*Vi.weight,nv.kol*nm.netto)*
    (case
      when (nm.flgWeight=1 or vi.weight>0) and (i.id is null) then nv.cost/iif(vi.weight=0,nm.netto,vi.weight)
      when (nm.flgWeight=1 or vi.weight>0) then i.cost/iif(isnull(i.weight,0)=0,nmI.netto,i.weight)
      when nm.flgWeight=0 and vi.weight=0  and (i.id is null) then nv.cost/iif(nm.netto<>0,nm.netto,1)
      when isnull(i.weight,0)=0 and nmI.netto=0 then i.cost
      else i.cost/iif(isnull(i.weight,0)=0,nmI.netto,i.weight)
    end)),2) as InpSC,
    --avg(isnull(ar.avgSrok,0)) as SrokFact,
    0 as PercNacenka,
    --sum(isnull(bc.spback,0)) as Back,
    count(distinct nv.hitag) as QtySKU,
    0 as Nacenka
   
    
  from
    nc
    inner join nv on nv.datnom=nc.datnom
    inner join nomen nm on nm.hitag=nv.hitag
    inner join Defcontract DC on DC.DCK=nc.DCK and DC.ContrTip=2
    inner join Def on Def.pin=DC.pin
    inner join #O on #O.our_id=nc.ourid
    --left join BrNetFmt brf on brf.Net=Def.NetType
    left join Def M on M.pin=Def.Master and M.Pin>0
    left join Visual Vi on Vi.id=nv.tekid
    left join Inpdet I on I.ID=Vi.StartID
    left join nomen nmI on nmI.hitag=I.hitag
    left join Def VEN on Ven.Ncod=Vi.Ncod
    left join Defcontract DV on DV.DCK=Vi.DCK and DV.ContrTip=1
    left join Vendors Ve on Ve.ncod=vi.NCOD and Ve.Ncod>0
    left join Raions R on R.Rn_id=def.Rn_ID
    --inner join SkladList SL on SL.SkladNo=nv.Sklad
    --left  join UsrPwd Us on Us.uin=Ve.buh_uin
    --left join DefFormatWide w on w.dfid=def.dfid
    --left  join Agentlist A1 on A1.AG_ID=NC.ag_id
    left join agentlist A1 on a1.ag_id=dc.ag_id
    left join Person P1 on P1.p_id=a1.p_id
    left join AgentList S1 on S1.ag_id=A1.sv_ag_id -- and S1.IsSupervis=1
    left join Person P2 on P2.p_id=s1.p_id
    left join AgentList A2 on A2.AG_ID=nc.op-1000 and nc.op>1000
    left join Person P3 on P3.p_id=a2.p_id
    left join AgentList S2 on s2.AG_ID=A2.sv_ag_id -- and S2.IsSupervis=1
    left join Person P4 on P4.p_id=s2.p_id
    left join Deps on Deps.depId=s1.DepID
   
    --left join Obl on Obl.Obl_ID=isnull(def.Obl_ID,0)
    --left join VendBaseCosts VB on VB.pin=DV.pin and VB.DCK=DV.DCK
  where nv.datnom between @DN0 and @DN1 
  group by 
      deps.DepID,  A1.sv_ag_id, a1.ag_id, nc.B_ID,
      deps.DName, P2.Fio, P1.Fio, Def.gpName,dc.dck
  ) E left join #BackNC bc on bc.dck=E.dck
      left join #AvgSrokOplata ar on ar.dck=E.dck 
      left join dbo.DailySaldoDCK dbr on E.dck=dbr.dck and dbr.ND=@day1

select * from LoadData.ExpSales where Comp=Host_Name() order by depid,sv_id,ag_id,b_id;
  
 /* ) E
  left join defcontract dc on dc.dck=e.koddog
  left join firmsconfig fc on fc.our_id=E.our_id
  left join NC_ShippingType st on st.STip=e.STip
  group by e.nd,e.tm,e.datnom,e.srok,e.sp,e.hitag,e.NAME,e.WEIGHT,e.baseei,e.netto,e.price,e.cost,e.b_id,
    e.klient, e.tovar1,e.klient1,e.nettype,e.klient3,e.comp1,e.comp2,e.comp3,e.comp4,
    e.kod1, e.kod2, e.kod3, e.kod4, e.kod5,e.comp5, e.Nds,
    e.depid, e.dname,e.Ngrp,e.KodDog, e.Dogovor, e.OblName, e.sklad, e.SkladName, e.Upak,
    e.Zakup, e.KodDogVen, e.DogName, e.Format, e.DocType, fc.ourName, e.GpAddr,st.Meaning,
    e.exttag, e.flgWeight, e.VenPin,
    -- round(iif(e.flgWeight=0, e.InpCost*e.Netto, e.InpCost),5), --  round(iif(e.InpWeight=0, e.InpCost, e.InpCost/e.InpWeight),5),
    round(iif(e.flgWeight=0 and e.Netto<>0, e.InpCost*e.Netto, e.InpCost),5),
    e.InpPrice, -- round(iif(e.InpWeight=0, e.InpPrice, e.InpPrice/e.InpWeight),5),
    E.VbBaseCost,
    E.FNetType, E.Unit, E.NameSebest3, E.AOper, e.Koff, e.Master
  having sum(e.kol)<>0
  order by e.datnom, e.name
*/

/*
  update #rez
  set MainParent=gr.MainParent
  from 
    #rez 
    inner join GR on GR.Ngrp=#rez.Ngrp;*/
/*

  -- Сводка по группам:
  select gr.MainParent, gr.GrpName, 
    sum(#rez.kol) as SKol,
    cast(sum(#rez.price*#rez.kol) as decimal(14,2)) as SPrice,
    cast(round(sum(#rez.kol*#rez.cost),2) as decimal(14,2)) as SCost,
    cast(round((sum(#rez.price*#rez.kol)/sum(#rez.kol*#rez.cost)-1)*100,2) as decimal(6,2)) as PercCost,
    cast(round(sum(#rez.kol*#rez.InpCost),2) as decimal(14,2)) SImpCost,
    cast(round((sum(#rez.price*#rez.kol)/sum(#rez.kol*#rez.Inpcost)-1)*100,2) as decimal(6,2)) as PercInpCost,
    round(sum(#rez.kol*isnull(#rez.VbBaseCost,0)),2) SVbBaseCost
  from 
    #rez 
    inner join GR on Gr.ngrp=#rez.MainParent
  group by gr.MainParent, gr.GrpName
  order by gr.MainParent;


  -- Сумма по всей таблице:
  select 
    sum(#rez.kol) as SKol,
    cast(sum(#rez.price*#rez.kol) as decimal(14,2)) as SPrice,
    cast(round(sum(#rez.kol*#rez.cost),2) as decimal(14,2)) as SCost,
    cast(round((sum(#rez.price*#rez.kol)/sum(#rez.kol*#rez.cost)-1)*100,2) as decimal(6,2)) as PercCost,
    cast(round(sum(#rez.kol*#rez.InpCost),2) as decimal(14,2)) SImpCost,
    cast(round((sum(#rez.price*#rez.kol)/sum(#rez.kol*#rez.Inpcost)-1)*100,2) as decimal(6,2)) as PercInpCost,
    round(sum(#rez.kol*isnull(#rez.VbBaseCost,0)),2) SVbBaseCost
  from 
    #rez;

  -- Поиск сомнительных цен:
  select datnom, hitag, flgWeight, cost, inpcost, price, kol 
  from #rez 
  where inpCost<>0.01 and (Cost>=InpCost*3 or InpCost>=Cost*3);
*/
  --truncate table loaddata.rez;
  --insert into loaddata.rez select * from #rez;
  
 -- select * from #rez order by price,kol;
end