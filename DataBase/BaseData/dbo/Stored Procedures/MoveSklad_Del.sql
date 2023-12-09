

CREATE PROCEDURE dbo.MoveSklad_Del  @ND1 datetime, @Nd2 datetime,@Comp varchar(16)
AS
BEGIN
declare @today datetime
set @today=convert(char(10), getdate(),104)
create table #TempTable (ND datetime,Hitag int, morn int,inpKol int, Sell int,
       ispr int,snyat int,skl int,skl_ int, Div int,Div_ int);
       
       
insert into #TempTable (ND,Hitag, morn,inpKol, Sell,ispr,snyat,skl,skl_,Div_,Div)

select Nd,A.hitag,0,0,Sum(Isnull(A.Kol,0)) as Sell,0,0,0,0,0,0
from nc
join
(select hitag,kol,DatNom,Sklad from Nv)A on A.DatNom=nc.DatNom
inner join ReqHitag RH on RH.Hitag=A.hitag and RH.Comp=@Comp
inner join ReqSklad RS on RS.Sklad=A.Sklad and RS.Comp=@Comp
where Nd>=@ND1 and ND<=@ND2 
group by Nd,A.hitag

union
select date,A.hitag,-Sum(Isnull(kol,0)),Sum(Isnull(kol,0)),0,0,0,0,0,0,0
from comman
join
(select Hitag,kol,Ncom,Sklad  
from inpDet)A on A.Ncom=comman.Ncom
inner join ReqHitag RH on RH.Hitag=A.Hitag and RH.Comp=@Comp
inner join ReqSklad RS on RS.Sklad=A.Sklad and RS.Comp=@Comp
where date>=@ND1 and date<=@ND2 
group by date,A.hitag;

------------ Поиск исправлений остатков:--------------------------------
insert into #TempTable (ND,Hitag, morn,inpKol, Sell,ispr,snyat,skl,skl_,Div_,Div)

select Izmen.Nd,B.hitag,Sum(Isnull(newKol,0)-Isnull(kol,0)),
                 0,0,Sum(Isnull(newKol,0)-Isnull(kol,0)),0,0,0,0,0
from Izmen
left join
(select hitag,Id from Visual)B on B.Id=Izmen.id
inner join ReqHitag RH on RH.Hitag=B.Hitag and RH.Comp=@Comp
inner join ReqSklad RS on RS.Sklad=Izmen.Sklad and RS.Comp=@Comp
where act='Испр' and Izmen.ND between @nd1 and @nd2 and ND<>@today
group by Izmen.Nd,B.hitag

union
select Izmen.Nd,A.hitag,Sum(Isnull(newKol,0)-Isnull(kol,0)),
                 0,0,Sum(Isnull(newKol,0)-Isnull(kol,0)),0,0,0,0,0
from Izmen
left join
(select hitag,Id from tdvi)A on A.Id=Izmen.id
inner join ReqHitag RH on RH.Hitag=A.Hitag and RH.Comp=@Comp
inner join ReqSklad RS on RS.Sklad=Izmen.Sklad and RS.Comp=@Comp 
where act='Испр' and Izmen.ND between @nd1 and @nd2 and ND=@today
group by Izmen.Nd,A.hitag



----------------поиск возвратов поставщ----------------------------
insert into #TempTable (ND,Hitag, morn,inpKol, Sell,ispr,snyat,skl,skl_, Div_,Div) 

select Izmen.Nd,B.hitag,Sum(Isnull(Kol,0)-Isnull(newkol,0)),
                    0,0,0,Sum(Isnull(Kol,0)-Isnull(newkol,0)),0,0,0,0
from Izmen
left join
(select hitag,Id from Visual)B on B.Id=Izmen.id
inner join ReqHitag RH on RH.Hitag=B.Hitag and RH.Comp=@Comp
inner join ReqSklad RS on RS.Sklad=Izmen.Sklad and RS.Comp=@Comp
where act='Снят' and Izmen.ND between @nd1 and @nd2 and ND<>@today
group by Izmen.Nd,B.hitag

union 
select Izmen.Nd,A.hitag,Sum(Isnull(Kol,0)-Isnull(newkol,0)),
                    0,0,0,Sum(Isnull(Kol,0)-Isnull(newkol,0)),0,0,0,0
