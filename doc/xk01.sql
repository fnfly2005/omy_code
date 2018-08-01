
select
    sp1.mt,
    per.performance_name,
    sp1.order_num,
    sp1.ticket_num,
    sp1.totalprice,
    sp1.grossprofit,
    sp1.rank
from (
    select
        mt,
        performance_id,
        order_num,
        ticket_num,
        totalprice,
        grossprofit,
        row_number() over (partition by mt order by totalprice desc) as rank
    from (
        select
            substr(spo.dt,1,7) mt,
            performance_id, 
            count(distinct spo.order_id) as order_num,
            sum(ticket_num) as ticket_num,
            sum(spo.totalprice) as totalprice,
            sum(spo.grossprofit) as grossprofit
        from (
            select partition_date as dt, order_id, sellchannel, customer_id, performance_id, meituan_userid, show_id, totalprice, grossprofit, setnumber, salesplan_count, setnumber*salesplan_count as ticket_num, expressfee, discountamount, income, expense, totalticketprice, ticket_price, sell_price, project_id, bill_id, salesplan_id, city_id, pay_time, substr(pay_time,12,2) as ht from mart_movie.detail_myshow_salepayorder where partition_date>='$$monthfirst{-1m}' and partition_date<'$$monthfirst'
                and sellchannel not in (9,10,11)
            ) spo
        group by
            1,2
        ) as sp0
    ) as sp1
    left join (
    select performance_id, activity_id, performance_name, category_id, category_name, area_1_level_name, area_2_level_name, province_name, province_id, city_id, city_name, shop_id, shop_name from mart_movie.dim_myshow_performance where performance_id is not null
    ) as per
    on per.performance_id=sp1.performance_id
where
    sp1.rank<=30
;
