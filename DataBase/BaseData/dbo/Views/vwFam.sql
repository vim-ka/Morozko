CREATE VIEW vwFam
AS
SELECT *, 
  Name3+' '+left(name1,1)+'. '+left(name2,1)+'.' as Fio,
  Name3+' '+Name2+' '+Name1 as FullFio
FROM Fam;