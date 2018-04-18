
select
    case when '$dt'=0 then '累计' 
    else spo.dt end as dt,
    case when '$pt'=0 then '全部'
    else md.value2 end as pt,
    cus.customer_type_name,
    cus.customer_lvl1_name,
    per.area_1_level_name,
    per.area_2_level_name,
    per.province_name,
    per.city_name,
    per.category_name,
    per.shop_name,
    per.performance_name,
    count(distinct spo.order_id) as order_num,
    sum(spo.salesplan_count*spo.setnumber) as ticket_num,
    sum(spo.TotalPrice) as TotalPrice,
    sum(spo.grossprofit) as grossprofit
from (
        select partition_date as dt, order_id, sellchannel, customer_id, performance_id, meituan_userid, show_id, totalprice, grossprofit, setnumber, salesplan_count, expressfee, discountamount, income, expense, totalticketprice, ticket_price, sell_price, project_id, bill_id, salesplan_id, city_id, pay_time from mart_movie.detail_myshow_salepayorder where partition_date>='$$begindate' and partition_date<'$$enddate'
        ) as spo
    join (
        select performance_id, activity_id, performance_name, category_id, category_name, area_1_level_name, area_2_level_name, province_name, city_id, city_name, shop_name from mart_movie.dim_myshow_performance where performance_id is not null
        and (performance_name like '%$name%'
        or '测试'='$name')
        and (performance_id in ($id)
            or -99 in ($id)
        ) per
        on spo.performance_id=per.performance_id
    left join (
        select customer_id, customer_type_id, customer_type_name, customer_lvl1_name, customer_name, customer_shortname, customer_code from mart_movie.dim_myshow_customer where customer_id is not null
        ) cus
        on spo.customer_id=cus.customer_id
    left join (
        select key, value1, value2, value3 from upload_table.myshow_dictionary where key_name is not null
        and key_name='sellchannel'
        ) md
        on md.key=spo.sellchannel
group by
    1,2,3,4,5,6,7,8,9,10,11
;
