
select
    case when 1 in ($dim) then substr(dt,1,7) 
    else 'all' end mt,
    case when 2 in ($dim) then dt
    else 'all' end dt,
    'maoyan' as ds,
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
    sum(order_num) as order_num,
    sum(totalprice) as totalprice,
    sum(ticket_num) as ticket_num,
    sum(grossprofit) as grossprofit
from (
    select
        partition_date as dt,
        sellchannel,
        customer_id,
        performance_id,
        count(distinct order_id) as order_num,
        sum(totalprice) as totalprice,
        sum(salesplan_count*setnumber) as ticket_num,
        sum(grossprofit) as grossprofit
    from mart_movie.detail_myshow_salepayorder where partition_date>='$$begindate' and partition_date<'$$enddate'
    group by
        1,2,3,4
        ) spo
    left join (
    select performance_id, activity_id, performance_name, category_id, category_name, area_1_level_name, area_2_level_name, province_name, city_id, city_name, shop_name from mart_movie.dim_myshow_performance where performance_id is not null
    ) per
    on spo.performance_id=per.performance_id
    left join (
    select customer_id, customer_type_id, customer_type_name, customer_lvl1_name, customer_name, customer_shortname, customer_code from mart_movie.dim_myshow_customer where customer_id is not null
    ) cus
    on cus.customer_id=spo.customer_id
    left join (
    select key, value1, value2, value3 from upload_table.myshow_dictionary where key_name is not null
    and key_name='sellchannel'
    ) md1
    on md1.key=spo.sellchannel
group by
    1,2,3,4,5,6,7,8,9,10,11
union all
select
    case when 1 in ($dim) then substr(dt,1,7) 
    else 'all' end mt,
    case when 2 in ($dim) then dt
    else 'all' end dt,
    'weige' as ds,
    case when 3 in ($dim) then value2 
    else 'all' end as pt,
    'all' customer_type_name,
    'all' customer_lvl1_name,
    case when 6 in ($dim) then type_lv1_name
    else 'all' end type_lv1_name,
    'all' area_1_level_name,
    'all' area_2_level_name,
    case when 9 in ($dim) then province_name
    else 'all' end province_name,
    case when 10 in ($dim) then city_name
    else 'all' end city_name,
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
    and (length(pay_no)>4
    or $pay=0)
    group by
        1,2,3
        ) wso
    left join (
    select item_id, item_no, title_cn, type_lv1_name, city_name, province_name, venue_name from upload_table.dim_wg_item
    ) wi
    on wso.item_id=wi.item_id
    left join (
    select key, value1, value2, value3 from upload_table.myshow_dictionary where key_name is not null
    and key_name='order_src'
    ) md2
    on wso.order_src=md2.key
group by
    1,2,3,4,5,6,7,8,9,10,11
;
