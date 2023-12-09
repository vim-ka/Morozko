CREATE PROCEDURE dbo.GetProgramsForLauncher
@login varchar(50)
AS
BEGIN
 DECLARE @uin INT
	if exists(select * 
						from hrmain.dbo.WorksheetCurrentPermiss 
						where persid in (							
															select Hrpersid 
															from person 
															where p_id in (
																						 select p_id 
																						 from usrPwd 
																						 where login=@login
																						 )
														 )
						)
	begin
		delete from PermissCurrent 
		where prg=22 
					and uin in(
											select uin 
											from usrPwd 
											where login=@login
											)
		
		insert into PermissCurrent (uin,prg,permiss)
		select uin,22,1 
		from usrPwd 
		where login=@login
	end
SELECT @uin=uin FROM usrPwd p WHERE p.login=@login
IF @uin IS NULL SET @uin=-1

SELECT p.*,
       IIF(EXISTS(SELECT 1 FROM PermissCurrent pc WHERE pc.uin=@uin AND pc.Permiss & 1 <>0 AND p.Prg=pc.prg),CAST(1 AS bit),CAST(0 AS bit)) [hasPerms]
FROM Programs p
WHERE p.prg>0 AND p.ExeName<>''
ORDER BY [hasPerms] DESC,prg
							
END