#!/bin/bash
path="/Users/fannian/Documents/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
}

fpw=`fun detail_flow_pv_wide_report.sql`
md=`fun myshow_dictionary.sql`

file="bs21"
lim=";"
attach="${path}doc/${file}.sql"
page_identifier='c_dqihv0si'

echo "
select
    dt,
    value2,
    approx_distinct(union_id) as uv,
    count(1) as pv
from (
    select
        partition_date as dt,
        stat_time,
        app_name,
        page_identifier,
        os,
        custom,
        union_id,
        user_id
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
    ) fpw
    left join (
    $md
    and key_name='app_name'
    ) md
    on md.key=fpw.app_name
group by
    1,2
$lim">${attach}

echo "succuess,detail see ${attach}"

