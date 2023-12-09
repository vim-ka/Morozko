CREATE procedure CalcInmarkoD1
@nd1 datetime, @nd2 datetime
AS
begin
  select 
    nc.nd, d.gpInn, d.gpName, d.gpAddr,
    case when d.[Master]=0 then 2 
        when d.[Master]>0 then 12
    end as grp,   
    case when d.[Master]=0 then 'Магазины' 
        when d.[Master]>0 then 'Сети'
    end as grpName,
    case when d.[Master]=0 then 51
        when d.[Master]>0 then 46
    end as fmt,         
    case when d.[Master]=0 then 'Розница BC' 
        when d.[Master]>0 then 'Супермаркет A'
    end as fmtName,
    r.rk,
    r.Region,
    a.fam,
    nc.b_id,
    n.CodeNum,
    n.[Name],
    sum(v.kol) as kol,
    round(sum(v.kol*v.price)/(1+1.0*n.NDS/100),2) as pricewoNDS,
    sum(v.kol*v.price) as price,
    round(sum(v.kol*v.cost)/(1+1.0*n.NDS/100),2) as costwoNDS,
    sum(v.kol*v.cost) as cost
  from nv v inner join nc on nc.datnom=v.datnom
            join InmarkoNomen n on v.hitag=n.hitag
            join Def d on nc.b_id=d.pin and d.tip=1
            join InmarkoRegions r on d.Obl_ID=r.obl_id and d.Rn_ID=r.Rn_id 
            left join agents a on a.ag_id=d.brAg_id 
            join supervis s on a.sv_id=s.sv_id
  where 
    nc.nd>=@nd1 and nc.nd<=@nd2
    and v.kol>0 and d.Worker=0 and d.gpName<>'ТЕСТ' and s.DepID<>5
  group by 
    nc.nd, d.gpInn,d.gpName,d.gpAddr,d.Master,r.rk,r.City,a.fam,nc.b_id,n.Hitag,n.CodeNum,n.NDS,n.[Name],r.Region

end