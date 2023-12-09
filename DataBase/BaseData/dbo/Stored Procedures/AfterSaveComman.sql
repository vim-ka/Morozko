CREATE PROCEDURE dbo.AfterSaveComman
@ncom int,
@ncod int,
@dck int,
@pin int,
@sdt datetime,
@snom varchar(20),
@tdt datetime,
@tnom varchar(30)
AS
declare @tranname varchar(15)
set @tranname='AfterSaveComman'
begin tran @tranname
declare @erReg int
DECLARE @our_id INT 
DECLARE @srok int
if @ncom<>0
begin
SELECT  @srok=dc.Srok,
		@our_id=dc.Our_id
FROM DefContract dc
WHERE dc.DCK=@dck

set @erReg=0
update comman set ncod=@ncod,
                  dck=@dck,
                  pin=@pin,
                  doc_date=@sdt,
                  TN_date=@tdt,
                  TN_nom=@tnom,
                  doc_nom=@snom,
				  srok=@srok,
				  our_id=@our_id
where Ncom=@ncom
set @erReg=@erReg+@@error
	
update tdvi set ncod=@ncod,
                dck=@dck,
                pin=@pin,
				OUR_ID=@our_id
where Ncom=@ncom
set @erReg=@erReg+@@error
	
update visual set 	ncod=@ncod,
                    dck=@dck,
                    pin=@pin,
our_id=@our_id
where Ncom=@ncom
set @erReg=@erReg+@@error
	
update izmen set ncod=@ncod,
                 dck=@dck,
                 pin=@pin                    
where Ncom=@ncom
set @erReg=@erReg+@@error
end
if @erReg=0
begin
	commit tran @tranname
	select cast(0 as bit) res, '' msg
end
else
begin
	rollback tran @tranname
	select cast(1 as bit) res, 'Во время переброса произошла ошибка' msg
end