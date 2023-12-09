CREATE PROCEDURE dbo.CalcBuyTurnSheet @pin int, @DCK int, @master int, @DateStart datetime, @DateEnd datetime, @DCKList varchar(100)='' with recompile
AS DECLARE @saldo money
BEGIN

  --SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED; 
  SET TRANSACTION ISOLATION LEVEL READ COMMITTED; 
  
  begin transaction Oborot;
  
  declare @AllContract bit, @AllNet bit, @Our_ID int 
  create table #tbDCK(dck integer);
  
  if @DCKList='' and @DCK=0 
  begin
    set @AllContract = 1; 
    set @Our_ID=0;
  end  
  else 
  begin
    set @AllContract =0;
    insert into #tbDCK select * from dbo.Str2intarray(@DCKList);
    if @DCK<>0 insert into #tbDCK values(@DCK);
    set @Our_ID=(select max(Our_ID) from DefContract where dck in (select dck from #tbDCK))
  end;
  
 -- if @DCK > 0 set @AllContract = 0; 
 -- else set @AllContract =1;
  
  declare @StartDatnom bigint, @EndDatnom bigint
  set @StartDatnom=dbo.InDatNom(0,@DateStart);
  set @EndDatnom=dbo.InDatNom(9999,@DateEnd);
   
  if @master > 0 
  begin
    set @AllNet = 1;
    if @AllContract=0 insert into #tbDCK select DCK from defcontract where DCKMaster in (select DCK from #tbDCK)
  end  
  else set @AllNet = 0;
 
  create table #TempTable (ND datetime, B_id int ,TM varchar(8), DatNumber varchar(50), Actn bit,
                           Srok int, SP decimal(12,2), SC money, Extra float, OurId int, Sum money, IzmSum money, Back money,
                           Remark varchar(150),Bank int, KassID int, DCK int, DocNom varchar(50), DocDate datetime);
        

  insert into  #TempTable (ND, B_id, TM, DatNumber, Actn, Srok, SP, SC, Extra, OurId, Sum,
                          IzmSum, Back, Remark, Bank, KassID, DCK, DocNom, DocDate)

      select c.ND as ND, --iif((c.DocDate is null or c.sp>0),c.ND,c.DocDate)
             c.B_id, 
             c.TM,
             cast(RIGHT(c.DatNom,5) as varchar) as DatNumber, --iif((c.DocNom is null or c.sp>0), cast(RIGHT(c.DatNom,4) as varchar), c.DocNom) as DatNumber,
             IsNull(c.Actn,0),
             c.Srok, 
             c.SP, 
             c.SC, 
             c.Extra, 
             c.OurId,
             0 as Sum,
             null as IzmSum,
             null as Back,
             iif(sp>0,(select cast(pin as varchar)+' '+gpName as gpName from Def where pin=c.B_ID),(select cast(pin as varchar) from Def where pin=c.B_ID))+
             '('+iif((c.DocNom is not null and c.sp<0),'№'+ c.DocNom,'')+iif((c.DocDate is not null and c.sp<0),' от '+convert(varchar,c.DocDate,104),'') +')' as Remark,
             null as Bank,
             null as KassId,
             c.DCK,
             isnull(c.DocNom,''),
             c.DocDate
      from NC c 
      where  c.datnom>=@StartDatnom and c.datnom<=@EndDatnom
             and (c.B_id=@pin or (c.B_id in (select pin from Def where Master=@pin) and @AllNet = 1)) 
             and c.Tara=0 and c.Frizer=0
             and (c.DCK in (select dck from #tbDCK) or @AllContract=1)  
      group by c.ND,c.B_Id ,c.TM,c.Actn,c.DatNom, c.Srok, c.SP, c.SC,c.Extra, c.OurId,c.Back, c.DCK, c.DocNom,c.DocDate 
      
      union 
      
      select iif(isnull(ks.Bank_id,0)<>0, ks.BankDay, ks.Nd) as Nd,
             min(ks.B_Id), --master
             min(ks.Tm),
             null,
             IsNull(ks.Actn,0),
             null,
             null,
             null,
             null,
             null,
             IIF(ks.Act='ВЫ',SUM(ks.Plata),null), 
             null,
             IIF(ks.Act='ВО',SUM(ks.Plata),null),
             ks.Remark + isnull(' Дов. №'+ d.DovNom+' от '+ convert(char(10),d.DovNom,104)+'г.','') as Remark,
             ks.Bank_ID,
             min(ks.KassID),
             min(ks.DCK) as DCK,
             isnull(d.DovNom,''),
             d.NDBeg
      from Kassa1 ks /*WITH(index(Kassa1_idx4))*/ left join NC a  on a.DatNom=ks.SourDatNom 
                     left join Dover d on ks.OrigRecn=d.DovID
      where (ks.B_id=@pin or (ks.B_id in (select pin from Def where Master=@pin) and @AllNet = 1)) 
           and (ks.DCK in (select dck from #tbDCK) or @AllContract=1 ) 
           and ((ks.nd>=@DateStart and ks.nd<=@DateEnd and isnull(ks.Bank_id,0)=0) or
                (ks.BankDay>=@DateStart and ks.BankDay<=@DateEnd and isnull(ks.Bank_id,0)<>0)) 
           and (ks.Act='ВЫ' or ks.Act='ВО') 
           and ks.oper=-2 --and isnull(a.Friz,0)=0 --and isnull(ks.Bank_id,0)=0
           and ks.sourdatnom>501010000 
           and a.Tara = 0 and a.Frizer = 0 and a.Actn = 0
      group by ks.Nd,ks.BankDay, ks.Actn,ks.Act,ks.Remark,ks.Bank_ID,d.DovNom,d.NDBeg
      
      union
  
      select izm.Nd,
             min(izm.B_Id),
             min(izm.TM),
             null,
             0,
             null,
             null,
             null,
             null,
             null,
             null,
             SUM(izm.Izmen),
             null,
             izm.Remark,
             null,
             null,
             izm.DCK,
             null,
             null
      from NCIzmen izm --left join NC n on izm.datnom=n.datnom
      where (izm.B_id=@pin or (izm.B_id in (select pin from Def where Master=@pin) and @AllNet = 1))
            and izm.nd>=@DateStart and izm.nd<=@DateEnd
            and (izm.DCK in (select dck from #tbDCK) or @AllContract=1 ) 
      group by izm.Nd,izm.Remark,izm.DCK

      
      union
  
      select CONVERT(varchar(8), r.ND, 112) as nd,
             n.pin,
             r.TM,
             cast(r.rk as varchar),
             1 as Actn,
             null,
             -d.sm,
             null,
             null,
             null,
             null,
             null,
             null,
             'Заявка на возврат №'+cast(r.Rk as varchar),
             null,
             null,
             n.DCK,
             null,
             null
      from Requests r left join ReqReturn n on r.rk=n.reqnum
                      left join (select d.reqretid, sum(d.kol*d.tovprice) as sm from ReqReturndet d 
                                 group by d.reqretid) d on r.rk=d.reqretid    
      where (n.pin=@pin or (n.pin in (select pin from Def where Master=@pin) and @AllNet = 1))
            and r.rs<>6 and r.rs<>7
            and (n.DCK in (select dck from #tbDCK) or @AllContract=1 ) 
      
      order by ND,tm;

   /*set @saldo=(select IsNull(sum(IsNull(nc.Sp,0)),0)-IsNull(Sum(IsNull(Ks.Sm,0)),0)
                      +IsNull(Sum(IsNull(Iz.Sm,0)),0) as Balance
                from NC 
                left join (select sum(Plata) as Sm, ks.B_Id,ks.SourDatNom 
                           from Kassa1 ks
                           where (ks.B_id = @pin or (ks.B_id in (select pin from Def where Master = @pin) and @AllNet = 1))
                                 and ((ks.nd<@DateStart and isnull(ks.Bank_id,0)=0) or (ks.BankDay<@DateStart and isnull(ks.Bank_id,0)<>0))
                                 and (ks.Act='ВЫ' or ks.Act='ВО')  and oper=-2 
                                 and (ks.DCK in (select dck from #tbDCK) or @AllContract=1) 
                               
                           group by ks.B_Id,ks.SourDatNom )Ks on ks.B_id=nc.B_Id  and ks.SourDatNom=nc.DatNom
                left join (select sum(Izmen) as Sm,B_ID,DatNom from NCIzmen iz
                            where iz.Datnom>501010000 and  iz.nd < @DateStart
                             group by iz.B_Id,DatNom)IZ on iz.B_id=nc.B_Id and iz.DatNom=nc.DatNom
               
                where (nc.B_id = @pin or (nc.B_id in (select pin from Def where Master = @pin) and @AllNet = 1))
                       and nc.nd<@DateStart and Tara!=1 and Frizer!=1 and Actn!=1
                       and (nc.DCK in (select dck from #tbDCK) or @AllContract = 1) 
                )*/
                
  set @saldo=isnull((select sum(nc.Sp)
              from NC 
              where (nc.B_id = @pin or (nc.B_id in (select pin from Def where Master = @pin) and @AllNet = 1))
                       and nc.nd<@DateStart and Tara!=1 and Frizer!=1 and Actn!=1
                       and (nc.DCK in (select dck from #tbDCK) or @AllContract = 1)),0)
  set @saldo=@saldo-                     
               isnull((select sum(Plata)
               from Kassa1 ks left join nc c on ks.sourdatnom=c.datnom
               where (ks.B_id = @pin or (ks.B_id in (select pin from Def where Master = @pin) and @AllNet = 1))
                     and ((ks.nd<@DateStart and isnull(ks.Bank_id,0)=0) or (ks.BankDay<@DateStart and isnull(ks.Bank_id,0)<>0))
                     and (ks.Act='ВЫ' or ks.Act='ВО')  and oper=-2 
                     and (ks.DCK in (select dck from #tbDCK) or @AllContract=1)
                     and c.Tara!=1 and c.Frizer!=1 and c.Actn!=1),0) 
  set @saldo=@saldo+                      
               isnull((select sum(Izmen)
               from NCIzmen iz
               where (iz.B_id = @pin or (iz.B_id in (select pin from Def where Master = @pin) and @AllNet = 1))
                     and (iz.DCK in (select dck from #tbDCK) or @AllContract=1)
                     and iz.Datnom>501010000 and iz.nd < @DateStart),0)
                                             

    
  if @saldo is null set @saldo=0
  
  create table #Table2 (ND datetime,B_Id int ,TM varchar(8), DatNumber varchar(50),Actn bit,
       Srok int,SP money,SC money,Extra float,OurId int,Sum money,IzmSum money,Back money,
       Remark varchar(80), saldo1 money, saldo2 money, Bank int, KassId int, DCK int,
       DocNom varchar(50), DocDate datetime)              
  
  
  
  DECLARE @ND datetime,@B_Id int ,@TM varchar(8), @DatNumber varchar(50), @Actn bit,
       @Srok int,@SP money,@SC money,@Extra float,@OurId int,@Sum money,@IzmSum money,
       @Back money,@Remark varchar(80), @saldo1 money, @saldo2 money, @Bank int, @KassId int, @DCK_C int,
       @DocNom varchar(50), @DocDate datetime;
       

  DECLARE @CURSOR CURSOR 
  SET @CURSOR  = CURSOR SCROLL
  FOR SELECT * FROM #TempTable order by nd,tm

  OPEN @CURSOR 

  FETCH NEXT FROM @CURSOR INTO @ND,@B_Id,@TM, @DatNumber,@Actn,@Srok,@SP,@SC,@Extra,@OurId,@Sum,
                  @IzmSum,@Back,@Remark,@Bank, @KassId, @DCK_C, @DocNom, @DocDate
  set @saldo1 = @saldo 
  if (@Actn = 0)
  begin               
    if (@SP is not null) set @saldo2=@saldo1+@SP
    else if (@Sum is not null) set @saldo2=@saldo1-@Sum            
    else if (@IzmSum is not null) set @saldo2=@saldo1+@IzmSum
    else if (@Back is not null) set @saldo2=@saldo1-@Back
  end
  else
    if ((@Actn=1) and (@SP is not null))
    begin
      set @saldo2=@saldo1
    end
    else 
    begin
      if (@Sum is not null) set @saldo2=@saldo1-@Sum            
      else if (@IzmSum is not null) set @saldo2=@saldo1+@IzmSum
      else if (@Back is not null) set @saldo2=@saldo1-@Back  
    end  
  
  

  WHILE @@FETCH_STATUS = 0
  BEGIN
 
    INSERT INTO #Table2 (ND,B_Id,TM, DatNumber,Actn,
       Srok,SP,SC,Extra,OurId,Sum,IzmSum,Back,
       Remark, saldo1, saldo2, Bank,KassID, DCK, DocNom, DocDate)
       VALUES (@ND,@B_Id,@TM, @DatNumber,@Actn,
       @Srok,@SP,@SC,@Extra,@OurId,@Sum,@IzmSum,@Back,
       @Remark, @saldo1, @saldo2,@Bank, @KassID, @DCK_C, @DocNom, @DocDate)
  
    FETCH NEXT FROM @CURSOR INTO @ND,@B_Id,@TM, @DatNumber,@Actn,@Srok,@SP,@SC,@Extra,@OurId,@Sum,
                    @IzmSum,@Back,@Remark,@Bank,@KassID, @DCK_C, @DocNom, @DocDate
    set @saldo1=@saldo2 
    if (@Actn=0)
    begin               
      if (@SP is not null) set @saldo2=@saldo1+@SP
      else if (@Sum is not null) set @saldo2=@saldo1-@Sum            
      else if (@IzmSum is not null) set @saldo2=@saldo1+@IzmSum
      else if (@Back is not null) set @saldo2=@saldo1-@Back
    end
    else
      if ((@Actn=1) and (@SP is not null))
      begin
        set @saldo2=@saldo1
      end
      else 
      begin
        if (@Sum is not null) set @saldo2=@saldo1-@Sum            
        else if (@IzmSum is not null) set @saldo2=@saldo1+@IzmSum
        else if (@Back is not null) set @saldo2=@saldo1-@Back  
      end  
     
  END
  
  CLOSE @CURSOR 
  
  declare @ourName varchar(100)
  
  set @ourName=(select ourName from FirmsConfig where our_id=(select our_id from Def where pin=@pin))
                
  if IsNull(@ourName,'')='' set @ourName='???';
    
  select t.*,@ourName as ourName, d.Contact, d.gpPhone,d.brPhone, 
         iif(@master>0, @master, t.b_id)  as master, @Our_ID as PrintOur_ID 
  from #Table2 t join Def d on t.B_ID=d.pin
  order by nd,tm  --#TempTable

  commit transaction Oborot;

END