CREATE procedure EditReportFormsDebug
  @Name varchar(50), @data image
as begin
  if EXISTS(select name from ReportFormsDebug where name=@name) 
  update ReportFormsDebug set Format=@data where Name=@name
  else insert into ReportFormsDebug(Name,Format) values(@Name,@data)  
end