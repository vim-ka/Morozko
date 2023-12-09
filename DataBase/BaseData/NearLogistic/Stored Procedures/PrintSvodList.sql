CREATE PROCEDURE NearLogistic.PrintSvodList @ND datetime, @Marsh int, @inPallets bit
AS
BEGIN
  declare @DatNom1 int, @DatNom2 int

  set @DatNom1=dbo.InDatNom(0,@ND)
  set @DatNom2=dbo.InDatNom(9999,@ND)

-------------сводная ведомость набора----------------------- 
  if @inPallets = 0 --печать не по паллетам
  begin
    select B.Skg,
           B.SkgName,
           f.Sklad,
           F.Hitag,
           case
             when F.Ves<>0 then F.Name+' '+cast(cast(round(F.Ves,2) as float) as varchar)+'кг'
             else F.Name
           end as Name,
           case
             when (sum(F.kol) % F.MinP*1.0)=0 then cast(cast(sum(F.kol)/F.MinP as int) as varchar)
             when (sum(F.kol) % F.MinP)>0 and (Cast(Sum(F.kol)/F.MinP as int)=0) then
                 '+'+cast(cast(sum(F.kol)*1.0%F.MinP as int) as varchar)
             when (sum(F.kol) % F.MinP)>0 then 
                 cast(cast(sum(F.kol)/F.MinP as int) as varchar)+'+'+
                 cast(cast(sum(F.kol)%F.MinP as int) as varchar)             
           end as Kols,
           case
             when F.MinP=1 then sum(F.kol)
             else sum(F.kol) / F.MinP*1.0
           end as KolUp,
           cast(F.MinP as  integer) as MinP,
           case
             when (IsNull(sum(F.Ves),0)>0) then F.Ves*sum(F.kol)          
             when F.Netto>0 then F.Netto*sum(F.kol)
           end as weight,
           cast(sum(F.Kol) as integer) as sKol,
           F.Netto,
           F.Ves,
           Sklad as SortSklad,
           '0' as PalNo,
           0 as NNak,
           0 as Marsh2,
           round(
            (case
             when MinP = 1 then sum(F.Kol)*F.VolMinP
             else sum(F.Kol) / F.MinP*1.0 *F.VolMinP
           end),4) as VolMinP
     from NC cross apply
         (select v.Sklad,v.DatNom,v.hitag,E.Name,
               case when E.Brutto>=E.Netto then E.brutto
                              else E.netto
                              end as Netto,
                 E.MinP,v.Kol,E.VolMinP,
          case
            when E.flgWeight=1 and (IsNull(B.Weight,0)>0) then B.Weight
            when E.flgWeight=1 and (IsNull(D.Weight,0)>0) then D.Weight 
            else 0
          end as Ves
          from NV v left join tdvi B on B.id=v.TekId
                    left join Visual D on D.id=v.TekId
                    left join Nomen E on E.hitag=v.hitag
           where v.DatNom=nc.DatNom and v.kol>0) F  
           left join (select SkladNo,sl.Skg,sg.skgName from SkladList sl join SkladGroups sg on sg.skg=sl.skg)B on B.SkladNo=F.Sklad
      where nc.datnom>=@datnom1 and nc.DatNom<=@datnom2 and Marsh=@Marsh and exists(select v.nvid from nv v where v.datnom=nc.datnom and v.kol>0)
      group by B.Skg,B.SkgName,f.Sklad,F.Hitag,F.Name,
              F.Netto,F.Ves,F.MinP,F.VolMinP
      order by f.Sklad,F.Name
     
  end
