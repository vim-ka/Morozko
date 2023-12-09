CREATE procedure dbo.SaveRemToRtrn
  @Datnom bigint, @SourDatNom bigint,
  @Id int, @Hitag int, @Remark varchar(80), @Reason_ID int,
  @Note varchar(80), @Tip smallint
as BEGIN 
  insert into RemToRtrn(ND,TM,Datnom,SourDatNom,Id,Hitag,Remark,Reason_ID,Note,Tip)  
  values( dbo.today(),
    convert(char(8), getdate(),108),
    @Datnom,@SourDatNom,@Id,@Hitag,@Remark,@Reason_ID,@Note,@Tip)  
end