
select
    '$$today{-1d}' dt,
    page_name_my,
    event_name_lv1,
    event_name_lv2,
    mm.event_id,
    mm.biz_par,
    mm.biz_typ,
    cid_type,
    mm.page_identifier,
    user_intention,
    user_int,
    page_loc,
    event_type,
    uv
from (
    select page_name_my, event_name_lv1, event_name_lv2, event_id, biz_par, biz_typ, cid_type, page_identifier, user_intention, user_int, page_loc, operation_flag from mart_movie.dim_myshow_mv where status=1
    ) mm
    left join (
        select 
            event_id,
            page_identifier,
            event_type,
            approx_distinct(union_id) uv
        from mart_flow.detail_flow_mv_wide_report where partition_date>='$$today{-1d}' and partition_date<'$$today{-0d}' and partition_log_channel='movie' and partition_app in ( 'movie', 'dianping_nova', 'other_app', 'dp_m', 'group' )
        group by
            1,2,3
        ) as fpw
    on mm.event_id=fpw.event_id
    and mm.page_identifier=fpw.page_identifier
;
