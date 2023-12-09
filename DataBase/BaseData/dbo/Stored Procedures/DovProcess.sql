CREATE PROCEDURE dbo.DovProcess @Act tinyint, @ag_id int, @Our_id int, @DovNom1 varchar(20), @DovNom2 varchar(20),
                                @Kolvo int, @ND1 datetime, @ND2 datetime, @OP int, @Remark varchar(50), @DovID int=0, @DovOutID int=0,
                                @DovStat int=0, @NDReturn datetime=null
AS
BEGIN
  
  declare @Nom1 int, @Nom2 int, @i int, @DovNom varchar(20), @Preffix varchar(10), @p_id INT, @DovIDsel int
  declare @ND DATETIME, @Yr int
  set @ND=getdate();
  
  select @p_id=p_id from agentlist where ag_id=@ag_id

  if @Act=0 --из типографии
  begin
    
    set @i=0
    set @Preffix=dbo.StrNonDigits(@DovNom1) 
    set @Nom1=dbo.StrNonLetters(@DovNom1)
    set @Nom2=dbo.StrNonLetters(@DovNom2)

    while @Nom1<=@Nom2
    begin
      if @i=0 
      begin
        insert into dbo.DovOut (DovNomStart, DovNomEnd, ND, OP, Our_ID, ag_id, NDBeg, NDEnd, Remark, p_id) 
                        values (@DovNom1,  @DovNom2, @ND, @OP,  @Our_ID,  @ag_id,  @ND1,  @ND2,  @Remark, @P_ID);        
        set @DovOutID = scope_identity();                
      end          
     
      set @DovNom=@Preffix+cast(@Nom1 as varchar);
        
      insert into dbo.Dover(DovNom,  DovOutID,  Our_ID,  ag_id,  ND,  NDBeg,  NDEnd,  [DovStat], p_id) 
                    values (@DovNom,  @DovOutID,  @Our_ID,  @ag_id,  @ND,  @ND1,  @ND2,  1, @P_ID);      
      set @Nom1=@Nom1+1      
      set @i=@i+1
    end       
  
  end
  else      
  if @Act=1 --печатаем сами
  begin
    
    set @i=1
    set @DovIDsel = isnull((select MAX(DovID) from Dover where Our_id=@Our_ID),0)
    set @DovNom1 = isnull((select DovNom from Dover where DovID=@DovIDsel),0)
    --set @DovNom1 = isnull((select max(DovNom) from Dover where Our_id=@Our_ID),0)
      
    set @Preffix=dbo.StrNonDigits(@DovNom1) 
    set @Nom1=dbo.StrNonLetters(@DovNom1) + 1
    set @Yr=CAST(LEFT(dbo.StrNonLetters(@DovNom1),4) AS INT)
    IF @Yr<>YEAR(dbo.today()) 
    begin
      SET @Nom1=YEAR(dbo.today())*100000+1 
      IF @Preffix = '' SET @Preffix=ISNULL((SELECT fc.OurAbbreviature FROM FirmsConfig fc WHERE fc.Our_id=@Our_id),'')
    end
      
    set @Nom2=@Nom1+@Kolvo-1
      
    --set @DovNom1=@Preffix+cast(@Nom1 as varchar)
    --set @DovNom2=@Preffix+cast(@Nom2 as varchar)
    
    set @DovNom1=@Preffix+format(@Nom1, '000000000')
    set @DovNom2=@Preffix+format(@Nom2, '000000000')
        
      
    while @i<=@Kolvo
    begin
      if @i=1 
      begin
        insert into dbo.DovOut (DovNomStart, DovNomEnd, ND, OP, Our_ID, ag_id, NDBeg, NDEnd, Remark, p_id) 
                        values (@DovNom1, @DovNom2, @ND, @OP, @Our_ID, @ag_id, @ND1, @ND2, @Remark, @p_id);        
        set @DovOutID = scope_identity();                
      end          
       
      set @DovNom=@Preffix+format(@Nom1, '000000000');
        
      insert into dbo.Dover(DovNom,  DovOutID,  Our_ID,  ag_id,  ND,  NDBeg,  NDEnd,  [DovStat], p_id) 
                      values (@DovNom,  @DovOutID,  @Our_ID,  @ag_id,  @ND,  @ND1,  @ND2,  1, @p_id);      
      set @Nom1=@Nom1+1      
      set @i=@i+1
    end       
  end
  else        
  if @Act=2 --изменение статуса по всей книге
  begin
    if @DovStat = 5 
    begin
     
      update Dover set Dover.DovStat=@DovStat
      where DovID in (select DovID from Dover where DovOutID=@DovOutID) --and Dover.DovStat=1   
      
      update DovOut set NDReturn=@NDReturn where DovOutID=@DovOutID
    end
    else update Dover set Dover.DovStat=@DovStat where DovID in (select DovID from Dover where DovOutID=@DovOutID) and Dover.DovStat=1 
  end
  if @Act=3 --изменение статуса 1 доверенности
  begin
    update Dover set Dover.DovStat=@DovStat where DovID=@DovID --and Dover.DovStat=1
  end
  else
  if @Act=4 --изменение статуса при сканировании
  begin
    update Dover set DovStat=5, ScanND=dbo.today() where DovID=@DovID;
    set @DovOutID = (select DovOutId from Dover where DovID = @DovID);

    if not exists(select * from Dover where DovOutID=@DovOutID and ScanND is null)
    update DovOut set NdReturn=dbo.today() where DovOutID=@DovOutID and NdReturn is null;
  end
  else
  if @Act=5 --изменение статуса при сканировании M2
  begin
    update Dover2PrintLog set DovStat=5, ScanND=dbo.today(), NdReturn=dbo.today() where DPLID=@DovID;
  end
  else
  if @Act=6 --изменение статуса
  begin
    if @DovID=0 set @DovID=@DovOutID;
    update Dover2PrintLog set DovStat=@DovStat, NdReturn=iif(@DovStat<>1,dbo.today(),null)  where DPLID=@DovID;
  end
    
  
END