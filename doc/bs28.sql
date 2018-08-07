
select
    sp.ds,
    sp.mt,
    sp.dt,
    sp.pt,
    sp.customer_type_name,
    sp.customer_lvl1_name,
    sp.category_name,
    sp.area_1_level_name,
    sp.area_2_level_name,
    sp.province_name,
    sp.city_name,
    sum(show_num) as show_num,
    sum(order_num) as order_num,
    sum(totalprice) as totalprice,
    sum(ticket_num) as ticket_num,
    sum(grossprofit) as grossprofit,
    sum(sp_num) as sp_num,
    sum(ap_num) as ap_num
from (
    select
        case when 0 in ($dim) then '猫眼' 
        else 'all' end as ds,
        case when 1 in ($dim) then substr(dt,1,7) 
        else 'all' end mt,
        case when 2 in ($dim) then dt
        else 'all' end dt,
        case when 3 in ($dim) then value2
        else 'all' end pt,
        case when 4 in ($dim) then customer_type_name
        else 'all' end customer_type_name,
        case when 5 in ($dim) then customer_lvl1_name
        else 'all' end customer_lvl1_name,
        case when 6 in ($dim) then category_name
        else 'all' end category_name,
        case when 7 in ($dim) then area_1_level_name
        else 'all' end area_1_level_name,
        case when 8 in ($dim) then area_2_level_name
        else 'all' end area_2_level_name,
        case when 9 in ($dim) then province_name
        else 'all' end province_name,
        case when 10 in ($dim) then city_name
        else 'all' end city_name,
        count(distinct spo.performance_id) as sp_num,
        sum(show_num) as show_num,
        sum(order_num) as order_num,
        sum(totalprice) as totalprice,
        sum(ticket_num) as ticket_num,
        sum(grossprofit) as grossprofit
    from (
        select
            dt,
            sellchannel,
            customer_id,
            performance_id,
            count(distinct show_id) as show_num,
            sum(order_num) as order_num,
            sum(totalprice) as totalprice,
            sum(ticket_num) as ticket_num,
            sum(grossprofit) as grossprofit
        from (
            select
                substr(order_create_time,1,10) as dt,
                sellchannel,
                customer_id,
                performance_id,
                show_id,
                count(distinct order_id) as order_num,
                sum(totalprice) as totalprice,
                sum(salesplan_count*setnumber) as ticket_num,
                0 as grossprofit
            from
                mart_movie.detail_myshow_saleorder
            where
                pay_time is null
                and order_create_time>='$$begindate'
                and order_create_time<'$$enddate'
                and $payflag=0
                and 0 in ($ds)
            group by
                1,2,3,4,5
            union all
            select
                partition_date as dt,
                sellchannel,
                customer_id,
                performance_id,
                show_id,
                count(distinct order_id) as order_num,
                sum(totalprice) as totalprice,
                sum(salesplan_count*setnumber) as ticket_num,
                sum(grossprofit) as grossprofit
            from mart_movie.detail_myshow_salepayorder where partition_date>='$$begindate' and partition_date<'$$enddate'
                and 0 in ($ds)
            group by
                1,2,3,4,5
            union all
            select
                substr(pay_time,1,10) as dt,
                sellchannel,
                customer_id,
                performance_id,
                show_id,
                count(distinct order_id) as order_num,
                sum(totalprice) as totalprice,
                sum(salesplan_count*setnumber) as ticket_num,
                0 as grossprofit
            from mart_movie.detail_myshow_saleorder where pay_time is not null and pay_time>='$$begindate' and pay_time<'$$enddate'
                and 0 in ($ds)
                and sellchannel in (9,10)
            group by
                1,2,3,4,5
            ) sp1
        group by
            1,2,3,4
            ) spo
        join (
        select key_name, key, key1, key2, value1, value2, value3, value4 from upload_table.myshow_dictionary_s where 1=1
        and key_name='sellchannel'
        and value2 in ('$pt')
        ) md1
        on md1.key=spo.sellchannel
        left join (
        select performance_id, activity_id, performance_name, category_id, category_name, area_1_level_name, area_2_level_name, province_name, province_id, city_id, city_name, shop_id, shop_name from mart_movie.dim_myshow_performance where performance_id is not null
        ) per
        on spo.performance_id=per.performance_id
        left join (
        select customer_id, customer_type_id, customer_type_name, customer_lvl1_name, customer_name, customer_shortname, customer_code from mart_movie.dim_myshow_customer where customer_id is not null
        ) cus
        on cus.customer_id=spo.customer_id
    group by
        1,2,3,4,5,6,7,8,9,10,11
    union all
    select
        case when 0 in ($dim) then '微格'
        else 'all' end as ds,
        case when 1 in ($dim) then substr(dt,1,7) 
        else 'all' end mt,
        case when 2 in ($dim) then dt
        else 'all' end dt,
        case when 3 in ($dim) then value2 
        else 'all' end as pt,
        case when 4 in ($dim) then '自营' 
        else 'all' end as customer_type_name,
        case when 5 in ($dim) then '微票开放平台' 
        else 'all' end as customer_lvl1_name,
        case when 6 in ($dim) then cat.category_name
        else 'all' end category_name,
        case when 7 in ($dim) then area_1_level_name
        else 'all' end area_1_level_name,
        case when 8 in ($dim) then area_2_level_name
        else 'all' end area_2_level_name,
        case when 9 in ($dim) then cit.province_name
        else 'all' end province_name,
        case when 10 in ($dim) then cit.city_name
        else 'all' end city_name,
        count(distinct wso.item_id) as sp_num,
        0 as show_num,
        sum(order_num) as order_num,
        sum(totalprice) as totalprice,
        0 as ticket_num,
        0 as grossprofit
    from (
        select
            dt,
            item_id,
            order_src,
            count(distinct order_id) as order_num,
            sum(total_money) as totalprice
        from upload_table.detail_wg_saleorder where dt>='$$begindate' and dt<'$$enddate'
        and order_src<>10
        and (
            length(pay_no)>5
            or $payflag=0
            )
        and 1 in ($ds)
        group by
            1,2,3
            ) wso
        join (
        select key_name, key, key1, key2, value1, value2, value3, value4 from upload_table.myshow_dictionary_s where 1=1
        and key_name='order_src'
        and value2 in ('$pt')
        ) md2
        on wso.order_src=md2.key
        left join (
        select item_id, performance_name, item_no, city_id, type_id, category_name, type_lv2_name, venue_id, shop_name, city_name, venue_type, province_id, province_name from upload_table.dim_wg_performance where performance_name NOT LIKE '%测试%' AND performance_name NOT LIKE '%调试%' AND performance_name NOT LIKE '%勿动%' AND performance_name NOT LIKE '%test%' AND performance_name NOT LIKE '%废%' AND performance_name NOT LIKE '%ceshi%'
        ) wi
        on wso.item_id=wi.item_id
        left join (
        select category_id, type_lv1_name from upload_table.dim_wg_type
        ) wt
        on wt.type_lv1_name=wi.category_name
        left join (
        select city_id, city_name from upload_table.dim_wg_citymap
        ) wc
        on wc.city_name=wi.city_name
        left join (
        select city_id, mt_city_id, city_name, province_name, area_1_level_name, area_2_level_name from mart_movie.dim_myshow_city where dp_flag=0
        ) cit
        on cit.city_id=wc.city_id
        left join (
        select category_id, category_name from mart_movie.dim_myshow_category where category_id is not null
        ) cat
        on cat.category_id=wt.category_id
    group by
        1,2,3,4,5,6,7,8,9,10,11
    union all
    select
        case when 0 in ($dim) then '团购'
        else 'all' end as ds,
        case when 1 in ($dim) then substr(pay_time,1,7) 
        else 'all' end mt,
        case when 2 in ($dim) then substr(pay_time,1,10)
        else 'all' end dt,
        'all' pt,
        case when 4 in ($dim) then '自营' 
        else 'all' end as customer_type_name,
        case when 5 in ($dim) then '团购' 
        else 'all' end as customer_lvl1_name,
        'all' category_name,
        'all' area_1_level_name,
        'all' area_2_level_name,
        'all' province_name,
        'all' city_name,
        count(distinct deal_id) as sp_num,
        0 as show_num,
        count(distinct order_id) as order_num,
        sum(purchase_price) as totalprice,
        sum(quantity) as ticket_num,
        0 as grossprofit
    from mart_movie.detail_maoyan_order_sale_cost_new_info where pay_time>='$$begindate' and pay_time<'$$enddate'
        and 2 in ($ds)
        and deal_id in (
            select 
                deal_id
            from mart_movie.dim_deal_new where category=12
            )
    group by
        1,2,3,4,5,6,7,8,9,10,11
    ) as sp
    left join (
        select
            case when 0 in ($dim) then '猫眼' 
            else 'all' end as ds,
            case when 1 in ($dim) then substr(dt,1,7) 
            else 'all' end mt,
            case when 2 in ($dim) then dt
            else 'all' end dt,
            'all' as pt,
            case when 4 in ($dim) then customer_type_name
            else 'all' end customer_type_name,
            case when 5 in ($dim) then customer_lvl1_name
            else 'all' end customer_lvl1_name,
            case when 6 in ($dim) then category_name
            else 'all' end category_name,
            case when 7 in ($dim) then area_1_level_name
            else 'all' end area_1_level_name,
            case when 8 in ($dim) then area_2_level_name
            else 'all' end area_2_level_name,
            case when 9 in ($dim) then province_name
            else 'all' end province_name,
            case when 10 in ($dim) then city_name
            else 'all' end city_name,
            count(distinct spo.performance_id) as ap_num
        from (
            select distinct
                partition_date as dt,
                customer_id,
                performance_id
            from mart_movie.detail_myshow_salesplan where salesplan_id is not null and partition_date>='$$begindate' and partition_date<'$$enddate'
            ) spo
            left join (
            select performance_id, activity_id, performance_name, category_id, category_name, area_1_level_name, area_2_level_name, province_name, province_id, city_id, city_name, shop_id, shop_name from mart_movie.dim_myshow_performance where performance_id is not null
            ) per
            on spo.performance_id=per.performance_id
            left join (
            select customer_id, customer_type_id, customer_type_name, customer_lvl1_name, customer_name, customer_shortname, customer_code from mart_movie.dim_myshow_customer where customer_id is not null
            ) cus
            on cus.customer_id=spo.customer_id
        where
            0 in ($ds)
        group by
            1,2,3,4,5,6,7,8,9,10,11
        ) ss
    on sp.ds=ss.ds
    and sp.mt=ss.mt
    and sp.dt=ss.dt
    and sp.pt=ss.pt
    and sp.customer_type_name=ss.customer_type_name
    and sp.customer_lvl1_name=ss.customer_lvl1_name
    and sp.category_name=ss.category_name
    and sp.area_1_level_name=ss.area_1_level_name
    and sp.area_2_level_name=ss.area_2_level_name
    and sp.province_name=ss.province_name
    and sp.city_name=ss.city_name
group by
    1,2,3,4,5,6,7,8,9,10,11
;
