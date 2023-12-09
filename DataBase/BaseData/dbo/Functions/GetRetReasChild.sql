CREATE FUNCTION dbo.GetRetReasChild (@Reason_ID int)
RETURNS varchar(2000)
AS
BEGIN
  declare @child varchar(2000);
  
  with RetReasChild (Reason_ID) as
  (select Reason_ID
        from ReasonToRtrn 
        where Parent_ID=@Reason_ID or Reason_ID=@Reason_ID
            
        union all 
        
        select r.Reason_ID
        from ReasonToRtrn r 
        inner join RetReasChild rr on rr.Reason_ID=r.parent_id
        where rr.Reason_id<>@Reason_ID
        )
    
    select @child= stuff((
    select N','+cast(Reason_ID as varchar)
    from RetReasChild
    for xml path(''), type).value('.','varchar(max)'),1,1,'')
    
   return isnull(@child,'')
END