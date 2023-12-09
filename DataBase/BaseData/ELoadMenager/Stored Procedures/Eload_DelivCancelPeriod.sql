CREATE PROCEDURE ELoadMenager.Eload_DelivCancelPeriod
@nd1 datetime,
@nd2 datetime
AS
BEGIN
if object_id('tempdb..#mh') is not null drop table #mh  
create table #mh (mhID int, 
				  datnom int,
                  nvid int,
                  DName varchar(100),
                  ag_id int,
                  fio varchar(200),
                  sp decimal(15,2),
                  fam varchar(400),
                  ndmarsh datetime,
                  b_id int,
                  Addr varchar(300), 
                  nextmarsh int,
                  nextmarshnd datetime
                  )  
insert into #mh
select m.mhid,c.datnom,v.nvid, d.DName, a.ag_id, p.fio, (v.kol*v.price*(1+(c.extra/100.0))) [sp],c.fam, m.nd, c.b_id, e.gpAddr,null,null
from dbo.marsh m
join dbo.nc c on c.mhid=m.mhid
join dbo.nv v with (index(nv_datnom_idx)) on v.datnom=c.datnom
left join dbo.agentlist a on c.ag_id=a.ag_id
left join dbo.person p on p.p_id=a.p_id
left join dbo.deps d on a.DepID=d.DepID
join def e on c.b_id=e.pin
where m.nd between @nd1 and @nd2
      and isnull(m.ScanND,'20170101')>='20170101'
     -- and not m.marsh in (99)
     -- and m.marsh<200
     -- and m.selfship=0
      and c.sp>=0
     
      
union      

select c.mhid,c.datnom,0, d.DName, a.ag_id, p.fio, c.sp,c.fam+iif(c.DayShift=1,'ФЛАГ - НА ЗАВТРА',''), c.nd, c.b_id , e.gpAddr, null,null
from dbo.nc c 
     left join dbo.agentlist a on c.ag_id=a.ag_id
     left join dbo.person p on p.p_id=a.p_id
     left join dbo.deps d on a.DepID=d.DepID
     join def e on c.b_id=e.pin
where c.nd between @nd1 and @nd2 and c.mhid=0 and c.sp>=0 
	
update #mh set #mh.nextmarsh=m.marsh, #mh.nextmarshnd=m.nd 
           from #mh join nc c on #mh.b_id=c.b_id
                    join marsh m on m.mhid=c.mhid 
        where c.datnom>#mh.datnom
      
      
select distinct [Дата],[Маршрут],[Накладная],[КодКлиента],[Клиент],[Адрес],[Данные о доставке],[Причина],'' as [Данные о складе],'' as [ПричинаСкл],
                [Отдел],[КодАгента],[ФИОАгента],[Сумма, руб.],[Дата рейса],[Следующий рейс],[Дата рейса]
