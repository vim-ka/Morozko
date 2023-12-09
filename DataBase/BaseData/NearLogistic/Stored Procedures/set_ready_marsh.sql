CREATE procedure NearLogistic.set_ready_marsh
@msg varchar(100) out,
@val int =1
as
begin
  if not exists(select 1 from dbo.config where val<>0 and param='ReadyMarsh')
  begin
    update c set val=@val from dbo.config c where param='ReadyMarsh'
    set @msg='Ответный файл будет выгружен в течение 10 минут.'
  end
  else set @msg='Ожидается выгрузка ответного файла.'
end