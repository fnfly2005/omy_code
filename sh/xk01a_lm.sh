#!/bin/bash
path="/Users/fannian/Documents/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
}

spo=`fun detail_myshow_salepayorder.sql` 
ss=`fun detail_myshow_salesplan.sql`

file="xk01"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    substr(ss1.dt,1,7) as mt,
    avg(ss1.ap_num) as ap_num,
    avg(ss1.as_num) as as_num,
    avg(sp1.sp_num) as sp_num,
    sum(sp1.order_num) as order_num,
    sum(sp1.ticket_num) as ticket_num,
    sum(sp1.totalprice) as totalprice,
    sum(sp1.grossprofit) as grossprofit,
    avg(sp1.order_num) as order_avgnum,
    avg(fpw.uv) as uv
from (
    select
        ss.dt,
        count(distinct ss.performance_id) as ap_num,
        count(distinct ss.salesplan_id) as as_num
    from
        (
        $ss
        and salesplan_sellout_flag=0
        ) ss
    group by
        ss.dt
    ) as ss1
    left join (
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
    ) as sp1
    on sp1.dt=ss1.dt
    left join (
    select
        partition_date as dt,
        approx_distinct(union_id) as uv
    from
        mart_flow.detail_flow_pv_wide_report
    where partition_date>='\$\$monthfirst{-1m}'
        and partition_date<'\$\$monthfirst'
        and partition_log_channel='movie'
        and partition_app in (
        'movie',
        'dianping_nova',
        'other_app',
        'dp_m',
        'group'
        )
        and page_identifier in (
        select value
        from upload_table.myshow_pv
        where key='page_identifier'
        and page_tag1>=0
        )
    group by
        partition_date
    ) as fpw
    on ss1.dt=fpw.dt
group by
    1
$lim">${attach}

echo "succuess,detail see ${attach}"