else
  begin


    create table #Svod (skg int,SkgName varchar(50),Sklad int,Hitag int,Name varchar(250),
                        Kols varchar(50),KolUp float, MinP int,weight float,sKol int,
                        Netto float,Ves float,PalNo varchar(50),NNak int,Marsh2 int, Pallet bit)

                  
    insert into #Svod (skg,SkgName,Sklad ,Hitag,Name,Kols,KolUp,MinP,weight,sKol,
                       Netto,Ves,PalNo,NNak,Marsh2, Pallet)
    select B.Skg,B.SkgName,f.Sklad,F.Hitag,
           case
             when F.Netto=0 then F.Name+' '+cast(cast(ROUND(F.Ves,2) as float) as varchar)+'кг'
             else F.Name
           end as Name,
           case
             when (sum(F.kol) % F.MinP*1.0)=0 then Cast(Cast(Sum(F.kol)/F.MinP as int) as Varchar)
             when (sum(F.kol) % F.MinP)>0 and (Cast(Sum(F.kol)/F.MinP as int)=0) then
                      '+'+Cast(Cast(Sum(F.kol)*1.0%F.MinP as int) as Varchar)
             when (sum(F.kol) % F.MinP)>0 then 
             Cast(Cast(sum(F.kol)/F.MinP as int) as Varchar)+'+'+
             Cast(Cast(sum(F.kol)%f.MinP as int) as Varchar)             
           end as Kols,
           case
             when F.MinP=1 then Sum(F.kol)
             else Sum(F.kol) / F.MinP*1.0
           end as KolUp,
           F.MinP,
           case
             when F.Netto>0 then F.Netto*Sum(F.kol)
             when F.Netto=0 and  (IsNull(Sum(F.Ves),0)>0) then F.Ves*Sum(F.kol)
           end as weight, sum(F.Kol) as sKol,F.Netto,F.Ves,'0' as PalNo,0 as NNak,
           0 as Marsh2, 0 as Pallet
     from NC join (select Sklad,DatNom,nv.hitag,E.Name,E.Netto,E.MinP,nv.Kol,
                   case
                     when E.Netto=0 and  (IsNull(B.Weight,0)>0) then B.Weight
                     when E.Netto=0 and (IsNull(B.Weight,0)=0) then IsNull(D.Weight,0)
                   end as Ves
                   from NV
                   left join (select id,weight from tdvi)B on B.id=TekId
                   left join (select id,weight from Visual)D on D.id=TekId
                   left join (select hitag,Name,
                              case
                                when Brutto>=Netto then brutto
                                else netto
                              end as Netto,MinP from Nomen)E on E.hitag=nv.hitag
                              where kol>0) F on F.DatNom=nc.DatNom
              left join (select SkladNo,sl.Skg,sg.skgName from SkladList sl join SkladGroups sg on sg.skg=sl.skg)B on B.SkladNo=F.Sklad
     where  nc.datnom>=@datnom1 and nc.DatNom<=@datnom2 and Marsh=@marsh and exists(select v.nvid from nv v where v.datnom=nc.datnom and v.kol>0) 
       and Skg not in (3)                             -- убираем склад мороженого (он у нас делится по паллетам)
     group by B.Skg,B.SkgName,f.Sklad,F.Hitag,F.Name,F.Netto,F.Ves,F.MinP
     order by f.Sklad,F.NAme

    ----------------делим то что нам нужно по паллетам------------
    create table #SvPalet(skg int,SkgName varchar(50),Sklad int,Hitag int,Name varchar(250),
                       Upak float,Kols varchar(50), MinP int,weight float,NNak int,
                       Marsh2 int,Ves float,Vol float, sKol int, Netto float,datnom Bigint)

    insert into #SvPalet(skg,SkgName,Sklad,Hitag,Name,Upak,Kols,MinP,weight,
                        NNak,Marsh2,Ves,Vol,skol,Netto,DatNom)
    select  B.Skg,B.SkgName,f.Sklad,F.Hitag,
            case
              when F.Netto=0 then F.NAme+' '+cast(Cast(ROUND(F.Ves,2) as float) as varchar)+'кг'
              else F.NAme
            end as Name,
            case  
               when F.MinP=1 then F.kol
               else F.kol / F.MinP*1.0
            end as Upak,
            case
              when (F.kol % F.MinP*1.0)=0 then Cast(Cast(F.kol/F.MinP as int) as Varchar)
              when (F.kol % F.MinP)>0 and (Cast(F.kol/F.MinP as int)=0) then 
                  '+'+Cast(Cast(F.kol*1.0%F.MinP as int) as Varchar)
              when (F.kol % F.MinP)>0 then 
                 Cast(Cast(F.kol/F.MinP as int) as Varchar)+'+'+
                 Cast(Cast(F.kol%f.MinP as int) as Varchar)         
           end as Kols,F.MinP,
           case
              when F.Netto>0 then (F.kol*F.Netto)
              when F.Netto=0 and (F.Ves>0) then (F.Ves*F.kol)
           end as weight, dbo.InNnak(nc.datNom)as NNak, Marsh2,F.Ves,
           case  
               when F.MinP=1 then F.kol*F.VolMinP
               else F.kol / F.MinP*1.0 *F.VolMinP
           end as Vol,F.kol,F.Netto,nc.DatNom
           
     from NC
     join
     (select Sklad,DatNom,nv.hitag,E.Name,E.Netto,E.MinP,
            case
               when E.Netto=0 and  (IsNull(B.Weight,0)>0) then B.Weight
               when E.Netto=0 and (IsNull(B.Weight,0)=0) then IsNull(D.Weight,0)
            end as Ves,nv.Kol,E.VolMinP
      from NV
      left join
        (select id,weight from tdvi)B on B.id=TekId
        left join
        (select id,weight from Visual)D on D.id=TekId
        left join
        (select hitag,Name,VolMinP,case
                  when Brutto>=Netto then brutto
                  else netto
                end as Netto,MinP from Nomen)E on E.hitag=nv.hitag   
     where kol>0 )F on F.DAtNom=nc.DatNom
     left join
     (select SkladNo,sl.Skg,sg.skgName from SkladList sl
      join SkladGroups sg on sg.skg=sl.skg)B on B.SkladNo=F.Sklad
     where  nc.datnom>=@datnom1 and nc.DatNom<=@datnom2 and Marsh=@marsh and exists(select v.nvid from nv v where v.datnom=nc.datnom and v.kol>0)
       and Skg in (3)                                    /* склады где нужна разбивка по паллетам  */
     order by Marsh2 desc,nc.Datnom,F.NAme


      create table #SvTmp(datnom Bigint,Skg int,Nnak int, PalNo int,SmVol float, Marsh2 int)

      declare @skg int,@Volum float,@NNak int,@Marsh2 int,@MaxVol float,
              @SumVol float,@PalNo int,@datnom Bigint,@tmp float


      DECLARE @CURSOR CURSOR
      SET @CURSOR= CURSOR SCROLL
      FOR select skg, 
                 case
                   when skg=3 then 1 --мax объем котор должен быть на паллете
                  -- when skg=1 then 0.1
                 end as MaxUp 
          from SkladGroups
          where skg in (3,1)


      OPEN @CURSOR
      FETCH NEXT FROM @CURSOR INTO @skg,@MaxVol

      WHILE @@FETCH_STATUS=0 
      BEGIN
