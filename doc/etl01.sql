
select
    partition_date,
    biz_bg,
    dmp.page_identifier,
    page_name_my,
    page_cat,
    case when cid_type='h5' then custom['fromTag']
    when cid_type in ('mini_programs','pc') then utm_source
    end as uv_src,
    case when biz_bg=1 and page_cat in (2,3)
        then case when cid_type='h5' then custom['performance_id']
            when cid_type='mini_programs' then custom['id']
            when cid_type='native' then custom['drama_id'] end
    end as performance_id,
    app_name,
    union_id,
    uuid,
    session_id,
    user_id,
    imei,
    idfa,
    stat_time,
    refer_page_identifier,
    custom,
    os,
    page_city_id,
    page_city_name,
    ip_location_city_id,
    ip_location_city_name
from (
    select page_identifier, page_name_my, cid_type, page_cat, biz_par, biz_bg from mart_movie.dim_myshow_pv where status=1
    ) dmp
    join mart_flow.detail_flow_pv_wide_report fpw
    on dmp.page_identifier=fpw.page_identifier
    and partition_date='$$today{-1d}'
    and partition_log_channel='movie'
    and partition_app in ('movie', 'dianping_nova', 'other_app', 'dp_m', 'group')
;
