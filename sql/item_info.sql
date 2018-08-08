/*微格项目信息表*/
select
    id as item_id,
    item_no as performance_id,
    replace(title_cn,',',' ') as performance_name,
    type_id,
    venue_id,
    city_id,
    substr(show_time,1,10) as dt
from
    item_info
where
    title_cn not like '%废%'
    and title_cn not like '%测试%'
    AND title_cn NOT LIKE '%调试%'
    AND title_cn NOT LIKE '%勿动%'
    AND title_cn NOT LIKE '%test%'
    AND title_cn NOT LIKE '%ceshi%'
