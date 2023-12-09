CREATE procedure ReadDefFormat
as
declare @dfID smallint, @dfId2 smallint, @subID tinyint, @MainID int
declare @dfName varchar(100), @dfName2 varchar(100), @fullName varchar(100)
begin
  create table #t (recn int not null identity(1,1) primary KEY, dfId int, fullName varchar(100), MainID int, SubID tinyint)
  --insert into #t(dfId, FullName) values(0,'<формат не задан>');
  
  declare C1 cursor fast_forward for select dfId, dfName from DefFormat where levl=0 order by dfID;
  open C1; 
  fetch next from C1 into @dfId,@dfName;
  WHILE (@@FETCH_STATUS=0)  BEGIN
    insert into #t(dfId, FullName, MainID) values(@dfID, @dfname, @dfID);
    declare C2 cursor fast_forward for select dfId, dfName, parent, subID from DefFormat where parent=@dfID order by dfID;
    open C2; 
    fetch next from C2 into @dfId2,@dfName2, @mainID, @subID;
    WHILE (@@FETCH_STATUS=0) BEGIN
      insert into #t(dfId, FullName, mainID, subID) values(@dfID2, @dfname+'/'+@dfname2, @MainID,  @subID);
      fetch next from C2 into @dfId2,@dfName2, @mainID, @subID;
    end;
    close C2;
    deallocate C2; 
    fetch next from C1 into @dfId,@dfName;
  end;
  close c1;
  deallocate c1;      
  
  truncate table DefFormatWide;
  
  insert into DefFormatWide(dfId, Fullname, mainID, subID)
  select dfId, Fullname, mainID, isnull(subID,0) as subID from #t order by recn;    
  
  select dfId, Fullname, mainID, isnull(subID,0) as subID from #t order by recn;    
end