create procedure Guard.SaveRemark @ND datetime, @Razv_ID int, @AG_ID int, @Mess varchar(80)
as
declare @rmid int
begin
  set @rmid=(select top 1 rmid from Guard.Remarks where ND=@ND and Razv_ID=@Razv_ID and AG_ID=@AG_ID);
  if (@rmid is null) and @Mess<>''
    insert into Guard.Remarks(ND,Razv_ID, AG_ID, Mess) values(@ND,@Razv_ID, @AG_ID, @Mess);
  else if @rmid is not null update guard.Remarks set Mess=@Mess where rmid=@rmid;
end;