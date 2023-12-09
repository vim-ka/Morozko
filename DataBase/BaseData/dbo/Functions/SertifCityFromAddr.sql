CREATE FUNCTION dbo.SertifCityFromAddr (@Addr VARCHAR(255))
RETURNS varchar(255)
AS
BEGIN
declare @City varchar(255)

SELECT @City = (
SELECT 
  CASE WHEN SUBSTRING(t.City,LEN(t.City),1) = ',' 
       THEN SUBSTRING(t.City,1, LEN(t.City)-1)
  ELSE t.City
  END AS City
  FROM (
SELECT 
CASE 
  WHEN PATINDEX('%Универсальный пр-д%', @Addr)>0 THEN 
  LEFT(@Addr,PATINDEX('%Универсальный пр-д%', @Addr)-1)

  WHEN PATINDEX('%Московский пр-т%', @Addr)>0 THEN 
  LEFT(@Addr,PATINDEX('%Московский пр-т%', @Addr)-1)

  WHEN PATINDEX('%Ленинский пр-т%', @Addr)>0 THEN 
  LEFT(@Addr,PATINDEX('%Ленинский пр-т%', @Addr)-1)

	WHEN PATINDEX('%пр-кт%', @Addr)>0 THEN 
  LEFT(@Addr,PATINDEX('%пр-кт%', @Addr)-1) 
  
  WHEN PATINDEX('%Пр-кт%', @Addr)>0 THEN 
  LEFT(@Addr,PATINDEX('%Пр-кт%', @Addr)-1) 

  WHEN PATINDEX('%проспект%', @Addr)>0 THEN 
  LEFT(@Addr,PATINDEX('%проспект%', @Addr)-1) 

  WHEN PATINDEX('% улица%', @Addr)>0 THEN 
  LEFT(@Addr,PATINDEX('% улица%', @Addr)-1)

	WHEN PATINDEX('% ул.%', @Addr)>0 THEN 
  LEFT(@Addr,PATINDEX('% ул.%', @Addr)-1)

  WHEN PATINDEX('% ул,%', @Addr)>0 THEN 
  LEFT(@Addr,PATINDEX('% ул,%', @Addr)-1)

  WHEN PATINDEX('%,ул %', @Addr)>0 THEN 
  LEFT(@Addr,PATINDEX('%,ул %', @Addr)-1)

  WHEN PATINDEX('%Ул.%', @Addr)>0 THEN 
  LEFT(@Addr,PATINDEX('%Ул.%', @Addr)-1)
   
	WHEN PATINDEX('% ул %', @Addr)>0 THEN 
  LEFT(@Addr,PATINDEX('% ул %', @Addr)-1)

  WHEN PATINDEX('% Ул %', @Addr)>0 THEN 
  LEFT(@Addr,PATINDEX('% Ул %', @Addr)-1)

  WHEN PATINDEX('% прт %', @Addr)>0 THEN 
  LEFT(@Addr,PATINDEX('% прт %', @Addr)-1)

 	WHEN PATINDEX('% Прт %', @Addr)>0 THEN 
  LEFT(@Addr,PATINDEX('% Прт %', @Addr)-1)

  WHEN PATINDEX('%прт.%', @Addr)>0 THEN 
  LEFT(@Addr,PATINDEX('%прт.%', @Addr)-1)

  WHEN PATINDEX('%Прт.%', @Addr)>0 THEN 
  LEFT(@Addr,PATINDEX('%Прт.%', @Addr)-1)

  WHEN PATINDEX('%пр-т%', @Addr)>0 THEN 
  LEFT(@Addr,PATINDEX('%пр-т%', @Addr)-1)

  WHEN PATINDEX('%Пр-т%', @Addr)>0 THEN 
  LEFT(@Addr,PATINDEX('%Пр-т%', @Addr)-1)

  WHEN PATINDEX('%пр-т.%', @Addr)>0 THEN 
  LEFT(@Addr,PATINDEX('%пр-т.%', @Addr)-1)

  WHEN PATINDEX('%Пр-т.%', @Addr)>0 THEN 
  LEFT(@Addr,PATINDEX('%Пр-т.%', @Addr)-1)

  WHEN PATINDEX('% пр %', @Addr)>0 THEN 
  LEFT(@Addr,PATINDEX('% пр %', @Addr)-1)

  WHEN PATINDEX('% Пр %', @Addr)>0 THEN 
  LEFT(@Addr,PATINDEX('% Пр %', @Addr)-1)

  WHEN PATINDEX('%пр.%', @Addr)>0 THEN 
  LEFT(@Addr,PATINDEX('%пр.%', @Addr)-1)

  WHEN PATINDEX('%Пр.%', @Addr)>0 THEN 
  LEFT(@Addr,PATINDEX('%Пр.%', @Addr)-1)

  WHEN PATINDEX('% пер %', @Addr)>0 THEN 
  LEFT(@Addr,PATINDEX('% пер %', @Addr)-1)

  WHEN PATINDEX('% Пер %', @Addr)>0 THEN 
  LEFT(@Addr,PATINDEX('% Пер %', @Addr)-1)

  WHEN PATINDEX('%пер.%', @Addr)>0 THEN 
  LEFT(@Addr,PATINDEX('%пер.%', @Addr)-1)

  WHEN PATINDEX('%Пер.%', @Addr)>0 THEN 
  LEFT(@Addr,PATINDEX('%Пер.%', @Addr)-1)

  WHEN PATINDEX('% пл %', @Addr)>0 THEN 
  LEFT(@Addr,PATINDEX('% пл %', @Addr)-1)

  WHEN PATINDEX('% Пл %', @Addr)>0 THEN 
  LEFT(@Addr,PATINDEX('% Пл %', @Addr)-1)

  WHEN PATINDEX('%пл.%', @Addr)>0 THEN 
  LEFT(@Addr,PATINDEX('%пл.%', @Addr)-1)

  WHEN PATINDEX('%Пл.%', @Addr)>0 THEN 
  LEFT(@Addr,PATINDEX('%Пл.%', @Addr)-1)

  WHEN PATINDEX('% микр %', @Addr)>0 THEN 
  LEFT(@Addr,PATINDEX('% микр %', @Addr)-1)

  WHEN PATINDEX('% Микр %', @Addr)>0 THEN 
  LEFT(@Addr,PATINDEX('% Микр %', @Addr)-1)

  WHEN PATINDEX('%микр.%', @Addr)>0 THEN 
  LEFT(@Addr,PATINDEX('%микр.%', @Addr)-1)
  
  WHEN PATINDEX('Микр.%', @Addr)>0 THEN 
  LEFT(@Addr,PATINDEX('%Микр.%', @Addr)-1)

  WHEN PATINDEX('%м-р%', @Addr)>0 THEN 
  LEFT(@Addr,PATINDEX('%м-р%', @Addr)-1)

  WHEN PATINDEX('%М-р%', @Addr)>0 THEN 
  LEFT(@Addr,PATINDEX('%М-р%', @Addr)-1)
 
  WHEN PATINDEX('% мр %', @Addr)>0 THEN 
  LEFT(@Addr,PATINDEX('% мр %', @Addr)-1)

  WHEN PATINDEX('% Мр %', @Addr)>0 THEN 
  LEFT(@Addr,PATINDEX('% Мр %', @Addr)-1)
    
  WHEN PATINDEX('% Мр %', @Addr)>0 THEN 
  LEFT(@Addr,PATINDEX('% Мр %', @Addr)-1)

  WHEN PATINDEX('%мкрн%', @Addr)>0 THEN 
  LEFT(@Addr,PATINDEX('%мкрн%', @Addr)-1)

  WHEN PATINDEX('%Мкрн%', @Addr)>0 THEN 
  LEFT(@Addr,PATINDEX('%Мкрн%', @Addr)-1)

  WHEN PATINDEX('%мкрн.%', @Addr)>0 THEN 
  LEFT(@Addr,PATINDEX('%мкрн.%', @Addr)-1)
  
  WHEN PATINDEX('%Мкрн.%', @Addr)>0 THEN 
  LEFT(@Addr,PATINDEX('%Мкрн.%', @Addr)-1)

  WHEN PATINDEX('%мкр%', @Addr)>0 THEN 
  LEFT(@Addr,PATINDEX('%мкр%', @Addr)-1)

  WHEN PATINDEX('%Мкр%', @Addr)>0 THEN 
  LEFT(@Addr,PATINDEX('%Мкр%', @Addr)-1)

  WHEN PATINDEX('%мкр.%', @Addr)>0 THEN 
  LEFT(@Addr,PATINDEX('%мкр.%', @Addr)-1)

  WHEN PATINDEX('%Мкр.%', @Addr)>0 THEN 
  LEFT(@Addr,PATINDEX('%Мкр.%', @Addr)-1)

  WHEN PATINDEX('% просп %', @Addr)>0 THEN 
  LEFT(@Addr,PATINDEX('% просп %', @Addr)-1)

  WHEN PATINDEX('% Просп %', @Addr)>0 THEN 
  LEFT(@Addr,PATINDEX('% Просп %', @Addr)-1)

  WHEN PATINDEX('%просп.%', @Addr)>0 THEN 
  LEFT(@Addr,PATINDEX('%просп.%', @Addr)-1)

  WHEN PATINDEX('%Просп.%', @Addr)>0 THEN 
  LEFT(@Addr,PATINDEX('%Просп.%', @Addr)-1)

  WHEN PATINDEX('%у.%', @Addr)>0 THEN 
  LEFT(@Addr,PATINDEX('%у.%', @Addr)-1)

  WHEN PATINDEX('%У.%', @Addr)>0 THEN 
  LEFT(@Addr,PATINDEX('%У.%', @Addr)-1)

  WHEN PATINDEX('%м.%', @Addr)>0 THEN 
  LEFT(@Addr,PATINDEX('%м.%', @Addr)-1)

  WHEN PATINDEX('%М.%', @Addr)>0 THEN 
  LEFT(@Addr,PATINDEX('%М.%', @Addr)-1)

  WHEN PATINDEX('% б.%', @Addr)>0 THEN 
  LEFT(@Addr,PATINDEX('% б.%', @Addr)-1)

  WHEN PATINDEX('%маг.%', @Addr)>0 THEN 
  LEFT(@Addr,PATINDEX('%маг.%', @Addr)-1)

  WHEN PATINDEX('%Маг.%', @Addr)>0 THEN 
  LEFT(@Addr,PATINDEX('%Маг.%', @Addr)-1)

  WHEN PATINDEX('% маг %', @Addr)>0 THEN 
  LEFT(@Addr,PATINDEX('% маг %', @Addr)-1)

  WHEN PATINDEX('% Маг %', @Addr)>0 THEN 
  LEFT(@Addr,PATINDEX('% Маг %', @Addr)-1)

  WHEN PATINDEX('%Бульвар%', @Addr)>0 THEN 
  LEFT(@Addr,PATINDEX('%Бульвар%', @Addr)-1)

  WHEN PATINDEX('%б-р%', @Addr)>0 THEN 
  LEFT(@Addr,PATINDEX('%б-р%', @Addr)-1)

  WHEN PATINDEX('% п %', @Addr)>0 THEN 
  LEFT(@Addr,PATINDEX('% п %', @Addr)-1)

  WHEN PATINDEX('%п.%', @Addr)>0 THEN 
  LEFT(@Addr,PATINDEX('%п.%', @Addr)-1)

  WHEN PATINDEX('% П %', @Addr)>0 THEN 
  LEFT(@Addr,PATINDEX('% П %', @Addr)-1)

  WHEN PATINDEX('%П.%', @Addr)>0 THEN 
  LEFT(@Addr,PATINDEX('%П.%', @Addr)-1)

 ELSE @Addr

END AS City

) t)

RETURN @City
END