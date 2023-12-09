CREATE FUNCTION dbo.GetGrOnlyParent (@ngrp int)
RETURNS int
AS
BEGIN
  declare @Parent int;
  with GRParent (ngrp)
    as (select parent as ngrp
        from dbo.gr 
        where ngrp<>0 and /*gr.aginvis=0 and*/ ngrp=@ngrp 
            
        union all 
        
        select gr.parent as ngrp
        from dbo.gr
        inner join GRParent on GRParent.ngrp=gr.ngrp
        where gr.ngrp<>0 and /*gr.aginvis=0 and*/ GR.parent<>0     
        )
    
    select @Parent=(select r.ngrp from GRParent g join dbo.gr r on g.ngrp=r.ngrp
                    where r.parent=0 AND r.[Ngrp]<>0)
   return @Parent
END