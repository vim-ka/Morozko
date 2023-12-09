CREATE PROCEDURE db_FarLogistic.GetLookUpToAdd
@ind int 
AS
declare @sql varchar(2500)
set @sql=case when @ind=1 then 'select 	p.PersID [id],
																				p.SecondName+'' ''+p.FirstName+'' ''+p.MiddleName [list]
																from hrmain.dbo.Pers p 
																join hrmain.dbo.Staffs s on s.StaffsID=p.PersStaff
																where s.SubDepsID=14 
																and s.PostsID in (16,79)
																and not p.persid in (select id from db_FarLogistic.dlDrivers)'
							when @ind=2 then 'select 	distinct
              													d.pin [id],
																				d.brName [list] 
																from def d
																join defcontract dc on d.pin=dc.pin 
																where not d.pin in (select id from db_FarLogistic.dlDef)
																			and dc.ContrTip in (1,2,4)
																			and dc.Actual=1
																			and d.Actual=1
                                union all
                                select distinct
                                			 pin,
                                			 brname
                                from def where ncod in (select vendors.ncod from vendors)'
							when @ind=3 then 'select -1 [id], ''Справочник не задан'' [list]'
							when @ind=4 then 'select -1 [id], ''Справочник не задан'' [list]'
							else 'select -1 [id], ''Справочник не задан'' [list]' 
					end

exec(@sql)