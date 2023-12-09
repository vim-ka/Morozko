CREATE PROCEDURE [NearLogistic].ListPayAdd 
@Op int, 
@Remark varchar(50), 
@ttID int, 
@ListNo int out
AS
BEGIN
 declare @StartND datetime
  declare @EndND datetime

  set @ListNo=isnull((select max(ListNo) from [NearLogistic].nlListPay),0) + 1
  set @StartND=isnull((select max(EndND) from [NearLogistic].nlListPay where ttid=@ttID),0) + 1

  if (@ttID = 4) or (@ttID = 5) 
  set @EndND=DATEADD(day, 14, @StartND)
  else set @EndND=DATEADD(day, 7, @StartND);

 INSERT INTO 
  NearLogistic.nlListPay
( ListNo,
  Op,
  Remark,
  StartND,
  EndND,
  ttID
) 
VALUES (
  @ListNo,
  @Op,
  @Remark,
  @StartND,
  @EndND,
  @ttID
);

select @ListNo [ListNo]

END