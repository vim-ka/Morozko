CREATE PROCEDURE CalcAgNotSat @day0 datetime, @day1 datetime
AS
BEGIN
 select n.*,
        nn.*,
        case when isnull(n.SkladRozn,0) > 0  then 'Товар заблокирован/недоступен'
             when isnull(n.SkladRozn,0) <= 0 then 'Нет на складе'
                                             else 'Склад заблокирован' END as Reason,    
        t.fio,
        p.fio ffam
 from NotSat n left join nomen nn on n.hitag=nn.hitag
               cross apply
              (select v.hitag, max(v.ncod) as ncod, p.fio
              from visual v left join vendors e on v.ncod=e.ncod
                            left join usrPwd u on u.uin=e.buh_uin
                            left join person p on u.p_id=p.p_id
              where n.hitag=v.hitag                       
              group by v.hitag, p.fio) t 
              left join agentlist a on n.ag_id=a.ag_id
              left join person p on a.p_id=p.p_id 
 where n.nd >= @day0 and n.nd <= @day1
 order by n.ag_id, n.hitag
END