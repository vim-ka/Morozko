CREATE FUNCTION NearLogistic.fnCrutch (@mhid int, @mode int, @DistR decimal(10,3))
returns money
as 
begin
  declare @res money 
  
  declare @smdrv money, @smspd money
  declare @DotsRound int, @Dots int

  declare @weight float
  declare @SecondDriver bit, @SpedDrID int, @ListNo int, @ListNoSped int ,@Volume int
  declare @Sped bit, @ttID int, @nlVehCapacityID int, @Dist float, @CrID int, @JurType bit 

  select @ttID = c.ttID, 
         @Dist = iif(isnull(m.dist,0)<>0,m.Dist,isnull(m.CalcDist,0)),
         @CrID = c.crID,
         @weight = m.weight,
         @Dots = m.Dots,
         @Volume = m.Volume
  from [dbo].marsh m join vehicle v on m.v_id=v.v_id
                     join carriers c on v.crID=c.crID
                     left join Drivers s on m.SpedDrID=s.DrID
  where m.mhid = @mhid
  
  
  declare @DistForCalc decimal(10,3)

  if @DistR <> 0.0 set @DistForCalc = @DistR
  else set @DistForCalc = @Dist

  set @DotsRound = [NearLogistic].RoundToDec(@Dots)
  
  set @Res = 0
  
  if @mode = 1 
  BEGIN  
  
  if @DistForCalc<=120 
  begin
    if (@weight<=1200 and @Volume<=11)
    begin
      set @Res = (select 
      case when @DotsRound=10 then 2500
           when @DotsRound=20 then 3000
           when @DotsRound=30 then 3500
           when @DotsRound>=40 then 4000
      end);
    end
    else
    if (@weight<=1500 and @Volume<=15)
    begin
      set @Res = (select 
      case when @DotsRound=10 then 3000
           when @DotsRound=20 then 3500
           when @DotsRound=30 then 4000
           when @DotsRound>=40 then 4500
      end);
    end    
    else
    --if (@weight<=2200 and @Volume<=20)
    begin
      set @Res = (select 
      case when @DotsRound=10 then 3500
           when @DotsRound=20 then 4000
           when @DotsRound=30 then 4500
           when @DotsRound>=40 then 5000
      end);
    end    
    
  end
  ELSE
  if @DistForCalc>120 and @DistForCalc<=200
  begin
    if (@weight<=1200 and @Volume<=11)
    begin
      set @Res = (select 
      case when @DotsRound=10 then 3000
           when @DotsRound=20 then 3500
           when @DotsRound=30 then 4000
           when @DotsRound>=40 then 4500
      end);
    end
    else
    if (@weight<=1500 and @Volume<=15)
    begin
      set @Res = (select 
      case when @DotsRound=10 then 3500
           when @DotsRound=20 then 4000
           when @DotsRound=30 then 4500
           when @DotsRound>=40 then 5000
      end);
    end    
    else
    --if (@weight<=2200 and @Volume<=20)
    begin
      set @Res = (select 
      case when @DotsRound=10 then 4000
           when @DotsRound=20 then 4500
           when @DotsRound=30 then 5000
           when @DotsRound>=40 then 5500
      end);
    end    
      
  end
  
  END
  else --MODE=2
  if @mode = 2 
  BEGIN  
  --set @DistForCalc = @DistCalc
  if @DistForCalc<=120 
  begin
    if (@weight<=1200 and @Volume<=11)
    begin
      set @Res = (select 
      case when @DotsRound=10 then 4130
           when @DotsRound=20 then 4720
           when @DotsRound=30 then 5310
           when @DotsRound>=40 then 5900
      end);
    end
    else
    if (@weight<=1500 and @Volume<=15)
    begin
      set @Res = (select 
      case when @DotsRound=10 then 4720
           when @DotsRound=20 then 5310
           when @DotsRound=30 then 5900
           when @DotsRound>=40 then 6490
      end);
    end    
    else
    --if (@weight<=2200 and @Volume<=20)
    begin
      set @Res = (select 
      case when @DotsRound=10 then 5310
           when @DotsRound=20 then 5900
           when @DotsRound=30 then 6490
           when @DotsRound>=40 then 7080
      end);
    end    
    
  end
  ELSE
  if @DistForCalc>120 and @DistForCalc<=200
  begin
 if (@weight<=1200 and @Volume<=11)
    begin
      set @Res = (select 
      case when @DotsRound=10 then 4720
           when @DotsRound=20 then 5310
           when @DotsRound=30 then 5900
           when @DotsRound>=40 then 6490
      end);
    end
    else
    if (@weight<=1500 and @Volume<=15)
    begin
      set @Res = (select 
      case when @DotsRound=10 then 5310
           when @DotsRound=20 then 5900
           when @DotsRound=30 then 6490
           when @DotsRound>=40 then 7080
      end);
    end    
    else
    --if (@weight<=2200 and @Volume<=20)
    begin
      set @Res = (select 
      case when @DotsRound=10 then 5900
           when @DotsRound=20 then 6490
           when @DotsRound=30 then 7080
           when @DotsRound>=40 then 7670
      end);
    end 
  end     
  ELSE
    if @DistForCalc>200
    begin
      if (@weight<=1200)
      begin
        set @Res = @DistForCalc*18.88; 
      end
      else
        if (@weight<=1500)
      begin
        set @Res = @DistForCalc*20.06;
      end    
      else
        if (@weight<=2200)
      begin
        set @Res = @DistForCalc*21.24;
      end
      else
         --if (@weight<=3000)
       begin
         set @Res = @DistForCalc*25.96;
       end
      
      if @Dots>25  
        set @Res=@Res+@Dots*70.8 
      else  
        set @Res=@Res+@Dots*35.4
     end
  END
             

  Return @Res 
  --Return 0
end