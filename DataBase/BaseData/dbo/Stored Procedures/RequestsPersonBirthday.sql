CREATE PROCEDURE dbo.RequestsPersonBirthday
AS
BEGIN
	declare @nd datetime 
  set @nd=convert(date,getdate())
  select *,
  			 (select dname from deps where depid=(select depid from person where p_id=x.p_id)) [dname]
  from (
  select  p.PersID,
  				p.SecondName+' '+p.FirstName+' '+p.MiddleName [fio],
          p.FirstName+' '+p.MiddleName [io_],
          p.DateOfBirth,
          (select min(e.p_id) from person e where e.HRPersID=p.PersID and closed=0) [p_id]          
  from hrmain.dbo.pers p
  where not p.PersState in (-1,5)
  		  and dateadd(year,year(@nd)-year(p.DateOfBirth),p.DateOfBirth)
    		between dateadd(day, 0, @nd) and dateadd(day, 3, @nd)) x
END