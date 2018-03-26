
select
    mobile
from (
    select phonenumber as mobile, performanceid as performance_id from origindb.dp_myshow__s_messagepush where phonenumber is not null
    and performanceid=$id
    ) mp
;
