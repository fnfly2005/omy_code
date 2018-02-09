#!/bin/bash
path="/Users/fannian/Documents/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
}

dms=`fun detail_myshow_salesplan.sql`
dmp=`fun dim_myshow_performance.sql`
dc=`fun dim_myshow_customer.sql`
dpr=`fun dim_myshow_project.sql`

file="bd13"
lim=";"
attach="${path}doc/${file}.sql"

echo "select
    dt,
    customer_type_name,
    customer_lvl1_name,
    area_1_level_name,
    area_2_level_name,
    province_name,
    city_name,
    category_name,
    dms.performance_id,
    performance_name,
    shop_name,
    case when dpr.bd_name is null then '无'
    else dpr.bd_name end as bd_name
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
    and customer_name not in ('广州丁添米贸易有限公司','上海劳益文化传媒有限公司','北京有票科技有限公司','广州颐星文化传播有限公司')
    ) dc
    on dms.customer_id=dc.customer_id
    left join 
    (
    $dpr
    ) dpr
    on dpr.project_id=dms.project_id
group by
    1,2,3,4,5,6,7,8,9,10,11,12
$lim">${attach}

echo "succuess,detail see ${attach}"