from Izmen
left join
(select hitag,Id from tdvi)A on A.Id=Izmen.id 
inner join ReqHitag RH on RH.Hitag=A.Hitag and RH.Comp=@Comp 
inner join ReqSklad RS on RS.Sklad=Izmen.Sklad and RS.Comp=@Comp
where act='Снят' and Izmen.ND between @nd1 and @nd2 and ND=@today
group by Izmen.Nd,A.hitag

-------------------------добавл на скл---------------------------
insert into #TempTable (ND,Hitag, morn,inpKol, Sell,ispr,snyat,skl,skl_,Div_,Div) 
select Izmen.Nd,B.hitag,0,0,0,0,0,Sum(Isnull(Kol,0)),0,0,0
from Izmen
left join
 (select hitag,Id from Visual)B on B.Id=Izmen.id
inner join ReqHitag RH on RH.Hitag=B.Hitag and RH.Comp=@Comp
inner join ReqSklad RS on RS.Sklad=Izmen.NewSklad and RS.Comp=@Comp
where act='Скла' and Izmen.ND between @nd1 and @nd2 and ND<>@today
group by Izmen.Nd,B.hitag

union 
select Izmen.Nd,A.hitag,0,0,0,0,0,Sum(Isnull(Kol,0)),0,0,0
from Izmen
left join
(select hitag,Id from tdvi)A on A.Id=Izmen.id 
inner join ReqHitag RH on RH.Hitag=A.Hitag and RH.Comp=@Comp 
inner join ReqSklad RS on RS.Sklad=Izmen.NewSklad and RS.Comp=@Comp
where act='Скла' and Izmen.ND between @nd1 and @nd2 and ND=@today
group by Izmen.Nd,A.hitag

------------------------снят со скл---------------------------------------
insert into #TempTable (ND,Hitag, morn,inpKol, Sell,ispr,snyat,skl,skl_,Div_,Div)

select Izmen.Nd,B.hitag,0,0,0,0,0,0,-Sum(Isnull(Kol,0)),0,0
from Izmen
left join
(select hitag,Id from Visual)B on B.Id=Izmen.id
inner join ReqHitag RH on RH.Hitag=B.Hitag and RH.Comp=@Comp
inner join ReqSklad RS on RS.Sklad=Izmen.Sklad and RS.Comp=@Comp
where act='Скла' and Izmen.ND between @nd1 and @nd2 and ND<>@today
group by Izmen.Nd,B.hitag

union
select Izmen.Nd,A.hitag,0,0,0,0,0,0,-Sum(Isnull(Kol,0)),0,0
from Izmen
left join
(select hitag,Id from tdvi)A on A.Id=Izmen.id 
inner join ReqHitag RH on RH.Hitag=A.Hitag and RH.Comp=@Comp 
inner join ReqSklad RS on RS.Sklad=Izmen.Sklad and RS.Comp=@Comp
where act='Скла' and Izmen.ND between @nd1 and @nd2 and ND=@today
group by Izmen.Nd,A.hitag

--------------- Поиск разбиений товаров------------------------
insert into #TempTable (ND,Hitag, morn,inpKol, Sell,ispr,snyat,skl,skl_, Div_,Div)

select Izmen.ND, V.hitag,0,0,0,0,0,0,0, cast(sum(kol-newkol) as integer),0
from Izmen  
inner join Visual V on V.id=Izmen.ID 
inner join ReqHitag RH on RH.Hitag=V.Hitag and RH.Comp=@Comp 
inner join ReqSklad RS on RS.Sklad=Izmen.Sklad and RS.Comp=@Comp  
where Izmen.ND between @nd1 and @nd2 and Izmen.ND<>@today
and Act='Div-'
group by Izmen.nd, v.hitag

union
select Izmen.ND, V.hitag,0,0,0,0,0,0,0, cast(sum(kol-newkol) as integer),0
from Izmen  
inner join tdVi V on V.id=Izmen.ID  
inner join ReqHitag RH on RH.Hitag=V.Hitag and RH.Comp=@Comp 
inner join ReqSklad RS on RS.Sklad=Izmen.Sklad and RS.Comp=@Comp  
where Izmen.ND between @nd1 and @nd2 and Izmen.ND=@today
and Act='Div-'
group by Izmen.nd, v.hitag

