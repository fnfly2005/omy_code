
select
    so.dt,
    totalprice,
    order_num,
    sku_num,
    uv,
    user_num,
    dea_num,
    rehi_totalprice,
    rehi_order_num
from (
    select 
        cni.dt,
        cni.totalprice,
		cni.order_num,
		cni.sku_num,
		cni.user_num,
		cni.dea_num,
		oni.rehi_totalprice,
		oni.rehi_order_num
    from (
        select
            substr(pay_time,1,10) dt,
            sum(purchase_price) as totalprice,
            count(distinct order_id) as order_num,
            sum(quantity) as sku_num,
            count(distinct user_id) as user_num,
            count(distinct deal_id) as dea_num
        from
            mart_movie.detail_maoyan_order_sale_cost_new_info
        where
            pay_time is not null
            and pay_time>='$$begindate'
            and pay_time<'$$enddate'
            and deal_id in (
                select
                    deal_id
                from
                    mart_movie.dim_deal_new
                where
                    category=12
                    )
        group by
            1
        ) cni
        left join (
            select
                dt,
                count(distinct order_id) as rehi_order_num,
                sum(totalprice) as rehi_totalprice
            from (
                select
                    substr(modified,1,10) dt,
                    order_id,
                    total_money/100 totalprice
                from
                    mart_movie.detail_maoyan_order_new_info
                where
                    pay_time is not null
                    and category=12
                    and yn=0
                    and modified>='$$begindate'
                    and modified<'$$enddate'
                    and pay_time<'$$begindate'
                ) on1
            group by
                1
            ) oni
        on oni.dt=cni.dt
    ) as so
    left join (
        select
            partition_date as dt,
            approx_distinct(union_id) as uv
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
            and page_identifier='c_dqihv0si'
        group by
            1
        ) as fpw
    on fpw.dt=so.dt
;
