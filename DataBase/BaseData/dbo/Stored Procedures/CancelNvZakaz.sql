CREATE PROCEDURE dbo.CancelNvZakaz
@datnom BIGint,
@hitag int,
@rem varchar(50) = 'old',
@op int,
@spk int
AS
BEGIN
	declare @rest decimal(10,3), @unid INT
  SET @unid = (SELECT z.unID FROM nvZakaz z WHERE datnom=@datnom and hitag=@Hitag)

	/*
  select @tekWeight=sum(case when n.flgWeight=1 
  													 then v.weight*(v.morn-v.sell+v.isprav-v.remov-v.rezerv) 
                             else (v.morn-v.sell+v.isprav-v.remov-v.rezerv) end) 
  from tdvi v
  left join nomen n on n.hitag=v.hitag
  where v.sklad in (select t.SkladNo from skladlist t where t.UpWeight=1 and t.AgInvis=0)
        and v.HITAG=@Hitag
  */

  
  set @rest = ISNULL((SELECT SUM(dbo.getQTY(v.HITAG, v.UnID, v.rest, @unid)) 
                 FROM tdvi v 
                WHERE v.sklad in 
                      (select t.SkladNo from skladlist t where t.UpWeight=1 and t.AgInvis=0)
                      and v.HITAG = @Hitag), 0)
  
   update nvzakaz 
      set done=1,
          tmEnd=CONVERT(varchar(8),getdate(),108),
          dtEnd=CONVERT(varchar(10),getdate(),104),
          curWeight=null,
          tekWeight=null,
          rest = @rest,
          confKol = 0,
          id=0,
          comp=comp+'@Cancel',
          remark=@rem,
          op=@op,
          spk=@spk
      where datnom=@datnom and hitag=@Hitag;                
                
END