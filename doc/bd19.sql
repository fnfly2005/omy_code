
select
    province_name,
    coalesce(city_name,'全部') as city_name,
    coalesce(type_lv1_name,'全部') as type_lv1_name,
    count(distinct order_mobile) as user_num
from (
    select item_id, item_no, title_cn, type_lv1_name, city_name, province_name from upload_table.dim_wg_item
    ) per
    join (
        select 
            order_mobile,
            item_id
        from 
            upload_table.detail_wg_saleorder
        ) so
    on so.item_id=per.item_id
group by
    type_lv1_name,
    province_name,
    city_name
grouping sets(
    (province_name),
    (province_name,city_name),
    (type_lv1_name,province_name),
    (type_lv1_name,province_name,city_name)
    ) 
;
