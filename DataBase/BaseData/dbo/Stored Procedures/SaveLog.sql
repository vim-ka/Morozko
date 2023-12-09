CREATE procedure SaveLog
  @Op int, @Tip varchar(5), @Mess varchar(80), 
  @param1 varchar(15),@param2 varchar(15),@param3 varchar(15), @Comp varchar(12), @LID int=0 output,
  @Remark varchar(20)=null
as
begin
	insert into Log(Nd,TM,OP,Tip,Mess,param1,param2,param3,Comp, Remark)
	values(convert(char(10), getdate(),104),
	  convert(char(8), getdate(),108),
	  @Op,@Tip,@Mess,@Param1,@Param2,@Param3,@Comp, @Remark);
      
    set @LID = @@identity;
    select @LID;
  
end