CREATE PROCEDURE [NearLogistic].DelFromMarsh @Rec bit, @mhid varchar(100), @ReqOrder int, @op int
AS
BEGIN
  declare @ermsg varchar(1000), @ids varchar(max)
  if @Rec = 0 
  begin
   select count(m.mrID) as Kolvo
   from NearLogistic.MarshRequests m
   where m.mhid in (select k from dbo.Str2intarray(@mhid))
         and m.ReqOrder=@ReqOrder and ReqType<>-1;
  end
  else
  begin
    
    set @ids=stuff((select cast(m.ReqID as varchar(10))+';'+cast(m.reqType as varchar(4))+';1#' from NearLogistic.MarshRequests  m where m.mhid in (select k from dbo.Str2intarray(@mhid)) and m.ReqOrder=@ReqOrder for xml path ('')),1,0,'') 
     
    EXEC [NearLogistic].[MarshRequetOperations]  @ids, 0, @op, 1, @ermsg, 1, 'Деловая карта' ;
  end;
  
END