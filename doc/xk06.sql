
select
    '$$today{-1d}' as dt,
    biz_bg_name,
    page_intention,
    page_name_my,
    cid_type,
    mp.page_identifier,
    page_cat,
    biz_bg,
    biz_par,
    sum(uv) as uv,
    sum(custom_uv) as custom_uv
from (
    select biz_bg_name, page_intention, page_name_my, cid_type, page_identifier, page_cat, biz_bg, biz_par from mart_movie.dim_myshow_pv where status=1
    ) mp
    left join (
        select 
            page_identifier,
            app_name,
            approx_distinct(union_id) uv,
            approx_distinct(case when page_name_my='演出详情页' and performance_id is not null then union_id end) custom_uv
        from mart_movie.detail_myshow_pv_wide_report where partition_date>='$$today{-1d}' and partition_date<'$$today{-0d}'
        group by
            1,2
        ) as fpw
    on mp.page_identifier=fpw.page_identifier
group by
    1,2,3,4,5,6,7,8,9
;
