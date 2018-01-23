#!/bin/bash
path="/Users/fannian/Documents/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
}

my=`fun aggr_movie_dau_client_core_page_daily.sql` 
dp=`fun aggr_movie_dianping_app_conversion_daily.sql`
wxycss=`fun aggr_movie_maoyan_weixin_daily.sql`
mt=`fun aggr_movie_meituan_app_conversion_daily.sql`
wxchwl=`fun aggr_movie_weixin_app_conversion_daily.sql`
file="bs11"
lim=";"
attach="${path}doc/${file}.sql"

echo "select
    my.dt,
    my.firstpage_uv my,
    dp.firstpage_uv dp,
    wxycss.firstpage_uv wxycss,
    mt.firstpage_uv mt,
    wxchwl.firstpage_uv wxchwl
from
    (
    $my
    ) my
    left join
    (
    $dp
    ) dp
    on my.dt=dp.dt
    left join
    (
    $wxycss
    ) wxycss
    on my.dt=wxycss.dt
    left join
    (
    $mt
    ) mt
    on my.dt=mt.dt
    left join
    (
    $wxchwl
    ) wxchwl
    on my.dt=wxchwl.dt
$lim">${attach}

echo "succuess,detail see ${attach}"

