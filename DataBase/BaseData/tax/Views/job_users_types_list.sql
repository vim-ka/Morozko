CREATE view tax.job_users_types_list
as
select *
from tax.job_types_list
where tech_job=0