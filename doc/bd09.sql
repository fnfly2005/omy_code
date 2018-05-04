
select
    case when 1 in ($dim) then spo.dt
    else 'all' end as dt,
    case when 2 in ($dim) then md.value2
    else 'all' end as pt,
    case when 3 in ($dim) then cus.customer_type_name
    else 'all' end as customer_type_name,
    case when 3 in ($dim) then cus.customer_lvl1_name
    else 'all' end as customer_lvl1_name,
    per.area_1_level_name,
    per.area_2_level_name,
    per.province_name,
    per.city_name,
    per.category_name,
    per.shop_name,
    per.performance_id,
    per.performance_name,
    case when 4 in ($dim) then show_name
    else 'all' end as show_name,
    case when 5 in ($dim) then refund_flag
    else 'all' end as refund_flag,
    case when 6 in ($dim) then newuser_flag
    else 'all' end as newuser_flag,
    sum(order_num) as order_num,
    sum(ticket_num) as ticket_num,
    sum(TotalPrice) as TotalPrice,
    sum(grossprofit) as grossprofit
from (
    select
        dt,
        sellchannel,
        performance_id,
        customer_id,
        show_id,
        case when sor.order_id is null then 'no'
            when sor.issuc=0 then 'apply'
        else 'yes' end as refund_flag,
        case when sfo.meituan_userid is not null then 'yes'
        else 'no' end as newuser_flag,
        count(distinct spo.order_id) as order_num,
        sum(spo.salesplan_count*spo.setnumber) as ticket_num,
        sum(spo.TotalPrice) as TotalPrice,
        sum(spo.grossprofit) as grossprofit
    from (
        select partition_date as dt, order_id, sellchannel, customer_id, performance_id, meituan_userid, show_id, totalprice, grossprofit, setnumber, salesplan_count, expressfee, discountamount, income, expense, totalticketprice, ticket_price, sell_price, project_id, bill_id, salesplan_id, city_id, pay_time from mart_movie.detail_myshow_salepayorder where partition_date>='$$begindate' and partition_date<'$$enddate'
        ) spo
        left join (
        select meituan_userid, first_pay_order_date from mart_movie.detail_myshow_salefirstorder where dianping_userid is not null and category_id=-99
        ) sfo
        on sfo.meituan_userid=spo.meituan_userid
        and sfo.first_pay_order_date=spo.dt
        left join (
        select orderid order_id, case when finishtime is null then 0 else 1 end as issuc from origindb.dp_myshow__s_orderrefund where orderrefundid is not null and createtime<'$$enddate'
        ) sor
        on sor.order_id=spo.order_id
    group by
        1,2,3,4,5,6,7
        ) as spo
    join (
        select performance_id, activity_id, performance_name, category_id, category_name, area_1_level_name, area_2_level_name, province_name, city_id, city_name, shop_name from mart_movie.dim_myshow_performance where performance_id is not null
        and (performance_name like '%$name%'
        or '全部'='$name')
        and (performance_id in ($id)
            or -99 in ($id))
        and (shop_name like '%$shop_name%'
        or '全部'='$shop_name')
        ) per
        on spo.performance_id=per.performance_id
    join (
        select customer_id, customer_type_id, customer_type_name, customer_lvl1_name, customer_name, customer_shortname, customer_code from mart_movie.dim_myshow_customer where customer_id is not null
        and (customer_name like '%$customer_name%'
        or '全部'='$customer_name')
        and (customer_code in ($customer_code)
        or -99 in ($customer_code))
        ) cus
        on spo.customer_id=cus.customer_id
    left join (
        select show_id, performance_id, substr(show_starttime,1,10) as show_starttime, show_endtime, show_name from mart_movie.dim_myshow_show where show_id is not null
        ) sho
        on sho.show_id=spo.show_id
    left join (
        select key, value1, value2, value3 from upload_table.myshow_dictionary where key_name is not null
        and key_name='sellchannel'
        ) md
        on md.key=spo.sellchannel
group by
    1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
;
