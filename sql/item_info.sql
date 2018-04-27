/*微格项目信息表*/
select
    id as item_id,
    item_no,
    replace(title_cn,',',' ') as item_name,
    type_id,
    venue_id,
    city_id
from
    item_info
