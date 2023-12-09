CREATE PROCEDURE NearLogistic.NaklReqList_del
@All bit,
@det bit,
@nd datetime,
@sIceCreame decimal(20,2) OUT,
@sIce decimal(20,2) OUT,
@sfrost decimal(20,2) OUT,
@sdry decimal(20,2) OUT,
@sall decimal(20,2) OUT,
@simg int out
AS
BEGIN
set nocount on

declare @n1 integer
declare @n2 integer
declare @sql varchar(max)

set @n1=dbo.InDatNom(0,@nd)
set @n2=@n1+9999

if object_id('tempdb..#tempMassType') is not null
 drop table #tempMassType

create table #tempMassType (mType varchar(15))

insert into #tempMassType
select 'IceCreame' 
union 
select 'Ice' 
union 
select 'Frost' 
union 
select 'Dry'

if object_id('tempdb..#tempNC') is not null
 drop table #tempNC

create table #tempNC (datnom Bigint,
           remark varchar(50),
           STIP int,
           B_ID int,
           B_ID2 int,
           sp money,
           actn int,
           Tomorrow bit,
           [marsh] int)
insert into #tempNC
select  c.DatNom,
    c.Remark,
    c.STip,
    c.B_ID,
    c.B_Id2,
    c.SP,
    c.Actn,
    c.Tomorrow,
    c.Marsh
from nc c 
where c.DatNom between @n1 and @n2
   and (c.Sp>0 or (c.SP=0 and c.actn=1))
   and c.Tomorrow=0
   and c.Marsh=case when @all=1 then c.Marsh else 0 end

create index tmpNC_Ind on #tempNC (Datnom)

if object_id('tempdb.dbo.#tempNV') is not null
 drop table #tempNV
 
create table #tempNV (datnom Bigint,
           hitag INT,
           price money,
           kol int,
           tekid int)
           
insert into #tempNV
select  v.DatNom,
    v.Hitag,
    v.Price,
    v.Kol,
    v.TekID
from nv v
inner join #tempNC c on c.DatNom=v.DatNom

create index tmpNV_Ind on #tempNV (Datnom,TekID,hitag)


if object_id('tempdb.dbo.#tmpRequests') is not null
 drop table #tmpRequests

create table #tmpRequests (Reg_ID varchar(5),
              Place varchar(250),
              nNak int,
              Hitag int,
              gpName varchar(100),
              gpAddr varchar(200),
              sp money,
              mas decimal(15,2) not null,
              mType varchar(15),
              isNeedVet bit,
              [Marsh] int,
              ShipType int,
              dop decimal(20,2))

insert into #tmpRequests
select  d.Reg_ID,
    r.Place,
    c.DatNom % 10000 [nNak],
    n.hitag,
    d.gpName,
    d.gpAddr,
    v.Price*v.kol*100/(n.nds+100) as Sp,
    case when isnull(vi.WEIGHT,0)=0 then isnull(v.Kol,0)*isnull(n.Brutto,0) else isnull(v.Kol,0)*vi.Weight end [mas],
    case when (g.Ngrp=3 or g.Parent=3) then 'IceCreame'
       else case when g.nlMt in (2,6) then 'Ice'
             when g.nlMt in (1,4,7) then 'Frost' 
            when g.nlMt in (3,5) then 'Dry'
         end
    end [mType],
    case when patindex('%вет%',c.remark)<>0 or patindex('%в\с%',c.remark)<>0 or patindex('%в/с%',c.remark)<>0 then cast(1 as bit) 
       else cast(0 as bit) end [isNeedVet],
    c.Marsh,
    c.Stip ShipType,
    isnull(z.Zakaz,0)*n.Netto [dop]
from #tempNV v
inner join #tempNC c on c.datnom=v.DatNom
inner join Def d on d.pin=iif(c.B_Id2=0,c.B_ID,c.B_Id2) 
inner join tdvi VI on VI.ID=v.TekID 
inner join Nomen N on N.hitag=v.Hitag
inner join gr G on N.ngrp=G.ngrp
inner join [nearlogistic].Regions r on r.Reg_ID=d.Reg_ID
left join nvZakaz z on z.datnom=c.DatNom and z.Hitag=v.Hitag and z.Done=0
where d.Worker=0   
   
