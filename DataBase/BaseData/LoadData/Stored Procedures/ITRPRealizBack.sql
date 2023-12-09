CREATE PROCEDURE [LoadData].ITRPRealizBack @DateStart datetime, @DateEnd datetime, @Bonus bit, @datnom int=0, @DocType int=1
AS
BEGIN
 SET NOCOUNT ON
 set transaction isolation level read uncommitted
 declare 
 @dn0 int,
 @dn1 int
 set @dn0 = dbo.InDatNom(0000, @DateStart)
 set @dn1 = dbo.InDatNom(9999, @DateEnd) 
 if @datnom=0 
   select c.ND as DATE, 
        c.TM as TIME,   
         case when v.kol>0 then 0 else 2 end as VID,   
         c.datnom as CODE,   
         c.OurID as CODE_O,   
         case when isnull(d.master,0)>0 then d.master else c.b_id end as CODE_K,   
         case when isnull(d.master,0)>0 then d.master else c.b_id end as CODE_D,   
         a.sv_ag_id as CODE_PR,   
         v.hitag as CODE_N,   
         v.kol as KOL,   
         v.price*(1.0+isnull(c.extra,0)/100) as CENA,   
         v.kol*v.price*(1.0+isnull(c.extra,0)/100) as SUM,   
         v.kol*iif(inp.cost is null or inp.hitag<>nom.hitag, v.cost, iif(nom.flgWeight=1 and inp.Weight<>0,round(inp.cost/inp.Weight,2)*i.weight, inp.cost)) as SEB,   
         v.sklad as CODE_S,   
         case when s.Discard=1 then 1 else 0 end as ST, 
         c.STip as Bonus,
         dp.pin as CODE_V,
         iif(c.Stip=4, 1, 0) as SafeCust   
      --   into #Temp
   from nc c join nv v on c.datnom=v.datnom   
           left join agentlist a on c.Ag_id=a.ag_id   
           left join def d on c.b_id=d.pin  
           left join FirmsConfig f on c.OurID=f.Our_id
           left join visual i on v.tekid=i.id
           left join def dp on i.ncod=dp.ncod
           left join SkladList s on v.Sklad=s.SkladNo
           left join inpdet inp on i.startid=inp.id
           left join nomen nom on v.hitag=nom.hitag
   where c.DatNom >= @dn0 and c.Datnom <= @dn1 and v.kol<>0 
         and ((c.STip in (1,2,3) and @Bonus=1) or (c.STip not in (1,2,3) and @Bonus=0))
         and f.FirmGroup in (7,10)
       --  and c.sp<0 and c.STip in (0,5)
         and ((c.sp>=0 and @DocType=1) or (c.sp<0 and @DocType=2))
        /* and exists (select 1 from  nc c1 join nv v1 on c1.datnom=v1.datnom
                                          join nomen nm on v1.hitag=nm.hitag
                     where c1.datnom=c.datnom and nm.flgWeight=1)*/
/*and  c.datnom
in 
(1704172320	,
1704193623	,
1704211551)	,
1701030153	,
1701030155	,
1701030156	,
1701030160	,
1701030164	,
1701030167	,
1701030170	,
1701030173	,
1701030174	,
1701032071	,
1701032072	,
1701032073	,
1701032074	,
1701032075	,
1701032076	,
1701032077	,
1701032079	,
1701032092	,
1701032097	,
1701032098	,
1701032099	,
1701032104	,
1701032106	,
1701032108	,
1701032117	,
1701032126	)
*/

    
    --and c.sp<0 and c.Stip in (0,5)
   order by c.ND,c.datnom 
 
 else
 
   select c.ND as DATE, 
        c.TM as TIME,   
         case when v.kol>0 then 0 else 2 end as VID,   
         c.datnom as CODE,   
         c.OurID as CODE_O,   
         case when isnull(d.master,0)>0 then d.master else c.b_id end as CODE_K,   
         case when isnull(d.master,0)>0 then d.master else c.b_id end as CODE_D,   
         a.sv_ag_id as CODE_PR,   
         v.hitag as CODE_N,   
         v.kol as KOL,   
         v.price*(1.0+isnull(c.extra,0)/100) as CENA,   
         v.kol*v.price*(1.0+isnull(c.extra,0)/100) as SUM,   
         v.kol*v.cost as SEB,   
         v.sklad as CODE_S,   
         case when v.sklad>90 then 1 else 0 end as ST, 
         c.STip as Bonus   
   from nc c join nv v on c.datnom=v.datnom   
           left join agentlist a on c.Ag_id=a.ag_id   
           left join def d on c.b_id=d.pin  
   where c.datnom=@datnom
   order by c.ND,c.datnom 
   
   --select sum(seb) from #Temp
 
END