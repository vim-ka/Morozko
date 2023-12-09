CREATE PROCEDURE dbo.DailyTestData
AS
BEGIN
  Declare @nd1 datetime, @nd2 datetime, @string varchar(max), @string1 varchar(max), @string2 varchar(max),
   @dat datetime,
   @in4 int,
   @re4 real,
   @ch1 varchar(35),
   @in5 INT,
   @re5 real,
   @re6 real,
   @re1 real,
   @re2 real,
   @re3 real,
   @in1 int,
   @in2 int,
   @in3 int,
   @m1 money,
   @m2 money
  set @nd1 = dateadd(Day,-90, GetDate())
  set @nd2=  dateadd(Day,-1, GetDate())
  set @string=''
  set @string1=''
  set @string2=''
  set @dat ='20000203'
  set @in4 =0
  set @in5=0
  set @re4 =0
  set @ch1 =''
  set @re5 =0
  set @re6 = 0
  set @re1=0
  set @re2=0
  set @re3=0
  set @in1=0
  set @in2=0
  set @in3=0
  set @m1=0
  set @m2=0
 
 ---CURS1 
  DECLARE CURS1 CURSOR FAST_FORWARD READ_ONLY LOCAL FOR

  select
  ND,
  cast(RIGHT(NC.DatNom,4) as int)as DatNumber,
  Sp, 
  cast(A.gpName as VarChar(35)) as Fam,
  IsNull(Sp_NV,0) as Sp_NV, 
  Sc-IsNull(Sc_NV,0)
  
  from NC left join (select gpName,pin from Def) A on A.pin=B_id
          left join (select round(Sum(Price*Kol),2) as Sp_NV, round(Sum(Cost*Kol),2) as Sc_NV,DatNom
                     from NV
                     group by DatNom)B on B.DatNom=nc.DatNom
  where Nd>=@ND1 and ND<=@ND2 and
        (((round(IsNull(Sp_NV,0)*(1+Extra/100),2)-Sp)>0.3 or (round(IsNull(Sp_NV,0)*(1+Extra/100),2)-Sp)<-0.3)   or
        ((Sc-IsNull(Sc_NV,0))>0.3 or (Sc-IsNull(Sc_NV,0))<-0.3)  ) and tomorrow=0
order by NC.DatNom


--OPEN CURS1
open curs1;
fetch NEXT from curs1 INTO @dat, @in1, @re1, @ch1, @re2, @re3;
set @string = IIF((@@FETCH_STATUS=-2) or (@@FETCH_STATUS=-1),@string+ 'Нет ошибок в реализации'+CHAR(13),@string+ 'ОШИБКИ в реализации:'+Char(13));
WHILE @@FETCH_STATUS = 0 
BEGIN
  
      
set @string = @string + CAST(@dat AS varchar)+
'   nomen: '+ CAST(@in1 AS varchar)+'   spp: '+
    CAST(@re1 AS varchar)+'  fam:  '+@ch1+'  spnv:  '+ CAST(@re2 AS varchar)+
    '    spdif: '+CAST(@re3 AS varchar)+'     '+CHAR(13);  
    fetch NEXT from curs1 INTO @dat, @in1, @re1, @ch1, @re2, @re3;
end;
close curs1;
deallocate curs1;
set @string =@string+'==============================================='+CHAR(13);

 --2[ 
--Create table #datnoms2 (datnom int primary key, refdatnom int) 

Declare @dn int

set @dn=1501010000
if object_id('tempdb..#datnoms2') is not null drop table #datnoms2;

select datnom, refdatnom
into #datnoms2
from nc c
where c.RefDatnom>@dn and c.sp<0

create index idx_dt on #datnoms2(datnom)
create index idx_rdt on #datnoms2(refdatnom)

--CURS2
DECLARE CURS2 CURSOR FAST_FORWARD READ_ONLY LOCAL FOR
select 	
        Nomen.name, 
        [v_old].datnom, 
        [v_old].TekID, 
        [v_old].kol [old_kol],
        [v_old].kol_b [old_kol_b],
        sum([v_new].kol) [kol_b_new]
from #datnoms2 [src] 
join nv [v_old] on [v_old].DatNom=[src].refdatnom
join nv [v_new] on [v_new].DatNom=[src].datnom and [v_old].TekID=[v_new].TekID
join dbo.Nomen on [v_old].Hitag=nomen.hitag
group by Nomen.name, 
        [v_old].datnom, 
        [v_old].TekID, 
        [v_old].kol,
        [v_old].kol_b
having [v_old].kol_b<>(-1*sum(v_new.kol))        
 

--]

