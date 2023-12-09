CREATE PROCEDURE NearLogistic.Import2BL @mrID varchar(14), @ReqOrder int, @tmArrival char(5), @mhid varchar(200)='', @NotSorted bit=0,
                                          @CalcDist float=0.0, @Distance int=0, @Type int 
AS
BEGIN

  --IF @mrID = '0' 
  if @Type=0
  begin
  
    UPDATE [dbo].Marsh 
    SET 
      TimeGo = dbo.today()+cast(@tmArrival as datetime),
      CalcDist = iif(@CalcDist>0.0, @CalcDist, CalcDist),
      Dist = iif(@CalcDist>0.0, @CalcDist*1.05, Dist)
    WHERE
    mhid in (select k from dbo.Str2intarray(@mhid));
    
    UPDATE 
      NearLogistic.MarshRequests  
    SET 
      ReqOrder = @ReqOrder,
      tmArrival = @tmArrival  
    WHERE 
    mhid in (select k from dbo.Str2intarray(@mhid));

    
   
    if not exists(select 1 from NearLogistic.MarshRequests where mhid in (select k from dbo.Str2intarray(@mhid)) and ReqID=-1 and ReqType=-1)
    INSERT INTO NearLogistic.MarshRequests
    (mhID, ReqID, ReqType, ReqAction, ReqOrder, DT, OP, Comp, PINTo, PINFrom, Cost_,  Weight_,  Volume_,  ReqRemark,
     KolBox_, ag_id, tmArrival,  DelivCancel,  ReqND,  liter_id,  distance) 
     select  s.k, -1, -1, s.k, @ReqOrder, 0, 0, '-', 16256, 0, 0,  0,  0,  'старт',
            0, 0, '',  0,  dbo.today(),  0, @Distance  
     from dbo.Str2intarray(@mhid) s;      
    else
    update NearLogistic.MarshRequests set distance=@Distance where mhid in (select k from dbo.Str2intarray(@mhid)) and ReqID=-1 and ReqType=-1;
    
  end
  ELSE
  begin
    declare @mrIDint int
    
    set @mrIDint=convert(int, left(@mrID, 7))
    
    --if @NotSorted = 0
    UPDATE 
      NearLogistic.MarshRequests  
    SET 
      ReqOrder = @ReqOrder,
      tmArrival = @tmArrival,
      Distance=@Distance  
    WHERE 
      mrID = @mrIDint;
    /*else  
       UPDATE 
         NearLogistic.MarshRequests  
       SET 
         tmArrival = @tmArrival  
       WHERE 
         mrID = @mrIDint;
     */
    end
END