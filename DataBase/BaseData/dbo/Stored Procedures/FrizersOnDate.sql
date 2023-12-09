CREATE procedure dbo.FrizersOnDate @ND datetime, @Nom int=0, -- код хол. или 0 для всех
  @OurIdList varchar(200)='0,1,2,3,4,5,6,7,8,90,11,12,13,14,15,16,17'
as
begin
  
  -- Первая учетная система, таблицы Frizer и FrizerDet.
  -- Какая самая последняя операция по каждому холодильнику?
  create table #k(nom int, frizmv int);
  
 insert into #k
    select nom, max(frizmv) AS LastMV
    from frizermov 
    where (@nom=0 or @Nom=nom) and ND<=@ND
    group by nom;
 UPDATE #k SET frizmv=0 WHERE frizmv IS NULL;
 
  -- список мест хранения холодильников по результатам последней операции:
  --  SELECT  
  --    #k.FrizMv, FM.Pin1, F.*
  --  from 
  --    #k
  --    inner join FrizerMov FM on FM.FrizMV=#k.FrizMv
  --    inner join Frizer F on F.nom=#k.Nom
  --  order by #k.nom -- FrizMV    
  
  
  -- Собственно список холодильников, заведенных в БД не позднее дня @Day0:

  CREATE TABLE #F ( Nom int,  TrueDCK int default 0,  
    SysDate1 datetime, SysDck1 int,
    SysDate2 datetime, SysDck2 int,
    Tip smallint,  Mode char(1),  InvNom varchar(20),
    FabNom varchar(15),  Nname varchar(60),  Ncod int,  DatePost datetime,
    OurId tinyint,  Ob float,  Korzin smallint,  Zamok tinyint,  Sticker varchar(3),
    DateSell datetime,  Remark varchar(20),  DogNom varchar(20),
    Price money,  DateCheck datetime,  DateCheckAgent datetime,  NCom int,
    SkladNo smallint,  Procreator varchar(20),  NCountry int,  Cost decimal(13, 5),
    fsID smallint ,  mID smallint,  CondID int,  hitag int,  B_ID1 int,
    StartPrice money ,  DateStart datetime,  DateAct datetime,  InmarkoTip int,
    InvNom2 varchar(30),  ffid int,  DCK int ,  length  numeric(7, 2),
    high  numeric(7, 2),  depth numeric(7, 2),  FMod int, DName varchar(70) );
    
  insert into #F (Nom,  Tip,  Mode,  InvNom,
    FabNom,  Nname,  Ncod,  DatePost,  OurId,  Ob,  Korzin,  Zamok,  Sticker,
    DateSell,  Remark,  DogNom, Price,  DateCheck,  DateCheckAgent,  NCom,
    SkladNo,  Procreator,  NCountry,  Cost,  fsID,  mID,  CondID,  hitag,  B_ID1,
    StartPrice,  DateStart,  DateAct,  InmarkoTip, InvNom2,  ffid,  DCK,  length,
    high,  depth,  FMod)
  select Nom,  Tip,  Mode,  InvNom,
    FabNom,  Nname,  Ncod,  DatePost,  OurId,  Ob,  Korzin,  Zamok,  Sticker,
    DateSell,  Remark,  DogNom, Price,  DateCheck,  DateCheckAgent,  NCom,
    SkladNo,  Procreator,  NCountry,  Cost,  fsID,  mID,  CondID,  hitag,  B_ID1,
    StartPrice,  DateStart,  DateAct,  InmarkoTip, InvNom2,  ffid,  DCK,  length,
    high,  depth,  FMod
  from Frizer
  where @Nom=0 or @Nom=nom;
 
  create index f_tmp_idx on #f(Nom);
  
  update #F 
  set SysDck1=fm.DCK1, SysDate1=FM.ND
  from  
    #k
    inner join #F on #F.nom=#k.nom
    inner join FrizerMov FM on FM.FrizMV=#k.FrizMv


  -- Вторая учетная система, таблицы Frizcontract и Frizcontractdet.
  -- Какая самая последняя операция по каждому холодильнику?
  create table #c(nom int, cdid int);
  

  insert into #c
  select Fd.nom,max(Fd.cdid) as CDID 
  from 
    Frizcontract FC
    inner join Frizcontractdet FD on FD.ContractID=FC.ContractID
  where (@nom=0 or @Nom=FD.nom) --and Fc.NDClose<=@ND  
  group by fd.nom;
 


  update #F 
  set SysDck2=(case when Fd.Kol<=0 then 0 else fd.DCK end), SysDate2=Fc.ND
  from  
    #c
    inner join #F on #F.nom=#c.nom
    inner join FrizContractDet Fd on Fd.cdid=#c.cdid
    inner join FrizContract Fc on Fc.ContractID=FD.ContractID;

   
  update #F set TrueDCK=SysDck1 where (SysDate2 is null) or (SysDate1>SysDate2);
  update #F set TrueDCK=SysDck2 where SysDate1 is null or SysDate2>=SysDate1;
  
  -- Какие отделы?
  update #f
    set DName=deps.dname
  from #f
    inner join defcontract dc on dc.dck=#f.TrueDCK
    inner join agentlist ag on ag.ag_id=dc.ag_id
    inner join deps on deps.DepID=ag.DepID
  
  select 
    @ND as ND, #F.*,
    Def.Pin as B_ID, def.gpname, FS.StickName, Ve.Fam as VeFam, #f.Truedck as KodDog, dc.contrName, FF.FuncName, FC.OurName
  from
    #F 
    inner join DefContract DC on DC.dck=#f.TrueDck
    inner join Def on Def.pin=dc.pin
    left join  FrizerStick FS on FS.fsid=#f.fsid
    inner join Vendors Ve on Ve.ncod=#f.ncod
    left join  FrizerFunc FF on FF.FFID=#F.FFID  
    left join  firmsconfig FC on FC.Our_ID=DC.Our_ID
   -- left join Agentlist a on dc.ag_id=a.ag_id
  where #f.tip=0 
    and dc.Our_id in (select k from dbo.Str2intarray(@OurIdList))
  order by #f.nom
 
end;