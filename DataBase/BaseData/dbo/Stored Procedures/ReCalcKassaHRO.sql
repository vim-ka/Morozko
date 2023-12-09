CREATE PROCEDURE dbo.ReCalcKassaHRO
AS
BEGIN
  declare @PredND datetime,
          @TekND datetime,
          @PredKassMorn money,
          @Rashod money,
          @Prihod money,
          @OurPlata money,
          @InputIn money,
          @InputOut money,
          @PersonMust money,
          @CommMust money,
          @IzmenIN money,
          @IzmenOUT money,
          @IspravIN money,
          @IspravOUT money,
          @RemoveIN money,
          @RemoveOUT money,
          @BuyBakIN money,
          @BuyBakOUT money,
          @SkladIN money,
          @SkladOUT money,
          @RealizIN money,
          @RealizOUT money,
          @AllRashod money,
          @AllDohod money,
          @SelNalIN money,
          @SelNalOUT money,
          @SelBnIN money,
          @SelBnOUT money,
          @GetRealIN money,
          @GetRealOUT money,
          @ZeroPlata money,
          @VendorKopl money,
          @EquipmentCost money
   
  
  
  set @EquipmentCost=(select sum(price) from Frizer)
   
  select @PredND = ND, @PredKassMorn = KassMorn from KassaHRO where nd=(select MAX(nd) from KassaHRO)
  set @TekND = @PredND + 1
  select @Prihod=(isNull(sum(k.plata),0)) from kassa1 k where k.nd>=@PredND and k.nd<=@PredND and k.bank_id=0 and k.oper in (select o.oper from KsOper o where o.rashflag=0)
  select @Rashod=(isNull(sum(k.plata),0)) from kassa1 k where k.nd>=@PredND and k.nd<=@PredND and (k.bank_id=0 or (k.bank_id=k.FromBank_id and k.bank_id>0)) and k.oper in (select o.oper from KsOper o where o.rashflag=1)
  
  select @OurPlata=(isNull(sum(k.plata),0)) from kassa1 k where k.nd>=@PredND and k.nd<=@PredND and k.Oper=-1
  
  select @InputIn=(isNull(sum(c.summacost),0)),
         @InputOut=(isNull(sum(c.summaprice),0))
  from comman c where c.date>=@PredND and c.date<=@PredND
  
  select @PersonMust=sum(isnull(Must,0)) from PsScores
  if @PersonMust is null set @PersonMust=0;  
  
  
  select @ZeroPlata=sum(isnull(plata,0)) from kassa1 k inner join vendors v on k.ncod=v.ncod and k.oper=-1 and k.nnak=0 and v.fam not like '%/холод%' and refncod=0;
  if @ZeroPlata is null set @Zeroplata=0;
  -- Оплата нулевых комиссий:
  select @CommMust=isnull(sum(summacost+izmen+remove+corr-plata),0) from comman inner join vendors v on v.ncod=comman.ncod and v.fam not like '%/холод%' and refncod=0;
  -- Эти комиссии отсутствуют в основном списке Comman, но учесть их надо:
  set @CommMust=@CommMust-@ZeroPlata
  
  
select @VendorKopl=sum(summacost+Izmen-plata+remove+corr)
from Comman cm inner join Vendors V on V.Ncod=cm.Ncod and v.refncod=0
where V.Fam not like '%/холод%' and cm.date+cm.srok<=GETDATE()

  
  
  
  select @RemoveIN=isnull(SUM(ROUND((newkol*newcost-kol*cost),2)),0) from Izmen
         where act='Снят' and nd>=@PredND and nd<=@PredND
  select @RemoveOUT=isnull(SUM(ROUND((newkol*newprice-kol*price),2)),0) from Izmen
         where act='Снят' and nd>=@PredND and nd<=@PredND
  select @IspravIN=isnull(SUM(ROUND((newkol*newcost-kol*cost),2)),0) from Izmen
         where act='Испр' and nd>=@PredND and nd<=@PredND
  select @IspravOUT=isnull(SUM(ROUND((newkol*newprice-kol*price),2)),0) from Izmen
         where act='Испр' and nd>=@PredND and nd<=@PredND       
  select @IzmenIN=isnull(SUM(ROUND((newkol*newcost-kol*cost),2)),0) from Izmen
         where act='ИзмЦ' and nd>=@PredND and nd<=@PredND
  select @IzmenOUT=isnull(SUM(ROUND((newkol*newprice-kol*price),2)),0) from Izmen
         where act='ИзмЦ' and nd>=@PredND and nd<=@PredND
         
  select @BuyBakIN=isnull(sum(sc),0) from NC
         where refdatnom>0 and nd>=@PredND and nd<=@PredND
  select @BuyBakOUT=isnull(sum(sp),0) from NC
         where refdatnom>0 and nd>=@PredND and nd<=@PredND       
  
