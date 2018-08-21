
select
    ds,
    mt,
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
        mt,
        province_name,
        city_name,
        category_name,
        shop_name,
        performance_id,
        performance_name,
        totalprice,
        order_num,
        row_number() over (partition by $par order by totalprice desc) rank
    from (
        select
            '范特西' as ds,
            mt,
            per.province_name,
            per.city_name,
            per.category_name,
            per.shop_name,
            per.performance_id,
            per.performance_name,
            sum(totalprice) totalprice,
            sum(order_num) order_num
        from (
            select performance_id, activity_id, performance_name, category_id, category_name, area_1_level_name, area_2_level_name, province_name, province_id, city_id, city_name, shop_id, shop_name from mart_movie.dim_myshow_performance where 1=1
                and (
                    regexp_like(performance_name,'$name')=true
                    or '全部'='$name'
                    )
                and (
                    -99 in ($id)
                    or performance_id in ($id)
                    )
                and 1 in ($source)
                and performance_seattype in ($performance_seattype)
            ) as per
            join (
            select
                case when 1 in ($dim) then substr(partition_date,1,7)
                else 'all' end as mt,
                performance_id,
                sellchannel,
                sum(totalprice) as totalprice,
                count(distinct order_id) as order_num
            from mart_movie.detail_myshow_salepayorder where partition_date>='$$begindate' and partition_date<'$$enddate'
            group by
                1,2,3
            ) as sp1
            on per.performance_id=sp1.performance_id
            join (
                select key_name, key, key1, key2, value1, value2, value3, value4 from upload_table.myshow_dictionary_s where 1=1
                and key_name='sellchannel'
                and value2 in ('$pt')
                ) as md
            on md.key=sp1.sellchannel
        group by
            1,2,3,4,5,6,7,8
        union all
        select
            '微格' as ds,
            mt,
            province_name,
            city_name,
            category_name,
            shop_name,
            item_no as performance_id,
            performance_name,
            sum(totalprice) totalprice,
            sum(order_num) order_num
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
                case when 1 in ($dim) then substr(dt,1,7)
                else 'all' end as mt,
                item_id,
                sum(total_money) as totalprice,
                count(distinct order_id) as order_num
            from 
                upload_table.detail_wg_saleorder
            where 
                dt<'$$enddate'
                and dt>='$$begindate'
                and pay_no is not null
            group by
                1,2
            ) so
            on so.item_id=dit.item_id
        group by
            1,2,3,4,5,6,7,8
        ) as rs
    ) as rr
where
    rank<=$rank
order by
    rank
;
