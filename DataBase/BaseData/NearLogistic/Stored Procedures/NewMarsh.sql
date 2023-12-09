
CREATE PROCEDURE NearLogistic.NewMarsh
@nd datetime,
@marsh int,
@PLID int=1
AS
begin
declare @range int
declare @step int
set @range=@marsh+1000
set @step=1

create table #marshs (id int)
while @step<@range
begin
 insert into #marshs values(@step)
 set @step = @step+1
end

delete from #marshs 
where [id] in (select marsh from dbo.marsh m where m.nd=@nd)

if @marsh = 0 or not exists(select 1 from #marshs where id=@marsh)
set @marsh=(select min(id) from #marshs)

insert into dbo.marsh(nd,marsh,plid) values(@nd,@marsh,@plid)
end