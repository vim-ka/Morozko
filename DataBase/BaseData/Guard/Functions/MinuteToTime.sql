CREATE FUNCTION [Guard].MinuteToTime (@InpM int
)
RETURNS char(5)
AS
BEGIN
  declare @h tinyint, @m tinyint, @ch char(2), @cm char(2), @r char(5)
  
  set @InpM = isnull(@InpM,0)
  if @InpM <> 0
  begin
  
    set @h = @InpM/60
  
    if @h<10 set @ch='0'+cast(@h as char(1))
    else set @ch=cast(@h as char(2))
  
    set @m  = @InpM - @h*60
 
    if @m<10 set @cm='0'+cast(@m as char(1))
    else set @cm=cast(@m as char(2))
  
    set @r = @ch+':'+@cm
  end;  
  else set @r=''
  Return @r
END