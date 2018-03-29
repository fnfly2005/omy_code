
select
    substr(dt,1,7) as mt,
    coalesce(cus.customer_type_name,'全部') as customer_type_name,
    coalesce(cus.customer_lvl1_name,'全部') as customer_lvl1_name,
    count(distinct spo.order_id) as order_num,
    sum(spo.salesplan_count*spo.setnumber) as ticket_num,
    sum(spo.totalprice) as totalprice,
    sum(spo.grossprofit) as grossprofit
from
    (
    select partition_date as dt, order_id, sellchannel, customer_id, performance_id, meituan_userid, show_id, totalprice, grossprofit, setnumber, salesplan_count, expressfee, discountamount, income, expense, totalticketprice, project_id, bill_id, salesplan_id, pay_time from mart_movie.detail_myshow_salepayorder where partition_date>='$$begindate' and partition_date<'$$enddate'
    ) spo
    left join (
    select customer_id, customer_type_id, customer_type_name, customer_lvl1_name, customer_name, customer_shortname, customer_code from mart_movie.dim_myshow_customer where customer_id is not null
    ) cus
    on spo.customer_id=cus.customer_id
group by
    substr(dt,1,7),
    cus.customer_type_name,
    cus.customer_lvl1_name
grouping sets(
(substr(dt,1,7),cus.customer_type_name),
(substr(dt,1,7),cus.customer_type_name,cus.customer_lvl1_name)
)
;
