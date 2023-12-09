CREATE PROCEDURE NearLogistic.FastSave
AS
  DECLARE @RC INT, @ND DATETIME, @weight DECIMAL(15,4), @PIN INT, @KolBox DECIMAL(15,4),
    @pallet_count DECIMAL(15,4), @ext_point_id VARCHAR(50), @DocNumber VARCHAR(100), @point_address VARCHAR(250)
    ,@volume DECIMAL(15,3), @point_name VARCHAR(200)
  DECLARE @docdate datetime
  DECLARE @docnom varchar(100)
  DECLARE @extcode varchar(50)
  DECLARE @mas decimal(38, 2)
  DECLARE @vol decimal(38, 2)
  DECLARE @box int
  DECLARE @pal decimal(38, 4)
  DECLARE @temp int
  DECLARE @cost money
  DECLARE @contact varchar(500)
  DECLARE @remark varchar(500)
  DECLARE @ext_pin_code varchar(50)
  DECLARE @pinname varchar(100)
  DECLARE @ext_adress_code varchar(50)
  DECLARE @adress varchar(500)
  DECLARE @adress_name varchar(50)
  DECLARE @tm varchar(8)
  DECLARE @posx float
  DECLARE @posy float
  DECLARE @ext_sklad_code varchar(50)
  DECLARE @sklad_adress varchar(500)
  DECLARE @delivdate datetime
  DECLARE @nal bit
begin
  DECLARE c1 CURSOR FAST_FORWARD FOR 
  SELECT   nd   ,remark   ,cost   ,pin   ,weight
   ,volume
   ,kolbox
   ,contact
   ,pallet_count
   ,ext_point_id
   ,Temp
   ,DocNumber
   ,DocDate
   ,extcode
   ,pal
   ,nal
   ,point_name
   ,point_address
   ,left(tm,5) as tm
  FROM NearLogistic.tmpMarshRequests_free;

  OPEN c1;

  FETCH c1 INTO @nd,@remark,@cost,@pin,@weight,@vol,@kolbox,@contact,@pallet_count
    ,@ext_point_id,@Temp,@DocNumber,@DocDate,@extcode,@pal,@nal,@point_name,@point_address,@tm

  WHILE @@fetch_status=0 BEGIN
    EXEC NearLogistic.create_marshrequests_ext @docdate,@docnumber
      ,@extcode,@weight,@vol,@kolbox,@pal,1,0,'',@remark,@pin,''
      ,@ext_point_id,@point_address,@point_name,@tm,0,0,27142
      ,'',@nd,@nal    
    FETCH c1 INTO @nd,@remark,@cost,@pin,@weight,@volume,@kolbox,@contact,@pallet_count
    ,@ext_point_id,@Temp,@DocNumber,@DocDate,@extcode,@pal,@nal,@point_name,@point_address,@tm
  END;
  CLOSE c1;
  DEALLOCATE c1;
END;