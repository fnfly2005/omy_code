
select
    dt,
    fromTag,
    performance_name,
    fpw.performance_id,
    uv,
    pv
from (
    select
        partition_date as dt,
        custom['fromTag'] as fromTag,
        case when app_name<>'maoyan_wxwallet_i'
                then custom['performance_id']
            else custom['id'] end as performance_id,
        approx_distinct(union_id) as uv,
        count(1) as pv
    from mart_flow.detail_flow_pv_wide_report
    where partition_date>='$$begindate'
        and partition_date<'$$enddate'
        and partition_log_channel='movie'
        and partition_app in (
        'movie',
        'dianping_nova',
        'other_app',
        'dp_m',
        'group'
        )
        and page_identifier in (
        select value
        from upload_table.myshow_pv
        where key='page_identifier'
        and name='演出详情页'
        and page<>'native'
        )
    group by
        1,2,3
    ) as fpw
    join (
        select performance_id, activity_id, performance_name, category_id, category_name, area_1_level_name, area_2_level_name, province_name, city_id, city_name, shop_name from mart_movie.dim_myshow_performance where performance_id is not null
        and performance_name like '%$name%'
        ) per
    on fpw.performance_id=per.performance_id
;
