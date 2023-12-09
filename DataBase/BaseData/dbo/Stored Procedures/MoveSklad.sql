﻿CREATE PROCEDURE dbo.[MoveSklad]  @ND1 datetime, @Nd2 datetime,@Comp varchar(16)
AS
BEGIN
declare @today datetime
set @today=convert(char(10), getdate(),104)
create table #TempTable (ND datetime,Hitag int, morn int,inpKol int, Sell int,
       ispr int,snyat int,skl int,skl_ int, Div int,Div_ int, Trn_ int default 0,Trn int default 0);
       
select distinct i.* into #IzmenTemp
from izmen i inner join ReqHitag RH on (RH.Hitag=i.Hitag and RH.Comp=@Comp) or (RH.Hitag=i.newHitag and RH.Comp=@Comp)
             inner join ReqSklad RS on (RS.Sklad=i.Sklad and RS.Comp=@Comp) or (RS.Sklad=i.NewSklad and RS.Comp=@Comp)
where i.ND between @nd1 and @nd2

      
insert into #TempTable (ND,Hitag, morn,inpKol, Sell,ispr,snyat,skl,skl_,Div_,Div)

select Nd,A.hitag,0,0,Sum(Isnull(A.Kol,0)) as Sell,0,0,0,0,0,0
from nc join nv A on A.DatNom=nc.DatNom
        inner join ReqHitag RH on RH.Hitag=A.hitag and RH.Comp=@Comp
        inner join ReqSklad RS on RS.Sklad=A.Sklad and RS.Comp=@Comp
where Nd>=@ND1 and ND<=@ND2 
group by Nd,A.hitag

union

select date,A.hitag,-Sum(Isnull(kol,0)),Sum(Isnull(kol,0)),0,0,0,0,0,0,0
from comman join inpDet A on A.Ncom=comman.Ncom
            inner join ReqHitag RH on RH.Hitag=A.Hitag and RH.Comp=@Comp
            inner join ReqSklad RS on RS.Sklad=A.Sklad and RS.Comp=@Comp
where date>=@ND1 and date<=@ND2 
group by date,A.hitag;



------------ Поиск исправлений остатков:--------------------------------
insert into #TempTable (ND,Hitag, morn,inpKol, Sell,ispr,snyat,skl,skl_,Div_,Div)

select #IzmenTemp.Nd,B.hitag,Sum(Isnull(newKol,0)-Isnull(kol,0)),
                 0,0,Sum(Isnull(newKol,0)-Isnull(kol,0)),0,0,0,0,0
from #IzmenTemp
      left join Visual B on B.Id=#IzmenTemp.id
      inner join ReqHitag RH on RH.Hitag=B.Hitag and RH.Comp=@Comp
      inner join ReqSklad RS on RS.Sklad=#IzmenTemp.Sklad and RS.Comp=@Comp
where act='Испр' and #IzmenTemp.ND between @nd1 and @nd2 and #IzmenTemp.ND<>@today
group by #IzmenTemp.Nd,B.hitag

union all

select #IzmenTemp.Nd, A.hitag, sum(Isnull(newKol,0)-Isnull(kol,0)),
                 0,0,Sum(Isnull(newKol,0)-Isnull(kol,0)),0,0,0,0,0
from #IzmenTemp
      left join tdvi A on A.Id=#IzmenTemp.id
      inner join ReqHitag RH on RH.Hitag=A.Hitag and RH.Comp=@Comp
      inner join ReqSklad RS on RS.Sklad=#IzmenTemp.Sklad and RS.Comp=@Comp 
where act='Испр' and #IzmenTemp.ND between @nd1 and @nd2 and #IzmenTemp.ND=@today
group by #IzmenTemp.Nd,A.hitag

----------------поиск возвратов поставщ----------------------------
insert into #TempTable (ND,Hitag, morn,inpKol, Sell,ispr,snyat,skl,skl_, Div_,Div) 

select #IzmenTemp.Nd,B.hitag,Sum(Isnull(Kol,0)-Isnull(newkol,0)),
                    0,0,0,Sum(Isnull(Kol,0)-Isnull(newkol,0)),0,0,0,0
from #IzmenTemp
left join Visual B on B.Id=#IzmenTemp.id
inner join ReqHitag RH on RH.Hitag=B.Hitag and RH.Comp=@Comp
inner join ReqSklad RS on RS.Sklad=#IzmenTemp.Sklad and RS.Comp=@Comp
where act='Снят' and #IzmenTemp.ND between @nd1 and @nd2 and #IzmenTemp.ND<>@today
group by #IzmenTemp.Nd,B.hitag

union all
select #IzmenTemp.Nd,A.hitag,Sum(Isnull(Kol,0)-Isnull(newkol,0)),
                    0,0,0,Sum(Isnull(Kol,0)-Isnull(newkol,0)),0,0,0,0
