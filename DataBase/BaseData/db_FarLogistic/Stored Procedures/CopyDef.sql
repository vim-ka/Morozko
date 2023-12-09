CREATE PROCEDURE db_FarLogistic.CopyDef
@ID int
AS
insert into db_FarLogistic.dlDef (db_FarLogistic.dlDef.MorozDefPin) values(@id)