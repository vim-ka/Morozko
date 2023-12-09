-- drop procedure CorrectMobZakaz;

CREATE procedure CorrectMobZakaz 
  @B_ID int, @CompName varchar(30), 
  @Dck int=0, @Force_ag_id int=0,
  @OP int=0,
  @StfNom varchar(10)='', 
  @StfDate datetime=NULL, @DocNom varchar(10)='', @DocDate datetime=NULL
as
declare @DepId int, @Sv_ID int, @Ag_ID int, @n0 int, @n1 int, @Datnom1 int, @Datnom2 int
declare @Hitag int, @Qty int, @Prognoz decimal(12,3)
declare @OrdStick bit, @nds int, @TekRest int, @TekSell int, @MinRest int
declare @TekND datetime
declare @Price decimal(12,2)
begin
  
  SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
  begin transaction Correct;  
  
  if @B_ID = 0 set @B_ID=(select pin from DefContract where DCK=@DCK)

  set @TekND=(SELECT dateadd(day, datediff(day,0,getdate()),0));
  
  set @n0=dbo.InDatNom(1,@TekND);
  set @n1=dbo.InDatNom(9999,@TekND);
  set @Datnom1=dbo.InDatnom(0, @TekND-2);
  set @Datnom2=dbo.InDatnom(9999, @TekND);

  declare @SavedZakaz float; set @SavedZakaz=0;
  if @Force_ag_id=0 begin
    set @OrdStick=0;
    set @ag_id=@Force_ag_id; 
  end else begin
    set @OrdStick=1;
    set @Ag_id = (select d.Ag_id from DefContract d where d.DCK=@DCK);
  end;

  set @Sv_id = (select a.sv_ag_id from agentlist a where a.ag_id=@Ag_ID);   
  set @DepID = (select s.DepID from agentlist s where s.ag_id=@Ag_id);     

  create table #h(depid int, hitag int not null, MinRest int );
  insert into #h values(1,18867,21);
  insert into #h values(1,14696,36);
  insert into #h values(1,13497,32);
  insert into #h values(1,13500,24);
  insert into #h values(1,15146,24);
  insert into #h values(1,21113,24);
  insert into #h values(1,11524,24);
  insert into #h values(1,14862,6);
  create index htemp_idx on #h(depid, hitag);

  if (@DepID = 1) and (exists (select nom from frizer where DCK = @Dck and ffid=2)) and (exists(select * from zakaz where compname=@Compname)) 
     and @B_ID not in (18721,15861,14895,23587)
  begin -- городской отдел. Для него впиливаем принудительно товары по списку.
/*    declare C1 cursor fast_forward for 
      select #h.hitag, nm.nds, max(v.price) as Price, #h.MinRest 
      from 
        #h 
        inner join tdvi v on v.hitag=#h.hitag and #h.depid=@depid
        inner join SkladList SL on SL.SkladNo=v.Sklad
        inner join Nomen nm on nm.hitag=#h.hitag
      where 
        v.morn-v.sell+v.isprav-v.bad-v.rezerv > 0
        and V.LOCKED=0
        and SL.skg not in (4,9,10,22,25) -- список накопителей, брака и оборудования
        and sl.Locked=0 -- заблокированный склад пропускаем
        and sl.Discard=0  -- отмененный склад пропускаем
      group by
        #h.hitag, nm.nds, #h.MinRest ;
      
    open C1;
    fetch next from C1 into @Hitag, @Nds, @Price, @MinRest;
    while (@@FETCH_STATUS=0) begin    
    -- Проверка: может, сегодня уже что-то продали текущему покупателю из списка?
      /*if not EXISTS(select * from nv inner join nc on nc.datnom=nv.datnom 
      where nv.hitag=@hitag and nc.b_id=@b_id and nv.kol>0) 
      and*/
*//*      if not exists(select * from zakaz where compname=@Compname and hitag=@Hitag)
      begin
      
        set @TekRest=isnull((select qty from Rests where pin=@B_ID and ND>=@TekND),0);
        
        set @TekSell=isnull((select sum(nv.kol) from nv join nc on nv.datnom=nc.datnom
           where nc.Datnom between @Datnom1 and @Datnom2 and nc.b_id=@B_ID 
           and nv.Hitag=@Hitag),0);
           
        set @Prognoz=@MinRest-@TekRest-@TekSell;
        
        if @Prognoz>0 begin
           insert into AutoOrder (ND,b_id,hitag,Qty,QtyAdd,Prognoz) 
             values (GETDATE(), @B_ID, @Hitag, 0, @Prognoz, @Prognoz);
           exec SaveZakazMob2 @B_ID, @CompName, @Hitag, @Prognoz, @Price, @SavedZakaz, 
             @Nds, 0, @OP, @Force_ag_id, @DCK, @StfNom, @StfDate, @DocNom, @DocDate
        end;
      end;
      fetch next from C1 into @Hitag, @Nds, @Price, @MinRest;
    end;
    close C1;
    deallocate C1;   */
    set @DepID=1;
  end;

  -- сетевой отдел. Для него продажи товаров из списка, возможно, увеличим.
  else if (@DepID=55) 
  begin
    declare @QtyAdd int
    declare @TekID int, @Rest int, @Delta int, @QtyTek int
    
    set @Datnom1=dbo.InDatnom(0, @TekND-20);
    set @Datnom2=dbo.InDatnom(9999, @TekND);
  
    declare C1 cursor fast_forward for 
      select z.hitag, sum(z.Qty) as Qty
      from Zakaz z 
      where z.CompName=@CompName and z.B_ID=@B_ID
      group by z.hitag
    open C1;
    fetch next from C1 into @Hitag, @Qty;
    
    while (@@FETCH_STATUS=0) begin    
    
      set @Prognoz=isnull((select sum(nv.kol) from nv join nc on nv.datnom=nc.datnom
         where nc.Datnom between @Datnom1 and @Datnom2 and nc.b_id=@B_ID 
         and nv.Hitag=@Hitag),0)*3/21 - isnull((select qty from Rests where pin=@B_ID and ND>=@TekND),0)

      set @QtyAdd = Round((1.2*@Prognoz - @Qty),0)     
      if @QtyAdd>0 begin
        
        declare C2 cursor fast_forward for 
        select z.tekid, z.Qty, (t.morn-t.sell+t.isprav-t.rezerv-t.bad) - (select sum(Qty) from zakaz where tekid=@tekid) as Rest 
        from Zakaz z inner join tdvi t on z.TekID=t.id
        where z.CompName=@CompName and z.B_ID=@B_ID and z.hitag=@Hitag
        
        open C2;
        fetch next from C1 into @TekID, @QtyTek, @Rest;   
               
        while (@@FETCH_STATUS=0) and (@QtyAdd>0) begin    
        
          if @Rest<=@QtyAdd set @Delta=@Rest;
          else set @Delta=@QtyAdd 
        
          if @Delta>0 begin
          
            insert into AutoOrder (ND,b_id,hitag,Qty,QtyAdd,Prognoz) 
            values (GETDATE(), @B_ID, @Hitag, @Qty, @Delta, @Prognoz); 
          
            update Zakaz set Qty=Qty+@Delta where TekID=@TekID and CompName=@CompName
            set @QtyAdd=@QtyAdd - @Delta 
          end  
          
          fetch next from C2 into @TekID, @QtyTek, @Rest;   
          
        end  
        close C2;
        deallocate C2;
      end;
      fetch next from C1 into @Hitag, @Qty;
    end; -- while

    close C1;
    deallocate C1;
  end
  Commit;
end