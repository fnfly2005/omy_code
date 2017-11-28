/*演出项目商品匹配表*/
select
    TPID,
    TPSProjectID
from
    origindb.dp_myshow__bs_activitymap
where
    TPID is not null
