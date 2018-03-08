#!/bin/bash
path="/Users/fannian/Documents/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
}

spo=`fun detail_myshow_salepayorder.sql` 
ss=`fun detail_myshow_salesplan.sql`
per=`fun dim_myshow_performance.sql`

file="xk01"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    sp1.dt,
    per.performance_name,
    sp1.order_num,
    sp1.ticket_num,
    sp1.totalprice,
    sp1.grossprofit,
    fpw.uv
from (
    select
        dt,
        performance_id,
        order_num,
        ticket_num,
        totalprice,
        grossprofit,
        row_number() over (partition by dt order by totalprice desc) as rank
    from (
        select
            spo.dt,
            performance_id, 
            count(distinct spo.order_id) as order_num,
            sum(spo.salesplan_count*spo.setnumber) as ticket_num,
            sum(spo.totalprice) as totalprice,
            sum(spo.grossprofit) as grossprofit
        from
            (
            $spo
            and sellchannel<>8
            ) spo
        group by
            spo.dt,
            performance_id
        ) as sp0
    ) as sp1
    left join (
    select
        partition_date as dt,
        case when page_identifier<>'pages/show/detail/index'
            then custom['performance_id']
        else custom['id'] end as performance_id,
        count(distinct union_id) as uv
    from
        mart_flow.detail_flow_pv_wide_report
    where partition_date='\$\$today{-1d}'
        and partition_log_channel='movie'
        and partition_app in (
        'movie',
        'dianping_nova',
        'other_app',
        'dp_m',
        'group'
        )
        and app_name<>'gewara'
        and page_identifier in (
        select value
        from upload_table.myshow_pv
        where key='page_identifier'
        and nav_flag=2
        and page_tag1=0
        and page<>'native'
        )
    group by
        1,2
    ) as fpw
    on sp1.dt=fpw.dt 
    and sp1.performance_id=fpw.performance_id
    left join (
    $per
    ) as per
    on per.performance_id=sp1.performance_id
where
    sp1.rank<=10
$lim">${attach}

echo "succuess,detail see ${attach}"