--OPEN CURS2
open curs2;
fetch NEXT from curs2 INTO @ch1, @in1, @in2, @re1, @re2, @re3;
set @string = IIF((@@FETCH_STATUS=-2) or (@@FETCH_STATUS=-1),@string+'Нет ошибок в возврате с реализацией'+CHAR(13),@string+'ОШИБКИ в возврате с реализацией:'+CHAR(13) );
WHILE @@FETCH_STATUS = 0 
BEGIN
  
      
set @string = @string + @ch1+'   Datnom: '+ Cast(@in1 AS varchar)+
'   TekId: '+ CAST(@in2 AS varchar)+'  Kol: '+
    CAST(@re2 AS varchar)+' Kolb:'+ CAST(@re3 AS varchar)+
    '  Newkolb: '+CAST(@re3 AS varchar)+CHAR(13);  
    fetch NEXT from curs2 INTO @ch1, @in1, @in2, @re1, @re2, @re3;
end;
close curs2;
deallocate curs2;
drop table #datnoms2;
set @string =@string+'==============================================='+CHAR(13);

--3[
--Create table #datnoms3 (datnom int primary key, refdatnom int) 
set @dn=1602010000
if object_id('tempdb..#datnoms3') is not null drop table #datnoms3;


select datnom, refdatnom
into #datnoms3
from nc c
where c.RefDatNom>@dn
		
create index idx_dt on #datnoms3(datnom)
create index idx_rdt on #datnoms3(refdatnom)


--CURS3
DECLARE CURS3 CURSOR FAST_FORWARD READ_ONLY LOCAL FOR
select 	[src].datnom,
        [src].refdatnom, 
        [v_old].TekID, 
        [v_old].Cost [oldCost],
        [v_new].Cost [newCost],
        abs([v_old].Cost - [v_new].Cost) [lambdaCost],
        [v_old].Price [oldPrice],
        [v_new].Price [newPrice],
    	abs([v_old].Price - [v_new].Price) [lamdaPrice],
        [v_old].Kol_B,
        [v_new].kol        
from #datnoms3 [src] 
join nv [v_old] on [v_old].DatNom=[src].refdatnom
join nv [v_new] on [v_new].DatNom=[src].datnom and [v_old].TekID=[v_new].TekID
where abs([v_old].Price - [v_new].Price)>0.1 
			or abs([v_old].Cost - [v_new].Cost)>0.1 



--OPEN CURS3
open curs3;
fetch NEXT from curs3 INTO @in1, @in2, @in3, @re1, @re2, @re3, @re4, @re5, @re6, @in4, @in5;
set @string = IIF((@@FETCH_STATUS=-2) or (@@FETCH_STATUS=-1),@string+'Нет ценовых несоответствий при возврате'+CHAR(13),@string+'Ценовые НЕСООТВЕТСТВИЯ при возврате:'+CHAR(13) );
WHILE @@FETCH_STATUS = 0 
BEGIN
  
      
set @string = @string +'Datnom: '+ Cast(@in1 AS varchar)+'   refDatnom: '+ Cast(@in2 AS varchar)+
'   TekId: '+ CAST(@in3 AS varchar)+'  OldCost: '+
    CAST(@re1 AS varchar)+' NewCost:'+ CAST(@re2 AS varchar)+
    '  LMDCost: '+CAST(@re3 AS varchar)+' OldPrise: '+CAST(@re4 AS varchar)+
    ' NewPrise: '+CAST(@re5 AS varchar)+' LMDPrise: '+CAST(@re6 AS varchar)+
    ' KolB: '+CAST(@in4 AS varchar)+' Kol: '+CAST(@in5 AS varchar)+CHAR(13);  
    fetch NEXT from curs3 INTO @in1, @in2, @in3, @re1, @re2, @re3, @re4, @re5, @re6, @in4, @in5;
end;
close curs3;
deallocate curs3;
drop table #datnoms3;
set @string =@string+'=============================================='+CHAR(13);


--CURS4
DECLARE CURS4 CURSOR FAST_FORWARD READ_ONLY LOCAL FOR
 select isnull((select sum(isnull(plata, 0)) from kassa1 k where k.oper = - 2 and
  k.sourdatnom = nc.datnom and (k.act = 'ВЫ' or k.act = 'ВО')), 0) [fakt summ], 
  nc.DatNom [datnom],
  NC.Fam [fam],
  nc.Fact [dog summ]
 from nc
 where abs(fact - isnull((select sum(isnull(plata, 0)) from kassa1 k where k.oper
  = - 2 and k.sourdatnom = nc.datnom and (k.act = 'ВЫ' or k.act = 'ВО')), 0)) >
  0.01 and
      nc.nd >= @nd1 and
      nc.nd <= @ND2
order by datnom, fam

--OPEN CURS4
open curs4;
fetch NEXT from curs4 INTO @re1, @in1, @ch1, @re2;
set @string = IIF((@@FETCH_STATUS=-2) or (@@FETCH_STATUS=-1),@string+'Нет несоответствий оплат'+CHAR(13),@string+'НЕСООТВЕТСВИЕ оплат:'+CHAR(13) );
WHILE @@FETCH_STATUS = 0 
BEGIN
  
      
set @string = @string +'Сумма по факту: '+ Cast(@re1 AS varchar)+' Datnom: '+ 
 CAST(@in1 AS varchar)+'  Поставщик: '+
    CAST(@ch1 AS varchar)+' Сумма по договору:'+ CAST(@re2 AS varchar)+CHAR(13);  
    fetch NEXT from curs4 INTO @re1, @in1, @ch1, @re2;
end;
close curs4;
deallocate curs4;
set @string =@string+'=================================================='+CHAR(13);


--CURS5
Declare CURS5 cursor FAST_FORWARD READ_ONLY LOCAL FOR
select v.ncod,
  (select sum(k.plata) from kassa1 k where k.ncod=v.ncod and k.nnak<>0) as TKassa,
  (select sum(c.plata) from comman c where c.ncod=v.ncod) as TComman,
  (select sum(k.plata) from kassa1 k where k.ncod=v.ncod and k.nnak<>0)- 
  (select sum(c.plata) from comman c where c.ncod=v.ncod) as Razn,
  (select sum(c.corr) from comman c where c.ncod=v.ncod) as SummaCorr
 from vendors v where (select sum(k.plata) from kassa1 k where k.ncod=v.ncod and k.nnak<>0)<>
       (select sum(c.plata) from comman c where c.ncod=v.ncod) 
 order by v.ncod

---OPEN CURS5 
 open curs5;
fetch NEXT from curs5 INTO @in1, @m1, @m2, @re3, @re4;
set @string = IIF((@@FETCH_STATUS=-2) or (@@FETCH_STATUS=-1),@string+'Нет ошибок оплат приходных комиссий'+CHAR(13),@string+'ОШИБКИ оплат приходных комиссий:'+CHAR(13) );
WHILE @@FETCH_STATUS = 0 
BEGIN
  
      
set @string = @string +'NCOD: '+ Cast(@in1 AS varchar)+' TKassa: '+ 
 CAST(@m1 AS varchar)+'  TComman: '+
    CAST(@m2 AS varchar)+' Razn:'+ CAST(@re3 AS varchar)+
    ' SummaCorr:'+ CAST(@re3 AS varchar)+CHAR(13);  
    fetch NEXT from curs5 INTO @in1, @m1, @m2, @re3, @re4;
end;
close curs5;
deallocate curs5;
set @string =@string+'================================================'+CHAR(13);

--CURS6
Declare CURS6 cursor FAST_FORWARD READ_ONLY LOCAL FOR
select c.ncom as ncom,
 c.ncod, 
 c.summacost, 
 c.plata,
isnull((select sum(k.plata) from kassa1 k where k.nnak=c.ncom and k.oper=-1),0) as kassa,
c.plata - (select sum(k.plata) from kassa1 k where k.nnak=c.ncom and k.oper=-1) as razn
from comman c, vendors v where c.plata <> (select isnull(sum(k.plata),0) from kassa1 k where k.nnak=c.ncom and k.oper=-1)
and c.ncom > 0 and v.ncod=c.ncod and v.actual=1
union 
select k.nnak as ncom, k.ncod, (select c.summacost from comman  c where c.ncom=k.nnak) as summacost,
(select c.plata from comman  c where c.ncom=k.nnak) as plata, sum(k.plata) as kassa, (select c.plata from comman  c where c.ncom=k.nnak)-sum(k.plata) as razn
from kassa1 k where k.oper=-1
group by k.nnak, k.ncod
having sum(k.plata) <> (select c.plata from comman c where c.ncom=k.nnak)
order by ncod

---OPEN CURS6 
 open curs6;
fetch NEXT from curs6 INTO @in1, @in2, @re1, @re2, @re3, @re4;
set @string = IIF((@@FETCH_STATUS=-2) or (@@FETCH_STATUS=-1),@string+'Нет несоответствий выплат по приходам'+CHAR(13),@string+'Кол-во несоответсвий выплат по приходам:' );
set @in3=0;
WHILE @@FETCH_STATUS = 0 
BEGIN
  set @in3=@in3+1;
fetch NEXT from curs6 INTO @in1, @in2, @re1, @re2, @re3, @re4;
end;
set @string = @string + Cast(@in3 AS varchar)+CHAR(13);  
set @in3=0;
close curs6;
deallocate curs6;
set @string =@string+'==============================================='+CHAR(13);

--CURS7
Declare CURS7 cursor FAST_FORWARD READ_ONLY LOCAL FOR
select c.ncom,c.ncod,c.izmen as Comman,(select sum(i.smi) from izmen i where i.ncom=c.ncom and i.act='ИзмЦ') as Izmen,'ИзмЦ' as Oper
from comman c 
where c.izmen<>(select isnull(sum(i.smi),0) from izmen i where i.ncom=c.ncom and i.act='ИзмЦ')
union
select c.ncom,c.ncod,c.remove as Comman,(select sum(i.smi) from izmen i where i.ncom=c.ncom and i.act='Снят') as Izmen,'Снят' as Oper
from comman c  
where c.remove<>(select isnull(sum(i.smi),0) from izmen i where i.ncom=c.ncom and i.act='Снят')

--OPEN CURS7
open curs7;
fetch NEXT from curs7 INTO  @in1, @in2, @re1, @re2, @ch1;
set @string = IIF((@@FETCH_STATUS=-2) or (@@FETCH_STATUS=-1),@string+'Нет ошибок Переоценки и Снятия'+CHAR(13),@string+'Количество Ошибок Переоценки и Снятия:' );

WHILE @@FETCH_STATUS = 0 
BEGIN
  
      
set @in3=@in3+1
    fetch NEXT from curs7 INTO @in1, @in2, @re1, @re2, @ch1;
end;
    
set @string = @string + Cast(@in3 AS varchar)+CHAR(13);  
set @in3=0;
close curs7;
deallocate curs7;
set @string =@string+'==============================================='+CHAR(13);

exec dbo.SendNotifyMail  'it@tdmorozko.ru', 'Проверка БД', @string , 0, ''

END