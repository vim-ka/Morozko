CREATE PROCEDURE LoadData.UnloadContractor @pin int, @ContrTip int, @Our_id int=23
AS
BEGIN

  if isnull(@our_id,0) = 0 set @Our_id=23

  if @ContrTip=1
  begin
    select d.upin as pin,d.brName as Name,d.brINN as INN,d.brKPP as KPP,d.brBIK as BIK, d.brBank as Bank,
           d.brCs as CS, d.brRs as RS, d.brPhone as Phone, d.gpAddr as factAddr,d.brAddr as urAddr, d.Worker as Phys, d.OKPO,
           c.ContrNum, c.ContrDate, c.Our_ID, c.NDS
    from Def d outer apply
         (select t.pin, t.ContrNum,t.ContrDate,t.Our_ID, t.NDS
         from (select pin,ContrNum,ContrDate,Our_ID,NDS, row_number() over (order by ContrDate desc) rn from DefContract where pin=d.Ncod and ContrTip=@ContrTip and Actual=1 and Our_id=@Our_id) t
         where t.rn = 1) c   
    
/*         (select top 1 c.pin, max(c.ContrDate) as ContrDate, c.gpOur_id as Our_ID,
          (select t.ContrNum from DefContract t
           where t.ContrTip=@ContrTip and t.Actual=1 and t.pin=c.pin 
             and isnull(t.ContrDate,'20150101')=(select max(isnull(t.ContrDate,'20150101')) from DefContract t where t.ContrTip=@ContrTip and t.Actual=1 and t.pin=c.pin)
           ) as ContrNum
          from DefContract c where d.ncod=c.pin and c.ContrTip=@ContrTip and c.Actual=1 group by c.pin, c.gpOur_ID) c*/
    where d.upin=@pin
  end 
 else
  if @ContrTip=2
  begin
    select d.upin as pin,d.brName as Name,d.brINN as INN,d.brKPP as KPP,d.brBIK as BIK, d.brBank as Bank,
           d.brCs as CS, d.brRs as RS, d.brPhone as Phone, d.gpAddr as factAddr,d.brAddr as urAddr, d.Worker as Phys, d.OKPO,
           c.ContrNum, c.ContrDate, c.Our_ID, c.NDS
    from Def d outer apply
         (select t.pin, t.ContrNum,t.ContrDate,t.Our_ID, t.NDS
         from (select pin,ContrNum,ContrDate,Our_ID as Our_ID, NDS, row_number() over (order by ContrDate desc) rn from DefContract where pin=d.pin and ContrTip=@ContrTip and Actual=1 and Our_id=@Our_id) t
         where t.rn = 1) c    
      
       
    where d.upin=@pin
  end
  else
  if (@ContrTip=3) or (@ContrTip=4)
  begin
    select d.upin as pin,d.brName as Name,d.brINN as INN,d.brKPP as KPP,d.brBIK as BIK, d.brBank as Bank,
           d.brCs as CS, d.brRs as RS, d.brPhone as Phone, d.gpAddr as factAddr,d.brAddr as urAddr, d.Worker as Phys, d.OKPO,
           c.ContrNum, c.ContrDate, c.Our_ID, c.NDS, c.NDS
    from Def d outer apply
         (select t.pin, t.ContrNum,t.ContrDate,t.Our_ID, t.NDS
         from (select pin,ContrNum,ContrDate,Our_ID as Our_ID,NDS, row_number() over (order by ContrDate desc) rn from DefContract where pin=d.pin and (ContrTip=3 or ContrTip=4) and Actual=1 and Our_id=@Our_id) t
         where t.rn = 1) c    
       
    where d.upin=@pin
  end
  
END