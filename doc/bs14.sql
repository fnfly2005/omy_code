
select
    substr(ss1.dt,1,7) as mt,
    avg(ss1.ap_num) as ap_num,
    avg(ss1.as_num) as as_num,
    avg(sp1.sp_num) as sp_num,
    avg(sp1.ss_num) as ss_num,
    sum(sp1.order_num) as order_num,
    sum(sp1.ticket_num) as ticket_num,
    sum(sp1.totalprice) as totalprice,
    sum(sp1.grossprofit) as grossprofit
from (
    select
        ss.dt,
        count(distinct ss.performance_id) as ap_num,
        count(distinct ss.salesplan_id) as as_num
    from
        (
        select partition_date as dt, performance_id, customer_id, shop_id, show_id, salesplan_sellout_flag, project_id, salesplan_id from mart_movie.detail_myshow_salesplan where salesplan_id is not null and partition_date>='$$today{-1d}' and partition_date<'$$today{-0d}'
        and salesplan_sellout_flag=0
        ) ss
    group by
        ss.dt
    ) as ss1
    left join (
    select
        spo.dt,
        count(distinct spo.performance_id) as sp_num,
        count(distinct spo.salesplan_id) as ss_num,
        count(distinct spo.order_id) as order_num,
        sum(spo.salesplan_count*spo.setnumber) as ticket_num,
        sum(spo.totalprice) as totalprice,
        sum(spo.grossprofit) as grossprofit
    from
        (
        select partition_date as dt, order_id, sellchannel, customer_id, performance_id, meituan_userid, show_id, totalprice, grossprofit, setnumber, salesplan_count, expressfee, project_id, bill_id, salesplan_id from mart_movie.detail_myshow_salepayorder where partition_date>='$$today{-1d}' and partition_date<'$$today{0d}'
        ) spo
    group by
        spo.dt
    ) as sp1
    on sp1.dt=ss1.dt
group by
    1
;
