CREATE procedure dbo.UpdNcExiteInfo
@datnom bigint,  @SP_Buyer decimal(12,2)
as 
declare @OrderDate datetime, @OrderDocNumber varchar(35), @OldSP_Buyer decimal(12,2)
begin 
  select @OrderDate=OrderDate, @OrderDocNumber=OrderDocNumber, 
    @OldSP_Buyer=SP_Buyer
    from nc_exiteinfo  
    where datnom=@datnom;
  if isnull(@SP_Buyer,0)<>isNull(@OldSP_Buyer,0) begin
    if EXISTS(select * from nc_exiteinfo where datnom=@datnom)
      update nc_exiteinfo set SP_Buyer=@SP_Buyer where datnom=@datnom;
    ELSE  insert into nc_exiteinfo(datnom,SP_Buyer)
      values(@datnom,@SP_Buyer);
  end;
end;