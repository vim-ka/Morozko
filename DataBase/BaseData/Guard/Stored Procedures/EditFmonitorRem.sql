

CREATE procedure guard.EditFmonitorRem @mdID int OUT, @Op int, @Comp varchar(25),
  @nd datetime,  @DepID int,   @Sv_ID int,   @Ag_ID int,  @B_ID int, @PicName varchar(30), @PicTrue bit,
  @PicGrade smallint,  @remark varchar(70),  @Note varchar(70),  @DName varchar(70),
  @SV_Fam varchar(100),  @AG_Fam varchar(100),  @B_Fam varchar(100)
as
declare @remID int
begin

  if @remark='' set @remID=null;
  else begin
    set @remID=(select remid from FMonitorRem where remText=@remark);
    if (@remID is null) begin
      insert into FMonitorRem(remText) values(@remark);
      set @remID=SCOPE_IDENTITY();
    end;
  end;
  
  if @mdID=0 begin
    INSERT INTO  dbo.FMonitorAppend
    ( nd,  DepID,  Sv_ID,  Ag_ID,  B_ID,  PicName,PicTrue,  PicGrade, RemID,
      Note,  OP,  Comp,  DName,  SV_Fam,  AG_Fam,  B_Fam) 
    VALUES ( @nd,  @DepID,  @Sv_ID,  @Ag_ID,  @B_ID,  @PicName,@PicTrue, @PicGrade, @RemID,
      @Note,  @OP,  @Comp,  @DName,  @SV_Fam,  @AG_Fam,  @B_Fam);  
    set @mdID=SCOPE_IDENTITY();
  end
  else
    update dbo.FMonitorAppend  
    SET 
      nd = @nd,
      DepID = @DepID,
      Sv_ID = @Sv_ID,
      Ag_ID = @Ag_ID,
      B_ID = @B_ID,
      PicName = @PicName,
      PicTrue = @PicTrue,
      PicGrade = @PicGrade,
      remID = @remID,
      Note = @Note,
      DateOP = dbo.today(),
      OP = @OP,
      TimeOP = cast(getdate() as time),
      Comp = @Comp,
      DName = @DName,
      SV_Fam = @SV_Fam,
      AG_Fam = @AG_Fam,
      B_Fam = @B_Fam 
    WHERE 
      mdID = @mdID
end;