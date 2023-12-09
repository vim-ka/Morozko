CREATE PROCEDURE dbo.GetOborot @Our_id int, @dateStart datetime, @dateEnd datetime, @flgReturn bit=0
AS 
BEGIN
  SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED; 

  create table #TempTable (nd datetime,datnom int, datnumber int, b_id int, master int, fam varchar(100),
                           sp_ money, ndsbase money,ndsbasezakup money, nds int, stfnom varchar(17), stfdate datetime, sp_br money, dck int, ContrName varchar(80),sc_ money)


  create table #ResTable (nd datetime, datnom int, DatNumber int, B_id int, master int, fam varchar(100),
                          SP_ money, NDS10 money, Nds18 money, NDS0 money, NDS10sum money, NDS18sum money, stfnom varchar(17), stfdate datetime, sp_br money,
                          dck int, ContrName varchar(80), NDS10Cost money, NDS18Cost money, NDS0Cost money, NDS10Costsum money, NDS18Costsum money, sc_ money)
                       
                        
  Declare @nd datetime, @datnom int,  @b_id int, @fam varchar(50),
          @sp_ money, @ndsbase money, @nds int, @Err money, @DatNumber int, @tekdatnom int,
          @NDS10 money, @NDS18 money, @NDS0 money, @NDS10sum money, @NDS18sum money,
          @stfnom varchar(17), @stfdate datetime, @sp_br money,  @dck int, @ContrName varchar(80),
          @tekb_id int, @master int, @NDS10Cost money, @NDS18Cost money, @NDS0Cost money, @NDS10Costsum money, @NDS18Costsum money, @sc_ money,
          @ndsbasezakup money;
        
  insert into #TempTable (nd, datnumber, datnom, b_id, master, fam, sp_, ndsbase, ndsbasezakup, nds, stfnom, stfdate, sp_br, dck, ContrName, sc_)        
  select  t.nd,
          dbo.InNnak(t.datnom) as DatNumber,
          t.datnom,
          case when t.master>0 then t.master else t.b_id end as b_id,
          t.master,
          t.fam, 
          t.sp_,
          sum(t.stoim*(1+t.Extra/100)) as ndsbase,
          sum(t.zakup) as ndsbasezak,
          t.nds,
          t.stfnom,
          t.stfdate,
          t.sp_br,
          t.dck,
          t.ContrName,
          t.sc_
  from
  (select c.nd,c.datnom,c.stfdate, c.stfnom,c.b_id, d.master, d.gpName as fam, c.sp as sp_,c.extra, isnull(x.sp_buyer,0) as sp_br,
          v.price*(v.kol+isnull((select sum(r.kol) from nv r join nc c on r.datnom=c.datnom 
                                 where c.refdatnom in (select c.datnom from nc c, def d where c.b_id=d.pin 
                                        and c.nd>=@dateStart and c.nd<=@dateEnd)
                                        and  isnull(c.remark,'')='' and v.datnom=c.refdatnom and r.tekid=v.tekid),0)
         ) as stoim,
         v.cost*(v.kol+isnull((select sum(r.kol) from nv r join nc c on r.datnom=c.datnom 
                                 where c.refdatnom in (select c.datnom from nc c, def d where c.b_id=d.pin 
                                        and c.nd>=@dateStart and c.nd<=@dateEnd)
                                        and  isnull(c.remark,'')='' and v.datnom=c.refdatnom and r.tekid=v.tekid),0)
         ) as zakup,
         n.nds,
         e.dck,
         e.ContrName,
         c.sc as sc_ 
   from nc c join nv v on c.datnom=v.datnom
             join nomen n on v.hitag=n.hitag
             join def d on c.b_id=d.pin
             join defcontract e on c.dck=e.dck
             left join nc_exiteinfo x on c.datnom=x.datnom
  where c.Ourid = @Our_id and (c.Sp>0 or @flgReturn=1) and c.ND>=@dateStart and c.ND<=@dateEnd and e.contrtip=2 and c.Actn=0
  )t
  group by t.nd, t.datnom, t.stfdate, t.stfnom ,t.b_id,t.master,t.fam,t.sp_,t.extra, t.nds, t.sp_br,t.dck, t.ContrName,t.sc_
  order by datnom                         
        