from #IzmenTemp
left join tdvi A on A.Id=#IzmenTemp.id 
inner join ReqHitag RH on RH.Hitag=A.Hitag and RH.Comp=@Comp 
inner join ReqSklad RS on RS.Sklad=#IzmenTemp.Sklad and RS.Comp=@Comp
where act='Снят' and #IzmenTemp.ND between @nd1 and @nd2 and #IzmenTemp.ND=@today
group by #IzmenTemp.Nd,A.hitag

-------------------------добавл на скл---------------------------
insert into #TempTable (ND,Hitag, morn,inpKol, Sell,ispr,snyat,skl,skl_,Div_,Div) 
select #IzmenTemp.Nd,B.hitag,0,0,0,0,0,Sum(Isnull(Kol,0)),0,0,0
from #IzmenTemp
left join Visual B on B.Id=#IzmenTemp.id
inner join ReqHitag RH on RH.Hitag=B.Hitag and RH.Comp=@Comp
inner join ReqSklad RS on RS.Sklad=#IzmenTemp.NewSklad and RS.Comp=@Comp
where act='Скла' and #IzmenTemp.ND between @nd1 and @nd2 and #IzmenTemp.ND<>@today
group by #IzmenTemp.Nd,B.hitag

union all
select #IzmenTemp.Nd,A.hitag,0,0,0,0,0,Sum(Isnull(Kol,0)),0,0,0
from #IzmenTemp
left join tdvi A on A.Id=#IzmenTemp.id 
inner join ReqHitag RH on RH.Hitag=A.Hitag and RH.Comp=@Comp 
inner join ReqSklad RS on RS.Sklad=#IzmenTemp.NewSklad and RS.Comp=@Comp
where act='Скла' and #IzmenTemp.ND between @nd1 and @nd2 and #IzmenTemp.ND=@today
group by #IzmenTemp.Nd,A.hitag

------------------------снят со скл---------------------------------------
insert into #TempTable (ND,Hitag, morn,inpKol, Sell,ispr,snyat,skl,skl_,Div_,Div)

select #IzmenTemp.Nd,B.hitag,0,0,0,0,0,0,-Sum(Isnull(Kol,0)),0,0
from #IzmenTemp
left join  Visual B on B.Id=#IzmenTemp.id
inner join ReqHitag RH on RH.Hitag=B.Hitag and RH.Comp=@Comp
inner join ReqSklad RS on RS.Sklad=#IzmenTemp.Sklad and RS.Comp=@Comp
where act='Скла' and #IzmenTemp.ND between @nd1 and @nd2 and #IzmenTemp.ND<>@today
group by #IzmenTemp.Nd,B.hitag

union all
select #IzmenTemp.Nd,A.hitag,0,0,0,0,0,0,-Sum(Isnull(Kol,0)),0,0
from #IzmenTemp
left join tdvi A on A.Id=#IzmenTemp.id 
inner join ReqHitag RH on RH.Hitag=A.Hitag and RH.Comp=@Comp 
inner join ReqSklad RS on RS.Sklad=#IzmenTemp.Sklad and RS.Comp=@Comp
where act='Скла' and #IzmenTemp.ND between @nd1 and @nd2 and #IzmenTemp.ND=@today
group by #IzmenTemp.Nd,A.hitag

--------------- Поиск разбиений товаров------------------------
insert into #TempTable (ND,Hitag, morn,inpKol, Sell,ispr,snyat,skl,skl_, Div_,Div)

select #IzmenTemp.ND, V.hitag,0,0,0,0,0,0,0, cast(sum(kol-newkol) as integer),0
from #IzmenTemp  
inner join Visual V on V.id=#IzmenTemp.ID 
inner join ReqHitag RH on RH.Hitag=V.Hitag and RH.Comp=@Comp 
inner join ReqSklad RS on RS.Sklad=#IzmenTemp.Sklad and RS.Comp=@Comp  
where #IzmenTemp.ND between @nd1 and @nd2 and #IzmenTemp.ND<>@today
and Act='Div-'
group by #IzmenTemp.nd, v.hitag

union all
select #IzmenTemp.ND, V.hitag,0,0,0,0,0,0,0, cast(sum(kol-newkol) as integer),0
from #IzmenTemp  
inner join tdVi V on V.id=#IzmenTemp.ID  
inner join ReqHitag RH on RH.Hitag=V.Hitag and RH.Comp=@Comp 
inner join ReqSklad RS on RS.Sklad=#IzmenTemp.Sklad and RS.Comp=@Comp  
where #IzmenTemp.ND between @nd1 and @nd2 and #IzmenTemp.ND=@today
and Act='Div-'
group by #IzmenTemp.nd, v.hitag

