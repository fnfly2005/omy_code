#!/bin/bash
path="/Users/fannian/Documents/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
}

spo=`fun detail_myshow_salepayorder.sql` 
fpw=`fun detail_flow_pv_wide_report.sql`

file="xk01"
lim=";"
attach="${path}doc/${file}.sql"

echo "
from (
    select
        spo.dt,
        count(distinct spo.performance_id) as sp_num,
        count(distinct spo.order_id) as order_num,
        sum(spo.salesplan_count*spo.setnumber) as ticket_num,
        sum(spo.totalprice) as totalprice,
        sum(spo.grossprofit) as grossprofit
    from
        (
        $spo
        ) spo
    group by
        spo.dt
    ) as spo0
    left join (
    select
        
    from
$lim">${attach}

echo "succuess,detail see ${attach}"

