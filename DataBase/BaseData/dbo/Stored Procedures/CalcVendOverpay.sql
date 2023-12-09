CREATE PROCEDURE CalcVendOverpay
AS
BEGIN
  DECLARE @Pay money
  Declare @BankDay datetime
  
  set @BankDay= getdate()
  
  create table #TempTable (Ncom int ,Ncod int, summacost money, Pereplata money,
                           CountComm int,Fam varchar(50), Our_id int, ND datetime, dck int, pin int);

  INSERT into #TempTable (Ncom, Ncod, summacost, Pereplata, CountComm, Fam, Our_id, ND, dck, pin)  
  SELECT distinct c.NCOM, c.Ncod, c.summacost,c.Plata-c.summacost-c.Izmen-c.Remove-c.corr as Pereplata,
       IsNull(A.CountComm,0) as CountComm,
       CAST(v.fam as varchar(50)) as Fam,
       e.Our_id,
       C.Date as ND,
       c.dck,
       c.pin
  FROM Comman c
  left Join
  (select COUNT(cm.Ncom)as CountComm,cm.Ncod, cm.dck from Comman cm
   where cm.summacost+cm.Izmen+cm.Remove+cm.corr-cm.plata>0 and cm.Ncom>0
   group by cm.Ncod, cm.dck) A on A.Ncod=c.Ncod and c.dck=A.dck
  left join
  (select ncod,fam from vendors) v on v.ncod=c.ncod
  left join
  (select dck,our_id from defcontract where ContrTip=1) e on e.dck=c.dck
  WHERE c.plata-(c.summacost+c.Izmen+c.Remove+c.corr)>0.01 /*and c.ncom>0 
      and c.date>='20070101'*/ /*and c.ncod=1*/
 
  UNION 
  
  SELECT 0 as Ncom, k.Ncod, 0 as summacost,sum(k.Plata) Pereplata,
        max(IsNull(D.CountComm,0)) as CountComm,
        max(CAST(v.fam as varchar(50))) as Fam,
        max(e.Our_id) as Our_id,
        max(k.ND) as ND,
        k.dck,
        max(k.pin) as pin
  FROM kassa1 k 
  left join
  (select COUNT(cm.Ncom)as CountComm,cm.Ncod from Comman cm
   where cm.summacost+cm.Izmen+cm.Remove+cm.corr-cm.plata>0 and cm.Ncom>0
   group by cm.Ncod) D on D.Ncod=k.Ncod
  left join
  (select ncod,fam from vendors) v on v.ncod=k.Ncod 
  left join
  (select dck,our_id from defcontract where ContrTip=1) e on e.dck=k.dck
  WHERE k.oper=-1 and k.nnak=0 /*and k.ncod=1*/
  group by  k.Ncod, k.dck
  having sum(k.Plata)>0
  ORDER BY Ncod, Ncom  
    
  DECLARE @Ncom int, @Ncod int, @Pereplata money, @CountComm int, @Fam varchar(50), @Our_id int, @ND DateTime, @dck int, @pin int


 /*внешний курсор по переплатам*/         
  DECLARE @CURSOR CURSOR 
  SET @CURSOR  = CURSOR SCROLL
  FOR SELECT Ncom,Ncod,Pereplata,CountComm,Fam, Our_id, ND, dck, pin FROM #TempTable
          /*IsNull(BankDay,CONVERT(varchar,getdate(),4)), Bank_id, our_id,*/ 

  OPEN @CURSOR 

  FETCH NEXT FROM @CURSOR INTO  @Ncom,@Ncod,@Pereplata,@CountComm,@Fam, @Our_id, @ND, @dck, @pin
  WHILE @@FETCH_STATUS = 0
  BEGIN   
    set @Pay=0
    if @CountComm>0 /*если есть не закрытые накладные*/
    begin
      EXECUTE PayComman @Ncod,@Pereplata,0,@BankDay,@Our_id,'компенсация отрицательного сальдо (пост.)',0,@Pay output, @dck, @pin
   
      if @Pereplata-@Pay <> 0    
      insert into Kassa1(Oper,Act,SourDate,Nnak,Plata,Fam,P_ID,B_ID,V_ID,Ncod,Remark,
                         RashFlag,LostFlag,LastFlag,Op,Bank_ID,Our_ID,BankDay,
                         Actn,Ck,Thr,ThrFam,DocNom,OrigRecn,ForPrint,SourDatNom,StNom,FromBank_ID, dck, pin)  
             
                 values (-1,'ВЫ',@ND,@Ncom,-(@Pereplata-@Pay),LEFT(@Fam,40),0,0,0,@Ncod,
                         'компенсация отрицательного сальдо (пост.)',
                          1,0,0,0,0,@Our_id,CONVERT(varchar,getdate(),4),0,0,0,'',0,0,0,0,0,0, @dck, @pin)

    end
    FETCH NEXT FROM @CURSOR INTO  @Ncom,@Ncod,@Pereplata,@CountComm,@Fam, @Our_id, @ND, @dck, @pin
  
  END

  CLOSE @CURSOR 
 
  
 
END