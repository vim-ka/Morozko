CREATE PROCEDURE users.SavePrg
@name varchar(50),
@descr varchar(100)=null,
@exe varchar(100)=null,
@source varchar(200)=null,
@img varbinary(max)=null,
@id int out
AS
BEGIN
	if @id=0
  begin
		select @id=max(prg)+1 from dbo.programs
  
  	insert into dbo.programs (prg,prgname, descr) values(@id,@name,@name)
  
  	insert into dbo.Permissions (prg,pID,PermisName) values(@id,1,'Запуск '+@name)
  end
  else
    update dbo.Programs set PrgName=@name,
                            Descr=@descr,
                            ExeName=@exe,
                            Source=@source,
                            PrgPicture=@img
    where prg=@id
  
END