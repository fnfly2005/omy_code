#!/bin/bash
clock="00"
t1=${1:-`date -v -1d +"%Y-%m-%d ${clock}:00:00"`}
t2=${2:-`date -j -f %s $(expr $(date -j -f%Y-%m-%d ${t1% *} +%s) + 86400) +"%Y-%m-%d ${clock}:00:00"`}
t3=`date -j -f %s $(expr $(date -j -f%Y-%m-%d ${t1% *} +%s) - 86400) +"%Y-%m-%d ${clock}:00:00"`
path="/Users/fannian/Documents/my_code/"
fun() {
echo `cat ${path}sql/${1}.sql | sed "s/-time1/${2:-${t1% *}}/g;
s/-time2/${3:-${t2% *}}/g;s/-time3/${4:-${t3% *}}/g"`
}
dfp=`fun detail_flow_pv_wide_report` 
file="cp01"
attach="${path}doc/${file}.sql"
an="('group','dianping_nova','movie','dianping_movie_wx')"
pid=40000386
so=`fun dp_myshow__s_order`

if [ $3 = 1 ]
then
echo "mode:1"
echo "/*分渠道页面跳失率*/
select
    partition_date,
    case app_name
        when 'group' then '美团'
        when 'dianping_nova' then '点评'
        when 'movie' then '猫眼'
        when 'dianping_movie_wx' then '微信站'
        when 'all' then '整体'
    end app_name,
    sv,
    jv
from
(select
    partition_date,
    app_name,
    count(distinct session_id) sv,
    count(distinct case when pv=1 then session_id end) jv
from
    (
    select
        partition_date,
        app_name,
        session_id,
        count(1) pv
    from (
    $dfp
    and app_name in $an
    and page_id=$pid
    ) dfp1
    group by
        1,2,3) df1
group by
    1,2
union all
select
    partition_date,
    'all' app_name,
    count(distinct session_id) sv,
    count(distinct case when pv=1 then session_id end) jv
from
    (
    select
        partition_date,
        session_id,
        count(1) pv
    from (
    $dfp
    and app_name in $an
    and page_id=$pid 
    ) dfp2
    group by
        1,2) df2
group by
    1,2) dfp ">${attach}
fi
file="cp01a"
attach="${path}doc/${file}.sql"

if [ $3 = 2 ]
then
echo "mode:2"
echo "
select
from
    $so
">${attach}
fi
