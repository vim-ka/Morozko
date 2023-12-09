CREATE function [RetroB].[BasCheckPricePrihod_Debug] (@PrihodReqID int)
returns @res table (id int, [tekid] int, msg varchar(100), spec int, PrihodCost decimal(15,5),[cost1kg] decimal(15,5), prID int, BaseCost decimal(15,5),FinalCost decimal(15,5),flgWeight bit)
AS
begin
  declare @tmp table ([id] int, [hitag] int, [cost] decimal(15,5), [ncod] int, [dck] int, [nd] datetime, [tekid] int, [cost1kg] decimal(15,5), flgWeight bit)
  insert into @tmp
  select pd.PrihodRDetID [id],
  		 pd.PrihodRDetHitag [hitag],
         pd.PrihodRDetCost [cost],
         dc.Ncod,
         p.PrihodRDefContract [dck],
         DATEADD(day, DATEDIFF(day, 0, p.PrihodRDate),0)  [nd],
         isnull(i.id,0) [tekid],
         iif(pd.PrihodRDetWeigth = 0,0,round(pd.PrihodRDetCost/pd.PrihodRDetWeigth, 5)) [cost1kg],
         iif(pd.PrihodRDetWeigth > 0, 1, 0)         
  from morozdata.dbo.PrihodReqDet pd
  join morozdata.dbo.PrihodReq p on pd.PrihodRID=p.PrihodRID
  left join morozdata.dbo.defcontract dc on dc.dck=p.PrihodRDefContract
  left join morozdata.dbo.inpdet i on i.hitag=pd.PrihodRDetHitag and i.ncom=pd.PrihodRDetNCom
  left join morozdata.dbo.nomen n on n.hitag=pd.PrihodRDetHitag 
  where p.PrihodRID=@PrihodReqID 
	
  insert into @res
  select distinct y.id, y.tekid, y.msg, y.spec, y.cost, y.cost1kg, y.prID, 
  			 isnull((select a.BaseCost from [RetroB].BasPrices a where a.prid=y.[prID]),0) [basecost], 
         isnull((select a.FinalCost from [RetroB].BasPrices a where a.prid=y.[prID]),0) [finalcost], 
         y.flgWeight
  from (
  select z.id,
  			 z.tekid,
         iif(z.[spec]=0,'Спецификация не найдена','Спецификация №'+cast(z.[spec] as varchar)) [msg],
  			 z.[spec],  				
  			 z.cost,
             z.cost1kg,
         iif(z.[spec]>0,
         (select top 1 bp.prID 
         	from [RetroB].BasPricesMain m 
         	join [RetroB].BasPrices bp on m.BPMid=bp.BPMid
          join [RetroB].BasVend v on m.BPMid=v.BPMid 
  				where m.Actual = 1
         				and ((v.Ncod = z.Ncod and v.DCK=0) or v.DCK = z.dck)
         				and bp.hitag = z.Hitag                                               
         				and z.nd >= bp.Day0 and z.nd <= bp.Day1 
         				and abs(bp.FinalCost - iif(bp.flgWeight=1, z.cost1kg,z.cost))<=0.03
                and bp.BPMid=z.[spec])
          ,0) [prID],
          z.flgWeight
  from  
  (
  select c.id,
         c.tekid,
         c.Ncod,
         c.DCK,
         c.ND,
         c.Hitag,
         c.cost as [cost],
         c.cost1kg as [cost1kg],
         c.flgWeight,
 		 isnull(
         (select min(m.BPMid) 
         	from [RetroB].BasPricesMain m 
         	join [RetroB].BasPrices bp on m.BPMid=bp.BPMid
            join [RetroB].BasVend v on m.BPMid=v.BPMid 
  				where m.Actual = 1
         				and ((v.Ncod = c.Ncod and v.DCK=0) or v.DCK = c.dck)
         				and bp.hitag = c.Hitag                                               
         				and c.nd>=bp.Day0 and c.nd<=bp.Day1
         				and abs(bp.FinalCost - iif(bp.flgWeight=1, c.cost1kg, c.cost))<=0.03)
          ,0) [spec]
  from @tmp [c]) z) y
  
	
  return
end