--------внутренний курсор----
        DECLARE @CUR CURSOR
        SET @CUR = CURSOR SCROLL
        FOR select Sum(Vol) as VloSm,NNak,Marsh2,DatNom
            from #SvPalet
            where skg=@skg
            group by NNak,Marsh2,DatNom
            order by Marsh2 desc,NNak
        
        OPEN @CUR
        FETCH NEXT FROM @CUR INTO @Volum,@NNak,@Marsh2,@DatNom
        
        set @PalNo=1;     
        set @SumVol=0;              
        
        WHILE @@FETCH_STATUS=0 
        BEGIN     
          set @tmp=@Volum;   
          
          if @tmp<@MaxVol
          begin
            if @SumVol+@tmp<=@MaxVol 
            begin
              if @SumVol+@tmp=@MaxVol
                set @SumVol=0
              if @SumVol+@tmp<@MaxVol
                set @SumVol=@SumVol+@tmp
             -- set @PalNo=@PalNo+1;  
              insert into #SvTmp(DatNom,Nnak, PalNo,SmVol,Marsh2,skg)
              values(@DatNom,@NNak,@PalNo,@tmp,@Marsh2,@skg)
            end
            else
              if @SumVol+@tmp>@MaxVol 
              begin
                set @PalNo=@PalNo+1;
                insert into #SvTmp(DatNom,Nnak, PalNo,SmVol,Marsh2,skg)
                values(@DatNom,@NNak,@PalNo,@tmp,@Marsh2,@skg)
                set @SumVol=@tmp;
              end                
          end
          else --если упак больше чем умещается на 1 паллете, то в цикле засовываем их на несколько паллет
          begin
            while @tmp>=@MaxVol 
            begin
              set @PalNo=@PalNo+1;
              insert into #SvTmp(DatNom,Nnak,PalNo,SmVol,Marsh2,skg)
              values(@DatNom,@NNak,@PalNo,@MaxVol,@Marsh2,@skg)
              set @tmp=@tmp-@MaxVol; 
               
            end;
            if @tmp<@MaxVol and @tmp>0
            begin
              set @PalNo=@PalNo+1;
              insert into #SvTmp(DatNom,Nnak, PalNo,SmVol,Marsh2,skg)
              values(@DatNom,@NNak,@PalNo,@tmp,@Marsh2,@skg) 
              set @PalNo=@PalNo+1;
              set @tmp=0;
            end; 
          end;
       
          FETCH NEXT FROM @CUR INTO @Volum,@NNak,@Marsh2,@DatNom
        END
        CLOSE @CUR
        DEALLOCATE @CUR
        
    --------конец внутр. курсора----- 

      FETCH NEXT FROM @CURSOR INTO @skg,@MaxVol
    END

      CLOSE @CURSOR

      create table #Pallet(DNom int,No varchar(50),skg int);
      declare @DNom int,@No int,@i int,@j int,@str varchar(50)
      set @str='';

      DECLARE @CUR1 CURSOR
      SET @CUR1= CURSOR SCROLL
      FOR select dbo.InNnak(datNom),PalNo,skg from #SvTmp
          order by datNom,PalNo,skg 
          
      OPEN @CUR1
        FETCH NEXT FROM @CUR1 INTO @DNom,@No,@skg
        set @i=@DNom
        set @j=@skg
        WHILE @@FETCH_STATUS=0 
        BEGIN       
          if @i=@DNom 
            set @str=@Str+cast(@No as varchar)+';'
          else
          BEGIN
            insert into #Pallet(DNom,No,skg) values(@i,@str,@j)
            set @i=@DNom
            set @j=@skg
            set @str=cast(@No as varchar)+';'
          end
          FETCH NEXT FROM  @CUR1 INTO @DNom,@No,@skg
        END
        insert into #Pallet(DNom,No,skg) values(@i,@str,@j)
      CLOSE @CUR1


