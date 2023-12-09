CREATE PROCEDURE dbo.GetSFList @master int, @dateStart datetime, @dateEnd datetime, @flgReturn bit=0
AS 
BEGIN
  SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED; 

  create table #TempTable (nd datetime,datnom int, datnumber int, b_id int, master int, fam varchar(100),
                           sp_ money, ndsbase money, nds int, stfnom varchar(17), stfdate datetime, sp_br money, dck int, ContrName varchar(80))


  create table #ResTable (nd datetime, datnom int, DatNumber int, B_id int, master int, fam varchar(100),
                          SP_ money, NDS10 money, Nds18 money, NDS0 money, NDS10sum money, NDS18sum money, stfnom varchar(17), stfdate datetime, sp_br money,
                          dck int, ContrName varchar(80))
                       
                        
  Declare @nd datetime, @datnom int,  @b_id int, @fam varchar(50),
          @sp_ money, @ndsbase money, @nds int, @Err money, @DatNumber int, @tekdatnom int,
          @NDS10 money, @NDS18 money, @NDS0 money, @NDS10sum money, @NDS18sum money,
          @stfnom varchar(17), @stfdate datetime, @sp_br money,  @dck int, @ContrName varchar(80),
          @Datnom1 int, @Datnom2 int;

  set @Datnom1 = dbo.InDatNom(0000, @dateStart)
  set @Datnom2 = dbo.InDatNom(9999, @dateEnd)          
        
  insert into #TempTable (nd, datnumber, datnom, b_id, master, fam, sp_, ndsbase, nds, stfnom, stfdate, sp_br, dck, ContrName)        
  select  t.nd,
          dbo.InNnak(t.datnom) as DatNumber,
          t.datnom,
          t.b_id,
          t.master,
          t.fam, 
          max(t.sp_) as sp_,
          sum(t.stoim*(1+t.Extra/100)) as ndsbase,
          t.nds,
          iif(t.nd>='20171001',
          iif(isnull(t.stfnom,'')<>'',t.stfnom, cast(month(t.nd) as varchar(2))+'-'+cast(day(t.nd) as varchar(2))+'-'+cast(dbo.InNnak(t.datnom) as varchar(4))),
          t.stfnom) as stfnom,
          t.stfdate,
          t.sp_br,
          t.dck,
          t.ContrName
  from
  (select c.nd,c.datnom,c.stfdate, c.stfnom,c.b_id, d.master, d.gpName as fam, c.sp as sp_,c.extra, isnull(x.sp_buyer,0) as sp_br, v.price*(v.kol+
          isnull((select sum(r.kol) from nv r join nc c on r.datnom=c.datnom 
          where c.refdatnom in (select c.datnom from nc c, def d where c.b_id=d.pin and c.Datnom>=@Datnom1 and c.Datnom<=@Datnom2 and d.master=@master)
                and  isnull(c.remark,'')='' and v.datnom=c.refdatnom and r.tekid=v.tekid),0)
         ) as stoim,
         n.nds,
         e.dck,
         e.ContrName

   from nc c join nv v on c.datnom=v.datnom
             join nomen n on v.hitag=n.hitag
             join def d on c.b_id=d.pin
             join defcontract e on c.dck=e.dck
             left join nc_exiteinfo x on c.datnom=x.datnom
  where d.master=@master and ((c.Sp>0 and c.Refdatnom=0) or (@flgReturn=1 and ((c.Sp>0 and c.Refdatnom=0) or c.SP<0)))
        and c.Datnom>=@Datnom1 and c.Datnom<=@Datnom2 and e.contrtip=2 and c.Actn=0
  
  union all
  
  select dbo.DatNomInDate(c.startdatnom) as ND,c.startdatnom as datnom,c.stfdate, c.stfnom,c.b_id, d.master, d.gpName as fam, c.sp as sp_,c.extra, isnull(x.sp_buyer,0) as sp_br, v.price*(v.kol+
          isnull((select sum(r.kol) from nv r join nc c on r.datnom=c.datnom 
          where c.refdatnom in (select c.datnom from nc c, def d where c.b_id=d.pin and c.StartDatnom>=@Datnom1 and c.StartDatnom<=@Datnom2 and d.master=@master)
                and  isnull(c.remark,'')='' and v.datnom=c.refdatnom and r.tekid=v.tekid),0)
         ) as stoim,
         n.nds,
         e.dck,
         e.ContrName

   from nc c join nv v on c.datnom=v.datnom
             join nomen n on v.hitag=n.hitag
             join def d on c.b_id=d.pin
             join defcontract e on c.dck=e.dck
             left join nc_exiteinfo x on c.datnom=x.datnom
  where d.master=@master and ((c.Sp>0 and c.Refdatnom>0) or @flgReturn=1 ) and c.Startdatnom>=@Datnom1 and c.StartDatnom<=@Datnom2 and e.contrtip=2 and c.Actn=0
  
  
  )t
  group by t.nd, t.datnom, t.stfdate, t.stfnom ,t.b_id,t.master,t.fam,t.extra, t.nds, t.sp_br,t.dck, t.ContrName
  order by datnom                         
        
  --select * from #TempTable order by datnom 
  
      
  Declare @CURSOR Cursor                          

  set @CURSOR  = Cursor scroll
  for select nd ,datnom, datnumber, b_id, master, fam,
             sp_, ndsbase, nds, stfnom, stfdate, sp_br,  dck, ContrName from #TempTable order by datnom
  --Открываем курсор
  open @CURSOR
  --Выбираем первую строку
  fetch next from @CURSOR into @nd ,@tekdatnom, @datnumber, @b_id, @master, @fam,
                               @sp_, @ndsbase, @nds, @stfnom, @stfdate, @sp_br, @dck, @ContrName
  set @datnom=@tekdatnom
  --Выполняем в цикле перебор строк
  insert into #ResTable (nd, datnom, DatNumber, B_id, master, fam, SP_, NDS10, Nds18, NDS0, NDS10sum, NDS18sum, stfnom, stfdate, sp_br,  dck, ContrName)
                 values (@nd, @tekdatnom, @datnumber, @B_id, @master, @fam, @SP_, 0, 0, 0, 0,0, @stfnom, @stfdate, @sp_br, @dck, @ContrName)
  
  while @@FETCH_STATUS = 0
  begin
    
    if @tekdatnom<>@datnom
    begin
      insert into #ResTable (nd, datnom, DatNumber, B_id, master, fam, SP_, NDS10, Nds18, NDS0, NDS10sum, NDS18sum, stfnom, stfdate, sp_br,  dck, ContrName)
                  values (@nd, @tekdatnom, @datnumber, @B_id, @master, @fam, @SP_, 0, 0, 0, 0,0, @stfnom, @stfdate, @sp_br, @dck, @ContrName)
      set @datnom=@tekdatnom               
    end                 
           
    if @nds=10       update #ResTable set NDS10 = @ndsbase, NDS10sum = round(@ndsbase - @ndsbase/1.1,2) where datnom=@tekdatnom
    else if @nds=18  update #ResTable set NDS18 = @ndsbase, NDS18sum = round(@ndsbase - @ndsbase/1.18,2) where datnom=@tekdatnom     
    
  
    fetch next from @CURSOR into @nd ,@tekdatnom, @datnumber, @b_id, @master, @fam, @sp_, @ndsbase,
                                 @nds, @stfnom, @stfdate, @sp_br, @dck, @ContrName

  end
  close @CURSOR
  
  --select * from #ResTable
  
  select r.*, 
         NDS10 + NDS18 + NDS0 as SP,
         SP_ + isnull(Back,0) - (NDS10 + NDS18 + NDS0) as Err
  from #ResTable r left join
  (select SUM(Sp) as Back,RefDatNom from NC where isnull(remark,'')='' group by RefDatNom)E on E.RefDatNom=r.DatNom   
  where NDS10 + NDS18 + NDS0<>0
  order by r.DatNom                       
  
END