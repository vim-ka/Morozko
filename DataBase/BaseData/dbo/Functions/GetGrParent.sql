CREATE FUNCTION dbo.GetGrParent (@ngrp int)
RETURNS varchar(2000)
AS
BEGIN
  declare @Parent varchar(2000);
  with GRParent (ngrp)
    as (select parent as ngrp
        from gr 
        where ngrp<>0 and gr.aginvis=0 and ngrp=@ngrp 
            
        union all 
        
        select gr.parent as ngrp
        from gr
        inner join GRParent on GRParent.ngrp=gr.ngrp
        where gr.ngrp<>0 and gr.aginvis=0 and GR.parent<>0     
        )
    
    select @Parent= stuff((
    select N','+cast(ngrp as varchar)
    from GRParent
    for xml path(''), type).value('.','varchar(max)'),1,1,'')
    
   return cast(@ngrp as varchar)+isnull(','+@Parent,'')
END