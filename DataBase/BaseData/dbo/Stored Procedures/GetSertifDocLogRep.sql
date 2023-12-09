CREATE PROCEDURE dbo.GetSertifDocLogRep
@nd datetime, 
@isDay bit=0,
@isStf bit=0
AS
BEGIN
	create table #stfDatnom (datnom int)
	create unique index dtn_idx on #stfDatnom(datnom)
	
	--if @isStf=0
		insert into #stfDatnom
		select datnom 
		from nc 
		where --isnull(nc.StfNom,'')=''
					--and 
					year(nc.nd)= case when @isDay=1 then year(nc.nd) else year(@nd) end 
					and month(nc.nd)= case when @isDay=1 then month(nc.nd) else month(@nd) end
					and nc.nd= case when @isDay=1 then @nd else nc.nd end
	--else
		/*
		insert into #stfDatnom
		select datnom 
		from nc 
		where isnull(nc.StfNom,'')<>''
					and year(nc.nd)= case when @isDay=1 then year(nc.nd) else year(@nd) end 
					and month(nc.nd)= case when @isDay=1 then month(nc.nd) else month(@nd) end
					and nc.nd= case when @isDay=1 then @nd else nc.nd end
		*/
	select 	case when @isDay=1 then @nd else dateadd(day,1,eomonth(dateadd(month,-1,@nd))) end smND,
					case when @isDay=1 then @nd else eomonth(@nd) end emND,
					u.uin,
					u.fio,
					d.dno,
					d.dName,
					case when z.dNo in (4)
					then 
					(select count(*)
					from
					(select l.nd,
									c.Marsh,
									c.b_id 
					 from SertifLog l
					 left join nc c on c.DatNom=l.datnom  
					 where l.op=z.op 
								 and year(l.nd)= case when @isDay=1 then year(l.nd) else year(@nd) end 
								 and month(l.nd)= case when @isDay=1 then month(l.nd) else month(@nd) end
								 and l.nd= case when @isDay=1 then @nd else l.nd end
								 and (l.SertifDoc & z.dno)<>0
								 and exists(select datnom from #stfDatNom where datnom=l.DatNom)								 
						group by l.nd, c.marsh, c.b_id) x
						)
						when z.dNo in (16)
						then 
						(select count(*)
						from
						(select l.nd,
										c.Marsh
						 from SertifLog l
						 left join nc c on c.DatNom=l.datnom  
						 where l.op=z.op 
									 and year(l.nd)= case when @isDay=1 then year(l.nd) else year(@nd) end 
									 and month(l.nd)= case when @isDay=1 then month(l.nd) else month(@nd) end
									 and l.nd= case when @isDay=1 then @nd else l.nd end
									 and (l.SertifDoc & z.dno)<>0
									 and exists(select datnom from #stfDatNom where datnom=l.DatNom)								 
							group by l.nd, c.marsh) x
							)
						else 
						(select count(*) 
						 from SertifLog l
						 where l.op=z.op 
									 and year(l.nd)= case when @isDay=1 then year(l.nd) else year(@nd) end 
									 and month(l.nd)= case when @isDay=1 then month(l.nd) else month(@nd) end
									 and l.nd= case when @isDay=1 then @nd else l.nd end
									 and (l.SertifDoc & z.dno)<>0
									 and exists(select datnom from #stfDatNom where datnom=l.DatNom)
									 )									 
						end as [cnt]
						
	from (select 	distinct sl.op,
								sd.dNo 				 
				from SertifLog sl
				join SertifDoc sd on 1=1
				where year(sl.nd)= case when @isDay=1 then year(sl.nd) else year(@nd) end 
							and month(sl.nd)= case when @isDay=1 then month(sl.nd) else month(@nd) end
							and sl.nd= case when @isDay=1 then @nd else sl.nd end
							and exists(select datnom from #stfDatNom where datnom=sl.DatNom)
							and exists(select * from SertifDocPerson where uin=sl.op and (docs & sd.dno)<>0) 
				) z
	left join usrpwd u on u.uin=z.op
	left join SertifDoc d on d.dno=z.dno
	order by u.fio, d.dno 
		
	drop table #stfDatnom
END