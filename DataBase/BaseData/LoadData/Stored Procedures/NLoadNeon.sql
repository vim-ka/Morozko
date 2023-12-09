CREATE PROCEDURE [LoadData].NLoadNeon  @Type smallint, @StartND datetime, @EndND datetime, @Ncod varchar(50)
AS
BEGIN
  --ncod=1467
  if @type = 1
  begin

    select 'ИНН' as INN,
           'Дистрибьютор' as Name,
           'Дата начала' as StartND,
           'Дата окончания' as EndND,
           'Номер склада' as Sklad,
           'Название склада' as SkladName,
           'Почта' as Email,
           0 as Junk

    union
    select distinct 
          '['+cast(f.OurINN as varchar)+']', 
           f.OurName,
           format(@StartND,'dd.MM.yy') as StartND,
           format(@EndND,'dd.MM.yy') as EndND,
           '['+cast(v.sklad as varchar)+']' as Sklad,
           g.skgName,
           'it@tdmorozko.ru' as email,
           1 as Junk
    from visual v join firmsconfig f on v.our_id=f.our_id
                  join skladlist s on v.sklad=s.skladno
                  join skladgroups g on s.skg=g.skg
    where v.Ncod in (select K from dbo.Str2intarray(@Ncod))
          and v.hitag not in (95007,90858) and v.sklad  in (32,34,84,90)
          and v.datepost<=@EndND and v.our_id<>6  
          -- v.datepost>=@StartND and
          and s.safecust=0 --and s.equipment=0     
    order by Junk      
  end
  else
  if @type = 2
  begin
    select '№ п/п' as Nom,
           'ИД операции' as IDOper,
           'Дата операции' as NDOper,
           'Дата документа' as NDDoc,
           'Тип перемещения' as TypeOper,
           'Код торгового представителя' as CodeAg,
           'Торговый представитель' as FIOAg,
           'Наименование клиента' as gpName,
           'Код клиента' as CodeCl,
           'ИНН Клиента' as INNCl,
           'Номер склада' as Sklad,
           '№ документа 1' as DocNom1,
           '№ документа 2' as DocNom2,
           '№ документа 3' as DocNom3,
           'Код ТП' as CodeTP,
           'Штрихкод ТП' as BarCode,
           'Наименование ТП' as NameTp,
           'Кол-во, в ед. товара' as Qty,
           'Цена реализации' as Price,
           'Цена поставки' as Cost,
           'Валюта операции' as RUR,
           'Код супервайзера' as CodeSv,
           'Супервайзер' as FIOSv,
           'Дата выпуска' as NDPost,
           'Адрес клиента' as Addr,
           'Идентификатор раздела Б' as PartB,
           0 as Junk
    union     
      select cast(ROW_NUMBER() OVER(ORDER BY nom) as varchar) AS RN,
             t.nom,
             isnull(format(t.nd,'dd.MM.yy'),''),
             isnull(format(t.docnd,'dd.MM.yy'),''),
             cast(t.type as varchar),
             '['+cast(t.ag_id as varchar)+']',
             t.fio,
             t.gpName,
             '['+cast(t.pin as varchar)+']',
             '['+cast(isnull(t.gpInn,'') as varchar)+']',
             '['+cast(t.sklad as varchar)+']',
             t.Doc1,
             isnull(t.stfnom,''),
             cast(isnull(t.gpKpp,'') as varchar),
             '['+cast(t.hitag as varchar)+']',
             '['+cast(t.barCode as varchar)+']',
             t.name,
             replace(cast(t.kol as varchar),'.', ','),
             replace(cast(t.price as varchar),'.', ','),
             replace(cast(t.cost as varchar),'.', ','),
             t.Rur,
             '['+cast(t.sv_ag_id as varchar)+']',
             t.fiosuper,
             isnull(format(t.dater,'dd.MM.yy'),''),
             t.gpAddr,
             t.B,
             1 as Junk
     from
    
     ( select 'sls'+ cast(c.ncid as varchar) as nom,
            c.nd,
            iif(c.stfdate is null, c.nd, c.stfdate) as docnd,
            iif (v.kol<0, 2, 0) as type,
            c.ag_id,
            pa.fio,
            d.gpName,
            d.pin,
            d.gpInn,
            i.sklad,
            iif(isnull(c.stfnom,'')='',cast(dbo.InNNak(c.datnom) as varchar), c.stfnom) as Doc1,
            c.stfnom, 
            d.gpKpp,
            v.hitag,
            n.barcode,
            iif(n.fname is null, n.name, n.fname) as name,
            iif (v.kol<0, -v.kol, v.kol) as kol,
            v.price,
            v.cost,
            'RUR' as Rur,
            a.sv_ag_id,
            ps.fio as fioSuper,
            i.dater,
            d.gpAddr,
            '' as B
    from nc c join nv v on c.datnom=v.datnom        
              join visual i on v.tekid=i.id
              join def d on c.b_id=d.pin
              join nomen n on n.hitag=v.hitag
              left join agentlist a on c.ag_id=a.ag_id
              left join person pa on a.p_id=pa.p_id
              left join agentlist s on a.sv_ag_id=s.ag_id
              left join person ps on s.p_id=ps.p_id
    where c.ND>=@StartND and c.ND<=@EndND and i.Ncod in (select K from dbo.Str2intarray(@Ncod))         
          and c.stip<>4 and v.kol<>0
          
    union

    select 'izm'+ cast(m.izmid as varchar) as nom,
            m.nd,
            m.nd as docnd,
            case when m.Act='Снят' then 4 
                 when m.Act='Скла' then 5
                 when m.Act='Испр' and m.kol-m.newkol<0 then 7        
                 when m.Act='Испр' and m.kol-m.newkol>0 then 8
         
            end as Type,  
            0 as ag_id,
            '' as fio,
            '' as gpName,
            0 as pin,
            '' as Inn,
            m.sklad,
            cast(m.izmid as varchar),
            '', 
            '',
            m.hitag,
            n.barcode,
            iif(n.fname is null, n.name, n.fname) as name,
            case when m.Act='Скла' then m.kol
                 when m.Act='Испр' and m.kol-m.newkol<0 then m.newkol-m.kol
                 when m.Act='Испр' and m.kol-m.newkol>0 then m.kol-m.newkol
                 else m.kol-m.newkol
            end as kol,
            m.price,
            m.cost,
            'RUR' as Rur,
            0 as sv_ag_id,
            '' as fio,
            i.dater,
            '' as gpAddr,
            '' as B
    from izmen m join visual i on m.id=i.id
                 join nomen n on n.hitag=m.hitag
                 join DefContract d on i.dck=d.dck
    where m.ND>=@StartND and m.ND<=@EndND and m.Ncod in (select K from dbo.Str2intarray(@Ncod)) and m.Act<>'ИзмЦ'
            and d.ContrTip=1 and m.sklad<>19
            
   union

    select 'izm'+ cast(m.izmid as varchar) as nom,
            m.nd,
            m.nd as docnd,
            case when m.Act='Скла' then 6
            end as Type,  
            0 as ag_id,
            '' as fio,
            '' as gpName,
            0 as pin,
            '' as Inn,
            m.newsklad,
            cast(m.izmid as varchar),
            '', 
            '',
            m.hitag,
            n.barcode,
            iif(n.fname is null, n.name, n.fname) as name,
            case when m.Act='Скла' then m.kol
            end as kol,
            m.price,
            m.cost,
            'RUR' as Rur,
            0 as sv_ag_id,
            '' as fio,
            i.dater,
            '' as gpAddr,
            '' as B
    from izmen m join visual i on m.id=i.id
                 join nomen n on n.hitag=m.hitag
                 join DefContract d on i.dck=d.dck
    where m.ND>=@StartND and m.ND<=@EndND and m.Ncod in (select K from dbo.Str2intarray(@Ncod)) and m.Act<>'ИзмЦ'
            and d.ContrTip=1 and m.sklad<>19 and m.Act='Скла'        

    union 
    
    select 'com'+ cast(i.id as varchar) as nom,
            c.[date],
            c.[date] as docnd,
            1 as Type,  
            0 as ag_id,
            '' as fio,
            '' as gpName,
            0 as pin,
            '' as Inn,
            i.sklad,
            cast(c.ncom as varchar), 
            cast(c.doc_nom as varchar),
            '',
            i.hitag,
            n.barcode,
            iif(n.fname is null, n.name, n.fname) as name,
            i.kol,
            i.price,
            i.cost,
            'RUR' as Rur,
            0 as sv_ag_id,
            '' as fio,
            i.dater,
            '' as gpAddr,
            '' as B
    from comman c join inpdet i on c.ncom=i.ncom
                  join nomen n on n.hitag=i.hitag
                  join DefContract d on c.dck=d.dck
    where c.[Date]>=@StartND and c.[Date]<=@EndND and c.Ncod in (select K from dbo.Str2intarray(@Ncod))
          and d.ContrTip=1 and i.hitag not in (95007,90858)
    ) t
    order by Junk, Nom
    
  end
  else
  if @type = 3
  begin
   
   
     select t.id, 
            t.MornRest as MornRest,
            t.MornRest*t.cost as Stoim,
            t.sklad,
            t.Hitag,
            t.dck
            into #BegOstat
     from   MorozArc.dbo.ArcVI t 
     where t.WorkDate=@StartND and t.Ncod in (select K from dbo.Str2intarray(@Ncod)) and
           t.hitag not in (95007,90858)

     select t.id,
            t.EveningRest as MornRest,
            t.EveningRest*t.cost as Stoim,
            t.sklad,
            t.Hitag,
            t.dck
            into #EndOstat
     from   MorozArc.dbo.ArcVI t 
     where t.WorkDate=@EndND and t.Ncod in (select K from dbo.Str2intarray(@Ncod)) and
           t.hitag not in (95007,90858)
      
      
      select 'Код ТП' as Hitag,
             'Штрихкод ТП' as barCode,
             'Наименование ТП' as gpName,
             'Остаток на начало, в ед. товара' as BegGoog,
             'Остаток на конец, в ед. товара' as EndGood,
             'Остаток на начало, в ценах поставки' as BegCost,
             'Остаток на конец, в ценах поставки' as EndCost,
             'Номер склада' as Sklad,
             'Дата выпуска' as Date,
             'Идентификатор раздела Б' as PartB,
             0 as Junk,
             0 as P

      union

      select cast(n.hitag as varchar),
            '['+n.barcode+']',
             iif(n.fname is null, n.name, n.fname) as name,
             cast(isnull(b.MornRest,0) as varchar) as BegRest,
             cast(isnull(e.MornRest,0) as varchar) as EndRest,
             replace(cast(isnull(b.Stoim,0) as varchar),'.', ',') as BegStoim,
             replace(cast(isnull(e.Stoim,0) as varchar),'.', ',') as EndStoim,
             '['+cast(iif(b.sklad is null, e.sklad,b.sklad)as varchar)+']',
             isnull(format(v.dater,'dd.MM.yy'),''),
             '' as B,
             1 as Junk,
             
             isnull(sum(i.kol),0) as Prih
      from  #BegOstat b full join #EndOstat e on b.id=e.id
                             join nomen n on n.hitag=iif(b.hitag is null, e.hitag, b.hitag)
                             join visual v on v.id=iif(b.id is null, e.id, b.id)
                             join defcontract d on d.dck=iif(b.dck is null, e.dck, b.dck)
                             
                             left join inpdet i on i.id=iif(b.id is null, e.id, b.id)
                             left join comman c on i.ncom=c.ncom and c.[date] between @StartND and @EndND
      where d.Contrtip=1
            
            
      group by n.hitag, n.barcode, n.name, n.fname, b.MornRest,e.MornRest,b.Stoim,e.Stoim ,e.sklad,b.sklad ,v.dater    
      order by Junk  
   
     drop table #BegOstat
     drop table #EndOstat
   
  end
  else
  if @type = 4
  begin
    select 'Дата установки' as DateStart,
           'Исправность' as Ispr,
           'Наименование клиента' as Client,
           'Код клиента' as CodeCl,
           'ИНН клиента' as INN,
           'Номер склада' as Sklad,
           'Адрес клиента' as Addr,
           'Код оборудования' as FrizCode,
           'Заводской №' as FabNom,
           'Инвентарный №' as InvNom,
           'Модель и наименование' as Model,
           'Стоимость размещения, руб' as CostRub,
           'Стоимость размещения, %' as CostPerc,
           0 as Junk

    union       
             
    select isnull(format(d.NDBeg,'dd.MM.yy'),''), 
           iif(f.b_id>0,'[1]','[4]') as Ispr,
           isnull(e.gpName,''),
           '['+cast(f.b_id as varchar)+']',
           '['+isnull(e.gpInn,'')+']',
            '[0]',
            isnull(e.gpAddr,''),
            '['+cast(f.nom as varchar)+']',
            '['+f.fabnom+']',
            '['+f.invnom+']',
            m.Model,'','',
            1 as Junk
    from FRIZER f left join
    (select 
      CASE
        when isnull(NestNo,0)<>0 then cast(max(NestNo) as  varchar) +'Н'
        when DopContrNo=0 then cast(max(ContractNo) as  varchar)
        else
          cast(max(ContractNo) as  varchar)+'/'+cast(DopContrNo as Varchar) 
      end as ContractNo, C.nom, NDBeg from FrizContract fc
     join
     (select nom,max(Contractid) as Contractid
     from FrizContractDet where kol>0 and isnull(DopNoExcep,0)=0
     group by nom) C on C.Contractid=fc.Contractid
     group by C.nom,DopContrNo,NDBeg,NestNo) D on f.nom=D.nom
     left join Def e on f.b_id=e.pin 
     left join FrizerFunc u on f.ffid=u.ffid
     left join FrizerStick k on f.fsID=k.fsID
     left join FrizerModel m on f.Fmod=m.Fmod
     where f.tip=0 and f.ncod in (-1)
     order by Junk
  
  end



END