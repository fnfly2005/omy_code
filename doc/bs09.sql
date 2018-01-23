select
    sp.partition_date,
    sp.customer_type_name,
    sp.category_name,
    sp.area_1_level_name,
    sp.province_name,
    sp.order_num,
    sp.totalprice,
    sp.sp_num,
    ap.ap_num
from
(select
    partition_date,
    coalesce(customer_type_name,'全部') as customer_type_name,
    coalesce(category_name,'全部') as category_name,
    coalesce(area_1_level_name,'全部') as area_1_level_name,
    coalesce(province_name,'全部') as province_name,
    order_num,
    totalprice,
    sp_num
from
(select
    partition_date,
    dc.customer_type_name,
    dp.category_name,
    dp.area_1_level_name,
    dp.province_name,
    count(distinct order_id) as order_num,
    sum(totalprice) as totalprice,
    count(distinct spo.performance_id) as sp_num
from
    (
    select partition_date, order_id, sellchannel, customer_id, performance_id, show_id, totalprice, grossprofit, setnumber, salesplan_count from mart_movie.detail_myshow_salepayorder where partition_date>='2017-10-01' and partition_date>='$time1' and partition_date<'$time2'
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
    dc.customer_type_name,
    dp.category_name,
    dp.area_1_level_name,
    dp.province_name
grouping sets(
partition_date,
(partition_date,dc.customer_type_name),
(partition_date,dp.category_name),
(partition_date,dp.area_1_level_name),
(partition_date,dp.province_name)
)) as t1 ) as sp
left join
(select
    partition_date,
    coalesce(customer_type_name,'全部') as customer_type_name,
    coalesce(category_name,'全部') as category_name,
    coalesce(area_1_level_name,'全部') as area_1_level_name,
    coalesce(province_name,'全部') as province_name,
    ap_num
from
    (
    select
        partition_date,
        dc.customer_type_name,
        dp.category_name,
        dp.area_1_level_name,
        dp.province_name,
        count(distinct ss.performance_id) as ap_num
    from
       (
       select partition_date, performance_id, customer_id, shop_id, show_id, salesplan_sellout_flag from mart_movie.detail_myshow_salesplan where salesplan_id is not null and partition_date>='$time1' and partition_date<'$time2'
       and salesplan_sellout_flag=0
       ) as ss
       left join
       (
       select performance_id, activity_id, performance_name, category_id, category_name, area_1_level_name, area_2_level_name, province_name, city_id, city_name, shop_name from mart_movie.dim_myshow_performance
       ) as dp
       on dp.performance_id=ss.performance_id
       left join 
       (
       select customer_id, case when customer_type_id=1 then customer_shortname else customer_type_name end customer_lvl0_name, customer_type_id, customer_type_name, customer_lvl1_name from mart_movie.dim_myshow_customer where customer_id is not null
       ) as dc
       on ss.customer_id=dc.customer_id
    group by
        partition_date,
        dc.customer_type_name,
        dp.category_name,
        dp.area_1_level_name,
        dp.province_name
    grouping sets(
    partition_date,
    (partition_date,dc.customer_type_name),
    (partition_date,dp.category_name),
    (partition_date,dp.area_1_level_name),
    (partition_date,dp.province_name)
    )
    ) as t2
    ) as ap
    on sp.partition_date=ap.partition_date
    and sp.customer_type_name=ap.customer_type_name
    and sp.category_name=ap.category_name
    and sp.area_1_level_name=ap.area_1_level_name
    and sp.province_name=ap.province_name
;
select
    s1.partition_date,
    s1.value2,
    order_num,
    totalprice,
    sp_num,
    uv,
    pv
from
(select
    partition_date,
    value2,
    count(distinct order_id) as order_num,
    sum(totalprice) as totalprice,
    count(distinct performance_id) as sp_num
from
    (
    select partition_date, order_id, sellchannel, customer_id, performance_id, show_id, totalprice, grossprofit, setnumber, salesplan_count from mart_movie.detail_myshow_salepayorder where partition_date>='2017-10-01' and partition_date>='$time1' and partition_date<'$time2'
    ) as spo
    left join
    (
    select key, value1, value2, value3 from upload_table.myshow_dictionary where key_name is not null
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
    select partition_date, order_id, sellchannel, customer_id, performance_id, show_id, totalprice, grossprofit, setnumber, salesplan_count from mart_movie.detail_myshow_salepayorder where partition_date>='2017-10-01' and partition_date>='$time1' and partition_date<'$time2'
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
    rank<=50
;
select
    s1.partition_date,
    s1.a_7num,
    s1.a_15num,
    s1.a_30num,
    s2.s_7num,
    s2.s_15num,
    s2.s_30num
from
    (select
        partition_date,
        count(distinct case when (date_diff('day',dt,date_parse(et,'%Y-%m-%d'))-1)<=7 then performance_id end) a_7num,
        count(distinct case when (date_diff('day',dt,date_parse(et,'%Y-%m-%d'))-1)<=15 then performance_id end) a_15num,
        count(distinct case when (date_diff('day',dt,date_parse(et,'%Y-%m-%d'))-1)<=30 then performance_id end) a_30num
    from
    (select
        ss.partition_date,
        date_parse(ss.partition_date,'%Y-%m-%d') as dt,
        ss.performance_id,
        ss.show_id,
        max(substr(ds.show_endtime,1,10)) as et
    from
        (
        select partition_date, performance_id, customer_id, shop_id, show_id, salesplan_sellout_flag from mart_movie.detail_myshow_salesplan where salesplan_id is not null and partition_date>='$time1' and partition_date<'$time2'
        and salesplan_sellout_flag=0
        ) as ss
        join
        (
        select show_id, performance_id, show_starttime, show_endtime from mart_movie.dim_myshow_show where show_id is not null
        ) as ds
        using(show_id)
    group by
        1,2,3,4) as s01
    where 
        date_diff('day',dt,date_parse(et,'%Y-%m-%d'))>0
    group by
        1) as s1
    left join
    (select
        partition_date,
        count(distinct case when date_diff('day',dt,date_parse(et,'%Y-%m-%d'))<=7 then performance_id end) s_7num,
        count(distinct case when date_diff('day',dt,date_parse(et,'%Y-%m-%d'))<=15 then performance_id end) s_15num,
        count(distinct case when date_diff('day',dt,date_parse(et,'%Y-%m-%d'))<=30 then performance_id end) s_30num
    from
    (select
        spo.partition_date,
        date_parse(spo.partition_date,'%Y-%m-%d') as dt,
        spo.performance_id,
        spo.show_id,
        max(substr(ds.show_endtime,1,10)) as et
    from
        (
        select partition_date, order_id, sellchannel, customer_id, performance_id, show_id, totalprice, grossprofit, setnumber, salesplan_count from mart_movie.detail_myshow_salepayorder where partition_date>='2017-10-01' and partition_date>='$time1' and partition_date<'$time2'
        ) as spo
        join
        (
        select show_id, performance_id, show_starttime, show_endtime from mart_movie.dim_myshow_show where show_id is not null
        ) as ds
       using(show_id)
    group by
        1,2,3,4) as s02
    group by
        1) as s2
    on s1.partition_date=s2.partition_date
;
select
    sp.partition_date,
    sp.customer_type_name,
    sp.category_name,
    sp.area_1_level_name,
    sp.province_name,
    sp.order_num,
    sp.totalprice,
    sp.sp_num,
    ap.ap_num
from
(select
    partition_date,
    coalesce(customer_type_name,'全部') as customer_type_name,
    coalesce(category_name,'全部') as category_name,
    coalesce(area_1_level_name,'全部') as area_1_level_name,
    coalesce(province_name,'全部') as province_name,
    order_num,
    totalprice,
    sp_num
from
(select
    partition_date,
    dc.customer_type_name,
    dp.category_name,
    dp.area_1_level_name,
    dp.province_name,
    count(distinct order_id) as order_num,
    sum(totalprice) as totalprice,
    count(distinct spo.performance_id) as sp_num
from
    (
    select partition_date, order_id, sellchannel, customer_id, performance_id, show_id, totalprice, grossprofit, setnumber, salesplan_count from mart_movie.detail_myshow_salepayorder where partition_date>='2017-10-01' and partition_date>='$time1' and partition_date<'$time2'
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
    dc.customer_type_name,
    dp.category_name,
    dp.area_1_level_name,
    dp.province_name
grouping sets(
partition_date,
(partition_date,dc.customer_type_name),
(partition_date,dp.category_name),
(partition_date,dp.area_1_level_name),
(partition_date,dp.province_name)
)) as t1 ) as sp
left join
(select
    partition_date,
    coalesce(customer_type_name,'全部') as customer_type_name,
    coalesce(category_name,'全部') as category_name,
    coalesce(area_1_level_name,'全部') as area_1_level_name,
    coalesce(province_name,'全部') as province_name,
    ap_num
from
    (
    select
        partition_date,
        '全部' as customer_type_name,
        dp.category_name,
        dp.area_1_level_name,
        dp.province_name,
        count(distinct dmp.performance_id) as ap_num
    from
       (
       select partition_date, performance_id from mart_movie.detail_myshow_performance_performancesnapshotid where ticketstatus in (2,3) and editstatus=1 and partition_date>='2017-12-04' and partition_date<'2017-12-20'
       ) as dmp
       left join
       (
       select performance_id, activity_id, performance_name, category_id, category_name, area_1_level_name, area_2_level_name, province_name, city_id, city_name, shop_name from mart_movie.dim_myshow_performance
       ) as dp
       on dp.performance_id=dmp.performance_id
    group by
        partition_date,
        '全部',
        dp.category_name,
        dp.area_1_level_name,
        dp.province_name
    grouping sets(
    partition_date,
    (partition_date,'全部'),
    (partition_date,dp.category_name),
    (partition_date,dp.area_1_level_name),
    (partition_date,dp.province_name)
    )
    ) as t2
    ) as ap
    on sp.partition_date=ap.partition_date
    and sp.customer_type_name=ap.customer_type_name
    and sp.category_name=ap.category_name
    and sp.area_1_level_name=ap.area_1_level_name
    and sp.province_name=ap.province_name
;

select
    partition_date,
    '微信钱包' as plat,
    new_page_name,
    sum(uv) as uv
from
    (
    select partition_date, new_page_name, pv, uv from mart_movie.aggr_myshow_pv_all where new_app_name='微信演出赛事' and partition_date>='$time1' and partition_date<'$time2'
    and new_page_name in ('演出首页','演出详情页','演出确认订单页')
    ) apa
group by
    1,2,3
union all
select
    partition_date,
    '全部' as plat,
    new_page_name,
    sum(uv) as uv
from
    (
    select partition_date, new_page_name, pv, uv from mart_movie.aggr_myshow_pv_page where partition_date>='$time1' and partition_date<'$time2'
    and new_page_name in ('演出首页','演出详情页','演出确认订单页')
    ) app
group by
    1,2,3
;
