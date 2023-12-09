CREATE PROCEDURE dbo.PrihodRCheck
@PrihodRID int
AS
BEGIN
  declare @res int 
	declare @PrihodRDetID int
	set @res=0
	set @PrihodRDetID=0
	
	UPDATE PrihodReqDet set PrihodRDetCloneMain=0 where PrihodRDetAfterParty=1 and PrihodRID=@PrihodRID
	/*
	merge into PrihodReqDet c
		using(select 	a.PrihodRDetHitag,
                  a.PrihodRDetClone,
									a.PrihodRDetDate,
									a.PrihodRDetSrokh,
									a.PrihodRDetShelfLife,
									a.PrihodRDetShelfLifeAdd
					from PrihodReqDet a
					where a.PrihodRID=@PrihodRID and
								a.PrihodRDetCloneMain=1
          GROUP BY a.PrihodRDetHitag,
									a.PrihodRDetDate,
									a.PrihodRDetSrokh,
									a.PrihodRDetShelfLife,
									a.PrihodRDetShelfLifeAdd,
                  a.PrihodRDetClone) b on b.PrihodRDetHitag=c.PrihodRDetHitag 
                                              and c.PrihodRID=@PrihodRID 
                                              AND b.PrihodRDetClone=c.PrihodRDetClone
																							and c.PrihodRDetCloneMain=0
		when matched then 
			update set
							PrihodRDetDate=b.PrihodRDetDate,
							PrihodRDetSrokh=b.PrihodRDetSrokh,
							PrihodRDetShelfLife=b.PrihodRDetShelfLife,
							PrihodRDetShelfLifeAdd=b.PrihodRDetShelfLifeAdd;
*/
  UPDATE PRIHODREQDET SET PRIHODRDETDATE=C1.PRIHODRDETDATE,
					                PRIHODRDETSROKH=C1.PRIHODRDETSROKH,
					                PRIHODRDETSHELFLIFE=C1.PRIHODRDETSHELFLIFE,
					                PRIHODRDETSHELFLIFEADD=C1.PRIHODRDETSHELFLIFEADD 
  FROM PRIHODREQDET C0
  INNER JOIN (SELECT DISTINCT A.PRIHODRDETHITAG,
                              A.PRIHODRDETCLONE,
                              A.PRIHODRDETDATE,
                              A.PRIHODRDETSROKH,
                              A.PRIHODRDETSHELFLIFE,
                              A.PRIHODRDETSHELFLIFEADD	
              FROM PRIHODREQDET A
			        WHERE A.PRIHODRID=@PRIHODRID 
						        AND A.PRIHODRDETCLONEMAIN=1) C1 ON C1.PRIHODRDETHITAG=C0.PRIHODRDETHITAG AND C1.PRIHODRDETCLONE=C0.PRIHODRDETCLONE
  WHERE C0.PRIHODRDETCLONEMAIN=0
        AND C0.PRIHODRID=@PRIHODRID
	
  if exists(select *
						from PrihodReqDet p
						where p.PrihodRID=@PrihodRID and
									((p.PrihodRDetDate is null or
									 p.PrihodRDetSrokh is null or
									 isnull(p.PrihodRDetShelfLife,0)=0)
									 and p.PrihodRDetShelfLifeAdd is null)
									 and exists(select t.hitag from tdvi t where t.hitag=p.PrihodRDetHitag and t.ncom=p.PrihodRDetNCom and not t.sklad in (88,92))
									 and not p.PrihodRDetHitag in (5659,2296,90858,95007,15028)
									 and not exists(select * from Nomen where nomen.hitag=p.PrihodRDetHitag and ngrp in (select ngrp from gr where aginvis=1)))
	set @res=@res+2

	set @PrihodRDetID=isnull((select top 1 p.PrihodRDetID
												from PrihodReqDet p
												where p.PrihodRID=@PrihodRID and
															DATEDIFF(day,p.PrihodRDetDate,getdate())<0),0)
	if @PrihodRDetID<>0
	set @res=@res+4
				 
	select @res [res], @PrihodRDetID [id]

END