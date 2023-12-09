CREATE function RetroB.BasCheckPricePrihod (@PrihodReqID int)
returns @res table (id int, msg varchar(100), spec int, prID int)
AS
begin
  insert into @res([id],[prID])
  select pd.PrihodRDetID [id],
  		 	 retrob.getbaspriceid(pd.prihodrdethitag,p.prihodrvendersid,p.Prihodrdefcontract,pd.prihodrdetcost,
                              iif(n.flgweight=1,
                              		iif(pd.prihodrdetweigth=0,pd.prihodrdetcost,pd.prihodrdetcost/pd.prihodrdetweigth),
                                  iif(n.netto=0,pd.prihodrdetcost,pd.prihodrdetcost/n.netto)),
                              convert(varchar,p.PrihodRDate,104))         
  from morozdata.dbo.PrihodReqDet pd
  join morozdata.dbo.PrihodReq p on pd.PrihodRID=p.PrihodRID
  left join morozdata.dbo.nomen n on n.hitag=pd.PrihodRDetHitag 
  where p.PrihodRID=@PrihodReqID 
  
  update a set a.spec=isnull(b.bpmid,0), 
  						 a.msg=iif(isnull(b.bpmid,0)=0,'Спецификация не найдена','Спецификация №'+cast(b.bpmid as varchar))
  from @res a
  left join retrob.basprices b on b.prid=a.prid
	
  return
end