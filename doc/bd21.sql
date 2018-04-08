
select
    '范特西' as ds,
    per.province_name,
    per.city_name,
    per.category_name,
    per.shop_name,
    per.performance_id,
    per.performance_name,
    sp1.order_num,
    sp1.totalprice
from (
    select performance_id, activity_id, performance_name, category_id, category_name, area_1_level_name, area_2_level_name, province_name, city_id, city_name, shop_name from mart_movie.dim_myshow_performance where performance_id is not null
    and (
        regexp_like(performance_name,'$name')=true
        or performance_id in ($id)
        )
    ) as per
    join (
    select
        performance_id,
        count(distinct order_id) as order_num,
        sum(totalprice) as totalprice
    from mart_movie.detail_myshow_salepayorder
    where
        partition_date<'$$today'
    group by
        1
    ) as sp1
    on per.performance_id=sp1.performance_id
union all
select
    '微格' as ds,
    province_name,
    city_name,
    type_lv1_name as category_name,
    venue_name as shop_name,
    item_no as performance_id,
    title_cn as performance_name,
    order_num,
    totalprice
from (
    select item_id, item_no, title_cn, type_lv1_name, city_name, province_name, venue_name from upload_table.dim_wg_item
    where regexp_like(title_cn,'$name')=true
        or item_no in ($id)
    ) dit
    join (
    select
        item_id,
        count(distinct order_id) as order_num,
        sum(total_money) as totalprice
    from upload_table.detail_wg_saleorder
    where pay_no is not null
    group by
        1
    ) so
    on so.item_id=dit.item_id
;
