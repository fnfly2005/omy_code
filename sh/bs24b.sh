#!/bin/bash
path="/Users/fannian/Documents/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
}

fpw=`fun detail_flow_pv_wide_report.sql`
per=`fun dim_myshow_performance.sql`

file="bs24"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select distinct
    user_id
from
    mart_flow.detail_flow_pv_wide_report
where
    partition_date>='\$\$begindate'
    and partition_date<'\$\$enddate'
    and partition_log_channel='movie'
    and partition_app in (
    'movie',
    'dianping_nova',
    'dp_m',
    'group'
    )
    and page_identifier='c_Q7wY4'
    and user_id is not null
    and page_city_name in ('郑州')
$lim">${attach}

echo "succuess,detail see ${attach}"
