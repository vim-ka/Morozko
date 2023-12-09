CREATE PROCEDURE dbo.GetUpdatePRG_Comp
@Comp varchar(100),
@Prg int
AS
BEGIN
  if not EXISTS(select * from LaunchCompPrg where comp=@comp and prg=@prg)
	if exists (select * from programs where prg=@prg)
	begin
		insert into LaunchCompPrg (Comp, Prg) values(@Comp, @Prg)
		
		select * from LaunchCompPrg where comp=@comp and prg=@prg
	end
	else
	begin
		select -1 [id], @comp [comp], @prg [prg], cast(0 as bit) [isUpd], getdate() [LastUpdate], cast(0 as bit) [ForceUpd]
	end	
	else
	select * from LaunchCompPrg where comp=@comp and prg=@prg
	
END