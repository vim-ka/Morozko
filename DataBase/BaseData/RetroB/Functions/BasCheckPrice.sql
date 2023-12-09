CREATE FUNCTION [RetroB].BasCheckPrice (@DCK int, @Hitag int, @Cost money)
RETURNS varchar(100)
AS
BEGIN
  declare @Ncod int, @CostRule money, @ND datetime, @BPMid int, @Mess varchar(100)
  set @ND=dbo.today()
  
  set @Ncod=(select pin from defcontract where dck=@DCK)
  
  
  set @BPMid=
  isnull((select min(m.BPMid) from [RetroB].BasPricesMain m join [RetroB].BasPrices p on m.BPMid=p.BPMid
                                                            join [RetroB].BasVend v on m.BPMid=v.BPMid 
  where m.Actual = 1
         and ((v.Ncod = @Ncod and v.DCK=0) or v.DCK = @DCK )
         and p.hitag = @Hitag                                               
         and @ND between p.Day0 and p.Day1 
         and abs(p.FinalCost - @Cost)<=0.03),0)
         
  if @BPMid = 0 set @Mess = 'Спецификации не найдено'        
  else set @Mess='Спецификация №'+cast(@BPMid as varchar)
 
  Return @Mess
END