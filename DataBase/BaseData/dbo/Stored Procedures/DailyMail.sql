CREATE PROCEDURE dbo.DailyMail
AS
BEGIN
  declare @nd1 datetime, @nd2 datetime, @string varchar(8000), @str2 varchar(80),
  @in1 int,
  @in2 INT,
  @re1 real,
  @re2 real,
  @ch1 varchar(50),
  @dn datetime
  
  set @nd1=DateAdd(DAY,-2,GETDATE())
  set @nd2=GETDATE()
  set @string=''
  set @in1=0
  set @in2=0
  set @re1=0
  set @re2=0
  set @ch1=''
  set @str2=''
  set @dn='20000101'
  
  DEClare curs Cursor FAST_FORWARD READ_ONLY LOCAL FOR
  select 
   d.gpName,
   c.DatNom%10000,
   c.ND,
   c.SP
  
  from dbo.nc c
  join dbo.nv v on c.DatNom=v.DatNom
  join dbo.def d on c.B_ID=d.pin
  join dbo.Person p on d.p_id=p.P_ID
  where 
  c.nd>=@nd1 and c.nd <=@nd2 and c.sp>0
  group by    c.B_ID, d.gpName, c.DatNom%10000, c.ND, c.SP,d.Worker, p.DepID
  HAVING d.Worker=1 and p.DepID=3
  
order by d.gpName
  
  
open curs;
FETCH NEXT from curs INTO  @ch1,@in1,@dn, @re1;
set @string = IIF((@@FETCH_STATUS=-2) or (@@FETCH_STATUS=-1),'Нет покупок сотрудников','Покупки сотрудников c '+
 Convert(varchar,@nd1,103)+' по '+Convert(varchar,@nd2,103)+Char(13));
declare @ch2 varchar(50)
set @ch2='i';
set @str2='Покупки сотрудников c ' + Convert(varchar,@nd1,103) + ' по ' +Convert(varchar,@nd2,103);
WHILE @@FETCH_STATUS = 0 
BEGIN
  set @ch2 = @ch1;
  set @string=@string+@ch2+Char(13);
  
  WHILE @ch2 =@ch1 and @@FETCH_STATUS = 0 
   Begin
     set @string=@string+' [Номер Накладной]: '+Cast(@in1 as varchar)+' [Дата]: '+Convert(varchar,@dn,103) +' [Сумма]: '+Cast(@re1 as varchar)+' руб.'+CHAR(13);
     fetch next from curs into @ch1,@in1,@dn, @re1;
   END
  set @string=@string+'--------------------------------------------'+Char(13);
  fetch next from curs INTO @ch1,@in1,@dn, @re1;
  
END
close curs;
deallocate curs;

exec dbo.SendNotifyMail  'it@tdmorozko.ru, seti@tdmorozko.ru', @str2, @string , 0, '';
--exec dbo.SendNotifyMail  'seti@tdmorozko.ru', @str2 , @string , 0, '';
End