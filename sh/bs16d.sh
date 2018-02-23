#!/bin/bash
path="/Users/fannian/Documents/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
}

md=`fun myshow_dictionary.sql`
file="bs16"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    dt,
    md.value2 as pt,
    mp.bu,
    mp.p_name,
    mp.m_name,
    sum(uv) as uv,
    sum(pv) as pv
from (
    select
        partition_date as dt,
        app_name,
        event_id,
        approx_distinct(union_id) as uv,
        count(1) as pv
    from
        mart_flow.detail_flow_mv_wide_report
    where
        partition_date>='\$\$begindate'
        and partition_date<'\$\$enddate'
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
        1,2,3
    ) as fmw
    join (
        $md
        and key_name='app_name'
        ) as md
    on md.key=fmw.app_name
    join (
    select 
        case when mp1.page_tag1=0 then '演出'
        when mp1.page_tag1=-1 then '平台' 
        else '电影' end as bu,
        mp1.name as p_name,
        mp2.value as event_id,
        mp2.name as m_name
    from upload_table.myshow_pv as mp1
        join upload_table.myshow_pv as mp2
        on mp1.value=mp2.page
        and mp1.key='page_identifier'
        and mp2.key='event_id'
        and mp1.nav_flag<=1
    ) mp 
    on mp.event_id=fmw.event_id
group by 
    1,2,3,4,5
$lim">${attach}

echo "succuess,detail see ${attach}"

