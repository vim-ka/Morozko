create procedure dbo.get_available_units @hitag int, @res varchar(50) output
as
begin
set @res=isnull((
select stuff((select N','+cast(unid as varchar) from (
							select unid from dbo.nomen where hitag=@hitag
							union select Unid2 from dbo.UnitConv where hitag=@hitag and isdel=0) a
              for xml path(''), type).value('.','varchar(max)'),1,1,'')
),'-1')              
end