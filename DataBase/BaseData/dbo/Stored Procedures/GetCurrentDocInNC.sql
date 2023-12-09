CREATE PROCEDURE dbo.GetCurrentDocInNC
@datnom bigint
AS
BEGIN
  select dName+isnull((select top 1 ' {'+fio+'}' [fio] 
										 from sertiflog lg 
                     left join usrpwd on uin=op 
                     where datnom=@datnom 
                     			 and lg.SertifDoc & dno <> 0
                           and nc.SertifDoc & dNo <> 0
                     ORDER BY lg.sid desc),'') [dName],
         case when dno & isnull(nc.SertifDoc,0)<>0 then cast(1 as bit) else cast(0 as bit) end [val],
         dNo
  from SertifDoc
  inner join nc on nc.DatNom=@datnom and 1=1
  --left join (select top 1 ' {'+fio+'}' [fio], SertifDoc from sertiflog left join usrpwd on uin=op where datnom=@datnom) [lg] on 1=1
  order by dNo
END