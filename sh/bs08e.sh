#!/bin/bash
#总体交易数据
path="/Users/fannian/Documents/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
}

spo=`fun detail_myshow_salepayorder.sql` 
cus=`fun dim_myshow_customer.sql`
ss=`fun detail_myshow_salesplan.sql`
per=`fun dim_myshow_performance.sql`

file="bs08"
lim=";"
attach="${path}doc/${file}.sql"

echo "
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
        $spo
        ) as spo
        left join 
        (
        $cus
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
        $spo
        ) as spo
        left join 
        (
        $cus
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
        $ss
        and salesplan_sellout_flag=0
        ) as ss
        left join (
        $cus
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
        $ss
        and salesplan_sellout_flag=0
        ) as ss
        left join (
        $cus
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
$lim">${attach}

echo "succuess,detail see ${attach}"
