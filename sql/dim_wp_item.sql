/*智慧剧院-项目维表*/
select
    item_id,
    item_no,
    item_name,
    type_lv1_name,
    city_name,
    province_name,
    venue_name
from
    upload_table.dim_wp_item
