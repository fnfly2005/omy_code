
select
    fp1.dt,
    fp1.pt,
    fp1.first_uv,
    fp1.detail_uv,
    fp1.order_uv,
    sp1.order_num
from (
    select
        dt,
        md.value2 as pt,
        sum(fp0.first_uv) as first_uv,
        sum(fp0.detail_uv) as detail_uv,
        sum(fp0.order_uv) as order_uv
    from (
        select
            partition_date as dt,
            app_name,
            count(distinct case when page_name_my='演出首页' then union_id end) as first_uv,
            count(distinct case when page_name_my='演出详情页' then union_id end) as detail_uv,
            count(distinct case when page_name_my='演出确认订单页' then union_id end) as order_uv
        from mart_movie.detail_myshow_pv_wide_report where partition_date>='$$today{-1d}' and partition_date<'$$today{-0d}' and partition_biz_bg=1
            and page_name_my in ('演出首页','演出详情页','演出确认订单页')
        group by
            partition_date,
            app_name
        ) as fp0
        join (
            select key_name, key, key1, key2, value1, value2, value3, value4 from upload_table.myshow_dictionary_s where 1=1
            and key_name='app_name'
            ) md
        on fp0.app_name=md.key
    group by
        dt,
        value2
    ) as fp1
    left join (
    select
        sp0.dt,
        md.value2 as pt,
        sum(sp0.order_num) as order_num
    from (
        select
            partition_date as dt,
            sellchannel,
            count(distinct order_id) as order_num
        from mart_movie.detail_myshow_salepayorder where partition_date>='$$today{-1d}' and partition_date<'$$today{-0d}'
        group by
            partition_date,
            sellchannel
        ) as sp0
        join (
            select key_name, key, key1, key2, value1, value2, value3, value4 from upload_table.myshow_dictionary_s where 1=1
            and key_name='sellchannel'
            and key1=1
            ) as md
        on sp0.sellchannel=md.key
    group by
        sp0.dt,
        md.value2
    ) as sp1
    on sp1.dt=fp1.dt
    and sp1.pt=fp1.pt
;
