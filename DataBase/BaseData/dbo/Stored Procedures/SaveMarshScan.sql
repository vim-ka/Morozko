create procedure SaveMarshScan
  @datnom int, @OpArc int, @OpSell INT, @OpCheck INT
-- Если @OpArc>=0 - следует записать в OpArc и тек.время в SavedArc
-- иначе просто не трогать то, что там есть.
-- Аналогично с @OpSell, @Opcheck
as begin
  if not EXISTS(select * from MarshScan where Datnom=@Datnom )
  insert into MarshScan(datnom) VALUES(@datnom);
  
  if @OpArc>=0 update MarshScan set OpArc=@OpArc, SavedArc=getdate()
  where Datnom=@Datnom;

  if @OpSell>=0 update MarshScan set OpSell=@OpSell, SavedSell=getdate()
  where Datnom=@Datnom;

  if @OpCheck>=0 update MarshScan set OpCheck=@OpCheck, SavedCheck=getdate()
  where Datnom=@Datnom;

end