--  select @SkladIN=isnull(sum((morn-sell)*cost),0) from tdvi         
--  select @SkladOUT=isnull(sum((morn-sell)*price),0) from tdvi                
  
  select @SkladIN=isnull(sum((t.morn-t.sell+t.isprav-t.remov)*t.cost),0),
         @SkladOUT=isnull(sum((t.morn-t.sell+t.isprav-t.remov)*t.price),0) 
  from tdvi t, vendors v where --t.sklad not in (0,60) and
  t.ncod=v.ncod and (LOWER(v.fam) NOT LIKE '%/холод%') and v.refncod = 0
  
  
/*  select @RealizIN=isnull(sum((SC+sc*izmen/sp)-SC*fact/sp),0) from nc
         where ((sp+Izmen)-fact)<>0 and Frizer=0 and tara=0 and actn=0 and sp<>0
  select @RealizOUT=isnull(sum((SP+izmen)-fact),0) from nc
         where ((sp+Izmen)-fact)<>0 and Frizer=0 and tara=0 and actn=0*/
         
         
  select  @RealizOUT=IsNull((Sum(Sp+Izmen)-Sum(Fact)),0)
          from NC 
          where Tara!=1 and Frizer!=1 and  Actn!=1 and 
                B_id in (select pin from Def where Actual=1)
                
  select  @RealizIN=IsNull((Sum(Sc+sc*izmen/sp)-Sum(SC*fact/sp)),0)
          from NC 
          where Tara!=1 and Frizer!=1 and  Actn!=1 and 
          B_id in (select pin from Def where Actual=1) and sp<>0              
                               
       
  select @AllDohod=(isNull(sum(k.plata),0)) from kassa1 k where k.nd>=@PredND and k.nd<=@PredND and k.oper in (select o.oper from KsOper o where o.rashflag=0)
  select @AllRashod=(isNull(sum(k.plata),0)) from kassa1 k where k.nd>=@PredND and k.nd<=@PredND and k.oper in (select o.oper from KsOper o where o.rashflag=1)
  
  select @SelNalIN=isnull(sum(sc),0) from NC where nd>=@PredND and nd<=@PredND and sc>0 and b_id=3434
  select @SelNalOUT=isnull(sum(sp),0) from NC where nd>=@PredND and nd<=@PredND and sp>0 and b_id=3434
  
  select @SelBnIN=isnull(sum(sc),0) from NC where nd>=@PredND and nd<=@PredND and sc>0 and b_id<>3434
  select @SelBnOUT=isnull(sum(sp),0) from NC where nd>=@PredND and nd<=@PredND and sp>0 and b_id<>3434
  
  select @GetRealIN=(isNull(sum(k.plata),0)) from kassa1 k where k.nd>=@PredND and k.nd<=@PredND and k.oper=-2
  select @GetRealOUT=(isNull(sum(k.plata),0)) from kassa1 k where k.nd>=@PredND and k.nd<=@PredND and k.oper=-2
    
  insert into KassaHRO (ND, KassMorn, Prihod, OurPlata, Rashod, InputIN, InputOut, PersonMust, CommMust,
                        IzmenIn, IzmenOUT, IspravIN, IspravOUT, RemoveIN, RemoveOUT, BuyBakIN, BuyBakOUT,
                        SkladIN, SkladOUT, RealizIN, RealizOUT, AllDohod, Profit, AllRashod, SelNalIN, SelNalOUT,
                        SelBnIN, SelBnOUT, GetRealIN, GetRealOUT, VendorKopl, EquipmentCost)
         values (@TekND, @PredKassMorn + @Prihod - @Rashod,@Prihod,@OurPlata,@Rashod,
                 @InputIn,@InputOut,@PersonMust,@CommMust,@IzmenIN,@IzmenOUT,@IspravIN,@IspravOUT,@RemoveIN,@RemoveOUT,
                 @BuyBakIN, @BuyBakOUT, @SkladIN, @SkladOUT, @RealizIN, @RealizOUT, @AllDohod, @AllDohod - @AllRashod, @AllRashod,
                 @SelNalIN, @SelNalOUT, @SelBnIN, @SelBnOUT, @GetRealIN, @GetRealOUT, @VendorKopl, @EquipmentCost)
END