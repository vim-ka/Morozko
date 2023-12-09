CREATE VIEW ELoadMenager.clients_and_net_list
as 
select pin [id], brname [list] from dbo.def where actual=1
union 
select pin [id], '[ВСЯ СЕТЬ]:'+brname [list] from dbo.def where pin=master and actual=1