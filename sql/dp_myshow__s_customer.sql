/*演出客户表*/
select
    TPID,
    Name
from
    origindb.dp_myshow__s_customer
where
    TPID is not null