------------------------ Поиск слияний товаров---------------------------
insert into #TempTable (ND,Hitag, morn,inpKol, Sell,ispr,snyat,skl,skl_,Div_,Div)

select #IzmenTemp.ND, V.hitag,0,0,0,0,0,0,0,0,cast(sum(newkol-kol) as integer)
from #IzmenTemp  
inner join Visual V on V.id=#IzmenTemp.newID    
inner join ReqHitag RH on RH.Hitag=V.Hitag and RH.Comp=@Comp 
inner join ReqSklad RS on RS.Sklad=#IzmenTemp.Sklad and RS.Comp=@Comp
where #IzmenTemp.ND between @nd1 and @nd2 and #IzmenTemp.ND<>@today
and Act='Div+'
group by #IzmenTemp.nd, v.hitag

union all
select #IzmenTemp.ND, V.hitag,0,0,0,0,0,0,0,0,cast(sum(newkol-kol) as integer)
from #IzmenTemp  
inner join tdVi V on V.id=#IzmenTemp.newID  
inner join ReqHitag RH on RH.Hitag=V.Hitag and RH.Comp=@Comp 
inner join ReqSklad RS on RS.Sklad=#IzmenTemp.Sklad and RS.Comp=@Comp  
where #IzmenTemp.ND between @nd1 and @nd2 and #IzmenTemp.ND=@today
and Act='Div+'
group by #IzmenTemp.nd, v.hitag
order by nd desc

------------------------ Поиск трансмутаций---------------------------
insert into #TempTable (ND,Hitag, morn,inpKol, Sell,ispr,snyat,skl,skl_,Div_,Div,Trn_,Trn)

select #IzmenTemp.ND, V.hitag,0,0,0,0,0,0,0,0,0,cast(sum(kol) as integer),0
from #IzmenTemp  
inner join Visual V on V.id=#IzmenTemp.ID    
inner join ReqHitag RH on RH.Hitag=V.Hitag and RH.Comp=@Comp 
inner join ReqSklad RS on RS.Sklad=#IzmenTemp.Sklad and RS.Comp=@Comp
where #IzmenTemp.ND between @nd1 and @nd2 and #IzmenTemp.ND<>@today
and Act='Tran'
group by #IzmenTemp.nd, v.hitag

union all

select #IzmenTemp.ND, V.hitag,0,0,0,0,0,0,0,0,0,cast(sum(kol) as integer),0
from #IzmenTemp  
inner join tdVi V on V.id=#IzmenTemp.ID  
inner join ReqHitag RH on RH.Hitag=V.Hitag and RH.Comp=@Comp 
inner join ReqSklad RS on RS.Sklad=#IzmenTemp.Sklad and RS.Comp=@Comp  
where #IzmenTemp.ND between @nd1 and @nd2 and #IzmenTemp.ND=@today
and Act='Tran'
group by #IzmenTemp.nd, v.hitag
order by nd desc

------------------------ Поиск трансмутаций---------------------------
insert into #TempTable (ND,Hitag, morn,inpKol, Sell,ispr,snyat,skl,skl_,Div_,Div,Trn_,Trn)

select #IzmenTemp.ND, V.hitag,0,0,0,0,0,0,0,0,0,0,cast(sum(newkol) as integer)
from #IzmenTemp  
inner join Visual V on V.id=#IzmenTemp.NewID    
inner join ReqHitag RH on RH.Hitag=V.Hitag and RH.Comp=@Comp 
inner join ReqSklad RS on RS.Sklad=#IzmenTemp.Sklad and RS.Comp=@Comp
where #IzmenTemp.ND between @nd1 and @nd2 and #IzmenTemp.ND<>@today
and Act='Tran'
group by #IzmenTemp.nd, v.hitag

union all

