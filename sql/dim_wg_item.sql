/*微格项目维表*/
select
    item_id,
    title_cn as performance_name,
    item_no,
    city_id,
    type_id,
    type_lv1_name as category_name,
    type_lv2_name,
    venue_id,
    venue_name as shop_name,
    city_name,
    venue_type,
    province_id,
    province_name,
    row_number() over (order by item_id) item_nu
from
    upload_table.dim_wg_item
where
    title_cn NOT LIKE '%测试%'
    AND title_cn NOT LIKE '%调试%'
    AND title_cn NOT LIKE '%勿动%'
    AND title_cn NOT LIKE '%test%'
    AND title_cn NOT LIKE '%废%'
    AND title_cn NOT LIKE '%ceshi%'
