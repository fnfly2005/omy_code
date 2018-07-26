
select
    '$$today{-1d}' as dt,
    lv1_type,
    sum(case when dt='$$today{-1d}' then totalprice end) as totalprice,
    sum(totalprice) as mtd_totalprice,
    sum(case when dt='$$today{-1d}' then order_num end) as order_num,
    sum(case when dt='$$today{-1d}' then ticket_num end) as ticket_num
from (
    select
        substr(pay_time,1,10) dt,
        'y' as type,
        '团购' as lv1_type,
        sum(purchase_price) as totalprice,
        count(distinct order_id) as order_num,
        sum(quantity) as ticket_num
    from
        mart_movie.detail_maoyan_order_sale_cost_new_info
    where
        pay_time is not null
        and pay_time>='$$yesterday_monthfirst'
        and pay_time<'$$today{-0d}'
        and deal_id in (
            select
                mydealid
            from
                origindb.dp_myshow__s_deal
                )
    group by
        1,2,3
    union all
    select
        dt,
        key1 as type,
        value4 as lv1_type,
        sum(totalprice) as totalprice,
        sum(order_num) as order_num,
        sum(ticket_num) as ticket_num
    from (
        select
            substr(pay_time,1,10) as dt,
            sellchannel,
            sum(totalprice) as totalprice,
            count(distinct order_id) as order_num,
            sum(setnumber*salesplan_count) as ticket_num
        from
            mart_movie.detail_myshow_saleorder
        where
            pay_time is not null
            and pay_time>='$$yesterday_monthfirst'
            and pay_time<'$$today{-0d}'
        group by
            1,2
        ) so
        left join (
            select key_name, key, key1, key2, value1, value2, value3, value4 from upload_table.myshow_dictionary_s where key_name is not null
            and key_name='sellchannel'
            ) md
        on so.sellchannel=md.key
    group by
        1,2,3
    union all
    select
        dt,
        'y' as type,
        '线下分销' as lv1_type,
        sum(totalprice) as totalprice,
        count(distinct sale_id) as order_num,
        sum(ticket_num) as ticket_num
    from
        upload_table.sale_offline
    where
        dt is not null
        and dt>='$$yesterday_monthfirst'
        and dt<'$$today{-0d}'
    group by
        1,2,3
    ) as sot
where
    type='y'
group by
    1,2
;
