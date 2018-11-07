/*ycsensitive项目商品匹配表*/
select
    TPID,
    TPSProjectID
from
    BS_ActivityMap
where
    TPID is not null
