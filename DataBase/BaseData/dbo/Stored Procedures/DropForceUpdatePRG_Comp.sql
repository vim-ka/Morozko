CREATE PROCEDURE dbo.DropForceUpdatePRG_Comp
@Comp varchar(100),
@Prg int
AS
BEGIN
  update LaunchCompPrg set 	ForceUpd=0,
														LastUpdate=getdate() 
	where comp=@comp and prg=@prg
	
END