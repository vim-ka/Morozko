CREATE FUNCTION dbo.Str2intarray (@list ntext)
      RETURNS @tbl TABLE (K bigint NOT NULL) AS
BEGIN
  -- пример: select K from dbo.Str2intarray('10,20,30')
  DECLARE @pos      int,
          @textpos  int,
          @chunklen smallint,
          @str      nvarchar(4000),
          @tmpstr   nvarchar(4000),
          @leftover nvarchar(4000)

  SET @textpos = 1
  SET @leftover = ''
  WHILE @textpos <= datalength(@list) / 2
  BEGIN
     SET @chunklen = 4000 - datalength(@leftover) / 2
     SET @tmpstr = ltrim(@leftover + substring(@list, @textpos, @chunklen))
     SET @textpos = @textpos + @chunklen
     SET @pos = charindex(',', @tmpstr)

     WHILE @pos > 0
     BEGIN
        SET @str = substring(@tmpstr, 1, @pos - 1)
        INSERT @tbl (K) VALUES(convert(bigint, @str))
        SET @tmpstr = ltrim(substring(@tmpstr, @pos + 1, len(@tmpstr)))
        SET @pos = charindex(',', @tmpstr)
     END

     SET @leftover = @tmpstr
  END

  IF ltrim(rtrim(@leftover)) <> ''
     INSERT @tbl (K) VALUES(convert(bigint, @leftover))

  RETURN
END