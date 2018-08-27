/*微格项目维表*/
select
    item_id,
    performance_name,
    item_no,
    city_id,
    type_id,
    category_name,
    type_lv2_name,
    venue_id,
    shop_name,
    city_name,
    venue_type,
    province_id,
    province_name
from
    upload_table.dim_wg_performance
where
    performance_name NOT LIKE '%测试%'
    and type_lv2_name NOT LIKE '%测试%'
    AND performance_name NOT LIKE '%调试%'
    AND performance_name NOT LIKE '%勿动%'
    AND performance_name NOT LIKE '%test%'
    AND performance_name NOT LIKE '%废%'
    AND performance_name NOT LIKE '%ceshi%'
