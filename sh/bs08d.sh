#!/bin/bash
path="/Users/fannian/Documents/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
}

apa=`fun aggr_myshow_pv_all.sql`
app=`fun aggr_myshow_pv_page.sql`

file="bs08"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    substr(dt,1,7) as mt,
    new_app_name as pt,
    new_page_name,
    avg(uv) as uv
from
    (
    $apa
    and new_page_name in ('演出首页','演出详情页','演出确认订单页')
    ) apa
group by
    1,2,3
union all
select
    substr(dt,1,7) as mt,
    '全部' as pt,
    new_page_name,
    avg(uv) as uv
from
    (
    $app
    and new_page_name in ('演出首页','演出详情页','演出确认订单页')
    ) app
group by
    1,2,3
$lim">${attach}

echo "succuess,detail see ${attach}"

