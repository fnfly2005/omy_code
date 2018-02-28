#!/bin/bash
path="/Users/fannian/Documents/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
}

fpw=`fun detail_flow_pv_wide_report.sql` 
md=`fun myshow_dictionary.sql`
per=`fun dim_myshow_performance.sql`
file="yysc09"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    dt,
    fromTag,
    performance_name,
    fpw.performance_id,
    uv,
    pv
from (
    select
        partition_date as dt,
        custom['fromTag'] as fromTag,
        case when app_name<>'maoyan_wxwallet_i'
                then custom['performance_id']
            else custom['id'] end as performance_id,
        approx_distinct(union_id) as uv,
        count(1) as pv
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
        and page_identifier in (
        select value
        from upload_table.myshow_pv
        where key='page_identifier'
        and name='演出详情页'
        and page<>'native'
        )
    group by
        1,2,3
    ) as fpw
    join (
        $per
        and performance_name like '%\$name%'
        ) per
    on fpw.performance_id=per.performance_id
$lim">${attach}

echo "succuess,detail see ${attach}"

