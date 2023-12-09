CREATE PROCEDURE dbo.ELoadSkladStatistics
@nd1 datetime,
@nd2 datetime
AS
BEGIN
  select convert(varchar,dtEnd,104) [Дата],
         datename(weekday, dtEnd) [День],
         (select count(distinct datnom) 
          from nvzakaz x 
          where x.dtEnd=z.dtEnd) [Количество накладных],
         (select count(1) 
          from nvzakaz x 
          where x.dtEnd=z.dtEnd) [Количество строк],
         (select count(1) 
          from nvzakaz x 
          where x.dtEnd=z.dtEnd 
                and len(Remark)<>0) [Количество отмен],
         (select avg(y.m) 
          from (select datediff(minute,x.tm,x.tmEnd) m 
                from nvzakaz x 
                where x.dtEnd=z.dtEnd 
                      and len(Remark)=0 
                group by datnom,x.tm,x.tmEnd)
          y) [Среднее время набора(мин)],
         (select min(y.m) 
          from (select datediff(minute,x.tm,x.tmEnd) m 
                from nvzakaz x 
                where x.dtEnd=z.dtEnd 
                      and len(Remark)=0 
                group by datnom,x.tm,x.tmEnd)
          y) [Минимальное время набора(мин)],
         (select max(y.m) 
          from (select datediff(minute,x.tm,x.tmEnd) m 
                from nvzakaz x 
                where x.dtEnd=z.dtEnd 
                      and len(Remark)=0 
                group by datnom,x.tm,x.tmEnd)
          y) [Максимальное время набора(мин)]
  from nvZakaz z
  where z.dtEnd between @nd1 and @nd2
  group by dtEnd
  order by dtEnd
END