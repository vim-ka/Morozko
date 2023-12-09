CREATE PROCEDURE dbo.SetSertifLogWork
@TypeID int,
@OP int,
@cnt int,
@com varchar(max)
AS
BEGIN
  declare @yymm int
	set @yymm=(year(getdate())-2000)*100+month(getdate())
	if exists(select * from SertifLogWork where yymm=@yymm and op=@op and typeid=@TypeID)
		begin
			update SertifLogWork set 
							counter=counter+@cnt,
							comment=comment+'$'+@com
			where yymm=@yymm 
						and op=@op 
						and typeid=@TypeID
		end
	else 
		begin
			insert into SertifLogWork(	YYMM,
  																TypeID,
  																OP,
  																Counter,
  																Comment) 
			values (@YYMM,
  						@TypeID,
  						@OP,
  						@Cnt,
  						@Com)
		end	
END