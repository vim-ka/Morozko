CREATE procedure EditReportForms 
  @Name varchar(50), @data image
as begin
  if EXISTS(select name from ReportForms where name=@name) 
  update ReportForms set Format=@data where Name=@name
  else insert into ReportForms(Name,Format) values(@Name,@data)  
end