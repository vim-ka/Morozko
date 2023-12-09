CREATE PROCEDURE [ELoadMenager].ELoad_MainBuyersListDay @ND1 datetime, @ND2 datetime
AS BEGIN
select distinct D3.pin, 
       c.DCK,
       d3.gpName,
       d3.gpAddr, 
       c.Actual,
       d3.master,
       c.Our_ID,
       d3.Worker, 
       IsNull(A.Duty,0)-IsNull(k.Oplat,0)+IsNull(I.IzmenNC,0) as Duty,
       IsNull(Ob.Sm,0)+IsNull(Iz.IzmenNCP,0) as Oborot,
       IsNull(Ob.Sc,0) [summa_cost],
       IsNull(O.Oplata,0) as Oplata,
       IsNull(A2.Duty,0)-IsNull(k2.Oplat,0)+IsNull(I2.IzmenNC,0) as Duty2,
       IsNull(B2.Overdolg,0) as Overdue
       --IsNull(B.Overdue,0)-IsNull(k.Oplat,0)/*+IsNull(I.IzmenNC,0)*/ as Overdue
       into  #TempTable
from Def D3 join DefContract c on D3.pin=c.pin and c.ContrTip=2
left join (select dck, sum(Sp) as Duty from NC where Datnom>501010000 and Tara!=1 and Frizer!=1 and Actn!=1 and ND<@ND1 group by dck) A on A.dck=c.dck
left join (select k.dck, sum(k.Plata) as Oplat from kassa1 k  
           left join (select isnull(Tara,0) as Tara, isnull(Actn,0) as Actn, isnull(Frizer,0) as Frizer, DatNom from NC) a on a.DatNom=k.SourDatNom  
                      where k.ND>='20050101' and k.ND<@ND1 and k.oper=-2 and a.Tara!=1 and a.Frizer!=1 and a.Actn!=1 group by dck) K on K.dck=c.dck   
                          
left join (select dck, sum(izmen) as IzmenNC from NCIzmen where ND<@ND1 and Datnom>501010000 group by dck) I on I.dck=c.dck  
    
left join (select dck, sum(SP) as Overdue from NC where Datnom>501010000 and ND>=@ND1 and ND+Srok+1<@ND2 and ND<@ND2 and Tara!=1 and Frizer!=1 and Actn!=1 group by dck) B on B.dck=c.dck
left join (select dck, sum(Plata) as Oplata from kassa1 k
           left join (select isnull(Tara,0) as Tara, isnull(Actn,0) as Actn, isnull(Frizer,0) as Frizer, DatNom from NC) a on a.DatNom=k.SourDatNom           
                      where ND>='20050101' and ND between @ND1 and @ND2 and oper=-2 group by dck) O on O.dck=c.dck 
left join (select dck, sum(izmen) as IzmenNCP from NCIzmen where ND between @ND1 and @ND2 and Datnom>501010000 group by dck) IZ on IZ.dck=c.dck 
left join (select dck, isnull(sum(Sp),0) as Sm, isnull(sum(sc),0) [sc] from NC where Datnom>501010000 and ND between @ND1 and @ND2 and Tara!=1 and Frizer!=1 and Actn!=1 group by dck) Ob on Ob.dck=c.dck 
    
left join (select dck, sum(Sp) as Duty from NC where Datnom>501010000 and Tara!=1 and Frizer!=1 and Actn!=1 and ND<=@ND2 group by dck) A2 on A2.dck=c.dck
left join (select k.dck, sum(k.Plata) as Oplat from kassa1 k  
           left join (select isnull(Tara,0) as Tara, isnull(Actn,0) as Actn, isnull(Frizer,0) as Frizer, DatNom from NC) a on a.DatNom=k.SourDatNom  
                      where k.ND>='20050101' and k.ND<=@ND2 and k.oper=-2 and a.Tara!=1 and a.Frizer!=1 and a.Actn!=1 group by dck) K2 on K2.dck=c.dck   
left join (select dck, sum(izmen) as IzmenNC from NCIzmen where ND<@ND2 and Datnom>501010000 group by dck) I2 on I2.dck=c.dck        

left join (select dck, sum(Overdue) as OverDolg from DailySaldoDCK where ND=@ND2 group by dck) B2 on B2.dck=c.dck        
    
where d3.Worker=0 --and d3.pin=648
order by pin

select pin [КодКлиента],
    dck [КодДоговора],
    gpName [НаименованиеГрузополучателя],
    gpAddr [АдресГрузополучателя],
    Actual [Актуальность],
    Master [КодМастера],
    Our_ID [КодОрганизации],
    Worker [ЭтоСотрудник],
    Duty [НачальныйДолг],
    Oborot [Оборот],
    [summa_cost]  [Себестоимость],
    Oplata [Оплата], 
    Duty2 [КонечныйДолг],
    Overdue [Просрочка]
from #TempTable  
END