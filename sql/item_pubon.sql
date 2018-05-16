/*微格项目上架时间*/
select
    item_id,
    business_id,
    FROM_UNIXTIME(LEFT(pubon_time, 10)) as ontime
from
    item_pubon
union all
select
    item_id,
    business_id,
    FROM_UNIXTIME(LEFT(pubon_time, 10)) as ontime
from
    item_puboff
