
select
    sp1.dt,
    per.performance_name,
    sp1.order_num,
    sp1.ticket_num,
    sp1.totalprice,
    sp1.grossprofit,
    fpw.uv
from (
    select
        dt,
        performance_id,
        order_num,
        ticket_num,
        totalprice,
        grossprofit,
        row_number() over (partition by dt order by totalprice desc) as rank
    from (
        select
            spo.dt,
            performance_id, 
            count(distinct spo.order_id) as order_num,
            sum(spo.salesplan_count*spo.setnumber) as ticket_num,
            sum(spo.totalprice) as totalprice,
            sum(spo.grossprofit) as grossprofit
        from
            (
            select partition_date as dt, order_id, sellchannel, customer_id, performance_id, meituan_userid, show_id, totalprice, grossprofit, setnumber, salesplan_count, expressfee, project_id, bill_id, salesplan_id from mart_movie.detail_myshow_salepayorder where partition_date>='$time1' and partition_date<'$time2'
            ) spo
        group by
            spo.dt,
            performance_id
        ) as sp0
    ) as sp1
    left join (
    select
        partition_date as dt,
        custom['performance_id'] as performance_id,
        count(distinct union_id) as uv
    from
        mart_flow.detail_flow_pv_wide_report
    where partition_date=''
        and partition_log_channel='movie'
        and partition_app in (
        select key
        from upload_table.myshow_dictionary
        where key_name='partition_app'
        )
        and page_identifier in (
        select value
        from upload_table.myshow_pv
        where key='page_identifier'
        and nav_flag=2
        and page_tag1=0
        )
    group by
        partition_date,
        custom['performance_id'] 
    ) as fpw
    on sp1.dt=fpw.dt 
    and sp1.performance_id=fpw.performance_id
    left join (
    select performance_id, activity_id, performance_name, category_id, category_name, area_1_level_name, area_2_level_name, province_name, city_id, city_name, shop_name from mart_movie.dim_myshow_performance where performance_id is not null
    ) as per
    on per.performance_id=sp1.performance_id
where
    sp1.rank<=10
;
