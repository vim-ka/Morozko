CREATE function dbo.get_vendors_marsh (@marshid int)
returns varchar(1000)
as
begin
	declare @res varchar(500); set @res='';
  set @res=left(
  	isnull(stuff(
    (select N','+isnull(d.brName,'<..>')
    from db_farlogistic.dljorneyinfo i 
    join db_farlogistic.dldef d on d.id=i.vendorid
    where i.marshid=@marshid and i.vendorid<>16256
    group by isnull(d.brName,'<..>')
    for xml path(''), type).value('.','varchar(max)'),1,1,''),'<..>')
  ,1000)
  return @res;
end