select #IzmenTemp.ND, V.hitag,0,0,0,0,0,0,0,0,0,0,cast(SUM(newkol) as integer)
from #IzmenTemp  
inner join tdVi V on V.id=#IzmenTemp.NewID  
inner join ReqHitag RH on RH.Hitag=V.Hitag and RH.Comp=@Comp 
inner join ReqSklad RS on RS.Sklad=#IzmenTemp.Sklad and RS.Comp=@Comp  
where #IzmenTemp.ND between @nd1 and @nd2 and #IzmenTemp.ND=@today
and Act='Tran'
group by #IzmenTemp.nd, v.hitag
order by nd desc

  create table #Table2 (ND datetime,Hitag int, morn int,inpKol int, Sell int,
       ispr int,snyat int,skl int,skl_ int,Div int,Div_ int, Trn_ int, Trn int, Ostat int);              
 
  
  DECLARE @ND datetime,@Nd_old datetime,@Htag int,@Hitag_ int, @morn int,@inpKol int, @Sell int,
       @ispr int,@snyat int,@skl int,@skl_ int, @NMorn int, @i int, @Ost int,
       @Div int,@Div_ int, @Trn_ int, @Trn int
  
  
  DECLARE @CURSORM CURSOR 
  SET @CURSORM  = CURSOR SCROLL
  FOR select hitag from ReqHitag where Comp= @Comp
    group by hitag
  OPEN @CURSORM
  
  FETCH NEXT FROM @CURSORM INTO @Htag
  WHILE @@FETCH_STATUS = 0
  BEGIN
     
      set @NMorn=( select IsNull(Sum(IsNull(morn,0)),0) 
                   from tdvi
                   --inner join ReqHitag RH on RH.Hitag=tdvi.Hitag and RH.Comp=@Comp 
                   inner join ReqSklad RS on RS.Sklad=tdvi.Sklad and RS.Comp=@Comp
                   where hitag=@Htag
                   );   


      DECLARE @CURSOR CURSOR 
      SET @CURSOR  = CURSOR SCROLL
      FOR select Nd, Sum(IsNull(morn,0)) ,Sum(IsNull(inpKol,0)), Sum(IsNull(Sell,0)) ,
                 Sum(IsNull(ispr,0)),Sum(IsNull(snyat,0)) ,Sum(IsNull(skl,0)),
                 Sum(IsNull(skl_,0)),Sum(IsNull(Div,0)), Sum(IsNull(Div_,0)),Sum(IsNull(Trn_,0)),Sum(IsNull(Trn,0))
         from #TempTable
         where hitag=@Htag
         group by Nd
         order by Nd desc

      OPEN @CURSOR 

      FETCH NEXT FROM @CURSOR INTO @ND, @morn,@inpKol, @Sell,
                                 @ispr,@snyat,@skl, @skl_,@Div,@Div_,@Trn_,@Trn  

/*
     set @Sell=( select IsNull(Sum(IsNull(sell,0)),0) 
                   from tdvi
                   --inner join ReqHitag RH on RH.Hitag=tdvi.Hitag and RH.Comp=@Comp 
                   inner join ReqSklad RS on RS.Sklad=tdvi.Sklad and RS.Comp=@Comp
                   where hitag=@Htag
                   )
*/
      if @ND<@today 
      begin
        insert into #Table2 (ND,Hitag, morn,inpKol, Sell,ispr,snyat,skl,skl_,Div,Div_,Trn_,Trn, Ostat)
        values(@today,@Htag, @NMorn,0, 0,0,0,0,0,0,0,0,0,@NMorn)
        set @i=@NMorn-@ispr+@snyat-@skl-@skl_+@Sell-@inpKol-@Div+@Div_-@Trn+@Trn_; 
        set @Ost=@NMorn; 
      end 
      else
      begin
        set @i=@NMorn; 
        set @Ost=@NMorn-@Sell+@Morn;   
      end; 
      
      set @Nd_old=@ND2;                    
      WHILE @@FETCH_STATUS = 0
      BEGIN
        while @Nd_old - 1 > @ND 
        begin
          insert into #Table2 (ND,Hitag, morn,inpKol, Sell,ispr,snyat,skl,skl_,Div,Div_,Trn,Trn_, Ostat)
          values(@Nd_old - 1,@Htag, @Ost,0, 0,0,0,0,0,0,0,0,0,@Ost)
          set @Nd_old=@Nd_old - 1
        end
        
        insert into #Table2 (ND,Hitag, morn,inpKol, Sell,ispr,snyat,skl,skl_,Div,Div_,Trn,Trn_, Ostat)
        values(@ND,@Htag, @i,@inpKol, @Sell,@ispr,@snyat,@skl,@skl_,@Div,@Div_,@Trn,@Trn_,@Ost)
        set @Nd_old=@Nd;        
        FETCH NEXT FROM @CURSOR INTO @ND, @morn,@inpKol, @Sell,
                                 @ispr,@snyat,@skl, @skl_,@Div,@Div_,@Trn_,@Trn
        set @Ost=@i;                        
        set @i=@i-@ispr+@snyat-@skl-@skl_+@Sell-@inpKol-@Div+@Div_-@Trn+@Trn_;
                                                    
      END
      
      while (@Nd_old > @ND1)
      begin
        insert into #Table2 (ND,Hitag, morn,inpKol, Sell,ispr,snyat,skl,skl_,Div,Div_,Trn,Trn_,Ostat)
                     values (@Nd_old-1,@Htag, @Ost,0, 0,0,0,0,0,0,0,0,0,@Ost)
        set @Nd_old=@Nd_old-1;
      end
              
      CLOSE @CURSOR 
      FETCH NEXT FROM @CURSORM INTO @Htag
  END
  CLOSE @CURSORM
  

select *,A.htag
from  #Table2
left join
(select Name,Hitag as hTag from Nomen)A on A.htag=hitag
order by Hitag,ND 
END