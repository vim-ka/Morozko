CREATE FUNCTION dbo.GetGrChild (@ngrp int)
RETURNS varchar(2000)
AS
BEGIN
	declare @child varchar(2000);
  with GRChild (ngrp)
    as (select ngrp
        from gr 
        where ngrp<>0 and gr.aginvis=0 and ngrp=@ngrp 
            
        union all 
        
        select gr.ngrp
        from gr
        inner join GRChild on GRChild.ngrp=gr.parent
        where gr.ngrp<>0 and gr.aginvis=0 and gr.ngrp<>@ngrp      
        )
    
    select @child= stuff((
    select N','+cast(ngrp as varchar)
    from GRChild
    for xml path(''), type).value('.','varchar(max)'),1,1,'')
    
   return isnull(@child,'')
END