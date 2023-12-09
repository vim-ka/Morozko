CREATE PROCEDURE dbo.ReCalcAllPSScores
AS
BEGIN

  update PsScores set MUST = 0 


  declare @KassID int

  declare TC cursor FAST_FORWARD for
  select Kassid 
  from Kassa1 where p_id > 0 and oper in (10,59) and StNom is null  
  
  OPEN TC 
  FETCH NEXT FROM TC INTO @Kassid  
  
  while @@FETCH_STATUS = 0 
  begin
    update Kassa1
    set StNom = p_id * 100 + 9
    where KassID=@KassID
    
    FETCH NEXT FROM TC INTO @Kassid  
  end
  Close TC;
  deallocate TC;
  
  SET IDENTITY_INSERT dbo.Person ON

  insert into Person(p_id, fio, hrpersid)
  select distinct p_id, max(fam), -555
  from kassa1 
  where oper in (10,59) and p_id not in (select p_id from Person) and p_id<>0
  group by p_id

  SET IDENTITY_INSERT dbo.Person OFF
 
  insert into PSScores(p_id, stid)
  select distinct p_id,
       stnom - p_id * 100
  from kassa1
  where stnom not in (select stnom from PsScores) and
      p_id > 0 and
      oper in (10, 59)

  update PsScores set MUST = 0 where Must is null

  update PsScores
  set MUST = isnull((select sum(round(k.plata/(1+k.nalog/100),2)) from
  Kassa1 k where k.oper = 59 and k.StNom = PsScores.StNom), 0)

  update PsScores
  set MUST = MUST - ISNULL((select sum(round(k.plata/(1+k.nalog/100),2))
  from Kassa1 k where k.oper = 10 and k.StNom = PsScores.StNom), 0)

  update PsScores set MUST = 0 where Must is null


  update PsScores set OverMust = (
                  select r.Plata-d.Plata as OverDolg
                  from
                 (select p_id, StNom, sum(plata) as Plata 
                  from kassa1 
                  where oper=59 and (plata<0 or (nd<getdate()-1-(select s.DaysDelay from PsScores s where s.p_id=Kassa1.p_id and s.StID=Kassa1.StNom-p_id*100 and s.DaysDelay<>0)))
                  group by p_id, StNOm) r
                  full join
                  (select p_id,StNom, sum(plata) as Plata from kassa1 where oper=10
                  group by p_id, StNom) d
                  on r.p_id=d.p_id and r.StNom=d.StNom
                  where PsScores.p_id=r.p_id and PsScores.StID=r.StNom-r.p_id*100)
                 
  update PsScores set Overmust=0 where (overmust is null) or (overmust<0);
  
END