CREATE PROCEDURE LoadData.UnloadRests @ND datetime, @Our_ID int
AS
BEGIN
   declare @FirmGroup int
   set @FirmGroup=(select FirmGroup from FirmsConfig where Our_ID=@Our_ID)

  if @ND < dbo.today() --остатки из архива

  select t.hitag, 
         iif(n.flgWeight=0,'шт','кг') as EdIzm, 
         ROUND(avg(iif(n.flgWeight=0,t.price,t.price/t.weight)),2) as price1unit,
         round(avg(iif(n.flgWeight=0,t.cost,t.cost/t.weight)),2) as cost1unit,
         sum(iif(n.flgWeight=0,t.EveningRest,t.weight*t.EveningRest)) as rest,
         sum(iif(n.flgWeight=0,t.EveningRest,t.weight*t.EveningRest)) as kolvo,
         sum(t.cost*t.EveningRest) as sm,
         sum(t.cost*t.EveningRest) as cost,
         n.name 
        
  from MorozArc.dbo.ArcVI t join nomen n on t.hitag=n.hitag 
                            join DefContract c on t.DCK=c.DCK
                           -- join Gr g on n.Ngrp=g.Ngrp
                           -- join SkladList l on l.SkladNo=a.Sklad
                           -- join FirmsConfig f on c.Our_ID=f.Our_ID
  where t.WorkDate = @ND 
        and c.Our_ID=@Our_ID
        --and f.FirmGroup=@Our_ID
        and c.ContrTip<>5 
        and t.hitag not in (2296,90858)
        and c.BnFlag=1
        --and g.AgInvis=0 
        --and l.Discard=0
        --and ((a.Weight<>0 and a.Weight*a.EveningRest<>0) or a.EveningRest<>0)        
   
  group by t.hitag, n.flgWeight,  n.name            
  having sum(iif(n.flgWeight=0,t.EveningRest,t.weight*t.EveningRest))<>0
  
  else --текущие остатки
  
    select t.hitag,
         iif(n.flgWeight=0,'шт','кг') as EdIzm, 
         ROUND(avg(iif(n.flgWeight=0,t.price,t.price/t.weight)),2) as price1unit,
         round(avg(iif(n.flgWeight=0,t.cost,t.cost/t.weight)),2) as cost1unit,
         sum(iif(n.flgWeight=0,t.morn,t.weight*t.morn)) as rest,
         sum(iif(n.flgWeight=0,t.morn,t.weight*t.morn)) as kolvo,
         sum(t.cost*t.morn) as sm,
         sum(t.cost*t.morn) as cost,
         n.name 
    from tdvi t join nomen n on t.hitag=n.hitag
                join DefContract c on t.DCK=c.DCK  
    where t.Our_id=@Our_id and c.ContrTip<>5 and c.BnFlag=1 and t.hitag not in (2296,90858)
    group by t.hitag, n.flgWeight, n.name
    having sum(iif(n.flgWeight=0,t.morn,t.weight*t.morn))<>0
END