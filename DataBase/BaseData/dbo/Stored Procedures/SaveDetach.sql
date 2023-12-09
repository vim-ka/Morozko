CREATE procedure dbo.SaveDetach @datnom int, @TrueOp int=0, @Comp varchar(12)=''
as
declare @NewDatNom int, @d1 int, @tekid int
declare @SP decimal(12,2), @SC decimal(12,2), @SC0 decimal(12,2), @NETTO decimal(12,3), @BoxQty decimal(12,3)
begin

begin try
  begin transaction; 
  -- Создаю новую накладную, пустую пока:
 
  set @NewDatNom=1+(select max(isnull(datnom,0)) from Nc where Nd=dbo.datnomindate(@datnom));
  
  insert into NC(ND,datnom,B_ID,Fam,Tm,OP,SP,SC,
    Extra,Srok,OurID,Pko,Man_ID, 
    BankId,TovChk,Frizer,ag_id,stfnom,stfdate,tomorrow,qtyFriz,
    Remark,Printed,Marsh,BoxQty,WEIGHT,Actn,CK,Tara,
    RefDatnom,MarshDay,Sk50prn, Done, Izmen, RemarkOp, Dck, 
    b_id2, Comp, gpOur_ID, mhid )
  SELECT Nd, @NewDatnom, B_ID,Fam,Tm,OP,0,0, 
    Extra,Srok,OurID,Pko,Man_ID, 
    BankId,TovChk,Frizer,ag_id,stfnom,stfdate,tomorrow,qtyFriz,
    Remark,0,0,null,null,Actn,CK,Tara,
    RefDatnom,MarshDay,Sk50prn, Done, Izmen, RemarkOp, Dck,
    b_id2, @Comp, gpOur_ID, 0
    from Nc where DatNom=@DatNom;  
  
--  insert into NearLogistic.MarshRequests(
--    mhid,reqid,     reqType,reqAction,reqOrder,Comp,Pinto,PinFrom,ag_id,DelivCancel,ReqND)
--  select 
--    mhid,@NewDatNom,reqType,reqAction,reqOrder,Comp,Pinto,PinFrom,ag_id,DelivCancel,ReqND 
--  from NearLogistic.MarshRequests
--  where reqid=@Datnom and ReqType=0;


  -- Корректирую номера накладной в NV для строк, содержащихся в DetachOrderDet:  
  declare Curdtch cursor fast_forward  for select tekid from DetachOrderDet where datnom=@datnom;
  open Curdtch;
  fetch next from Curdtch into @tekid;
  WHILE (@@FETCH_STATUS=0) begin
    update NV set Datnom=@NewDatnom where Datnom=@Datnom and TekId=@TekId;
    fetch next from Curdtch into @tekid;
  end;
  close Curdtch;
  deallocate Curdtch;      
  
  -- Теперь считаю суммы по исходной и новой накладной:
  declare Cursumm cursor fast_forward for select 
   nv.DatNom,sum(nv.Kol*nv.cost) SC, sum(nv.Kol*nv.Price*(1.0+nc.extra/100.0)) SP,
   sum(nv.kol*isnull(nm.Netto,0)) as NET,
   sum(nv.Kol/v.minp/v.mpu) as BoxQty
   from nv inner join nc on nc.DatNom=nv.DatNom
   inner join Nomen nm on nm.hitag=nv.Hitag
   inner join tdVI V on V.id=nv.tekid
   where NV.datnom in (@datnom, @newdatnom)
   group by nv.DatNom;

  open Cursumm;
  
  fetch next from Cursumm into @d1,@Sc,@SP,@NETTO, @BoxQty;
  
  WHILE (@@FETCH_STATUS=0) begin
    update Nc set SC=@Sc,SP=@SP,Weight=@Netto, BoxQty=@BoxQty where datnom=@d1;
    fetch next from Cursumm into @d1,@Sc,@SP,@NETTO, @BoxQty;
  end;
  
  close Cursumm;
  deallocate Cursumm;      

  delete from DetachOrderDet where datnom=@datnom; 
  
  insert into Log(Op,Tip,Mess,Param1,Param2, Comp)
  VALUES(@TrueOp, 'DIV', 'Разделена, Исх№/Новый№', @Datnom, @NewDatNom, @Comp)
  
  commit; 
  
end try
  begin catch
    --    SELECT ERROR_NUMBER() AS ErrorNumber, ERROR_MESSAGE() AS ErrorMessage
    insert into ProcErrors(errnum, errmess, procname, errline) select ERROR_NUMBER(), ERROR_MESSAGE(), object_name(@@procid), ERROR_LINE()
  end catch   
end


/*
select @DatNom = DatNom,@Izmen = Izmen from inserted

declare @sc0 decimal(12,2), @sp0 decimal(12,2);

select @SC0=sum(nv.kol*nv.Cost)
  from NV inner join Nc on NC.datnom=nv.datnom
  inner join DetachOrderDet d on d.datnom=nv.datnom and d.tekid=nv.tekid
  where nv.DatNom=1008042437;
print @sc0;

print @sp0;
  

declare @Sc money;
declare @Sp money;
set @Sc=(select sum(nv.kol*nv.Cost)
  from NV inner join Nc on NC.datnom=nv.datnom
  inner join DetachOrderDet d on d.datnom=nv.datnom and d.tekid=nv.tekid
  where nv.DatNom=1008042437  )

set @Sp=(select sum(nv.kol*nv.price*(1.0+nc.Extra/100.0))
  from NV inner join Nc on NC.datnom=nv.datnom
  inner join DetachOrderDet d on d.datnom=nv.datnom and d.tekid=nv.tekid
  where nv.DatNom=1008042437  )

  */
  
  
--truncate table detachorderdet
/*
 select 
   nv.DatNom,sum(nv.Kol*nv.cost) SC, sum(nv.Kol*nv.Price*(1.0+nc.extra/100.0)) SP,
   sum(nv.kol*isnull(nm.Netto,0)) as NET,
   sum(nv.Kol/v.minp/v.mpu) as BoxQty
   from nv inner join nc on nc.DatNom=nv.DatNom
   inner join Nomen nm on nm.hitag=nv.Hitag
   inner join tdVI V on V.id=nv.tekid
   where NV.datnom in (1008042437, 1008042770)
   group by nv.DatNom
   */