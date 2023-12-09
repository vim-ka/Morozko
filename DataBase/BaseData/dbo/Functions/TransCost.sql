CREATE FUNCTION [dbo].[TransCost] (@Marsh int, @ND datetime) RETURNS Money
AS
BEGIN
 declare @CityFLG numeric(1,0) 
  
 declare @Rashod money
 declare @Dist float
 declare @Dots float
 declare @W float
 
 declare @Cursor Cursor 
 set @Cursor  = Cursor scroll
 for select m.CityFLG,m.Dist,m.Dots,m.Weight from Marsh m where m.ND=@ND and m.Marsh=@Marsh

 Open @CURSOR
 fetch next from @Cursor into @CityFLG, @Dist, @Dots, @W
 
 set @Rashod = 0 
 
 if @CityFLG = 0 
 begin
   if (@W<2000) set @Rashod=7.5*@Dist; else if (@W<2500) set @Rashod=9*@Dist;
   else set @Rashod=10*@Dist
   
   if (@Dots <= 25) set @Rashod=@Rashod+900; 
   else set @Rashod=@Rashod+1200
 end
 else
 begin
 
   if @Dist>=120 and @Dist<=199 set @Rashod=3*@Dist
   if @Dist>=200 set @Rashod=7.5*@Dist 
   
   declare @D int
   
   set @D=DatePart(weekday,@ND)
   
   if (@D = 1) or (@D = 4) or (@D = 6) or (@D = 7)
   set @Rashod=@Rashod+1000; else set @Rashod=@Rashod+1200
   
   declare @Dts int
   declare @DtsNet int
   set @DtsNet=0
   set @Dts=0
   
   set @DtsNet=(select count(d.pin) from def d where (d.master<>0 and d.master is not NULL) and d.tip=1 and d.pin in
            (select n.b_id from nc n where n.nd=@ND and n.marsh=@Marsh))
   set @Dts=(select count(d.pin) from def d where (d.master=0 or d.master is NULL) and d.tip=1 and d.pin in
            (select n.b_id from nc n where n.nd=@ND and n.marsh=@Marsh))
   set @Rashod=@Rashod+50*@Dts+80*@DtsNet
 end
 close @Cursor
 RETURN @Rashod
END