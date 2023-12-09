CREATE PROCEDURE [dbo].SetSertNum
@datnom int,
@isMarsh bit,
@op int,
@SertNo varchar(40),
@sertnd datetime
AS
BEGIN
  if @isMarsh=0
	begin
		update NC set SertNo=@SertNo, 
									SertND=@SertND
		where datnom=@datnom
	end
	else
	begin
		declare @marsh int
		declare @nd datetime
		
		select 	@marsh=Marsh,
						@nd=nd
		from nc 
		where datnom=@datnom
		
		update NC set SertNo=@SertNo, 
									SertND=@SertND
		where Nd=@ND 
					and Marsh=@Marsh
	end
END