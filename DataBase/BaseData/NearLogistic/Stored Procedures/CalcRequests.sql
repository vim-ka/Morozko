CREATE PROCEDURE NearLogistic.CalcRequests
AS 
BEGIN
  declare @nd DATETIME, @dn1 BIGINT, @dn2 BIGINT, @cntMarsh INT, @cntAll INT 
  set @nd = dbo.today()
  
  set @dn1 = dbo.indatnom(0, @nd)
  set @dn2 = @dn1 + 9999
  
  SET @cntAll = 
    (SELECT COUNT(t.datnom) FROM 
      (
       select c.datnom
         from dbo.nc c 
        where c.datnom between @dn1 and @dn2
          and c.sp>=0
          and isnull(c.dayshift,0)=0
          and c.done=1
       union
       select c.datnom
         from dbo.nc c 
        where isnull(c.dayshift,0)=0
          and c.datnom in (select z.datnom from dbo.nvzakaz z with(index(nvZakaz_idx)) where z.datnom between @dn1 and @dn2 and z.done=0)
       union
       select mf.mrfID AS datnom
         from nearlogistic.MarshRequests_free mf 
        where (mf.dt_create >= @nd
           or isnull(mf.mhid,0) = 0)
          AND mf.isdel=0
      )t
    )

      
  SET @cntMarsh = 
    (SELECT COUNT(t.datnom) FROM 
      (
       select c.datnom
         from dbo.nc c 
        where c.datnom between @dn1 and @dn2
          and c.sp>=0
          and isnull(c.dayshift,0)=0
         and isnull(c.mhid,0) not in (0,99)
         and c.done=1
       union
       select c.datnom
         from dbo.nc c 
        where isnull(c.dayshift,0)=0
          and isnull(c.mhid,0) not in (0,99)
          and c.datnom in (select z.datnom from dbo.nvzakaz z with(index(nvZakaz_idx)) where z.datnom between @dn1 and @dn2 and z.done=0)
       union
       select mf.mrfID AS datnom
         from nearlogistic.MarshRequests_free mf 
        where mf.dt_create >= @nd 
          and isnull(mf.mhid,0) not in (0,99)           
          and mf.isdel=0
      )t
    )

  SELECT @cntMarsh AS cntMarsh, @cntAll AS cntAll   

END