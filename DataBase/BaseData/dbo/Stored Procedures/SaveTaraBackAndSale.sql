CREATE procedure SaveTaraBackAndSale @SourDatnom int, @DestDatNom int, @Op int
as
declare @nd datetime
declare @tm CHAR(8)
declare @b_id int 
declare @TaraTip int
declare @TaraPrice money
declare @SourNnak int
declare @DestNnak int
declare @Delta int
declare @SourDate datetime

begin
  set @ND=convert(char(10), getdate(),104);
  set @TM=convert(char(8), getdate(),108);
  set @b_id=(select b_id from NC where datnom=@Sourdatnom);
  set @SourDate=dbo.DatNomInDate(@SourDatNom);
  set @SourNnak=dbo.InNnak(@SourDatNom);
  set @DestNnak=dbo.InNnak(@DestDatNom);
  
  SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
  begin transaction T1; 

  -- Нюанс: данные по таре буду брать уже из новой накладной, не из исходной:
  declare CR cursor fast_forward for
	select t.TaraTip, t.TaraPrice as Price,
    sum(nv.kol) as Delta
	from nv inner join taraCode2 t on t.fishtag=nv.hitag
	where nv.datnom=@DestDatnom 
	group by t.TaraTip, t.TaraPrice;
    
  open CR;    
  fetch next from CR into @TaraTip, @TaraPrice,@Delta
  
  WHILE (@@FETCH_STATUS=0)  BEGIN
    
    -- Запись возврата: 
    insert into TaraDet(nd,tm,b_id,Nnak,selldate,datnom,act,taratip,kol,price,OP,naktip,remark)
    values(@nd,@tm,@b_id,@SourNnak,@SourDate,@Sourdatnom,'ТВ',@taratip,-@Delta,@taraprice,@OP,0,'Перебивка-');
    
    -- Запись новой отгрузки:
    insert into TaraDet(nd,tm,b_id,Nnak,selldate,datnom,act,taratip,kol,price,OP,naktip,remark)
    values(@nd,@tm,@b_id,@DestNnak,@nd,@Destdatnom,'ТП',@taratip,@Delta,@taraprice,@OP,0,'Перебивка+');
    
    fetch next from CR into @TaraTip, @TaraPrice,@Delta
  END;
  
  close CR;
  deallocate CR;       
  Commit;
end