#!/bin/bash
path="/Users/fannian/Documents/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
}

oni=`fun detail_maoyan_order_new_info.sql`
cni=`fun detail_maoyan_order_sale_cost_new_info.sql`
fpw=`fun detail_flow_pv_wide_report.sql`

file="xk01"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    so.dt,
    total_money,
    order_num,
    sku_num,
    dea_num,
    uv
from (
    select 
        dt,
        sum(total_money) as total_money,
        count(distinct oni.order_id) as order_num,
        sum(quantity) sku_num,
        count(distinct deal_id) dea_num
    from (
        $oni
        ) oni
        join (
        $cni
        ) cni
        on oni.order_id=cni.order_id
    group by
        1
    ) as so
    left join (
        select
            partition_date as dt,
            approx_distinct(union_id) as uv
        from mart_flow.detail_flow_pv_wide_report
        where partition_date>='\$\$begindate'
            and partition_date<'\$\$enddate'
            and partition_log_channel='movie'
            and partition_app in (
            'movie',
            'dianping_nova',
            'other_app',
            'dp_m',
            'group'
            )
            and page_identifier='c_dqihv0si'
        group by
            1
        ) as fpw
    on fpw.dt=so.dt
$lim">${attach}
echo "succuess,detail see ${attach}"
