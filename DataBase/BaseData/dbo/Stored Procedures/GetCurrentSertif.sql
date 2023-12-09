CREATE PROCEDURE dbo.GetCurrentSertif
AS
select 	s.sert_id,
				s.PersOtv,
				s.orgName,
				s.nSert,
				s.begDate,
				s.endDate,
				s.nVet,
				s.dateVet,
				(select count(p.sert_id) from SertifPic p where p.sert_id=s.sert_id and p.isdel=0) [cnt]
from Sertif s
order by 1