CREATE PROCEDURE dbo.ShiftStNom
@p_id int 
AS
declare @tranname varchar(10)
set @tranname='ShiftStNom'
begin tran @tranname
	declare @er int
	set @er=0
	update kassa1 
		set kassa1.StNom=kassa1.p_id*100 + kassa1.StNom % 100 
	where p_id=@p_id and Kassa1.StNom/100 - Kassa1.StNom%100/100<>@p_id
	set @er=@@error+@er
  
  insert into PSScores(p_id, stid)
  select distinct p_id,
       stnom - p_id * 100
  from kassa1
  where stnom not in (select stnom from PsScores) and
        p_id = @p_id and
        oper in (10, 59)
  set @er=@@error+@er      
      
  update PsScores set MUST = 0 where Must is null and p_id = @p_id
  set @er=@@error+@er

  update PsScores
  set MUST = isnull((select sum(round(k.plata/(1+k.nalog/100),2)) from
  Kassa1 k where k.oper = 59 and k.StNom = PsScores.StNom), 0) where p_id = @p_id
  set @er=@@error+@er
 
 
  update PsScores
  set MUST = MUST - ISNULL((select sum(round(k.plata/(1+k.nalog/100),2))
  from Kassa1 k where k.oper = 10 and k.StNom = PsScores.StNom), 0) where p_id = @p_id
  set @er=@@error+@er
  
  update PsScores set MUST = 0 where Must is null and p_id = @p_id
  set @er=@@error+@er
  
if @er=0 
	begin
		commit tran @tranname
		print 'Успех'
	end
else
	begin
		rollback tran @tranname
		print 'Откат'
	end