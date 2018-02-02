#!/bin/bash
path="/Users/fannian/Documents/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
}

fpw=`fun detail_flow_pv_wide_report.sql` 
mp=`fun myshow_pv.sql`
file="bs13"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    os,
    page_tag1,
    name,
    count(1) pv,
    count(distinct union_id) uv
from
    (
    $fpw
    and app_name='gewara'
    ) fpw
    left join 
    (
    $mp
    and page='native'
    ) mp
    on fpw.page_identifier=mp.value
group by
    1,2,3
union all
select
    os,
    page_tag1,
    'all' as name,
    count(1) pv,
    count(distinct union_id) uv
from
    (
    $fpw
    and app_name='gewara'
    ) fpw
    left join 
    (
    $mp
    and page='native'
    ) mp
    on fpw.page_identifier=mp.value
group by
    1,2,3
union all
select
    os,
    'all' page_tag1,
    'all' name,
    count(1) pv,
    count(distinct union_id) uv
from
    (
    $fpw
    and app_name='gewara'
    ) fpw
    left join 
    (
    $mp
    and page='native'
    ) mp
    on fpw.page_identifier=mp.value
group by
    1,2,3
$lim">${attach}

echo "succuess,detail see ${attach}"

