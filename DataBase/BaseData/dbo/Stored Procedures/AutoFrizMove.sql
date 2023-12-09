CREATE PROCEDURE dbo.AutoFrizMove
AS
BEGIN
declare @KolError int
set @KolError=0
declare @ND datetime,
    @TM char(8),
    @NOM int,
    @OP int,
    @Pin int,
    @Dck0 int,
    @Dck1 int,
    @Remark varchar(40),
    @Price money,
    @SkladNoFrom int,
    @SkladNoTo int, 
    @DogNom varchar(20),
    @DateSell datetime,
    @ContractID int 



  BEGIN transaction FrizMove
 
    declare obor_cursor cursor for
    select b_id,nom,price,dck from frizer where dck in (select dck from defcontract where our_id=6) and tip=0 order by b_id,nom

    OPEN obor_cursor

    FETCH NEXT FROM obor_cursor 
    INTO @pin, @nom, @price, @dck0

    WHILE @@FETCH_STATUS = 0
    BEGIN

      set @dck1=isnull((select min(dck) from defcontract where pin=@pin and contrtip=2 and actual=1 and our_id in (8,17)),0)
      if @dck1<>0 
      begin

        set @ContractID = ISNULL((select fc.ContractID  
        from FrizContract fc
        join
        (select nom,max(Contractid) as Contractid
         from FrizContractDet where kol>0 and isnull(DopNoExcep,0)=0
         group by nom) C on C.Contractid=fc.Contractid
         where c.nom=@Nom),0)

         INSERT INTO 
        dbo.FrizerMov
      (
       ND,
       TM, 
       Nom,
       Op,
       Pin0,
       Dck0,
       Pin1,
       Dck1,
       DocDate,
       DocNom,
       remark,
       Price,
       NDTm,
       SkladNoFrom,
       SkladNoTo
       ) 
        VALUES (
       dbo.today(),
        '15:00:00',
       @Nom,
       0,
       @Pin,
       @Dck0,
       @Pin,
       @Dck1,
       dbo.today(),
       '',
       'Перемещение м/у договорами',
       @Price,
     '15:00:00',
       null,
        null
     )
 
         update Frizer set DCK=@Dck1 where NOM=@NOM
         if @@Error<>0 set @KolError=@KolError + 1

         if @ContractID <>0 update FrizContractDet set DCK=@DCK1 where Nom=@Nom and ContractID=@ContractID
         if @@Error<>0 set @KolError=@KolError + 1
     end    
  
    FETCH NEXT FROM obor_cursor 
    INTO @pin, @nom, @price, @dck0
   END 
CLOSE obor_cursor;
DEALLOCATE obor_cursor;


if @KolError = 0 COMMIT ELSE ROLLBACK

select @KolError as KolError

END