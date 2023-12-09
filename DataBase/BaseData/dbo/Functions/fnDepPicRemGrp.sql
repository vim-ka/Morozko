CREATE FUNCTION dbo.fnDepPicRemGrp (@DepID int, @rm varchar(3)) returns smallint
AS
BEGIN
  declare @grp smallint; 
  set @Grp=0;


  if @rm in ('7', 'инв')
    set @Grp=7;
  else if @DepID=4 
    set @Grp=
      case when @rm='д' then 1
      when @rm='м' then 2
      when @rm='б' then 3
      when @rm='к' then 4
      when @rm='и' then 5
      else 6
      end;
  else if @DepID=3 
    set @Grp=
      case when @rm='1' then 1
      when @rm='2' then 2
      when @rm='3' then 3
      else 6
      end;
  else
    set @Grp=
      case when @rm='к' then 1
      when @rm='н' then 2
      when @rm='ок' then 3
      when @rm='л' then 4
      when @rm='и' then 5
      else 6
      end;
  
  return @grp;
end;