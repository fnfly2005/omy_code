
select
    ds,
    province_name,
    city_name,
    category_name,
    shop_name,
    performance_id,
    performance_name,
    totalprice,
    order_num,
    rank
from (
    select
        ds,
        province_name,
        city_name,
        category_name,
        shop_name,
        performance_id,
        performance_name,
        totalprice,
        order_num,
        row_number() over (order by totalprice desc) rank
    from (
        select
            '范特西' as ds,
            per.province_name,
            per.city_name,
            per.category_name,
            per.shop_name,
            per.performance_id,
            per.performance_name,
            totalprice,
            order_num
        from (
            select performance_id, activity_id, performance_name, category_id, category_name, area_1_level_name, area_2_level_name, province_name, city_id, city_name, shop_name from mart_movie.dim_myshow_performance where performance_id is not null
                and (
                    regexp_like(performance_name,'$name')=true
                    or '全部'='$name'
                    )
                and (
                    -99 in ($id)
                    or performance_id in ($id)
                    )
                and 1 in ($source)
            ) as per
            join (
            select
                performance_id,
                sum(totalprice) as totalprice,
                count(distinct order_id) as order_num
            from mart_movie.detail_myshow_salepayorder
            where
                partition_date<'$enddate'
                and partition_date>='$begindate'
            group by
                1
            ) as sp1
            on per.performance_id=sp1.performance_id
        union all
        select
            '微格' as ds,
            province_name,
            city_name,
            category_name,
            shop_name,
            item_no as performance_id,
            performance_name,
            totalprice,
            order_num
        from (
            select item_id, performance_name, item_no, city_id, type_id, category_name, type_lv2_name, venue_id, shop_name, city_name, venue_type, province_id, province_name from upload_table.dim_wg_performance where performance_name NOT LIKE '%测试%' AND performance_name NOT LIKE '%调试%' AND performance_name NOT LIKE '%勿动%' AND performance_name NOT LIKE '%test%' AND performance_name NOT LIKE '%废%' AND performance_name NOT LIKE '%ceshi%'
                and (
                    regexp_like(performance_name,'$name')=true
                    or '全部'='$name'
                    )
                and (
                    -99 in ($id)
                    or item_no in ($id)
                    )
                and 2 in ($source)
            ) dit
            join (
            select
                item_id,
                sum(total_money) as totalprice,
                count(distinct order_id) as order_num
            from 
                upload_table.detail_wg_saleorder
            where 
                dt<'$enddate'
                and dt>='$begindate'
                and pay_no is not null
            group by
                1
            ) so
            on so.item_id=dit.item_id
        ) as rs
    ) as rr
where
    rank<=$rank
order by
    rank
;
