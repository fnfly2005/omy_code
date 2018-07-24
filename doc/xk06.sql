
select
    dt,
    mm.event_id,
    mm.page_identifier,
    page_name_my,
    event_name_lv1,
    event_name_lv2,
    user_int,
    mm.biz_par,
    biz_typ,
    page_loc,
    md1.value2 as biz_bg_v,
    cid_type,
    event_type,
    md2.value2 as user_int_v,
    biz_bg,
    page_cat,
    uv
from (
    select event_id, event_name_lv1, event_name_lv2, page_identifier, user_int, biz_par, biz_typ, page_loc from mart_movie.dim_myshow_mv where status=1
    ) mm
    left join (
        select page_identifier, page_name_my, cid_type, page_cat, biz_par, biz_bg from mart_movie.dim_myshow_pv where status=1
        ) mp
    on mp.page_identifier=mm.page_identifier
    left join (
        select key_name, key, key1, key2, value1, value2, value3, value4 from upload_table.myshow_dictionary_s where key_name is not null
        and key_name='biz_bg'
        ) md1
    on md1.key=mp.biz_bg
    left join (
        select key_name, key, key1, key2, value1, value2, value3, value4 from upload_table.myshow_dictionary_s where key_name is not null
        and key_name='user_int'
        ) md2
    on md2.key=mm.user_int
    left join (
        select 
            partition_date as dt,
            event_id,
            page_identifier,
            event_type,
            approx_distinct(union_id) uv
        from mart_flow.detail_flow_mv_wide_report where partition_date>='$$today{-1d}' and partition_date<'$$today{-0d}' and partition_log_channel='movie' and partition_etl_source='2_5x' and partition_app in ( 'movie', 'dianping_nova', 'other_app', 'dp_m', 'group' )
        group by
            1,2,3,4
        ) as fpw
    on mm.event_id=fpw.event_id
    and mm.page_identifier=fpw.page_identifier
order by
   12,15,16,17 desc
;
