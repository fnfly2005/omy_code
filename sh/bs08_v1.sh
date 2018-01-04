#!/bin/bash
path="/Users/fannian/Documents/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
}

so=`fun detail_myshow_salepayorder.sql` 
dc=`fun dim_myshow_customer.sql`
dss=`fun detail_myshow_salesplan.sql`
file="bs08"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    substr(partition_date,1,7) as mt,
    customer_type_name,
    sum(order_num) as order_num,
    sum(totalprice) as totalprice,
    avg(sp_num) as sp_num,
    sum(grossprofit) as grossprofit
from
(select
    partition_date,
    customer_type_name,
    count(distinct order_id) as order_num,
    sum(totalprice) as totalprice,
    count(distinct performance_id) as sp_num,
    sum(grossprofit) as grossprofit
from
    (
    $so
    ) as so
    left join 
    (
    $dc
    ) as dc
    using(customer_id)
group by
    1,2
union all
select
    partition_date,
    '全部' as customer_type_name,
    count(distinct performance_id) as sp_num,
    count(distinct order_id) as order_num,
    sum(totalprice) as totalprice,
    sum(grossprofit) as grossprofit
from
    (
    $so
    ) as so
    left join 
    (
    $dc
    ) as dc
    using(customer_id)
group by
    1,2) as test
group by
    1,2
$lim">${attach}

echo "
select
    substr(partition_date,1,7) as mt,
    customer_type_name,
    avg(ap_num) as ap_num
from
(select
    partition_date,
    customer_type_name,
    count(distinct performance_id) as ap_num
from
    (
    $dss
    and salesplan_sellout_flag=0
    ) as dss
    left join 
    (
    $dc
    ) as dc
    using(customer_id)
group by
    1,2
union all
select
    partition_date,
    '全部' as customer_type_name,
    count(distinct performance_id) as ap_num
from
    (
    $dss
    and salesplan_sellout_flag=0
    ) as dss
    left join 
    (
    $dc
    ) as dc
    using(customer_id)
group by
    1,2
    ) as test
group by
    1,2
$lim">>${attach}

echo "
select
from
    (
    $spo
    ) as spo
    left 
$lim">>${attach}
echo "succuess,detail see ${attach}"
