/*微格项目信息表*/
select
    id,
    title_cn,
    type_id,
    source
from
    item_info
where
    id is not null
