CREATE procedure AddArcNc @ND datetime,
  @Nnak int, @B_ID int, @Fam varchar(30),
  @SP money, @SC money, @Fact money,
  @Tara TINYINT, @Frizer int,
  @Actn TINYINT, @Ice tinyint, @Srok INT,
  @NcID int output, @Extra float
as 
begin
  insert into ArcNC(nd,nnak,b_id,fam,sp,sc,fact,tara,[frizer],actn,ice,srok, extra)
  values(@nd,@nnak,@b_id,@fam,@sp,@sc,@fact,@tara,@frizer,@actn,@ice,@srok, @extra);
  set @NcId=@@IDENTITY;
end