create index tmpReq_Ind on #tmpRequests (nNak,mType)
   
if object_id('tempdb.dbo.#tmpHead') is not null
 drop table #tmpHead

create table #tmpHead(isHeader bit, 
           nNak int,
           Reg_ID varchar(5), 
           Casher varchar(200), 
           Place varchar(250),
           sp money, 
           sMas decimal(15,2),
           sAll decimal(15,2), 
           mType varchar(15),
           isNeedVet bit,
           [marsh] int,
           ShipType int)

insert into #tmpHead   
select  cast(1 as bit) [isHeader],
    0,
    s.Reg_ID,
    s.Place,
    'Кол-во заявок: '+cast((select count(distinct nNak) from #tmpRequests where Reg_ID=s.Reg_ID) as varchar),
    sum(s.sp) [sp],
    sum(case when x.mType=s.mType then s.mas+s.dop else 0 end) [sMas],
    sum(s.mas) [sAll],
    x.mType,
    cast(0 as bit),
    0,
    0
from #tmpRequests s
inner join #tempMassType x on 1=1
group by s.Reg_ID,s.Place,x.mType--,s.ShipType

create index tmpHead_Ind on #tmpHead (nNak,mType)

if @det=1
begin
 if object_id('tempdb.dbo.#tmpBody') is not null
  drop table #tmpBody

 create table #tmpBody(isHeader bit, 
            nNak int,
            Reg_ID varchar(5), 
            Casher varchar(200), 
            Place varchar(250),
            sp money, 
            sMas decimal(15,2),
            sAll decimal(15,2), 
            mType varchar(15),
            isNeedVet bit,
            [marsh] int,
            ShipType int)
             
 insert into #tmpBody   
 select  cast(0 as bit) [isHeader],
     nNak,
     s.Reg_ID,
     s.gpName,
     s.gpAddr,
     sum(s.sp) [sp],
     sum(case when x.mType=s.mType then s.mas+s.dop else 0 end) [sMas],
     sum(s.mas) [sAll],
     x.mType,
     s.isNeedVet,
     s.[marsh],
     s.ShipType
 from #tmpRequests s
 inner join #tempMassType x on 1=1
 group by nNak,s.Reg_ID,s.gpAddr,s.gpName,s.isNeedVet,s.[marsh],x.mType,s.ShipType

 create index tmpBody_Ind on #tmpBody (nNak,mType)
end

set @sql=''

set @sql='
  select cast(0 as bit) [X],* from (
  select * from #tmpHead
  pivot (sum(smas) for mType in ([IceCreame],[Ice],[Frost],[Dry])) as pvt'
  
if @Det=1
begin
set @sql=@sql+'
  union 
  select * from #tmpBody
  pivot (sum(smas) for mType in ([IceCreame],[Ice],[Frost],[Dry])) as pvt'
end

set @sql=@sql+'
  ) z
  order by z.Reg_ID,z.isHeader desc,z.Casher,z.nNak'

EXEC(@sql)

select @sIceCreame=sum(smas)
from #tmpHead x
where x.mType='IceCreame'

select @sIce=sum(smas)
from #tmpHead x
where x.mType='Ice'

select @sfrost=sum(smas)
from #tmpHead x
where x.mType='Frost'

select @sdry=sum(smas)
from #tmpHead x
where x.mType='Dry'

select @sall=sum(smas)
from #tmpHead x

declare @plan int
declare @fact int 

select @plan=count(*)
from PlanVisit2
where dn=DATEPART(weekday,@nd)
   and tip=0

select @fact=count(*)
from #tempNC

if (@fact*1.0)/(@plan*1.0)<=0.7
 set @simg=0
ELSE
 if (@fact*1.0)/(@plan*1.0)<=0.9
  set @simg=1
 else
  set @simg=2

drop table #tmpHead
if @det=1
 drop table #tmpBody 
drop table #tmpRequests
drop table #tempMassType
drop table #tempNC
drop table #tempNV

set nocount off
END