CREATE PROCEDURE dbo.OplataMarsh @ND1 dateTime, @ND2 datetime, @type varchar(3), @Op int, @Rem varchar(60)
AS
BEGIN
  Declare @VedOpl int, @countRec int
  begin try     
  --Проверяем есть ли за этот период нужная нам ведомость
  set @VedOpl=(select IsNull(VedNo,0) 
                 from MarshVedOpl
                 where act=@type and StartND like '%'+cast(@Nd1 as varchar)+'%' and 
                       EndND like '%'+cast(@Nd2 as varchar)+'%'); 
  
  if @VedOpl is null
  begin
    set @VedOpl=0;
  end;

  set @type=UPPER(@type)
  create table #Oplata (ND datetime,Marsh int,Napravl varchar(50),
                    plata float,otherplata float,drId int,DrName varchar(100),
                    Descript varchar(300),crId int,CrName varchar(100),
                    Phys int,ScanND datetime,VedNo int,mhid int,
                    Dist float,DistPay float,DrvPay float,weight float,Dots float,
                    DotsPay float,SpedPay float,PercWorkPay float,Peni float)
                    
  create table #Ved(ND datetime,Msh int,Nom int,mhid int)
  

  if @type='DRV' 
  begin
    insert into #Oplata (ND,Marsh,Napravl,plata,otherplata,
                     drId,DrName,Descript,crId,crName,ScanND,VedNo,mhid,
                     Dist,DistPay,DrvPay,weight,Dots,DotsPay,SpedPay,PercWorkPay,Peni)
    select ND,m.Marsh,m.Driver,
         case
           when DotsPay<100 then
             IsNull(Dist*DistPay+DrvPay*(weight+dopWeight)+Dots*DotsPay+SpedPay-IsNull(Peni,0),0)
           else
             IsNull(Dist*DistPay+DrvPay*(weight+dopWeight)+DotsPay+SpedPay-IsNull(Peni,0),0) 
         end as plata,
         IsNull(vetPay+waypay,0) as otherplata,m.drId,Dr.Fio,
         'Серия '+IsNull(Dr.PaspSeries,'')+' №'+IsNull(Dr.PaspNom,'')+
         ' Кем выдан: '+IsNull(Dr.PaspV,'')+' Дата выдачи '+
         IsNull(cast(Dr.PaspDateV as varchar(10)),''),A.crId,
         /*IsNull(A.PhysPerson,0)as Phys*/A.crName ,ScanND,IsNull(m.VedNo,0),m.mhid,
         Dist,DistPay,DrvPay,weight+dopWeight,Dots,DotsPay,SpedPay,PercWorkPay,Peni
    from Marsh m
    left join
    (select Fio,PaspNom,PaspSeries,PaspDateV,PaspV,drid,trId
     from Drivers)Dr on Dr.drid=m.drid 
    left join
    (select V_id,v.crid,Cr.physperson,cr.crName from Vehicle v
     left JOIN
     (select physPerson,crName,crid from Carriers) Cr on Cr.crid=v.crid
    ) A on A.V_id=m.V_id
    where /*ScanND>=@ND1*/VedNo=@VedOpl and ScanND<=@ND2 and mstate=2 and m.drid<>0 and ND>='04.04.11'
         and (A.crid=0 or A.PhysPerson>0 or A.CrId=7) and Dr.trId<>6 and Dr.trId<>8 and DelivCancel=0 /*and km0<>0 and km1<>0*/
    order by A.crId                 
  end
  else if @type='CRR' 
  begin
      insert into #Oplata (ND,Marsh,Napravl,plata,otherplata,
                     drId,DrName,Descript,crId,CrName,Phys,ScanND,VedNo,mhid,
                     Dist,DistPay,DrvPay,weight,Dots,DotsPay,SpedPay,PercWorkPay,Peni)
      select ND,m.Marsh,m.Driver,
           case
             when Dots>25 then 
                 IsNull(25*DotsPay+(Dots-25)*2*DotsPay+dist*distPay+DrvPay*(Weight+dopWeight)
                                  /*+IsNull(PercWorkPay,0)*/-IsNull(Peni,0),0)
             else IsNull(Dots*DotsPay+dist*distPay+DrvPay*(Weight+dopWeight)/*+IsNull(PercWorkPay,0)*/
                         -IsNull(Peni,0),0)
           end as plata,IsNull(vetPay+waypay,0) as otherplata,
           m.DrID,Dr.Fio,'Расчетный счет '+A.crRs+'   ИНН '+A.CrInn,A.CrId,A.crName,
           IsNull(A.PhysPerson,0)as Phys,ScanND,IsNull(m.VedNo,0),m.mhid,
           Dist,DistPay,DrvPay,weight+dopWeight,Dots,DotsPay,SpedPay,PercWorkPay,Peni
      from Marsh m
      left join
      (select V_id,v.crid,Cr.physperson,Cr.crName,Cr.crRs,Cr.CrInn, Cr.NDS from Vehicle v
       left JOIN
       (select physPerson,crid,crName,crRs,CrInn, NDS from Carriers)Cr on Cr.crid=v.crid
       )A on A.V_id=m.V_id
      left join
      (select Fio,drid
       from Drivers)Dr on Dr.drid=m.drid
      where /*ScanND>=@Nd1*/VedNo=@VedOpl and ScanND<=@ND2 and mstate = 2 and m.V_id<>0 and ND>='04.04.11'
           and A.crid<>0 and A.PhysPerson=0 and A.CrId<>7 and A.CrId<>61 and A.NDS=0 and DelivCancel=0 /*and km0<>0 and km1<>0*/
      order by A.crId
 end
 else if @type='CRN' 
  begin
      insert into #Oplata (ND,Marsh,Napravl,plata,otherplata,
                     drId,DrName,Descript,crId,CrName,Phys,ScanND,VedNo,mhid,
                     Dist,DistPay,DrvPay,weight,Dots,DotsPay,SpedPay,PercWorkPay,Peni)
      select ND,m.Marsh,m.Driver,
           case
           when DotsPay<100 then
             IsNull(Dots*DotsPay+dist*DistPay+DrvPay*(weight+dopWeight)+IsNull(PercWorkPay,0)-IsNull(Peni,0),0)
           else
             IsNull(DotsPay+dist*DistPay+DrvPay*(weight+dopWeight)+IsNull(PercWorkPay,0)-IsNull(Peni,0),0) 
           end as plata,
           IsNull(vetPay+waypay,0) as otherplata,
           m.DrID,Dr.Fio,'Расчетный счет '+A.crRs+'   ИНН '+A.CrInn,A.CrId,A.crName,
           IsNull(A.PhysPerson,0)as Phys,ScanND,IsNull(m.VedNo,0),m.mhid,
           Dist,DistPay,DrvPay,weight+dopWeight,Dots,DotsPay,SpedPay,PercWorkPay,Peni
      from Marsh m
      left join
      (select V_id,v.crid,Cr.physperson,Cr.crName,Cr.crRs,Cr.CrInn,Cr.NDS from Vehicle v
       left JOIN
       (select physPerson,crid,crName,crRs,CrInn,NDS from Carriers)Cr on Cr.crid=v.crid
       )A on A.V_id=m.V_id
      left join
      (select Fio,drid
       from Drivers)Dr on Dr.drid=m.drid
      where /*ScanND>=@Nd1*/VedNo=@VedOpl and ScanND<=@ND2 and mstate=2 and m.V_id<>0 and ND>='04.04.11'
           and A.crid<>0 and A.PhysPerson=0 and A.CrId<>7 and A.CrId<>61 and A.NDS=1 and DelivCancel=0 /*and km0<>0 and km1<>0*/
      order by A.crId
  end
  

  set @countRec=(select count(ND) from #Oplata)
  if @countRec=0
  begin
    set @VedOpl=-1;
  end;
                     
if @VedOpl=0 or @VedOpl is null   --если  ведомость сформировывается впервые 
begin
    if @type='DRV' or @type='CRR' or @type='CRN'
    begin
         Declare @Date datetime,@Msh int,@VedNo int,@mhid int
         
         set @VedOpl=(select IsNull(Max(VedNo),0)+1 from MarshVedOpl);
         insert into MarshVedOpl(VedNo,Op,Remark,StartND,EndND,act)
         values(@VedOpl,@Op,@Rem,@Nd1,@Nd2,@Type)

         Declare @CURSOR CURSOR
         set @CURSOR= CURSOR SCROLL
         for select Nd,Marsh,VedNo,mhid from #Oplata
         
         Open @CURSOR
         FETCH NEXT FROM @CURSOR into @Date,@Msh,@VedNo,@mhid
         
         WHILE @@FETCH_STATUS=0
         BEGIN
          
           if @VedNo=0
           begin
             update Marsh set VedNo=@VedOpl
             where ND=@Date and marsh=@Msh
             
             insert into #ved(ND,msh,nom,mhid)
             values (@Date,@Msh,@VedOpl,@mhid)
           end
           else
             if @VedOpl=@VedNo 
               insert into #ved(ND,msh,nom,mhid)
               values (@Date,@Msh,@VedOpl,@mhid)
            FETCH NEXT FROM @CURSOR into @Date,@Msh,@VedNo,@mhid
         END
         
         CLOSE @CURSOR

    end;
    
    create table #tbDolg (drid int, podotchet float,brDolg float)
    insert into #tbDolg (drid, podotchet,brDolg)
    select drid,IsNull(B.Must,0),IsNull(A.Duty,0)
    from Drivers d
    LEFT JOIN
     (select  Sum(Sp+Izmen)-Sum(Fact)as Duty,B_id
      from  NC --nc
      where Tara!=1 and Frizer!=1 and Actn!=1 
      group by B_id
      having Sum(Sp+Izmen)-Sum(Fact)>0)A on A.B_Id=D.B_id and D.B_id>0
    left join
     (select sum(k.must) as must,k.p_id from PsScores k 
      group by k.p_id
      having sum(k.must)>0)B on B.P_id=d.p_id
    
    insert into MarshOplDet (VedNo,NdMarsh,Marsh,OplataSum,OplataOther,
              Dist,DistPay,DrvPay,weight,Dots,DotsPay,SpedPay,PercWorkPay,Peni,
              podotchet,brDolg)       
    select distinct v.Nom,#Oplata.ND,Marsh,plata,otherplata,Dist,DistPay,
           DrvPay,weight,Dots,DotsPay,SpedPay,PercWorkPay,Peni,IsNull(D.podotchet,0),Isnull(D.brDolg,0)
    from #Oplata
    join #Ved v on v.Nd=#Oplata.Nd and v.Msh=#Oplata.Marsh 
    left join #tbDolg d on d.drId=#Oplata.drid
    order by #Oplata.ND,Marsh
  
end;

if @VedOpl<>0 and @VedOpl is not null
begin
  if @type='DRV' 
  begin    
        select distinct o.ND,o.Marsh,Napravl,A.OplataSm,A.otherOplSm,
               v.OplataSum as plata,v.OplataOther as otherplata,
               o.drId,DrName,Descript,o.crId,CrName,Phys,o.Dist,o.weight,o.Dots,
               case
               when o.DotsPay<100 then
                 IsNull(o.Dots*o.DotsPay,0)
               else
                 IsNull(o.DotsPay,0) 
               end as DotsPay,
               case 
                 when ScanND is null then ''
                 else convert(Varchar(10),ScanND,4)
               end as ScanND,v.VedNo,mo.Nd as VedND,v.podotchet,v.brDolg,
               (select count(distinct OP.ND) from #Oplata OP where OP.crId=o.crID) as kolND
        from #Oplata o
        join MarshOplDet v on v.NdMarsh=o.Nd and v.Marsh=o.Marsh 
        left join MarshVedOpl mo on mo.VedNo=v.VedNo
        left join
        (select Sum(d.OplataSum) as OplataSm,Sum(d.OplataOther) as otherOplSm,C.crID
         from MarshOplDet d 
         left join 
         (select nd,Marsh,drid,VedNo,f.crid from Marsh
           left join
           (select V_id,v.crid,Cr.physperson from Vehicle v
            left JOIN
            (select physPerson,crid from Carriers)Cr on Cr.crid=v.crid
           )f on f.V_id=marsh.V_id
          )C on C.Nd=d.NdMarsh and C.Marsh=d.Marsh and C.VedNo=@VedOpl
         group by C.crID )A on A.crID=o.crID
               
        
        /*(select Sum(d.OplataSum) as OplataSm,Sum(d.OplataOther) as otherOplSm,C.drid ,
                Sum(d.podotchet)as SumPd,Sum(d.brDolg) as SumbrDolg
         from MarshOplDet d 
         left join 
         (select nd,Marsh,drid,VedNo from Marsh)C on C.Nd=d.NdMarsh and 
                                                C.Marsh=d.Marsh and C.VedNo=@VedOpl
         group by C.drid )A on A.drid=o.drid*/
         
         
                 
         order by o.crId
  end
  else 
    if @type='CRR'
    begin  
        select distinct o.ND,o.Marsh,Napravl,A.OplataSm,A.otherOplSm,
               v.OplataSum as plata,v.OplataOther as otherplata,
               o.drId,DrName,Descript,o.crId,CrName,Phys,o.Dist,o.weight,o.Dots,
               case
               when o.DotsPay<100 then
                 IsNull(o.Dots*o.DotsPay,0)
               else
                 IsNull(o.DotsPay,0) 
               end as DotsPay,
               case 
                 when ScanND is null then ''
                 else convert(Varchar(10),ScanND,4)
               end as ScanND,v.VedNo,mo.Nd as VedND, 
               v.podotchet,v.brDolg,
               (select count(distinct OP.ND) from #Oplata OP where OP.crId=o.crID) as kolND
        from #Oplata o
        join MarshOplDet v on v.NdMarsh=o.Nd and v.Marsh=o.Marsh 
        left join MarshVedOpl mo on mo.VedNo=v.VedNo
        left join
         (select Sum(d.OplataSum) as OplataSm,Sum(d.OplataOther) as otherOplSm,C.crID
         from MarshOplDet d 
         left join 
         (select nd,Marsh,drid,VedNo,f.crid from Marsh
           left join
           (select V_id,v.crid,Cr.physperson from Vehicle v
            left JOIN
            (select physPerson,crid from Carriers)Cr on Cr.crid=v.crid
           )f on f.V_id=marsh.V_id
          )C on C.Nd=d.NdMarsh and C.Marsh=d.Marsh and C.VedNo=@VedOpl
         group by C.crID )A on A.crID=o.crID
         order by o.CrId
    end
    else
    if @type='CRN'
    begin  
        select distinct o.ND,o.Marsh,Napravl,A.OplataSm,A.otherOplSm,
               v.OplataSum as plata,v.OplataOther as otherplata,
               o.drId,DrName,Descript,o.crId,CrName,Phys,o.Dist,o.weight,o.Dots,
               case
               when o.DotsPay<100 then
                 IsNull(o.Dots*o.DotsPay,0)
               else
                 IsNull(o.DotsPay,0) 
               end as DotsPay,
               case 
                 when ScanND is null then ''
                 else convert(Varchar(10),ScanND,4)
               end as ScanND,v.VedNo,mo.Nd as VedND, 
               v.podotchet,v.brDolg,
               (select count(distinct OP.ND) from #Oplata OP where OP.crId=o.crID) as kolND
        from #Oplata o
        join MarshOplDet v on v.NdMarsh=o.Nd and v.Marsh=o.Marsh 
        left join MarshVedOpl mo on mo.VedNo=v.VedNo
        left join
         (select Sum(d.OplataSum) as OplataSm,Sum(d.OplataOther) as otherOplSm,C.crID
         from MarshOplDet d 
         left join 
         (select nd,Marsh,drid,VedNo,f.crid from Marsh
           left join
           (select V_id,v.crid,Cr.physperson from Vehicle v
            left JOIN
            (select physPerson,crid from Carriers)Cr on Cr.crid=v.crid
           )f on f.V_id=marsh.V_id
          )C on C.Nd=d.NdMarsh and C.Marsh=d.Marsh and C.VedNo=@VedOpl
         group by C.crID )A on A.crID=o.crID
         order by o.CrId
    end;
end;
end try
begin catch
  --    SELECT ERROR_NUMBER() AS ErrorNumber, ERROR_MESSAGE() AS ErrorMessage
  insert into ProcErrors(errnum, errmess, procname, errline) select ERROR_NUMBER(), ERROR_MESSAGE(), object_name(@@procid), ERROR_LINE()
end catch
  
END