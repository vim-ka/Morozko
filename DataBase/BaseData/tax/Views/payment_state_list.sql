CREATE view tax.payment_state_list
as
select 0 [id], 'запланирован' [list]
union select 1, 'исполнен'
union select 2, 'не исполнен'
union select 3, 'частичная оплата'