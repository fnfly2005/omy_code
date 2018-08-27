
select
    item_no as performance_id,
    item_id,
    performance_name,
    case when cat.category_id is null then 8
    else cat.category_id end as category_id,
    case when cat.category_name is null then '其他'
    else cat.category_name end as category_name,
    cim.city_id,
    case when cit.city_name is null then '其他'
    else cit.city_name end as city_name,
    cit.province_id,
    cit.province_name,
    area_1_level_id,
    area_1_level_name,
    area_2_level_id,
    area_2_level_name,
    venue_id,
    shop_name,
    type_id,
    type_lv2_name,
    venue_type
from (
    select item_id, performance_name, item_no, city_id, type_id, category_name, type_lv2_name, venue_id, shop_name, city_name, venue_type, province_id, province_name from upload_table.dim_wg_performance where performance_name NOT LIKE '%测试%' and type_lv2_name NOT LIKE '%测试%' AND performance_name NOT LIKE '%调试%' AND performance_name NOT LIKE '%勿动%' AND performance_name NOT LIKE '%test%' AND performance_name NOT LIKE '%废%' AND performance_name NOT LIKE '%ceshi%'
        and item_no is not null
    union all
    select
        item_id,
        performance_name,
        row_number() over (order by item_id)+1804043364 as item_no,
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
    from upload_table.dim_wg_performance where performance_name NOT LIKE '%测试%' and type_lv2_name NOT LIKE '%测试%' AND performance_name NOT LIKE '%调试%' AND performance_name NOT LIKE '%勿动%' AND performance_name NOT LIKE '%test%' AND performance_name NOT LIKE '%废%' AND performance_name NOT LIKE '%ceshi%'
        and item_no is null
    ) per
    left join (
        select category_id, type_lv1_name from upload_table.dim_wg_type
        ) typ
    on typ.type_lv1_name=per.category_name
    left join (
        select city_id, city_name from upload_table.dim_wg_citymap
        ) cim
    on cim.city_name=per.city_name
    left join (
        select city_id, mt_city_id, city_name, province_id, province_name, area_1_level_id, area_1_level_name, area_2_level_id, area_2_level_name from mart_movie.dim_myshow_city where 1=1
        ) as cit
        on cit.city_id=cim.city_id
    left join (
        select category_id, category_name from mart_movie.dim_myshow_category where category_id is not null
        ) as cat
        on cat.category_id=typ.category_id
;