------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------
      insert into #Svod (skg ,SkgName,Sklad,Hitag,Name,Kols ,KolUp, MinP,weight,sKol,
                        Netto,Ves,PalNo,NNak, Pallet)
      select sp.skg,SkgName,Sklad,sp.Hitag,Name,
              case
                when (sum(skol) % MinP*1.0)=0 then Cast(Cast(sum(skol)/MinP as int) as varchar)
                when (sum(skol) % MinP)>0 and (Cast(sum(skol)/MinP as int)=0) then
                            '+'+Cast(Cast(Sum(skol)*1.0%MinP as int) as varchar)
                when (sum(skol) % MinP)>0 then 
                   cast(cast(sum(skol)/MinP as int) as varchar)+'+'+
                   cast(cast(sum(skol)%MinP as int) as varchar)             
             end as Kols, sum(Upak) as Upak, MinP,
             case
                when Netto > 0 then Netto*sum(skol)
                when Netto = 0 and  (IsNull(sum(Ves),0)>0) then Ves*sum(skol)
             end as weight,
            Sum(sKol) as Skol,Netto,Ves,Sv.No,0,1
      from #SvPalet sp
      left join
      (select Dnom, No,skg from #Pallet) Sv on Sv.DNom=sp.NNak and sv.skg=sp.skg
      group by sp.Skg,SkgName,No,Sklad,sp.Hitag,NAme,Netto,Ves,MinP
      order by Sklad,NAme

      delete NcPalletNom
      where pnId in (select pnid from NcPalletNom np join #SvTmp s on s.skg=np.skg and s.DatNom=np.DatNom)

      insert into NcPalletNom (skg, datNom, PalletNo, Volum)
      select skg, datNom, PalNo, sum(SmVol)
      from #SvTmp
      group by skg,PalNo,datNom

      select s.skg,
             s.SkgName,
             s.Sklad ,
             s.Hitag,
             s.Name,
             s.Kols,
             s.KolUp,
             s.MinP,
             s.weight,
             s.sKol,
             s.Netto,
             s.Ves,
             s.PalNo,
             s.NNak,
             s.Marsh2,
             case
               when s.Pallet=1 then 0
               else s.Sklad
             end as SortSklad,
             round(
             (case  
               when s.MinP=1 then s.skol*A.VolMinP
               else s.skol / s.MinP*1.0 *A.VolMinP
             end) ,4) as VolMinP
             
      from #Svod s left join Nomen A on A.hitag=s.hitag
      order by s.skg, s.PalNo, s.Sklad, Name

      /*
      select skg,datNom,PalNo,Sum(SmVol)
      from #SvTmp
      group by skg,PalNo,datNom

      select *
      from #Pallet

      select Sum(Vol) as VloSm,NNak,Marsh2,DatNom
                  from #SvPalet
                  where skg=3
                  group by NNak,Marsh2,DatNom
                  order by Marsh2 desc,NNak*/
  end        
END