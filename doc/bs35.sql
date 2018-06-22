
select
    case when 1 in ($dim) then substr(fpw.dt,1,7)
    else 'all' end as mt, 
    case when 2 in ($dim) then fpw.dt
    else 'all' end as dt, 
    case when 3 in ($dim) then fpw.pt
    else 'all' end as pt,
    case when 4 in ($dim) then per.area_1_level_name
    else 'all' end as area_1_level_name,
    case when 5 in ($dim) then per.area_2_level_name
    else 'all' end as area_2_level_name,
    case when 6 in ($dim) then per.province_name
    else 'all' end as province_name,
    case when 7 in ($dim) then per.city_name
    else 'all' end as city_name,
    case when 8 in ($dim) then per.category_name
    else 'all' end as category_name,
    case when 9 in ($dim) then per.shop_name
    else 'all' end as shop_name,
    count(distinct per.performance_id) as p_num
from (
    select distinct
        dt,
        value2 as pt,
        performance_id
    from (
        select distinct
            partition_date as dt,
            app_name,
            case when page_identifier in (
                'pages/show/detail/index',
                'packages/show/pages/detail/index')
                then custom['id'] 
            when page_identifier='c_b5okwrne'
                then custom['dramaId']
            else custom['performance_id'] end as performance_id
        from mart_flow.detail_flow_pv_wide_report
        where partition_date>='$$begindate'
            and partition_date<'$$enddate'
            and partition_log_channel='movie'
            and partition_app in (
                'movie','dianping_nova','other_app','dp_m','group'
                )
            and page_identifier in (
                'c_b5okwrne',
                'packages/show/pages/detail/index',
                'pages/show/detail/index',
                'c_Q7wY4'
                )
        ) as fp1
        left join (
            select key_name, key, key1, key2, value1, value2, value3, value4 from upload_table.myshow_dictionary_s where key_name is not null
            and key_name='app_name'
            ) md
        on md.key=fp1.app_name
    where
        performance_id is not null
        and performance_id>0
    ) as fpw
    join (
        select
            partition_date as dt,
            performance_id
        from mart_movie.detail_myshow_salesplan where salesplan_id is not null and partition_date>='$$begindate' and partition_date<'$$enddate'
        and salesplan_sellout_flag=0
        ) ss
    on ss.dt=fpw.dt
    and ss.performance_id=fpw.performance_id
    left join (
        select performance_id, activity_id, performance_name, category_id, category_name, area_1_level_name, area_2_level_name, province_name, city_id, city_name, shop_name from mart_movie.dim_myshow_performance where performance_id is not null
        ) as per
    on per.performance_id=fpw.performance_id
group by
    1,2,3,4,5,6,7,8,9
;
