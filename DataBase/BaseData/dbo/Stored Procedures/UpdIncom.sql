
create procedure UpdIncom @iid int output, @ND DateTime,
  @Ncod int, @Weight smallint, @ProjTime char(8),
  @FactTime char(8), @CalcTime char(8), @OutStart char(8),
  @OutFinish char(8), @Reason varchar(40),
  @lgs int, @master varchar(30)
as 
declare @OldIid int
begin
  if (@iid=0) begin
    insert into Incom(nd,ncod,weight,projtime,facttime,calctime,outstart,outfinish,reason, lgs, master)
    values(@nd,@ncod,@weight,@projtime,@facttime,@calctime,@outstart,@outfinish,@reason, @lgs, @master);
    set @iid=@@identity;
  end;
  else
    update Incom set nd=@nd,ncod=@ncod,weight=@weight,projtime=@projtime,
     facttime=@facttime, calctime=@calctime,outstart=@outstart,
     outfinish=@outfinish, lgs=@lgs, master=@master, reason=@reason
     where iid=@iid  
end