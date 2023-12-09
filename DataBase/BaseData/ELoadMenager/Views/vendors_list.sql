CREATE view ELoadMenager.vendors_list
as
select ncod [id], fam [list] from dbo.vendors where actual=1