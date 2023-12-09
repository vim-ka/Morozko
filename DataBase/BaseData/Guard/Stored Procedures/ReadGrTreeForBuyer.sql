CREATE procedure Guard.ReadGrTreeForBuyer @b_id INT, @nd1 datetime, @nd2 datetime
as
  declare @Ngrp int
  declare @Grpname varchar(50)
  declare @Mtr tinyint;
begin
  create table #g(ngrp int, mtr tinyint default 0)
  if @B_ID>0 -- это если покупатель задан.
    insert into #g
    select a.ngrp,cast(max(a.Mtr) as tinyint) as Mtr from
      -- Так было:
      -- Rests r, Nomen n, Gr g where r.Hitag=n.Hitag and g.ngrp=n.ngrp and r.pin=@b_id and r.nd>=@nd1 and g.AgInvis=0
      --  union
      --  select g.ngrp, 1 as Mtr from MtOrder m, Nomen n, Gr g where g.ngrp=n.ngrp and m.hitag=n.hitag and m.b_id=@b_id and m.dtEnd>@nd2 and g.AgInvis=0
    ( select g.ngrp, 0 as Mtr 
      from 
        gr g
        left join nomen n on n.ngrp=g.Ngrp
        left join rests r on r.hitag=n.hitag
      where 
        r.pin=@b_id and r.nd>=@nd1 and g.AgInvis=0
           UNION
      select g.ngrp, 1 as Mtr 
      from 
        gr g
        left join nomen n on n.ngrp=g.Ngrp
        left join MtOrder m on m.hitag=n.hitag
      where 
        m.b_id=@b_id and m.dtEnd>@nd2 and g.AgInvis=0      
    ) a
    group by a.ngrp
    order by mtr desc;
  ELSE -- а если не задан, то просто все группы товаров
    insert into #g
    select distinct ngrp,0 from gr where gr.AgInvis=0
    order by ngrp;


  --  select * from #g
    
  create table #t(Ngrp int, GrpName varchar(55), mtr tinyint);

    declare C1 cursor fast_forward for 
      select gr.Parent, g2.grpname, max(#g.mtr) as Mtr
      from 
        gr 
        inner join #g on #g.ngrp=gr.Ngrp
        inner join gr g2 on g2.ngrp=gr.Parent
      where gr.levl=1 and gr.Parent>0 and gr.AgInvis=0
      group by gr.Parent, g2.grpname
      order by gr.Parent;
    open c1;
    fetch next from c1 into @Ngrp, @Grpname, @Mtr;

    WHILE (@@FETCH_STATUS=0)
    begin
      insert into #t values(@Ngrp, @GrpName, @Mtr);
      insert into #t 
        select gr.Ngrp, '    '+gr.Grpname, #g.mtr 
        from 
          GR 
          inner join #g on #g.ngrp=gr.ngrp
        where gr.Parent>0 and gr.Parent=@Ngrp and gr.Grpname<>''
        order by gr.GrpName;
        
      fetch next from c1 into @Ngrp, @Grpname, @Mtr;
    end;
    close c1;
    deallocate c1;

    insert into #t(ngrp, grpname,mtr)
    select ngrp, grpname,0
    from gr
    where gr.levl=0 and ngrp not in (0,84,86,90) and ngrp not in (select ngrp from #t);
    
  select ngrp, Grpname, cast(mtr as bit) OnMatrix from #t
end;