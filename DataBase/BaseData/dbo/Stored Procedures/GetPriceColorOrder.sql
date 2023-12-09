CREATE PROCEDURE dbo.GetPriceColorOrder
@DepID int,
@NGRP int
AS
BEGIN
  /*
  select  m.mp,
          m.nd,
          m.op,
          u.fio,
          m.Hitag,
          n.name,
          m.depid,
          m.sv_id,
          m.ag_id,
          m.b_id,
          m.ngrp,
          m.LightEnable,
          m.NamePrefix,
          m.Clr,
          m.ord
  from mtprior m
  join nomen n on n.hitag=m.hitag
  join usrpwd u on u.uin=m.op
	where m.DepID=iif(@DepID=0,m.DepID,@DepID)
  			and n.ngrp=iif(@NGRP=0,n.ngrp,@NGRP)  			
  */
create table #resNomenColor (hitag int,
														 name varchar(90))
                             
insert into #resNomenColor
select hitag,
			 name
from nomen 
inner join gr on nomen.ngrp=gr.ngrp
where nomen.ngrp=iif(@ngrp=-1,nomen.ngrp,@ngrp)
			and gr.AgInvis=0

create nonclustered index idx_nomencolor on #resNomenColor(hitag)

create table #resColors (hitag int,
												 LightEnable bit,
                         Clr int,
                         Ord int,
                         mp int)
                         
insert into #resColors
select hitag,
			 LightEnable,
       clr,
       ord,
       mp
from MtPrior m
where depid=@depid

create nonclustered index idx_color on #resColors(hitag)

alter table #resNomenColor add Clr int not null default 0,
                               Ord int not null default 0,
                               mp int not null default -1,
                         			 flgTop bit not null default cast(0 as bit)

update #resNomenColor set clr=isnull(c.clr,0),
													ord=isnull(c.ord,0),
                          mp=isnull(c.mp,-1),
                          flgTop=iif(c.mp is null or isnull(c.ord,0)=0,0,1)
from #resNomenColor n
inner join #resColors c on c.hitag=n.hitag                  

select * 
from #resNomenColor
order by flgTop desc,
				 ord,
         name

drop table #resNomenColor
drop table #resColors
END