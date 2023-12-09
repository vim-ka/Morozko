CREATE VIEW vFam
AS
SELECT *, 
  Name3 +' '+iif(name1='','', left(name1,1)+'. ')
    +iif(name2='','', left(name2,1)+'.') as Fio,
  Name3+' '+Name1+' '+Name2 as FullFio
FROM Fam;