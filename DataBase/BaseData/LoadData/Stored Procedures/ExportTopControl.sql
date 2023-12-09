CREATE procedure LoadData.ExportTopControl
  @day0 datetime, @day1 datetime,
  @FirmGroups varchar(300)='10'
as
begin

    --    print('Расчет начальных остатков на вечер предыдущего дня'); -- не смейтесь над названиями полей
    --    create table LoadData.Nost(Datatime datetime, KodTov int, IdTov int,
    --      Tovar varchar(100), BaseEi varchar(4), EiOst varchar(4),
    --      Kolvo decimal(10,3),
    --      Cena decimal(12,4),
    --      Reserv decimal(10,3),
    --      KodSkl smallint,
    --      Sklad varchar(100),

    --    create table #Sales( -- таблица продаж. 
    --      Datatime datetime, 
    --      DocType varchar(20),
    --      DocNum varchar(4),
    --      StrNum varchar(3),


select  Z.datnom,
        Z.hitag,
        Z.addop,
        p.fio as AddOper,
        st.Meaning as ShipType
into #AddSale        
from
(select distinct 
        e.datnom,
        e.hitag,
        e.addop as AddOp
 from nvedit e
 where e.nd >= @day0 and e.nd <= @day1 and e.Kol=0 and e.NewKol>0
) Z
left join usrpwd u on u.uin=z.addop
left join Person P on p.p_id=u.p_id
left join nc on nc.datnom=z.datnom
left join nc_ShippingType st on st.STip=nc.STip

-- select top 100 * from #AddSale;


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
  if @FirmGroups = 10 insert into #O(Our_id) values (23);
  if @FirmGroups = 23 insert into #O(Our_id) select Our_id from FirmsConfig where FirmGroup=10;
  
CREATE TABLE #rez(MainParent int, nd datetime,tm char(8),datnom int,srok int,sp money,hitag int,
  name varchar(90),WEIGHT decimal(12, 3),baseei tinyint,netto decimal(10, 3),price numeric(14,5),
  cost decimal(14,5),b_id int,klient varchar(255),tovar1 varchar(50),klient1 varchar(255),nettype numeric(2,0),
  klient3 varchar(50),comp1 varchar(100),comp2 varchar(100),comp3 varchar(100),comp4 varchar(100),
  kod1 smallint,kod2 smallint,kod3 smallint,kod4 smallint,depid int,dname varchar(70),Ngrp int,
  KODDOG int,Dogovor varchar(336),Oblast varchar(50),Sklad smallint,SkladName varchar(50),kol decimal(12, 3),
  Upak int,Zakup varchar(70),KodDogVen int,DogName varchar(50),Format varchar(100),DocType varchar(255),
  Nds tinyint,Ourname varchar(60),GpAddr varchar(255),ShipType varchar(40),Exttag varchar(20),
  flgWeight bit,VenPin int,InpCost decimal(12, 4),InpPrice decimal(12, 4),VbBaseCost decimal(10, 2), FNetType varchar(30), unit varchar(3),
  NameSebest3 varchar(20), AOper varchar(100), Koff numeric(10,4), Master varchar(100))



INSERT INTO #rez(nd,tm,datnom,srok,sp,hitag,NAME,WEIGHT,baseei,netto,price,cost,
  b_id,klient,tovar1,klient1,nettype,klient3,comp1,comp2,comp3,comp4,kod1,kod2,kod3,kod4,
  depid,dname,Ngrp,KODDOG,Dogovor,Oblast,Sklad,SkladName,kol,Upak,Zakup,KodDogVen,DogName,
  Format,DocType,Nds,Ourname,GpAddr,ShipType,Exttag,flgWeight,VenPin,InpCost,InpPrice,VbBaseCost, FNetType, unit,
  NameSebest3, AOper, Koff, Master) 
