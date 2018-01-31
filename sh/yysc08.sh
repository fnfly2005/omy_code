#!/bin/bash
path="/Users/fannian/Documents/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
}

spo=`fun detail_myshow_salepayorder.sql`
dp=`fun dim_myshow_performance.sql`
fp=`fun detail_flow_pv_wide_report.sql`
mpv=`fun myshow_pv.sql`

file="yysc08"
lim=";"
attach="${path}doc/${file}.sql"
performance_name='$performance_name'

echo "
select
    vp.dt,
    vp.ht,
    dp.city_name,
    dp.performance_name,
    vp.uv,
    case when sp.performance_id is null then 0
    else sp.order_num end as order_num,
    case when sp.performance_id is null then 0
    else sp.ticket_num end as ticket_num, 
    case when sp.performance_id is null then 0
    else sp.totalprice end as totalprice,
    case when sp.performance_id is null then 0
    else sp.grossprofit end as grossprofit
from
    (select
        dt,
        ht,
        custom['performance_id'] as performance_id,
        approx_distinct(union_id) as uv
    from
        (
        $fp
        and page_identifier in (
        $mpv
        and name='演出详情页'
        )
        ) fp
    group by
        1,2,3
    ) vp
    left join 
    (select
        spo.dt,
        spo.ht,
        spo.performance_id,
        count(distinct spo.order_id) order_num,
        sum(spo.salesplan_count*spo.setnumber) ticket_num,
        sum(spo.totalprice) totalprice,
        sum(spo.grossprofit) grossprofit
    from
        (
        $spo
        ) as spo
    group by
        1,2,3
        ) as sp
    on sp.performance_id=vp.performance_id
    and vp.performance_id is not null
    and sp.dt=vp.dt
    and sp.ht=vp.ht
    left join 
    (
    $dp
    ) as dp
    on vp.performance_id=dp.performance_id
where
    dp.performance_name like '%$performance_name%'
$lim">${attach}

echo "succuess,detail see ${attach}"
