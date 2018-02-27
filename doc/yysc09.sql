
select
    dt,
    fromtag,
    performance_name,
    fpw.performance_id,
    uv,
    pv
from (
    select
        partition_date as dt,
        case when regexp_like(url_parameters,'[Ff]romTag=') then split_part(regexp_extract(url_parameters,'[Ff]romTag=[^&]+'),'=',2)
        when regexp_like(substr(url,40,40),'fromTag%3D') then split_part(regexp_extract(substr(url,40,40),'fromTag%3D[^%]+'),'%3D',2)
        when regexp_like(substr(url,40,40),'from=') then split_part(regexp_extract(substr(url,40,40),'from=[^&]+'),'=',2)
        else 'other'
        end as fromtag,
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