from (
select convert(varchar,m.nd,104) [Дата],
       m.marsh [Маршрут],
	   d.DatNom [Накладная], 
       #mh.b_id [КодКлиента],      
       #mh.fam  [Клиент],
       #mh.Addr [Адрес],
       dr.fio+', '+dr.Phone [Данные о доставке],
       d.Remark+', ['+iif(d.resID=-1,'не указана',rr.Reason)+']' [Причина],
       #mh.DName as [Отдел],
       #mh.ag_id [КодАгента],
       #mh.fio [ФИОАгента],
       sum(sp) [Сумма, руб.],
       #mh.ndmarsh as [Дата_рейса],
       #mh.nextmarsh [Следующий рейс],
       #mh.nextmarshnd [Дата рейса]
from dbo.marsh m
join dbo.drivers dr on dr.drid=m.drid
join #mh on #mh.mhid=m.mhid
join dbo.DelivCancel d on d.mhid=#mh.mhid
left join dbo.reasontortrn rr on rr.reason_id=d.resID
where d.nvid=0 and d.datnom=0 and #mh.mhid<>0
group by convert(varchar,m.nd,104),m.marsh,d.datnom,dr.fio+', '+dr.Phone,d.Remark+', ['+iif(d.resID=-1,'не указана',rr.Reason)+']',#mh.DName,#mh.ag_id,#mh.fio,#mh.ndmarsh,#mh.b_id,#mh.Addr,
         #mh.nextmarsh,   #mh.nextmarshnd , #mh.fam 

union 

select convert(varchar,m.nd,104) [Дата],
       m.marsh [Маршрут],
	   d.DatNom%10000 [Накладная],       
       #mh.b_id [КодКлиента], 
       #mh.fam  [Клиент],     
       #mh.Addr [Адрес],
       isnull(dr.fio,'<нет данных о водителе>')+', '+isnull(dr.Phone,'') [Данные о доставке],
       d.Remark+', ['+iif(d.resID=-1,'не указана',rr.Reason)+']' [Причина],
       #mh.DName as [Отдел],
       #mh.ag_id [КодАгента],
       #mh.fio [ФИОАгента],
       sum(sp) [Сумма, руб.],
       #mh.ndmarsh as [Дата_рейса],
       #mh.nextmarsh [Следующий рейс],
       #mh.nextmarshnd [Дата рейса]

from dbo.marsh m
join dbo.drivers dr on dr.drid=m.drid
join #mh on #mh.mhid=m.mhid
join dbo.DelivCancel d on d.datnom=#mh.datnom
left join dbo.reasontortrn rr on rr.reason_id=d.resID
where d.nvid=0 and d.mhid=0 and #mh.mhid<>0
group by convert(varchar,m.nd,104),m.marsh,d.datnom%10000,dr.fio, dr.Phone,d.Remark+', ['+iif(d.resID=-1,'не указана',rr.Reason)+']',#mh.DName,#mh.ag_id,#mh.fio,#mh.ndmarsh,#mh.b_id,  #mh.Addr,
                  #mh.nextmarsh,   #mh.nextmarshnd ,#mh.fam 

union 

select convert(varchar,dbo.DatNomInDate(d.datnom),104) [Дата],
       0 [Маршрут],
  	   d.DatNom%10000 [Накладная],       
       d.b_id [КодКлиента],
       d.fam [Клиент],
       d.Addr [Адрес],
       'Не запланировано' [Данные о доставке],
       
       case when d.fam like '%ПЕРЕМЕЩЕНА%' then 'Перемещена на завтра торговым отделом'
            when d.sp=0  then 'Удалена торговым отделом'
            else 'Не включена в маршрут отделом доставки' end [Причина],
       d.DName as [Отдел],
       d.ag_id [КодАгента],
       d.fio [ФИОАгента],
       d.sp [Сумма, руб.],
       d.ndmarsh as [Дата_рейса],
       d.nextmarsh [Следующий рейс],
       d.nextmarshnd [Дата рейса]

from #mh d
where d.mhid=0

union 

select convert(varchar,dbo.DatNomInDate(d.datnom),104) [Дата],
       m.marsh [Маршрут],
  	   d.DatNom%10000 [Накладная],       
       d.b_id [КодКлиента],
       d.fam [Клиент],
       d.Addr [Адрес],
       isnull(i.fio,'<нет данных о водителе>')+', '+isnull(i.Phone,'') [Данные о доставке],
       'нет' [Причина],
       d.DName as [Отдел],
       d.ag_id [КодАгента],
       d.fio [ФИОАгента],
       sum(d.sp) [Сумма, руб.],
       d.ndmarsh as [Дата_рейса],
       d.nextmarsh [Следующий рейс],
       d.nextmarshnd [Дата рейса]

from #mh d join marsh m on d.mhid=m.mhid
           join Drivers i on m.drID=i.drID
where d.mhid>0
group by
convert(varchar,dbo.DatNomInDate(d.datnom),104),
       m.marsh,
  	   d.DatNom%10000,       
       d.b_id,
       d.fam,
       d.Addr,
       d.DName,
       d.ag_id,
       d.fio,
       d.ndmarsh,
       d.nextmarsh,
       d.nextmarshnd,
       i.fio,
       i.phone

) x
order by 1,2,3

if object_id('tempdb..#mh') is not null drop table #mh  
END