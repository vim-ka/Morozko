CREATE VIEW NearLogistic.requests_free_actions
as
select id, action_name [list]
from nearlogistic.requestsactions 
where flag  & 2 <>0