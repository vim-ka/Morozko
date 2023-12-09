CREATE PROCEDURE NearLogistic.GetStackSheets 
@ND1 datetime, 
@ND2 datetime
AS
BEGIN
select  l.nd, 
        l.tm, 
        l.ListNo as VedNo, 
        l.Op,
        p.fio,
        l.StartND,
        l.EndND, 
        t.TariffType,
        l.ttID
from [NearLogistic].nlListPay l 
join [NearLogistic].nlTariffType t on l.ttID=t.ttID
JOIN usrPwd p ON l.Op=p.uin
where l.ND BETWEEN @ND1 AND @ND2
			and year(l.nd)>=2018
END