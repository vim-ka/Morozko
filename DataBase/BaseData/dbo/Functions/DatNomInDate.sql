CREATE FUNCTION dbo.DatNomInDate (@DatNom bigint) RETURNS datetime
AS
BEGIN
  declare @N bigint, @Day datetime;

  set @N = round((@datnom - (@datnom % 100000)) / 100000,0)
  
  if @N>=100000 set @Day=cast('20'+Cast(@N as varchar(6)) as datetime);
  else set @Day=cast('200'+Cast(@N as varchar(6)) as datetime);

  Return @Day 
END