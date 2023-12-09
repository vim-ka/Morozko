CREATE PROCEDURE dbo.CheckPerson @P_ID int
AS
BEGIN

    insert into PSScores(p_id, stid)
    select distinct p_id,
           stnom - p_id * 100
    from kassa1
    where stnom not in (select stnom from PsScores) and
          p_id = @P_ID and
          oper in (10, 59)
          
    update PsScores set MUST = 0 where Must is null and P_ID=@P_ID

    update PsScores
    set MUST = isnull((select sum(round(k.plata/(1+k.nalog/100),2)) from
    Kassa1 k where k.oper = 59 and k.StNom = PsScores.StNom), 0)
    where P_ID=@P_ID
     
     
    update PsScores
    set MUST = MUST - ISNULL((select sum(round(k.plata/(1+k.nalog/100),2))
    from Kassa1 k where k.oper = 10 and k.StNom = PsScores.StNom), 0)
    where P_ID=@P_ID
     
    update PsScores set MUST = 0 where Must is null and P_ID=@P_ID
    
END