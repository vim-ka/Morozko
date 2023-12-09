CREATE PROCEDURE dbo.NomenVendUpdate @PLU varchar(100) ,@ExtTag varchar(100),@ediID int
AS
BEGIN
  declare @CLID int, @DCK int, @Hitag int

  select @CLID=clid, @DCK=DCK from Exite_Clients where ediID=@ediID

  set @Hitag = (select e.hitag 
                from exite_nomen e cross apply 
               (select max(n.id) as id from exite_nomen n where n.clid=@CLID and n.plu=@PLU) n
                where e.id=n.id);  
               
  update nomenvend set exttag=@ExtTag where DCK=@DCK and Hitag=@hitag
  
  --у сибирской коллекции есть и второй поставщик
  --if @DCK=44290 update nomenvend set exttag=@ExtTag where dck=43737 and hitag=@hitag 
  
END