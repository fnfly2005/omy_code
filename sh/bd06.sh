#!/bin/bash
path="/Users/fannian/Documents/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
}

dms=`fun detail_myshow_salesplan.sql`
dmp=`fun dim_myshow_performance.sql`
dc=`fun dim_myshow_customer.sql`
file="bd06"
lim=";"
attach="${path}doc/${file}.sql"

echo "select
    partition_date,
    customer_type_name,
    customer_lvl0_name,
    area_1_level_name,
    area_2_level_name,
    category_name,
    count(distinct dms.performance_id) ap_num
from
    (
    $dms
    and salesplan_sellout_flag=0
    ) dms
    left join
    (
    $dmp
    ) dmp
    using(performance_id)
    left join
    (
    $dc
    ) dc
    on dms.customer_id=dc.customer_id
group by
    1,2,3,4,5,6
$lim">${attach}

echo "succuess,detail see ${attach}"
