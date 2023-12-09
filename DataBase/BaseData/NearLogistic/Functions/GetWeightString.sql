create function NearLogistic.GetWeightString (@mhid int)
returns varchar(100)
as
begin
	declare @res varchar(100)
  declare @mas decimal(15,2)
  
  select @mas=sum(iif(n.flgweight=1,isnull(t.weight,s.weight)*v.kol,n.brutto*v.kol))
  from dbo.nc c 
  join dbo.nv v with(nolock, index(nv_datnom_idx)) on c.datnom=v.datnom
  join dbo.nomen n on n.hitag=v.hitag
  join dbo.gr g on g.ngrp=n.ngrp
  join nearlogistic.masstype ms on ms.nlmt=g.nlmt_new
  left join dbo.tdvi t on t.id=v.tekid
  left join dbo.visual s on s.id=v.tekid
  where c.mhid=@mhid            
      	and ms.min_term in (-18)
        
	set @res=iif(isnull(@mas,0)>0,'['+cast(@mas as varchar)+']','')  
  return @res      
end