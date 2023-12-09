CREATE procedure warehouse.terminal_CancelNvZakaz
@nzID int,
@rem varchar(50) = 'old',
@op int,
@spk int,
@admin_spk int =-1,
@group_id int =-1
AS
BEGIN
	declare @rest decimal(10,3), @unid INT
  SET @unid = (SELECT z.unID FROM nvZakaz z WHERE nzID=@nzID)

	declare @tekweight decimal(10,3)
  declare @sklad int
  declare @hitag INT

  select @sklad=skladno, @hitag=hitag from dbo.nvzakaz where nzid=@nzID

/*
	select @tekWeight=sum(case when n.flgWeight=1 
  													 then v.weight*(v.morn-v.sell+v.isprav-v.remov-v.rezerv) 
                             else (v.morn-v.sell+v.isprav-v.remov-v.rezerv) end) 
  from dbo.tdvi v
  left join dbo.nomen n on n.hitag=v.hitag
  where v.sklad=@sklad and v.hitag=@Hitag
*/

  set @rest = ISNULL((SELECT SUM(dbo.getQTY(v.HITAG, v.UnID, v.rest, @unid)) 
                 FROM tdvi v 
                WHERE v.sklad in 
                      (select t.SkladNo from skladlist t where t.UpWeight=1 and t.AgInvis=0)
                      and v.HITAG = @Hitag), 0)

  update z 
     set z.done=1, 
         z.tmEnd=CONVERT(varchar(8),getdate(),108), 
         z.dtEnd=CONVERT(varchar(10),getdate(),104),
         --z.curWeight=0, 
         --z.tekWeight=@tekWeight, 
         z.curWeight = NULL, 
         z.tekWeight = NULL,   
         rest = @rest,
         confKol = 0,          
         z.id=0, z.comp=z.comp+'#'+host_name()+'@Cancel', z.remark=@rem,
         z.op=@op, z.spk=@spk, z.group_id=@group_id 
  from dbo.nvzakaz z
  where z.nzID=@nzID
  
  insert into warehouse.terminal_shippingzakaz_log(nzid,ves,op,spk,msg,done)
	values (@nzid,0,@op,@spk,@rem,cast(1 as bit))
end