select
    e.nd,e.tm,e.datnom,e.srok,e.sp,e.hitag,e.NAME,e.WEIGHT,e.baseei,e.netto,e.price,e.cost,e.b_id,
    e.klient, e.tovar1,e.klient1,e.nettype,e.klient3,
    e.comp1, e.comp2, e.comp3, e.comp4, 
    e.kod1, e.kod2, e.kod3, e.kod4, e.depid, e.dname,e.Ngrp, e.KODDOG, e.Dogovor, e.OblName Oblast, e.Sklad, e.SkladName,
    sum(e.kol) kol,
    e.Upak, e.Zakup, e.KodDogVen, e.DogName, e.Format, e.DocType, e.Nds, fc.Ourname,
    e.GpAddr,st.Meaning as ShipType, E.Exttag, e.flgWeight, e.VenPin,
    round(iif(e.flgWeight=0 and e.Netto<>0, e.InpCost*e.Netto, e.InpCost),5) as InpCost,
    e.InpPrice, -- round(iif(e.InpWeight=0, e.InpPrice, e.InpPrice/e.InpWeight),5) as InpPrice,
    iif(isnull(E.VbBaseCost,0)=0, round(iif(e.flgWeight=0 and e.Netto<>0, e.InpCost*e.Netto, e.InpCost),5), E.VbBaseCost),
    e.FNetType, e.unit, e.NameSebest3, e.AOper, e.Koff, e.Master
  from
  (select
    Ven.Pin as VenPin,
    nc.nd,
    nc.tm,
    nc.datnom,
    nc.srok,
    nc.SP,
    nv.Hitag, 
    nm.name,
    vi.[weight],
    nm.MeasID as BaseEI,
    nv.Kol*iif(nm.flgWeight=1 or vi.weight>0,iif(vi.weight=0,nm.netto,vi.weight),1) as Kol,
    nm.Netto,
    nm.Nds,
    nv.price*(1.0+nc.extra/100)/iif(nm.flgWeight=1 or vi.weight>0,iif(vi.weight=0,nm.netto,vi.weight),1) as Price,
    nv.cost/iif(nm.flgWeight=1 or vi.weight>0,iif(vi.weight=0,nm.netto,vi.weight),1) as Cost,
    nc.B_ID,
    Def.gpName as Klient,
    Ve.fam as Tovar1,
    iif(def.master=0, def.gpname, M.gpName) as Klient1,
    def.NetType,
    R.RName as Klient3,
    P2.Fio as Comp1,                                                    --Суперайзер клиента
    case when a1.ag_id=17 then P1.Fio+'(закрытые)'
         when a1.ag_id=32 then P1.Fio+'(дебиторка)'
         when a1.ag_id=33 then P1.Fio+'(досудебные)'
    else P1.Fio end as Comp2,                                           --ТП клиента   
    iif(isnull(s2.ag_id,0) = 0, 'Князева Светлана', P4.Fio) as Comp3,   --Суперайзер накладной
    iif(isnull(s2.ag_id,0) = 0, U.Fio, P3.Fio) as Comp4,                --ТП накладной
    s1.ag_id as Kod1,
    a1.ag_id as Kod2,
    iif(isnull(s2.ag_id, 0) = 0, 10012, s2.ag_id) as Kod3,
    iif(isnull(s2.ag_id, 0) = 0, U.Uin+10000, a2.ag_id) as Kod4,
    s1.DepID,
    deps.dname,
    nm.Ngrp,
    nc.dck as KodDog,
    Def.gpName+' '+dc.ContrName as Dogovor,
    Def.Obl_ID,
    Obl.OblName,
    nv.sklad,
    sl.skladName,
    Vi.minp*Vi.mpu as UPAK,
    Us.fio as Zakup, Vi.DCK as KodDogVen, DV.ContrNum as DogName, w.fullname as Format,
    case
      when nv.kol>0     then 'Реализация'
      when nc.remark='' then 'Возврат A2'
      when sl.Discard=1 then 'Возврат A5 брак'
      else nc.Remark
    end as DocType,
    Def.gpAddr,
    #O.our_id, nc.STip, NE.ExtTag, 
    
    cast(iif(nm.flgWeight=1 or vi.weight>0, 1, 0) as bit) as FlgWeight,
    
    case
      when (nm.flgWeight=1 or vi.weight>0) and (i.id is null) then nv.cost/iif(vi.weight=0,nm.netto,vi.weight)
      when (nm.flgWeight=1 or vi.weight>0) then i.cost/iif(isnull(i.weight,0)=0,nmI.netto,i.weight)
      when nm.flgWeight=0 and vi.weight=0  and (i.id is null) then nv.cost/iif(nm.netto<>0,nm.netto,1)
      when isnull(i.weight,0)=0 and nmI.netto=0 then i.cost
      else i.cost/iif(isnull(i.weight,0)=0,nmI.netto,i.weight)
    end as InpCost,
    
    case
      when (nm.flgWeight=1 or vi.weight>0) and (i.id is null) then nv.price/iif(vi.weight=0,nm.netto,vi.weight)
      when (nm.flgWeight=1 or vi.weight>0) then i.price/iif(isnull(i.weight,0)=0,nmI.netto,i.weight)
      when nm.flgWeight=0 and vi.weight=0  and (i.id is null) then nv.price/iif(nm.netto<>0,nm.netto,1)
      when i.weight=0 and nmI.netto=0 then i.price
      else i.price/iif(i.weight=0,nmI.netto,i.weight)
    end as InpPrice,
    
    case 
      when nm.flgWeight=0 and vi.weight=0 then 0
      when i.id is null then iif(vi.weight=0,nm.netto,vi.weight)
      when i.hitag=nv.hitag then i.Weight
      when i.weight<>0 then i.weight
      else iif(vi.weight=0,nm.netto,vi.weight)
    end as InpWeight,

    vb.BaseCost as VbBaseCost,
    brf.NetType as FNetType,
    iif(nm.flgWeight=1 or vi.weight>0, 'кг', 'шт') as unit,
    'Базовая с/с' as NameSebest3,
    isnull(al.AddOper,'') as AOper,
    nm.netto as Koff,
    iif(def.master=0, def.gpname, M.gpName) as Master
    
  from
    nc
    inner join nv on nv.datnom=nc.datnom
    left join #AddSale al on nv.datnom=al.datnom and nv.hitag=al.hitag
    inner join Defcontract DC on DC.DCK=nc.DCK and DC.ContrTip=2
    inner join #O on #O.our_id=nc.ourid
    inner join Def on Def.pin=DC.pin
    left join BrNetFmt brf on brf.Net=Def.NetType
    left join Def M on M.pin=Def.Master and M.Pin>0
    inner join nomen nm on nm.hitag=nv.hitag
    left join Visual Vi on Vi.id=nv.tekid
    left join Inpdet I on I.ID=Vi.StartID
    left join nomen nmI on nmI.hitag=I.hitag
    left join Def VEN on Ven.Ncod=Vi.Ncod
    left join NomenVend NE on NE.hitag=nv.hitag and NE.dck=vi.dck
    left join Defcontract DV on DV.DCK=Vi.DCK and DV.ContrTip=1
    left join Vendors Ve on Ve.ncod=vi.NCOD and Ve.Ncod>0
    left join Raions R on R.Rn_id=def.Rn_ID
    inner join SkladList SL on SL.SkladNo=nv.Sklad
    left join UsrPwd Us on Us.uin=Ve.buh_uin
    left join DefFormatWide w on w.dfid=def.dfid
    --  left  join Agentlist A1 on A1.AG_ID=NC.ag_id
    left join agentlist A1 on a1.ag_id=dc.ag_id
    left join Person P1 on P1.p_id=a1.p_id
    left join AgentList S1 on S1.ag_id=A1.sv_ag_id -- and S1.IsSupervis=1
    left join Person P2 on P2.p_id=s1.p_id
    left join AgentList A2 on A2.AG_ID=nc.op-1000 and nc.op>1000
    left join Person P3 on P3.p_id=a2.p_id
    left join AgentList S2 on s2.AG_ID=A2.sv_ag_id -- and S2.IsSupervis=1
    left join Person P4 on P4.p_id=s2.p_id
    left join Deps on Deps.depId=s1.DepID
    left join UsrPwd U on U.uin=NC.op and nc.op<1000
    left join Obl on Obl.Obl_ID=isnull(def.Obl_ID,0)
    left join VendBaseCosts VB on VB.pin=DV.pin and VB.DCK=DV.DCK
  where nv.datnom between @DN0 and @DN1 --and A2.Ag_id=85  and nv.Hitag=36476 
  ) E
  left join defcontract dc on dc.dck=e.koddog
  left join firmsconfig fc on fc.our_id=E.our_id
  left join NC_ShippingType st on st.STip=e.STip
  group by e.nd,e.tm,e.datnom,e.srok,e.sp,e.hitag,e.NAME,e.WEIGHT,e.baseei,e.netto,e.price,e.cost,e.b_id,
    e.klient, e.tovar1,e.klient1,e.nettype,e.klient3,e.comp1,e.comp2,e.comp3,e.comp4,
    e.kod1, e.kod2, e.kod3, e.kod4, e.Nds,
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



  update #rez
  set MainParent=gr.MainParent
  from 
    #rez 
    inner join GR on GR.Ngrp=#rez.Ngrp;
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
  truncate table loaddata.rez;
 -- insert into loaddata.rez select * from #rez;
  
  select * from #rez order by datnom;
end