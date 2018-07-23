
select
    ss1.dt,
    ss1.ap_num,
    ss1.as_num,
    sp1.sp_num,
    sp1.order_num,
    sp1.ticket_num,
    sp1.totalprice,
    sp1.grossprofit,
    fpw.uv
from (
    select
        ss.dt,
        count(distinct ss.performance_id) as ap_num,
        count(distinct ss.salesplan_id) as as_num
    from
        (
        select partition_date as dt, performance_id, customer_type_id, customer_id, shop_id, show_id, salesplan_sellout_flag, project_id, salesplan_id, ticketclass_id, city_id from mart_movie.detail_myshow_salesplan where salesplan_id is not null and partition_date>='$$today{-1d}' and partition_date<'$$today{-0d}'
        and salesplan_sellout_flag=0
        ) ss
    group by
        ss.dt
    ) as ss1
    left join (
    select
        spo.dt,
        count(distinct spo.performance_id) as sp_num,
        count(distinct spo.order_id) as order_num,
        sum(spo.salesplan_count*spo.setnumber) as ticket_num,
        sum(spo.totalprice) as totalprice,
        sum(spo.grossprofit) as grossprofit
    from (
        select partition_date as dt, order_id, sellchannel, customer_id, performance_id, meituan_userid, show_id, totalprice, grossprofit, setnumber, salesplan_count, setnumber*salesplan_count as ticket_num, expressfee, discountamount, income, expense, totalticketprice, ticket_price, sell_price, project_id, bill_id, salesplan_id, city_id, pay_time, substr(pay_time,12,2) as ht from mart_movie.detail_myshow_salepayorder where partition_date>='$$today{-1d}' and partition_date<'$$today{-0d}'
            and sellchannel not in (9,10,11)
        ) spo
    group by
        spo.dt
    ) as sp1
    on sp1.dt=ss1.dt
    left join (
        select
            partition_date as dt,
            count(distinct union_id) as uv
        from mart_movie.detail_myshow_pv_wide_report where partition_date>='$$today{-1d}' and partition_date<'$$today{-0d}' and partition_biz_bg=1
        group by
            1
        ) as fpw
    on ss1.dt=fpw.dt
;
