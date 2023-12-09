create procedure eloadmenager.eload_get_list_of_first_shoot
@nd datetime
as
begin
  if object_id('tempdb..#res') is not null drop table #res
  create table #res (datnom int, [ship_end] datetime, [first_print] datetime)

  insert into #res
  select z.datnom, max(cast(convert(varchar,z.dtEnd,104)+' '+z.tmEnd as datetime)) [ship_end], min(l.nd) [first_print]
  from dbo.nvzakaz z join dbo.printlog l on l.datnom=z.datnom where z.nd=@nd
  group by z.datnom

  select convert(varchar,c.nd,104) [дата], dbo.InNnak(c.datnom) [номер], c.fam [клиент],
         #res.[ship_end] [последний набор], #res.[first_print] [первая печать]
  from #res 
  join dbo.nc c on c.datnom=#res.datnom
  where datediff(minute,[ship_end],[first_print]) <= 0

  if object_id('tempdb..#res') is not null drop table #res
end