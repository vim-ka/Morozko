-- Свертка NV по товарам с одинаковым ID внутри накладной
CREATE procedure NVRoll  @n0 int, @n1 int -- @day0 datetime, @day1 datetime
as
declare @Skol int, @SkolB int, @SP decimal(12,2), @SC decimal(15,5),
  @cnt int,  @datnom int, @tekid int, @MinNvID int


begin
  --  set @n0=dbo.InDatNom(1, @day0);
  --  set @n1=dbo.InDatNom(9999, @day1);

  truncate table templog;
  insert into tempLog(comp,mess) VALUES('IT4','Proc.NVROLL: @n0='+cast(@n0 as varchar(10)));
  insert into tempLog(comp,mess) VALUES('IT4','Proc.NVROLL: @n1='+cast(@n1 as varchar(10)));
  
  create table #t(datnom int, tekid int, cnt int default 0);
  --  сначала накладные, где еще и цены различаются
  /*
  insert into #t(datnom,tekid)
  select 
    distinct nv.datnom, nv.tekid
  from nv inner join nv nv1 on nv1.datnom=nv.datnom and nv.tekid=nv1.tekid
  where 
    nv.datnom between @n0 and @n1
    and nv1.datnom between @n0 and @n1
    and NV.price<>nv1.price
  order by nv.datnom;
  */

  --  накладные с неоднократным вхождением tekid:
  insert into #t(datnom, tekid, cnt)
  select datnom, tekid, count(*) from nv
  where nv.datnom between @n0 and @n1
  group by datnom, tekid
  having count(*)>1;
  
  
  
  set @cnt=(select count(*) from #t);
  insert into tempLog(comp,mess) VALUES('IT4','Proc.NVROLL: '+cast(@cnt as varchar(6))+' rec.found');
 
  declare c1 cursor fast_forward for select datnom,tekid from #t;
  open c1;
  fetch next from c1 into @datnom, @tekid;
  WHILE (@@FETCH_STATUS=0) begin  
    -- по заданной паре datnom, tekid я считаю средневзвешенную цену и суммарное количество:
    insert into tempLog(comp,mess) VALUES('IT4','Proc.NVROLL: datnom='+cast(@datnom as varchar(10))+'  tekid='+cast(@tekid as varchar(12)));

    select 
      @SKol=sum(kol), @SKolB=sum(kol_b), @SP=sum(kol*price), @SC=sum(kol*cost), 
      @MinNVId=MIN(nvid)
    from nv where datnom=@datnom and tekid=@tekid;


    delete from nv where datnom=@datnom and tekid=@tekid and nvid>@MinNvID;
    if @SKol=0 begin
      update nv set kol=0, kol_b=@SKolB where datnom=@datnom and tekid=@tekid;
    end;
    else begin 
      update nv set Kol=@SKol, Price=@sp/@Skol, Cost=@SC/@SKol, kol_b=@SKolB 
      where datnom=@datnom and tekid=@tekid;
    end;
    fetch next from c1 into @datnom, @tekid;
  end;
  close c1;
  deallocate c1;
  -- select * from #t;
end;