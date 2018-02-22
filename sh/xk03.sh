#!/bin/bash
path="/Users/fannian/Documents/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
}

file="xk03"
lim=";"
attach="${path}doc/${file}.sql"

echo "select
from (
    select
        partition_date as dt,
        event_id,
        approx_distinct(union_id) as uv,
        count(1) as pv
    from
        mart_flow.detail_flow_mv_wide_report
    where
        partition_date='$$begindate'
        and partition_log_channel='movie'
        and partition_etl_source='2_5x'
        and partition_app in (
        'movie',
        'dianping_nova',
        'other_app',
        'dp_m',
        'group'
        )
    group by
        partition_date as dt,
        event_id,
        union_id
    ) as fmw
        select 
            mp2.value as pn
        from upload_table.myshow_pv mp1
            join upload_table.myshow_pv mp2
            on mp1.page=mp2.value
            and mp1.key='event_id'
            and mp2.key='page_identifier'
            and mp2.page='h5'
$lim">${attach}

echo "succuess,detail see ${attach}"

