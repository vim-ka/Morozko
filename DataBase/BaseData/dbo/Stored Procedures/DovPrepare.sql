CREATE PROCEDURE dbo.DovPrepare @ag_id int, @Our_id int
AS
BEGIN
  
  declare @Nom1 int, @Nom2 int, @i int, @DovNom varchar(20), @Preffix varchar(10), @p_id int
  declare @ND DATETIME, @Srok int, @K int, @KFact int, @KRest int
  set @ND=dbo.today();
  
  set @Srok=35
  
  set @KFact=(select count(kassid) from kassa1 where op=@ag_id+1000 and oper=59 and nd between @ND-@Srok and @ND-1) -- 1.0*(select count(kassid) from kassa1 where op=@ag_id*1000 and nd between dbo.today()-36 and dbo.today()-1)/@srok
  
  set @K=(select count(dc.dck) from defcontract dc where dc.Our_id=@Our_ID and dc.BnFlag=0 and dc.Actual=1 and dc.ag_id=@ag_id)
    
  set @KRest=(select (Count(d.DovID)) from Dover d join DovOut do on do.DovOutID=d.DovOutID 
              where do.ag_id=@ag_id and do.Our_id=@Our_ID and @ND between do.NDBeg and do.NDEnd and d.DovStat=1)
  
  select @K as Clients, @KFact as DovUse, @KRest as DovRest, @Our_ID as Our_ID, @ag_id as ag_id, @Srok as Srok
END