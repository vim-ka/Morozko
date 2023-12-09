CREATE PROCEDURE NearLogistic.TariffClientFind @mhid int, @bill_idIn int, @force bit
AS
BEGIN

  --SET @mhid = 349295
  declare @bill_id int, @casher_id int, @smreq money
  if object_id('temp_db..#NeedIDS') is not null drop table #NeedIDS
  create table #NeedIDS (bill_id int, casher_id int);
  insert into #NeedIDS (bill_id, casher_id)
  select b.bill_id,b.casher_id from NearLogistic.billsSum b
  where b.mhid=@mhid or b.bill_id=@bill_idIn

  declare CursorBill cursor local fast_forward
  for select bill_id,casher_id from #NeedIDS 
    
  open CursorBill
  
  fetch next from CursorBill into @bill_id, @casher_id
  while @@FETCH_STATUS = 0 
  begin
      declare @TeknlTariffParamsID int
      declare @weight float
      declare @SecondDriver bit, @SpedDrID int, @ListNo int, @ListNoSped int
      declare @msg varchar(500)
      set @msg=''
      
      select @TeknlTariffParamsID = m.nlTariffParamsID
      from NearLogistic.billsSum m where m.bill_id=@bill_id  
      
      if (@TeknlTariffParamsID) = 0 or (@force = 1)
      begin
        declare @Sped BIT = 0, @ttID INT = 0, @nlVehCapacityID INT = 0, 
                @CalcDist FLOAT = 0.0, @is_Old BIT = 0

        select @ttID = c.ttID, 
               @nlVehCapacityID = v.nlVehCapacityID,
               @CalcDist = isnull(m.realdist/1000.0,0),
               @weight = m.mas,
               @is_Old=m.is_Old,
               @Sped = iif((a.SpedDrID<>0), 1, 0)
        from  NearLogistic.billsSum m join NearLogistic.marshrequests_cashers c on m.casher_id=c.casher_id
                     join [dbo].marsh a on m.mhid=a.mhid
                     join vehicle v on a.v_id=v.v_id
        where m.bill_id = @bill_id
        --Возьмем @nlVehCapacityID не по транспорту, а по загрузке рейса
        select @nlVehCapacityID=n.nlVehCapacityID from [NearLogistic].nlVehCapacity n where n.WeightMin<@weight and @weight<=n.WeightMax
        
        --print cast(@nlVehCapacityID as varchar)
         
        if (@TeknlTariffParamsID = 0) or (@force = 1)
        begin
          set @TeknlTariffParamsID = isnull((select d.nlTariffParamsID 
                                         from [NearLogistic].nlTariffs t join [NearLogistic].nlTariffsDet d on t.nlTariffsID=d.nlTariffsID
                                         where t.ttID=@ttID and @CalcDist between t.DistStart and t.DistEnd and t.withSped=@Sped
                                               and d.nlVehCapacityID=@nlVehCapacityID), 0)
          
          if ISNULL(@is_Old,0)=0
          begin
             if @casher_id=2653
             begin
               set @smReq=isnull((select sum(mf.cost) 
                                 from NearLogistic.billsSum bs join marsh m on bs.mhid=m.mhid 
                                                               join NearLogistic.MarshRequests_free mf on m.mhid=mf.mhid 
                                 where bs.bill_id=@bill_id),0)
             END 

              
/*
             update NearLogistic.billsSum set nlTariffParamsID = @TeknlTariffParamsID,
                                              req_pay = iif(@casher_id=2653,@smReq*0.105, NearLogistic.Bill1CalcFact(@bill_id, 0.0, 0))
                                              --req_pay =  NearLogistic.Bill1CalcFact(@bill_id, 0.0, 0)
                                          where bill_id=@bill_id
*/
              


             update NearLogistic.billsSum 
                set nlTariffParamsID = @TeknlTariffParamsID
              where bill_id=@bill_id

             DECLARE @s MONEY 
             SET @s = NearLogistic.Bill1CalcFact(@bill_id, 0.0, 0)
             update NearLogistic.billsSum 
                set req_pay = iif(@casher_id=2653,@smReq*0.105, @s)
              where bill_id=@bill_id
               
              /*  --для проверки
                declare  @b int 
                SET @b = (SELECT pd.Pay1Km
                            from [NearLogistic].BillsSum m join [dbo].marsh a on m.mhid=a.mhid
                            left join Drivers r on a.drId=r.drId
                            left join vehicle h on a.v_id=h.v_id
                            left join NearLogistic.nlTariffParams pd on pd.nlTariffParamsID=m.nlTariffParamsID
                            left join NearLogistic.nlTariffsDet d on pd.nlTariffParamsID=d.nlTariffParamsID
                            left join NearLogistic.nlTariffs t on d.nlTariffsID=t.nlTariffsID                
                           WHERE m.bill_id=@bill_id )

              PRINT @bill_id
              PRINT @s  
              PRINT @b    
              */


          end   
        end 
      end
     
      select @msg=t.TariffName  
      from  NearLogistic.billsSum m
      left join [NearLogistic].nlTariffsDet d on d.nlTariffParamsID=m.nlTariffParamsID
      left join [NearLogistic].nlTariffs t on t.nlTariffsID=d.nlTariffsID
      where m.bill_id=@bill_id
      
      insert into NearLogistic.MarshRequestsOperationsLog(op,mhid,mhid_old,ids,ids_,operationType,remark) 
      values(0,@mhid,@bill_id,'','',9,iif(@force=1,'Принудительно - счет -','Вручную - счет -')+isnull(@msg,''))
    
  
      fetch next from CursorBill into @bill_id, @casher_id
  end
  close  CursorBill;
  deallocate CursorBill;
           
END