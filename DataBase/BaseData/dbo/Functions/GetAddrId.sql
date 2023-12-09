CREATE FUNCTION dbo.GetAddrId (@Storage int, @level int, @Index int,
                               @NLine int, @Depth int) RETURNS varchar(12)
AS
BEGIN
   declare @tmp varchar(2),@Addr varchar(20)
  set @Addr='';
  
  set @tmp=@Storage;
  if len(@tmp)<=2
  begin
    if len(@tmp)=1
      set @tmp='0'+@tmp;
    set @Addr=@tmp+'.'; 
  end;
  
  set @tmp=@Level;
  if len(@tmp)=1 and @Addr<>''
  begin
    set @Addr=@Addr+@tmp+'.'; 
  end;
  
  set @tmp=@Index;
  if len(@tmp)=1 and @Addr<>''
  begin
    set @Addr=@Addr+@tmp+'.'; 
  end;
  
  set @tmp=@NLine;
  if len(@tmp)<=2 and @Addr<>''
  begin
    if len(@tmp)=1
      set @tmp='0'+@tmp;
    set @Addr=@Addr+@tmp+'.'; 
  end;
  
  set @tmp=@Depth;
  if len(@tmp)<=2 and @Addr<>''
  begin
    if len(@tmp)=1
      set @tmp='0'+@tmp;
    set @Addr=@Addr+@tmp; 
  end;
  
RETURN @Addr
  
END