CREATE function NearLogistic.get_free_reg_id(@reqid int,@flg int =0) 
returns varchar(50)
as
begin
	declare @res varchar(50)
  
  set @res=isnull((
  select top 1 iif(@flg=0,p.reg_id,r.place)
  from nearlogistic.marshrequestsdet d
  join nearlogistic.marshrequests_points p on p.point_id=d.point_id 
  join dbo.Regions r on r.Reg_ID=p.reg_id
  where mrfid=@reqid and action_id=6 order by d.place desc),'')
  
  return ltrim(rtrim(@res))
end