
select
    per.performance_name,
    sp1.order_num,
    sp1.ticket_num,
    sp1.totalprice,
    sp1.grossprofit
from (
    select
        performance_id,
        order_num,
        ticket_num,
        totalprice,
        grossprofit,
        row_number() over (order by totalprice desc) as rank
    from (
        select
            performance_id, 
            count(distinct spo.order_id) as order_num,
            sum(spo.salesplan_count*spo.setnumber) as ticket_num,
            sum(spo.totalprice) as totalprice,
            sum(spo.grossprofit) as grossprofit
        from
            (
            select partition_date as dt, order_id, sellchannel, customer_id, performance_id, meituan_userid, show_id, totalprice, grossprofit, setnumber, salesplan_count, expressfee, project_id, bill_id, salesplan_id from mart_movie.detail_myshow_salepayorder where partition_date>='$$begindate' and partition_date<'$$enddate'
            and sellchannel=8
            ) spo
        group by
            performance_id
        ) as sp0
    ) as sp1
    left join (
    select performance_id, activity_id, performance_name, category_id, category_name, area_1_level_name, area_2_level_name, province_name, city_id, city_name, shop_name from mart_movie.dim_myshow_performance where performance_id is not null
    ) as per
    on per.performance_id=sp1.performance_id
where
    sp1.rank<=10
;
