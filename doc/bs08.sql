
select
    substr(sp1.dt,1,7) as mt,
    sp1.customer_type_name,
    sp1.customer_lvl1_name,
    sum(order_num) as order_num,
    sum(totalprice) as totalprice,
    avg(sp_num) as sp_num,
    sum(grossprofit) as grossprofit,
    sum(ticket_num) as ticket_num,
    avg(ap_num) as ap_num
from (
    select
        dt,
        customer_type_name,
        customer_lvl1_name,
        count(distinct order_id) as order_num,
        sum(totalprice) as totalprice,
        count(distinct performance_id) as sp_num,
        sum(grossprofit) as grossprofit,
        sum(salesplan_count*setnumber) as ticket_num
    from
        (
        select partition_date as dt, order_id, sellchannel, customer_id, performance_id, meituan_userid, show_id, totalprice, grossprofit, setnumber, salesplan_count, expressfee, project_id, bill_id, salesplan_id from mart_movie.detail_myshow_salepayorder where partition_date>='$$begindate' and partition_date<'$$enddate'
        ) as spo
        left join 
        (
        select customer_id, customer_type_id, customer_type_name, customer_lvl1_name, customer_name, customer_code from mart_movie.dim_myshow_customer where customer_id is not null
        ) as cus
        using(customer_id)
    group by
        1,2,3
    union all
    select
        dt,
        customer_type_name,
        'all' as customer_lvl1_name,
        count(distinct order_id) as order_num,
        sum(totalprice) as totalprice,
        count(distinct performance_id) as sp_num,
        sum(grossprofit) as grossprofit,
        sum(salesplan_count*setnumber) as ticket_num
    from
        (
        select partition_date as dt, order_id, sellchannel, customer_id, performance_id, meituan_userid, show_id, totalprice, grossprofit, setnumber, salesplan_count, expressfee, project_id, bill_id, salesplan_id from mart_movie.detail_myshow_salepayorder where partition_date>='$$begindate' and partition_date<'$$enddate'
        ) as spo
        left join 
        (
        select customer_id, customer_type_id, customer_type_name, customer_lvl1_name, customer_name, customer_code from mart_movie.dim_myshow_customer where customer_id is not null
        ) as cus
        using(customer_id)
    group by
        1,2,3
    ) as sp1
    left join (
    select
        dt,
        customer_type_name,
        customer_lvl1_name,
        count(distinct performance_id) as ap_num
    from (
        select partition_date as dt, performance_id, customer_id, shop_id, show_id, salesplan_sellout_flag, project_id, salesplan_id from mart_movie.detail_myshow_salesplan where salesplan_id is not null and partition_date>='$$begindate' and partition_date<'$$enddate'
        and salesplan_sellout_flag=0
        ) as ss
        left join (
        select customer_id, customer_type_id, customer_type_name, customer_lvl1_name, customer_name, customer_code from mart_movie.dim_myshow_customer where customer_id is not null
        ) as cus
        using(customer_id)
    group by
        1,2,3
    union all
    select
        dt,
        customer_type_name,
        'all' as customer_lvl1_name,
        count(distinct performance_id) as ap_num
    from (
        select partition_date as dt, performance_id, customer_id, shop_id, show_id, salesplan_sellout_flag, project_id, salesplan_id from mart_movie.detail_myshow_salesplan where salesplan_id is not null and partition_date>='$$begindate' and partition_date<'$$enddate'
        and salesplan_sellout_flag=0
        ) as ss
        left join (
        select customer_id, customer_type_id, customer_type_name, customer_lvl1_name, customer_name, customer_code from mart_movie.dim_myshow_customer where customer_id is not null
        ) as cus
        using(customer_id)
    group by
        1,2,3
       ) as ss1
    on sp1.dt=ss1.dt
    and sp1.customer_type_name=ss1.customer_type_name
    and sp1.customer_lvl1_name=ss1.customer_lvl1_name
group by
    1,2,3
;
