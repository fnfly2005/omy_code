#!/bin/bash
path="/Users/fannian/Documents/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
}

oni=`fun detail_maoyan_order_new_info.sql`
cni=`fun detail_maoyan_order_sale_cost_new_info.sql`
fpw=`fun detail_flow_pv_wide_report.sql`

file="bs08"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    substr(pay_time,1,7) mt,
    sum(quantity) as sku_num
from
    mart_movie.detail_maoyan_order_sale_cost_new_info
where
    pay_time is not null
    and pay_time>='\$\$begindate'
    and pay_time<'\$\$enddate'
    and deal_id in (
        select
            deal_id
        from
            mart_movie.dim_deal_new
        where
            category=12
            )
group by
    1
$lim">${attach}
echo "succuess,detail see ${attach}"
