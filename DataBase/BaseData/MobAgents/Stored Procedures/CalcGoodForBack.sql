CREATE PROCEDURE MobAgents.CalcGoodForBack
AS
BEGIN
  
  truncate table [MobAgents].GoodForBack

  declare @nd datetime
  declare @datnom1 bigint
  set @nd=dbo.today()
   
  set @datnom1 = dbo.InDatNom(0,@nd-200) 
  select distinct TekID into #TempID from nv where datnom>=@datnom1 and kol>0
  
  declare @PLID int
  
  declare C_PLID cursor local for
  select PLID from SkladPlace
  
  open C_PLID
  
  fetch next from C_PLID
  into @PLID
  
  WHILE @@FETCH_STATUS = 0  
  begin    
    
    select distinct v.hitag, fc.FirmGroup, g.PLID into #NeedIDs
    from tdvi v left join skladlist s on v.sklad=s.skladNo
                left join nomen n on v.hitag=n.hitag                                
                left join SkladGroups g on s.skg=g.skg
                join FirmsConfig fc on v.Our_ID=fc.Our_id
    where v.locked=0 and s.locked=0 and s.agInvis=0 and s.Discard=0 and g.PLID=@PLID and 
          s.Equipment=0
        
    insert into GoodForBack (hitag,FirmGroup, PLID)
    select t.hitag, t.FirmGroup, t.PLID from
    (select distinct v.hitag,fc.FirmGroup, g.PLID from visual v join FirmsConfig fc on v.Our_ID=fc.Our_id 
                                                                join skladlist s on v.sklad=s.skladno
                                                                join skladgroups g on s.skg=g.skg 
                                                                join #TempID d on v.id=d.tekid
     where /*v.datepost>=(@nd-200) and*/ g.PLID=@PLID
     
    except 
    
    select distinct s.hitag,s.FirmGroup, s.PLID from #NeedIDs s ) t
    
    
    drop table #NeedIDs
    fetch next from C_PLID
    into @PLID
  
  end
  
  close C_PLID;  
  deallocate C_PLID;
  
  select v.hitag, max(v.ncom) as ncom into #TempPrice 
  from visual v --join #NeedIDs nid on v.hitag=nid.hitag
  group by v.hitag
  
  --select f.*, t.* from #TempPrice t right join GoodForBack f on t.hitag=f.hitag
  
  update [MobAgents].GoodForBack set Price=(select max(iif((n.flgWeight=0 or v.weight=0),v.Price,v.Price/v.weight)) from visual v join #TempPrice t on v.hitag=t.hitag and v.ncom=t.ncom
                                                                              join nomen n on v.hitag=n.hitag
                                            where [MobAgents].GoodForBack.hitag=v.hitag) 
                                            
                                            
                                                                      
  drop table #TempPrice                                                                    
  
END