------------------------ Поиск слияний товаров---------------------------
insert into #TempTable (ND,Hitag, morn,inpKol, Sell,ispr,snyat,skl,skl_,Div_,Div)

select Izmen.ND, V.hitag,0,0,0,0,0,0,0,0,cast(sum(newkol-kol) as integer)
from Izmen  
inner join Visual V on V.id=Izmen.ID    
inner join ReqHitag RH on RH.Hitag=V.Hitag and RH.Comp=@Comp 
inner join ReqSklad RS on RS.Sklad=Izmen.Sklad and RS.Comp=@Comp
where Izmen.ND between @nd1 and @nd2 and Izmen.ND<>@today
and Act='Div+'
group by Izmen.nd, v.hitag

union
select Izmen.ND, V.hitag,0,0,0,0,0,0,0,0,cast(sum(newkol-kol) as integer)
from Izmen  
inner join tdVi V on V.id=Izmen.ID  
inner join ReqHitag RH on RH.Hitag=V.Hitag and RH.Comp=@Comp 
inner join ReqSklad RS on RS.Sklad=Izmen.Sklad and RS.Comp=@Comp  
where Izmen.ND between @nd1 and @nd2 and Izmen.ND=@today
and Act='Div+'
group by Izmen.nd, v.hitag
order by nd desc

  create table #Table2 (ND datetime,Hitag int, morn int,inpKol int, Sell int,
       ispr int,snyat int,skl int,skl_ int,Div int,Div_ int, Ostat int);              
 
  
  DECLARE @ND datetime,@Hitag_ int, @morn int,@inpKol int, @Sell int,
       @ispr int,@snyat int,@skl int,@skl_ int, @NMorn int, @i int, @Ost int,
       @Div int,@Div_ int
   
  set @NMorn=( select Sum(IsNull(morn,0)) 
               from tdvi
               inner join ReqHitag RH on RH.Hitag=tdvi.Hitag and RH.Comp=@Comp 
               --where hitag in @hitag
               /*group by hitag*/);    

  DECLARE @CURSOR CURSOR 
  SET @CURSOR  = CURSOR SCROLL
  FOR select Nd, Sum(IsNull(morn,0)) ,Sum(IsNull(inpKol,0)), Sum(IsNull(Sell,0)) ,
             Sum(IsNull(ispr,0)),Sum(IsNull(snyat,0)) ,Sum(IsNull(skl,0)),
             Sum(IsNull(skl_,0)),Sum(IsNull(Div,0)), Sum(IsNull(Div_,0))
     from #TempTable
     group by Nd
     order by Nd desc

  OPEN @CURSOR 

  FETCH NEXT FROM @CURSOR INTO @ND , @morn,@inpKol, @Sell,
                             @ispr,@snyat,@skl, @skl_,@Div,@Div_  

  if @ND<@today 
  begin
    insert into #Table2 (ND,Hitag, morn,inpKol, Sell,ispr,snyat,skl,skl_,Div,Div_, Ostat)
    values(@today,0, @NMorn,0, 0,0,0,0,0,0,0,@NMorn)
    set @i=@NMorn-@ispr+@snyat-@skl-@skl_+@Sell-@inpKol-@Div+@Div_; 
    set @Ost=@NMorn; 
  end 
  else
  begin
    set @i=@NMorn+@morn; 
    set @Ost=@NMorn-@Sell;   
  end;                     
  WHILE @@FETCH_STATUS = 0
  BEGIN
  
    insert into #Table2 (ND,Hitag, morn,inpKol, Sell,ispr,snyat,skl,skl_,Div,Div_, Ostat)
    values(@ND,0, @i,@inpKol, @Sell,@ispr,@snyat,@skl,@skl_,@Div,@Div_,@Ost)
    
    FETCH NEXT FROM @CURSOR INTO @ND , @morn,@inpKol, @Sell,
                             @ispr,@snyat,@skl, @skl_,@Div,@Div_
    set @Ost=@i;                        
    set @i=@i-@ispr+@snyat-@skl-@skl_+@Sell-@inpKol-@Div+@Div_;
                                
  END
  
  CLOSE @CURSOR 

select *
from #Table2
order by ND 
END