-- select * from #TempTable order by datnom 
  
      
  Declare @CURSOR Cursor                          

  set @CURSOR  = Cursor scroll
  for select nd, datnom, datnumber, b_id, master, fam,
             sp_, ndsbase, nds, stfnom, stfdate, sp_br, dck, ContrName, ndsbasezakup,sc_ 
  from #TempTable order by b_id
  --Открываем курсор
  open @CURSOR
  --Выбираем первую строку
  fetch next from @CURSOR into @nd ,@tekdatnom, @datnumber, @b_id, @master, @fam,
                               @sp_, @ndsbase, @nds, @stfnom, @stfdate, @sp_br, @dck, @ContrName, @ndsbasezakup, @sc_
  set @tekb_id=@b_id 
  --Выполняем в цикле перебор строк
  insert into #ResTable (nd, datnom, DatNumber, B_id, master, fam, SP_, NDS10, Nds18, NDS0, NDS10sum, NDS18sum, stfnom, stfdate, sp_br,  dck, ContrName,
                         NDS10Cost, NDS18Cost, NDS0Cost, NDS10Costsum, NDS18Costsum, sc_)
                 values (@nd, @tekdatnom, @datnumber, @B_id, 0, @fam, @SP_, 0, 0, 0, 0,0, @stfnom, @stfdate, @sp_br, @dck, @ContrName,
                         0, 0, 0, 0, 0, @sc_)
  
  while @@FETCH_STATUS = 0
  begin
    
    if @tekb_id<>@b_id
    begin
      insert into #ResTable (nd, datnom, DatNumber, B_id, master, fam, SP_, NDS10, Nds18, NDS0, NDS10sum, NDS18sum, stfnom, stfdate, sp_br,  dck, ContrName,
                             NDS10Cost, NDS18Cost, NDS0Cost, NDS10Costsum, NDS18Costsum, sc_)
                  values (@nd, @tekdatnom, @datnumber, @B_id, 0, @fam, @SP_, 0, 0, 0, 0,0, @stfnom, @stfdate, @sp_br, @dck, @ContrName,
                          0, 0, 0, 0, 0, @sc_)
      set @tekb_id=@b_id              
    end                 
           
    if @nds=10      
    begin
      update #ResTable set NDS10 = NDS10+@ndsbase, NDS10sum = NDS10sum+round(@ndsbase - @ndsbase/1.1,2) where b_id=@tekb_id
      update #ResTable set NDS10Cost = NDS10Cost+@ndsbasezakup, NDS10Costsum = NDS10Costsum+round(@ndsbasezakup - @ndsbasezakup/1.1,2) where b_id=@tekb_id
    end 
    else if @nds=18
    begin
      update #ResTable set NDS18 = NDS18+@ndsbase, NDS18sum = NDS18sum+round(@ndsbase - @ndsbase/1.18,2) where b_id=@tekb_id
      update #ResTable set NDS18Cost = NDS18Cost+@ndsbasezakup, NDS18Costsum = NDS18Costsum+round(@ndsbasezakup - @ndsbasezakup/1.18,2) where b_id=@tekb_id
    end 
    update #ResTable set sp_ = sp_+@sp_,sc_=sc_+@sc_ where b_id=@tekb_id
    
  
    fetch next from @CURSOR into @nd ,@tekdatnom, @datnumber, @b_id, @master, @fam, @sp_, @ndsbase,
                                 @nds, @stfnom, @stfdate, @sp_br, @dck, @ContrName, @ndsbasezakup, @sc_

  end
  close @CURSOR
  
   
  select r.*, 
         NDS10 + NDS18 + NDS0 as SP,
         NDS10Cost + NDS18Cost +NDS0Cost as SC,
         SP_ - (NDS10 + NDS18 + NDS0)-- + isnull(Back,0)
         as Err
  from #ResTable r 
  --left join (select SUM(Sp) as Back,RefDatNom from NC where isnull(remark,'')='' group by RefDatNom) E on E.RefDatNom=r.DatNom   
  where NDS10 + NDS18 + NDS0<>0
  order by r.b_id                    
  
END