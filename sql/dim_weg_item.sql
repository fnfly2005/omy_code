/*微格项目维表-原始表*/
select
    item_id,
    performance_name,
    performance_id,
    city_id,
    type_id,
    type_lv1_name,
    type_lv2_name,
    venue_id,
    shop_name,
    venue_type,
    city_name,
    province_id,
    province_name
from
    upload_table.dim_weg_item
