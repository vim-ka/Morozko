CREATE FUNCTION fnMinutes2str(@mnts smallint) RETURNS varchar(5)
-- Перевод времени суток, выраженного в целых минутах, прошедших с полуночи,
-- в текстовое представление
AS
BEGIN
  declare @rez varchar(5), @sut float
  if @mnts is null set @rez=null
  else begin
    set @sut=1.0*@mnts/1440.0+0.000001;
    set @rez=CONVERT(varchar(5), convert(datetime, @sut), 108);
  end;
  return @rez;
END