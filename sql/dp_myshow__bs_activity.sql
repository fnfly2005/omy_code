/*演出项目商品匹配表*/
select
    TPID
from
    origindb.dp_myshow__bs_activity
where
    TPID is not null
