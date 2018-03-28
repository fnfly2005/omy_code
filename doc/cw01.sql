
select
    substr(spo.dt,1,7) mt,
    customer_type_name,
    customer_lvl1_name,
    case when sre.order_id is null then 'no'
    else 'yes' end as isrefund,
    count(distinct spo.order_id) as order_num,
    sum(spo.salesplan_count*spo.setnumber) as ticket_num,
    sum(spo.totalprice) as totalprice,
    sum(spo.grossprofit) as grossprofit,
    sum(spo.expressfee) as expressfee,
    sum(spo.discountamount) as discountamount,
    sum(spo.income) as income,
    sum(spo.expense) as expense,
    sum(spo.totalticketprice) as totalticketprice
from (
    select partition_date as dt, order_id, sellchannel, customer_id, performance_id, meituan_userid, show_id, totalprice, grossprofit, setnumber, salesplan_count, expressfee, discountamount, income, expense, totalticketprice, project_id, bill_id, salesplan_id from mart_movie.detail_myshow_salepayorder where partition_date>='$$begindate' and partition_date<'$$enddate'
    ) spo
   join (
   select performance_id, activity_id, performance_name, category_id, category_name, area_1_level_name, area_2_level_name, province_name, city_id, city_name, shop_name from mart_movie.dim_myshow_performance where performance_id is not null
   and category_name='休闲展览'
   ) per
   on spo.performance_id=per.performance_id
   left join (
   select orderid as order_id from origindb.dp_myshow__s_settlementrefund
   ) sre
   on spo.order_id=sre.order_id
   left join (
   select customer_id, customer_type_id, customer_type_name, customer_lvl1_name, customer_name, customer_shortname, customer_code from mart_movie.dim_myshow_customer where customer_id is not null
   ) cus
   on cus.customer_id=spo.customer_id
group by
    1,2,3,4
;
