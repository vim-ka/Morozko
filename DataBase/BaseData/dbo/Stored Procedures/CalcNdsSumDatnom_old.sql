CREATE PROCEDURE dbo.[CalcNdsSumDatnom_old] @kassid int
AS
BEGIN
  declare @Plata money, @nvid int, @sp money, @payall money, @PlataTek money, @KassidTek int, @datnom int, @i integer
  

  if object_id ('#TempNV') is not null drop table #TempNV;

  create table #TempNV (nd datetime,kassid int, nvid int, datnom int, hitag int, name varchar(100), price money, qty decimal(10,3),
                        sp money, nds int, pay money, ndssp money, payall money, tekid int);
                        
                        
  insert into #TempNV  (nd, kassid, nvid, datnom, hitag, name, price, qty, sp, nds, pay, ndssp, payall, tekid)
  select k.nd, 0, v.nvid, c.datnom, v.hitag, n.name, (1+c.extra/100)*v.price, v.kol,
         round((1+c.extra/100)*v.price*v.kol,2), n.nds, 0, 0/*round((1+c.extra/100)*v.price*(v.kol-v.kol_b)*n.nds/(100+n.nds),2)*/, 0, v.tekid
  from kassa1 k join nc c on k.sourdatnom=c.datnom
                join nv v on c.datnom=v.datnom                   
                join nomen n on v.hitag=n.hitag
  where k.kassid=@kassid or (k.origrecn=@kassid and k.plata>0)
  
  set @datnom=(select max(datnom) from #TempNV)
  
  create table #TempKassa(kassid int, plata money)  
  
  insert into #TempKassa (kassid,plata) 
  --select -1, sum(plata) as plata from kassa1 where sourdatnom=@datnom and oper=-2 and kassid<@kassid having sum(plata)>0
  select kassid, plata from kassa1 where sourdatnom=@datnom and oper=-2 and kassid<@kassid and plata<>0
  union
  select kassid, plata from kassa1 where kassid=@kassid and plata<>0
  union
  select kassid, plata from kassa1 where origrecn=@kassid and plata<>0
   
    
  declare Nakl cursor local for
  select nvid, sp
  from #tempNV order by nvid
  select * from #TempNV
  open Nakl  
  
  declare Kassa cursor local for
  select kassid, plata
  from #TempKassa order by kassid
    
  select * from #TempKassa

  open Kassa  
    
  fetch next from Nakl
  into @nvid, @sp 

  fetch next from Kassa
  into @KassidTek, @PlataTek 
  
  set @payall=0
  set @i=1
  
  while @@fetch_status = 0 and @PlataTek<>0
  begin
    while @@fetch_status = 0 and @PlataTek<>0
    begin  
      if @sp - @payall <= @PlataTek and @payall<@sp
      begin
        update #tempNV set pay=@sp - @payall, payall=payall+@sp-@payall, kassid=@KassidTek,
               ndssp=round(price*qty*nds/(100+nds),2)
        where nvid=@nvid
        
        set @PlataTek = @PlataTek - @sp + @payall
        set @payall=0
        fetch next from Nakl
        into @nvid, @sp   
      end
      else
      if @payall<@sp
      begin
        insert into #TempNV (nd, kassid, nvid, datnom, hitag, name, price, qty, sp, nds, pay, ndssp, payall)
        select nd, @KassidTek, @i, datnom, hitag, name, price, qty, sp, nds, @PlataTek, round(@PlataTek*nds/(100+nds),2), @PlataTek 
        from #TempNV where nvid = @nvid
      
        set @i=@i+1       
        set @payall = @payall + @PlataTek
        set @PlataTek = 0
      end   
      else 
      if @sp<0 and @PlataTek > 0 and abs(@sp - @payall) <= @PlataTek and @payall<abs(@sp)
      begin
        update #tempNV set pay=@sp - @payall, payall=payall+@sp-@payall, kassid=@KassidTek,
               ndssp=round(price*qty*nds/(100+nds),2)
        where nvid=@nvid
        
        set @PlataTek = @PlataTek - @sp + @payall
        set @payall=0
        fetch next from Nakl
        into @nvid, @sp   
      end
      else
      if @sp<0 and @PlataTek > 0 and @payall<abs(@sp)
      begin
        insert into #TempNV (nd, kassid, nvid, datnom, hitag, name, price, qty, sp, nds, pay, ndssp, payall)
        select nd, @KassidTek, @i, datnom, hitag, name, price, qty, sp, nds, @PlataTek, round(@PlataTek*nds/(100+nds),2), @PlataTek 
        from #TempNV where nvid = @nvid
      
        set @i=@i+1       
        set @payall = @payall + @PlataTek
        set @PlataTek = 0
      end   
      else 
      begin
        fetch next from Nakl
        into @nvid, @sp
        set @payall=0
      end
    end
    fetch next from Kassa
    into @KassidTek, @PlataTek 
  end  
  
  select rank() over (order by name, nvid desc) as rank, nd, nvid, dbo.InNnak(datnom) as NNak, 
  dbo.DatNomInDate(datnom) as NNakDate, hitag, name, price, qty, sp, nds, round(pay,2) as Pay, ndssp, kassid, payall, tekid
  from #tempNV 
  where kassid=@kassid
  order by rank 


END