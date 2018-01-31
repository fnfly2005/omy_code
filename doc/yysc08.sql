
select
    vp.dt,
    vp.ht,
    dp.city_name,
    dp.performance_name,
    vp.uv,
    case when sp.performance_id is null then 0
    else sp.order_num end as order_num,
    case when sp.performance_id is null then 0
    else sp.ticket_num end as ticket_num, 
    case when sp.performance_id is null then 0
    else sp.totalprice end as totalprice,
    case when sp.performance_id is null then 0
    else sp.grossprofit end as grossprofit
from
    (select
        dt,
        ht,
        custom['performance_id'] as performance_id,
        approx_distinct(union_id) as uv
    from
        (
        select partition_date as dt, substr(stat_time,12,2) as ht, custom, union_id from mart_flow.detail_flow_pv_wide_report where partition_date>='$time1' and partition_date<'$time2' and partition_log_channel='movie' and partition_app in ( select key from upload_table.myshow_dictionary where key_name='partition_app' ) and page_identifier in ( select value from upload_table.myshow_pv where key='page_identifier' and page_tag1>=0 )
        and page_identifier in (
        select value from upload_table.myshow_pv where key='page_identifier'
        and name='演出详情页'
        )
        ) fp
    group by
        1,2,3
    ) vp
    left join 
    (select
        spo.dt,
        spo.ht,
        spo.performance_id,
        count(distinct spo.order_id) order_num,
        sum(spo.salesplan_count*spo.setnumber) ticket_num,
        sum(spo.totalprice) totalprice,
        sum(spo.grossprofit) grossprofit
    from
        (
        select partition_date as dt, order_id, sellchannel, customer_id, performance_id, meituan_userid, show_id, totalprice, grossprofit, setnumber, salesplan_count, expressfee, project_id, bill_id, substr(pay_time,12,2) as ht from mart_movie.detail_myshow_salepayorder where partition_date>='$time1' and partition_date<'$time2'
        ) as spo
    group by
        1,2,3
        ) as sp
    on sp.performance_id=vp.performance_id
    and vp.performance_id is not null
    and sp.dt=vp.dt
    and sp.ht=vp.ht
    left join 
    (
    select performance_id, activity_id, performance_name, category_id, category_name, area_1_level_name, area_2_level_name, province_name, city_id, city_name, shop_name from mart_movie.dim_myshow_performance where performance_id is not null
    ) as dp
    on vp.performance_id=dp.performance_id
where
    dp.performance_name like '%$performance_name%'
;
