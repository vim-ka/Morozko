CREATE FUNCTION dbo.String_to_Int (@list ntext, @delimiter varchar(1)=' ', @datatype int=1)
      RETURNS @tbl TABLE (listpos int IDENTITY(1, 1) NOT NULL,
                          number  int NOT NULL,
													dates datetime not null,
													[str] varchar(100) not null) AS
   BEGIN
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

         SET @pos = charindex(@delimiter, @tmpstr)
         WHILE @pos > 0
         BEGIN
            SET @str = substring(@tmpstr, 1, @pos - 1)
            if @datatype=1
							INSERT @tbl (number, dates, [str]) VALUES(convert(int, @str), '20010101', '')
						if @datatype=2
							INSERT @tbl (number, dates, [str]) VALUES(0,@str, '')
						if @datatype=3
							INSERT @tbl (number, dates, [str]) VALUES(0,'20010101',@str)						
            SET @tmpstr = ltrim(substring(@tmpstr, @pos + 1, len(@tmpstr)))
            SET @pos = charindex(@delimiter, @tmpstr)
         END

         SET @leftover = @tmpstr
      END

      IF ltrim(rtrim(@leftover)) <> ''
         if @datatype=1
							INSERT @tbl (number, dates, [str]) VALUES(convert(int, @leftover), '20010101', '')
				if @datatype=2
					INSERT @tbl (number, dates, [str]) VALUES(0,@leftover, '')
				if @datatype=3
					INSERT @tbl (number, dates, [str]) VALUES(0,'20010101',@leftover)	
      RETURN
   END