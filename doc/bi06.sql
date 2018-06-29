
select
    mp.*,
    md.value2,
    page_id,
    uv
from (
    select page_identifier, page_name_my, cid_type, page_cat, biz_par, biz_bg from mart_movie.dim_myshow_pv where status=1
    ) mp
    left join (
        select key_name, key, key1, key2, value1, value2, value3, value4 from upload_table.myshow_dictionary_s where key_name is not null
        and key_name='page_cat'
        ) md
    on md.key=mp.page_cat
    left join (
        select 
            page_identifier,
            page_id,
            approx_distinct(union_id) uv
        from 
            mart_flow.detail_flow_pv_wide_report
        where
            partition_date>='$$today{-1d}'
            and partition_date<'$$today{-0d}'
            and partition_log_channel='movie'
            and partition_app in (
                'movie',
                'dianping_nova',
                'other_app',
                'dp_m',
                'group')
        group by
            1,2
        ) as fpw
    on mp.page_identifier=fpw.page_identifier
;
