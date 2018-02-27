
select
    sp1.dt, 
    sp1.plat,
    per.area_1_level_name,
    per.area_2_level_name,
    per.province_name,
    per.city_name,
    per.category_name,
    per.shop_name,
    per.performance_id,
    per.performance_name,
    fpw.uv,
    sp1.order_num,
    sp1.ticket_num,
    sp1.totalprice,
    sp1.grossprofit
from (
    select
        spo.dt,
        case when sellchannel<>8 then 'other'
            else 'gewara'
        end as plat,
        performance_id,
        count(distinct spo.order_id) as order_num,
        sum(spo.salesplan_count*spo.setnumber) as ticket_num,
        sum(spo.totalprice) as totalprice,
        sum(spo.grossprofit) as grossprofit
    from
        (
        select partition_date as dt, order_id, sellchannel, customer_id, performance_id, meituan_userid, show_id, totalprice, grossprofit, setnumber, salesplan_count, expressfee, project_id, bill_id, salesplan_id from mart_movie.detail_myshow_salepayorder where partition_date>='$$begindate' and partition_date<'$$enddate'
        ) spo
    group by
        1,2
    ) as sp1
    left join (
    select performance_id, activity_id, performance_name, category_id, category_name, area_1_level_name, area_2_level_name, province_name, city_id, city_name, shop_name from mart_movie.dim_myshow_performance where performance_id is not null
    ) as per
    on per.performance_id=sp1.performance_id
    left join (
        select
            partition_date as dt,
            'other' as plat,
            case when app_name='maoyan_wxwallet_i' then custom['id'] 
            else custom['performance_id'] end as performance_id,
            approx_distinct(union_id) as uv
        from mart_flow.detail_flow_pv_wide_report
        where partition_date>='$$begindate'
            and partition_date<'$$enddate'
            and partition_log_channel='movie'
            and partition_app in (
            'movie','dianping_nova','other_app','dp_m','group'
            )
            and app_name<>'gewara'
            and page_identifier in (
            select value
            from upload_table.myshow_pv
            where key='page_identifier'
            and nav_flag=2
            and page in ('h5','mini_programs')
            )
        group by
            1,2,3
        ) as fpw
    on sp1.dt=fpw.dt
    and sp1.performance_id=fpw.performance_id
    and sp1.plat=fpw.plat
;
