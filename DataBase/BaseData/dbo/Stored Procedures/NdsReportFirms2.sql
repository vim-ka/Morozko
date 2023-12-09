CREATE PROCEDURE dbo.NdsReportFirms2 @FirmId int, @ND1 datetime, @ND2 datetime, @Param int
AS
BEGIN

declare @datnom1 bigint, @datnom2 bigint

set @datnom1=dbo.InDatNom(0,@ND1)
set @datnom2=dbo.InDatNom(99999,@ND2)

create table #TempTable (Datnom bigint,B_id int, sp money, base money, nds money)
      
create table #TempTable2 (B_id int, CountNak int,bezNDS money, nds money, PSum money,
                                    CountBNak int, bezNDS_ money, nds_ money, BSum money)

declare  @Count_r int, @bezNDS_r money, @nds_r money, @PSum money
declare  @Count_b int, @bezNDS_b money, @nds_b money, @BSum money                       

declare @TekB_ID int, @Datnom int,@B_id int, @sp money, @base money, @nds money
declare @Cursor Cursor
                           
if @FirmId > 0 /**************************************по выбранной фирме*********************************************/
begin

insert into  #TempTable (Datnom, B_id, sp, base, nds)
select  t.datnom,
          t.b_id,
          sum(t.stoim*(1+t.Extra/100)) as sp,
          round( sum(t.stoim*(1+t.Extra/100)/(1.0+t.nds/100.0)) ,2) as base,
          sum(t.stoim*(1+t.Extra/100))-round( sum(t.stoim*(1+t.Extra/100)/(1.0+t.nds/100.0)) ,2) as nds
from
       (select c.datnom,
               case when (@Param=1 and d.master<>0) then d.master else c.b_id end as b_id,
               c.fam,
               c.sp as sp_,
               c.extra,
               v.price*(v.kol+isnull((select sum(r.kol) from nv r join nc k on r.datnom=k.datnom 
                              where k.refdatnom in (select j.datnom from nc j join def d on j.b_id=d.pin 
                                                    where j.datnom>=@datnom1 and j.datnom<=@datnom2)
                              and isnull(k.remark,'')='' and k.refdatnom=v.datnom and r.tekid=v.tekid),0)) as stoim, 
               n.nds

         from nc c join nv v on c.datnom=v.datnom
                   join nomen n on v.hitag=n.hitag
                   join def d on c.b_id=d.pin
         where c.datnom>=@datnom1 and c.datnom<=@datnom2 and (c.Sp>0 or (c.Sp<0 and isnull(c.remark,'')<>'')) and  c.Tara<>1 and c.Frizer<>1 and c.Actn<>1 
               and c.ourid=@FirmID
        ) t
where t.stoim<>0
group by t.datnom,t.b_id
order by b_id
end
/*****************************************************по всем фирмам***********************************************************/
ELSE
begin

insert into  #TempTable (Datnom, B_id, sp, base, nds)
select  t.datnom,
          t.b_id,
          sum(t.stoim*(1+t.Extra/100)) as sp,
          round( sum(t.stoim*(1+t.Extra/100)/(1.0+t.nds/100.0)) ,2) as base,
          sum(t.stoim*(1+t.Extra/100))-round( sum(t.stoim*(1+t.Extra/100)/(1.0+t.nds/100.0)) ,2) as nds
from
       (select c.datnom,
               case when (@Param=1 and d.master<>0) then d.master else c.b_id end as b_id,
               c.fam,
               c.sp as sp_,
               c.extra,
               v.price*(v.kol+isnull((select sum(r.kol) from nv r join nc k on r.datnom=k.datnom 
                              where k.refdatnom in (select j.datnom from nc j join def d on j.b_id=d.pin 
                                                    where j.datnom>=@datnom1 and j.datnom<=@datnom2)
                              and isnull(k.remark,'')='' and k.refdatnom=v.datnom and r.tekid=v.tekid),0)) as stoim, 
               n.nds

         from nc c join nv v on c.datnom=v.datnom
                   join nomen n on v.hitag=n.hitag
                   join def d on c.b_id=d.pin
         where c.datnom>=@datnom1 and c.datnom<=@datnom2 and (c.Sp>0 or (c.Sp<0 and isnull(c.remark,'')<>'')) and  c.Tara<>1 and c.Frizer<>1 and c.Actn<>1 
        ) t
where t.stoim<>0
group by t.datnom,t.b_id
order by b_id

end

set @CURSOR  = Cursor scroll
for select * from #TempTable order by b_id, datnom
 /*Открываем курсор*/
open @CURSOR
 /*Выбираем первую строку*/
fetch next from @CURSOR into @Datnom,@B_id, @sp, @base, @nds
  set @TekB_ID=@B_id

  set @Count_r = 0
  set @bezNDS_r = 0
  set @nds_r = 0
  set @PSum = 0
  
  set @Count_b = 0
  set @bezNDS_b = 0
  set @nds_b = 0
  set @BSum  = 0
  
/*Выполняем в цикле перебор строк*/
while @@FETCH_STATUS = 0
begin
  if @B_id = @TekB_ID 
  begin
    if @sp>0 
    begin 
      set @Count_r = @Count_r + 1
      set @bezNDS_r = @bezNDS_r + @base
      set @nds_r = @nds_r + @nds
      set @PSum =@PSum + @sp
    end
    else
    begin
      set @Count_b =@Count_b + 1
      set @bezNDS_b =@bezNDS_b + @base
      set @nds_b =@nds_b + @nds
      set @BSum =@BSum + @sp
    end
  end
  else
  begin
    insert into #TempTable2 (B_id, CountNak, bezNDS, nds, PSum, CountBNak, bezNDS_, nds_, BSum) 
                     values (@TekB_ID,@Count_r,@bezNDS_r,@nds_r,@PSum, @Count_b,@bezNDS_b,@nds_b,@BSum )                   
    set @TekB_ID=@B_id

    if @sp>0 
    begin 
      set @Count_r =  1
      set @bezNDS_r =  @base
      set @nds_r =  @nds
      set @PSum = @sp
      
      set @Count_b = 0
      set @bezNDS_b = 0
      set @nds_b = 0
      set @BSum  = 0
    end
    else
    begin
      set @Count_r = 0
      set @bezNDS_r = 0
      set @nds_r = 0
      set @PSum = 0
      
      set @Count_b = 1
      set @bezNDS_b = @base
      set @nds_b = @nds
      set @BSum = @sp
    end 
    
  end
  
  fetch next from @CURSOR into @Datnom,@B_id, @sp, @base, @nds 
end
insert into #TempTable2 (B_id, CountNak, bezNDS, nds, PSum, CountBNak, bezNDS_, nds_, BSum) 
                 values (@TekB_ID,@Count_r,@bezNDS_r,@nds_r,@PSum, @Count_b,@bezNDS_b,@nds_b,@BSum )  
close @CURSOR
  

  select t.B_id,d.gpName as fam, t.CountNak, t.bezNDS, t.nds, t.PSum,
                                 t.CountBNak, t.bezNDS_, t.nds_ ,t.BSum, 
                                        t.PSum + t.BSum  as Allsum, @Param as mas
  from #TempTable2 t join Def d on t.b_id=d.pin
  order by fam
  
END