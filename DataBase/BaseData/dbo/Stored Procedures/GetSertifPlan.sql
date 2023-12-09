CREATE PROCEDURE dbo.GetSertifPlan
@nd datetime
AS
BEGIN
  set @nd=dateadd(day,1,EOMONTH((dateadd(month,-1,@nd))))
	
	if not exists(select * from sertifplan where nd=@nd)
	begin
		insert into SertifPlan(nd,sert_id,endDate)
		select @nd, sert_id, endDate 
		from Sertif 
		where month(endDate)=month(@nd)
					and year(endDate)=year(@nd)
	end	

	update sertifplan set isWasted=case when not exists(select * 
																										  from Sertif 
																											where month(sertif.endDate)=month(@nd) 
																														and year(sertif.endDate)=year(@nd) 
																														and sertif.sert_id=sertifplan.sert_id) then 1 else 0 end
	where nd=@nd
				--and isnull(isWasted,0)=0 
				--and not exists(select * from Sertif where month(sertif.endDate)=month(@nd) and year(sertif.endDate)=year(@nd) and sertif.sert_id=sertifplan.sert_id)

	select * from sertifplan where nd=@nd
END