/*演出项目商品匹配表*/
select
    ActivityID,
    case when TPID<6 then '渠道'
    else '自营' end tp_type,
    TPID,
    TPSProjectID
from
    origindb.dp_myshow__bs_activitymap
where
    TPID is not null
