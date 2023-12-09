CREATE function NearLogistic.get_naklsremark (@mhid int, @b_id int)
returns varchar(3000)
as
begin
	declare @res varchar(max)
  declare @result varchar(max)
  set @res=stuff((
  select N''+iif(ltrim(rtrim(isnull(x.remark,'')))='','',ltrim(rtrim(x.remark))+';'+char(10))
  from (
  select distinct ltrim(rtrim(isnull(c.remark,''))) [remark]
  from dbo.nc c 
  where c.mhid=@mhid and c.b_id=@b_id and c.delivcancel=0) x
  for xml path(''), type).value('.','varchar(max)'),1,0,'')
  
  set @res=replace(@res,'доставка','<b> [ДОСТАВКА] </b>')
  
  set @result=ltrim(rtrim(left(isnull(@res,''),3000)))
  return @result
end