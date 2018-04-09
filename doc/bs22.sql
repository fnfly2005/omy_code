
select
    count(1) as num,
    count(distinct user_id) as user_num
from (
    select dt, item_id, user_id from upload_table.detail_wg_itemattentions
    ) ia
;
