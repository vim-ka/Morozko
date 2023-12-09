-- возвращает следущий свободный код для номенклатуры
CREATE PROCEDURE dbo.GetHitagNomen @Hit int out
AS
BEGIN
	set @Hit=(select top 1 nom.hh  
						from (select 	case when ROW_NUMBER() OVER(ORDER BY hitag) in (select hitag from Nomen) 
															 then 0
															 else  ROW_NUMBER() OVER(ORDER BY hitag)
													end hh
									from Nomen) nom
						where nom.hh>0)
	if @Hit=0 set @Hit=(select max(hitag)+1 from Nomen);
  
	select @Hit 
END