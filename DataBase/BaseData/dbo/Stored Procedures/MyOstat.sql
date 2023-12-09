CREATE PROCEDURE dbo.MyOstat @id int, @Nd datetime,@Nd2 datetime
AS
BEGIN
  create table #TempTable (morn27 int,Kol_sell int,Kol_back int,isprav int,remov int,
                          Kol_inp int,Kol_Skl int,
                           kol_skl_ int, KolD int, KolD_ int, Kol_res int); 
                           
----------------morn28
   insert into #TempTable (morn27,Kol_sell,Kol_back,isprav,remov,
                          Kol_inp,Kol_Skl, kol_skl_ , KolD, KolD_ , Kol_res) 
                       
  (select IsNull((Morn-sell+isprav-remov),0),0,0,0,0,0,0,0,0,0,0
  from Vi27
  where id=@id)
------------------sell
/*
 insert into #TempTable (morn27,Kol_sell,Kol_back,isprav,remov,
                          Kol_inp,Kol_Skl, kol_skl_ , KolD, KolD_ , Kol_res)                       
  (select 0,IsNull(Sum(A.Kol_sell),0)as  Kol_sell,0,0,0,0,0,0,0,0,0
  from NC
  join
  (select sum(Kol)as Kol_sell,DatNom
  from Nv
  where kol>0 and tekId=@id
  group by DatNom) A on A.DatNom=nc.DatNom
  where ND>=@Nd2 and nd<=@Nd)
----------------------Back  
   insert into #TempTable (morn27,Kol_sell,Kol_back,isprav,remov,
                          Kol_inp,Kol_Skl, kol_skl_ , KolD, KolD_ , Kol_res)
  (select 0,0,IsNull(Sum(A.Kol_sell),0) as  Kol_Back,0,0,0,0,0,0,0,0
  from NC
  join
  (select sum(Kol)as Kol_sell,DatNom
  from Nv
  where kol<0 and tekId=@Id
  group by DatNom) A on A.DatNom=nc.DatNom
  where ND>=@Nd2 and nd<=@nd)
  */
------------- inp 
  insert into #TempTable (morn27,Kol_sell,Kol_back,isprav,remov,
                          Kol_inp,Kol_Skl, kol_skl_ , KolD, KolD_ , Kol_res)
  select 0,0,0,0,0,IsNull(A.kol,0),0,0,0,0,0 
  from Comman cm
  join
  (select Kol, Ncom,Id from InpDet)A on A.Ncom=cm.Ncom
  where date>=@Nd2 and date<=@Nd and A.id=@id
----------------remov
  insert into #TempTable (morn27,Kol_sell,Kol_back,isprav,remov,
                          Kol_inp,Kol_Skl, kol_skl_ , KolD, KolD_ , Kol_res)
  select 0,0,0,0,Sum(Isnull(Kol,0)-Isnull(newkol,0)),0,0,0,0,0,0 
  from Izmen
  where act='Снят' and ND>=@Nd2 and  Izmen.ND<=@Nd and Id=@id
  group by Izmen.Id
-----------------ispr
  insert into #TempTable (morn27,Kol_sell,Kol_back,isprav,remov,
                          Kol_inp,Kol_Skl, kol_skl_ , KolD, KolD_ , Kol_res)
  select 0,0,0,Sum(Isnull(newKol,0)-Isnull(kol,0)),0,0,0,0,0,0,0 
  from Izmen
  where act='Испр' and ND>=@Nd2 and Izmen.ND<=@Nd and  Id=@id
  group by Izmen.id
---------------Skl
  insert into #TempTable (morn27,Kol_sell,Kol_back,isprav,remov,
                          Kol_inp,Kol_Skl, kol_skl_ , KolD, KolD_ , Kol_res)
  select 0,0,0,0,0,0,IsNull(sum(kol),0),0,0,0,0 
  from Izmen
  where ND>=@Nd2 and Nd<=@Nd and newid=@id
  and Act='скла'
  group by newid
--------Skl_
  insert into #TempTable (morn27,Kol_sell,Kol_back,isprav,remov,
                          Kol_inp,Kol_Skl, kol_skl_ , KolD, KolD_ , Kol_res)
  select 0,0,0,0,0,0,0,IsNull(sum(kol),0),0,0,0 
  from Izmen
  where ND>=@Nd2 and Nd<=@Nd and id=@id
  and Act='скла'
  group by id
--------------div-
  insert into #TempTable (morn27,Kol_sell,Kol_back,isprav,remov,
                          Kol_inp,Kol_Skl, kol_skl_ , KolD, KolD_ , Kol_res)
  select 0,0,0,0,0,0,0,0,0,IsNull(Sum(kol-newkol),0),0 
  from Izmen 
  where ND>=@nd2 and Nd<=@nd and id=@id
  and Act='Div-'
  group by id
----------Div+
  insert into #TempTable (morn27,Kol_sell,Kol_back,isprav,remov,
                          Kol_inp,Kol_Skl, kol_skl_ , KolD, KolD_ , Kol_res)
  select 0,0,0,0,0,0,0,0,IsNull(Sum(newkol-kol),0),0,0 
  from Izmen
  where ND>=@nd2 and Nd<=@nd and id=@id
  and Act='Div+'
  group by newId

  
  
  
  
  
  
  
  select  Sum(IsNull(morn27,0)) as morn27,Sum(IsNull(Kol_sell,0)) as Kol_sell,
        Sum(IsNull(Kol_back,0)) as Kol_back,Sum(IsNull(isprav,0)) isprav,
        Sum(IsNull(remov,0)) as remov,Sum(IsNull(Kol_inp,0)) as Kol_inp,
        Sum(IsNull(Kol_Skl,0)) as Kol_Skl,Sum(IsNull(Kol_Skl_,0)) as Kol_Skl_,
        Sum(IsNull(KolD_,0)) as KolD_,Sum(IsNull(KolD,0)) as KolD
  from #TempTable


END