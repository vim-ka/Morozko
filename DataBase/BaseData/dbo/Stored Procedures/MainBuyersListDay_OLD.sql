

CREATE PROCEDURE dbo.[MainBuyersListDay_OLD] @ND1 datetime, @ND2 datetime
AS
BEGIN
  SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED; 
  --set @today=convert(char(10), getdate(),104)

  create table #TempTable (
    RecId int IDENTITY(1, 1) NOT NULL, 
    pin int,
    tip tinyint,
    gpName varchar(255),
    gpAddr varchar(255),
    Actual bit,
    Oborot money,
    Master int,
    Our_ID tinyint,
    Worker bit,
    Duty money,
    Overdue money, 
    Oplata money,
    Duty2 money,
    Dt money,
    Opl money,
    Inc money
    );
         
    insert into  #TempTable
    select distinct D3.pin, 
           tip, 
           gpName,
           gpAddr, 
           c.Actual,
           IsNull(Ob.Sm,0)+IsNull(Iz.IzmenNCP,0) as Oborot,
           Master,
           c.Our_ID,
           Worker, 
           IsNull(A.Duty,0)-IsNull(k.Oplat,0)+IsNull(I.IzmenNC,0) as Duty,
           IsNull(B.Overdue,0)-IsNull(k.Oplat,0)/*+IsNull(I.IzmenNC,0)*/ as Overdue,
           IsNull(O.Oplata,0) as Oplata,
           IsNull(A2.Duty,0)-IsNull(k2.Oplat,0)+IsNull(I2.IzmenNC,0) as Duty2,
           IsNull(A2.Duty,0) as Dt,IsNull(k2.Oplat,0) as Opl,IsNull(I2.IzmenNC,0) as InC
    from Def D3 join DefContract c on D3.pin=c.pin and c.ContrTip=2
    LEFT JOIN
      (select  B_id,Sum(Sp) as Duty
       from NC 
       where Tara!=1 and Frizer!=1 and Actn!=1 and ND<=@ND1
       group by B_id) A on A.B_Id=D3.pin 
    LEFT JOIN
      (select B_Id, Sum(Plata) as Oplat
       from  kassa1 
       where  ND<=@ND1 and oper=-2 and Act='ВЫ'
       group by B_Id) K on K.B_id=D3.pin      
    LEFT JOIN
      (select B_id, sum(izmen) as IzmenNC
        from NCIzmen where ND<=@ND1 and Datnom>501010000
        group by B_id) I on I.B_id=D3.pin    
    LEFT JOIN
      (select B_Id, Sum(SP) as Overdue
       from  NC 
       where  ND+Srok+1<@ND2 and ND<@ND2 and Tara!=1 and Frizer!=1 and Actn!=1  
       group by B_Id) B on B.B_id=D3.pin
    LEFT JOIN
      (select B_Id, Sum(Plata) as Oplata
       from  kassa1 
       where  ND between @ND1 and @ND2 and oper=-2 and Act='ВЫ'
       group by B_Id) O on O.B_id=D3.pin      
    LEFT JOIN
      (select B_id, sum(izmen) as IzmenNCP
        from NCIzmen where ND between @ND1 and @ND2 and Datnom>501010000
        group by B_id) IZ on IZ.B_id=D3.pin  
    LEFT JOIN
      (select B_id,ISNULL(Sum(Sp),0) as Sm 
       from NC where ND between @ND1 and @ND2 and Tara!=1 and Frizer!=1 and Actn!=1
       group by B_id) Ob on Ob.B_id=D3.pin 
    LEFT JOIN
      (select  B_id, sum(Sp) as Duty
       from NC 
       where Tara!=1 and Frizer!=1 and Actn!=1 and ND<=@ND2
       group by B_id) A2 on A2.B_Id=D3.pin 
    LEFT JOIN
      (select B_Id, sum(Plata) as Oplat
       from  kassa1 
       where  ND<=@ND2 and oper=-2 and Act='ВЫ'
       group by B_Id) K2 on K2.B_id=D3.pin  
    LEFT JOIN
      (select B_id, sum(izmen) as IzmenNC
        from NCIzmen where ND<=@ND2 and Datnom>501010000
        group by B_id) I2 on I2.B_id=D3.pin        
    order by pin


select RecID,
    pin,
    tip,
    gpName,
    gpAddr,
    Actual,
    Master,
    Our_ID,
    Worker,
    Duty as Dolg1,
    Oborot,
    Oplata, 
    Duty2 as Dolg2,
    Overdue
from #TempTable where Worker=0 --and  Actual=1 and
order by RecId
 
END