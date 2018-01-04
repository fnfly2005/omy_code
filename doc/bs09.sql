
select
    sp.partition_date,
    sp.customer_type_name,
    sp.order_num,
    sp.totalprice,
    sp.sp_num,
    ap.ap_num
from
(select
    partition_date,
    coalesce(customer_type_name,'全部') as customer_type_name,
    order_num,
    totalprice,
    sp_num
from
(select
    partition_date,
    customer_type_name,
    count(distinct order_id) as order_num,
    sum(totalprice) as totalprice,
    count(distinct spo.performance_id) as sp_num
from
    (
    select partition_date, order_id, sellchannel, customer_id, performance_id, totalprice, grossprofit from mart_movie.detail_myshow_salepayorder where partition_date>='2017-10-01' and partition_date>='$time1' and partition_date<'$time2'
    ) as spo
    left join
    (
    select performance_id, activity_id, performance_name, category_id, category_name, area_1_level_name, area_2_level_name, province_name, city_id, city_name, shop_name from mart_movie.dim_myshow_performance
    ) as dp
    on dp.performance_id=spo.performance_id
    left join
    (
    select customer_id, case when customer_type_id=1 then customer_shortname else customer_type_name end customer_lvl0_name, customer_type_id, customer_type_name, customer_lvl1_name from mart_movie.dim_myshow_customer where customer_id is not null
    ) as dc
    on dc.customer_id=spo.customer_id
group by
    partition_date,
    customer_type_name
grouping sets(
partition_date,
(partition_date,customer_type_name)
)) as t1 ) as sp
left join
(select
    partition_date,
    coalesce(customer_type_name,'全部') as customer_type_name,
    ap_num
from
    (
    select
        partition_date,
        customer_type_name,
        count(distinct dss.performance_id) as ap_num
    from
       (
       select partition_date, performance_id, customer_id, salesplan_sellout_flag from mart_movie.detail_myshow_salesplan where salesplan_id is not null and partition_date>='$time1' and partition_date<'$time2'
       and salesplan_sellout_flag=0
       ) as dss
       left join 
       (
       select customer_id, case when customer_type_id=1 then customer_shortname else customer_type_name end customer_lvl0_name, customer_type_id, customer_type_name, customer_lvl1_name from mart_movie.dim_myshow_customer where customer_id is not null
       ) as dc
       on dss.customer_id=dc.customer_id
    group by
        partition_date,
        customer_type_name
    grouping sets(
    partition_date,
    (partition_date,customer_type_name))
    ) as t2
    ) as ap
    on sp.partition_date=ap.partition_date
    and sp.customer_type_name=ap.customer_type_name
;

select
    s1.partition_date,
    s1.value2,
    order_num,
    totalprice,
    uv,
    pv
from
(select
    partition_date,
    value2,
    count(distinct order_id) as order_num,
    sum(totalprice) as totalprice
from
    (
    select partition_date, order_id, sellchannel, customer_id, performance_id, totalprice, grossprofit from mart_movie.detail_myshow_salepayorder where partition_date>='2017-10-01' and partition_date>='$time1' and partition_date<'$time2'
    ) as spo
    left join
    (
    select key, value1, value2, value3 from upload_table.dictionary003 where key_name is not null
    and key_name='sellchannel'
    ) as md
    on md.key=spo.sellchannel
group by
    1,2) as s1
left join
    (
    select partition_date, case new_app_name when '微信演出赛事' then '微信钱包' when '微信吃喝玩乐' then '微信点评' when '未知' then '其他' else new_app_name end as new_app_name, sum(uv) as uv, sum(pv) as pv from mart_movie.aggr_myshow_pv_platform where partition_date>='$time1' and partition_date<'$time2' group by 1, 2
    ) as amp
    on s1.partition_date=amp.partition_date
    and s1.value2=amp.new_app_name
;

select
    partition_date,
    performance_name,
    order_num,
    totalprice,
    rank
from
(select
    partition_date,
    performance_name,
    order_num,
    totalprice,
    row_number() over (partition by partition_date order by totalprice desc) as rank 
from
(select
    partition_date,
    performance_name,
    count(distinct order_id) as order_num,
    sum(totalprice) as totalprice
from
    (
    select partition_date, order_id, sellchannel, customer_id, performance_id, totalprice, grossprofit from mart_movie.detail_myshow_salepayorder where partition_date>='2017-10-01' and partition_date>='$time1' and partition_date<'$time2'
    ) as spo
    left join
    (
    select performance_id, activity_id, performance_name, category_id, category_name, area_1_level_name, area_2_level_name, province_name, city_id, city_name, shop_name from mart_movie.dim_myshow_performance
    ) as dp
    on dp.performance_id=spo.performance_id
group by
    1,2
    ) as s1) as s2
where
    rank<=10
;
