CREATE procedure dbo.ReadGrTree
as
declare @Ngrp int, @Grpname varchar(100)
begin
  create table #t(Ngrp int, GrpName varchar(100));

  declare C1 cursor fast_forward
    for select Ngrp, GrpName
    from GR where Levl=0
    order by Ngrp;
  open c1;
  fetch next from c1 into @Ngrp, @Grpname;

  WHILE (@@FETCH_STATUS=0)
  begin
    insert into #t values(@Ngrp, @GrpName);
    
    insert into #t 
      select Ngrp, '    '+Grpname 
      from GR 
      where Parent>0 and Parent=@Ngrp and Grpname<>''
      order by GrpName;
      
    fetch next from c1 into @Ngrp, @Grpname;
  end;
  close c1;
  deallocate c1;
  select * from #t;
end