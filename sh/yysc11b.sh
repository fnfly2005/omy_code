#!/bin/bash
path="/Users/fannian/Documents/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
}

mou=`fun dim_myshow_movieuser.sql`
cit=`fun dim_myshow_city.sql`

file="yysc11"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    cit.province_name,
    cit.city_name,
    approx_percentile(phone_num,0.5) as num
from (
    $cit
    ) cit
    join (
    select
        active_date,
        mou.city_id,
        approx_distinct(mobile) as phone_num
    from (
        $mou
        ) mou
    group by
        1,2
    ) sc
    on sc.city_id=cit.mt_city_id
group by
    1,2
union all
select
    cit.province_name,
    '全部' city_name,
    approx_percentile(phone_num,0.5) as num
from (
    $cit
    ) cit
    join (
    select
        active_date,
        mou.city_id,
        approx_distinct(mobile) as phone_num
    from (
        $mou
        ) mou
    group by
        1,2
    ) sc
    on sc.city_id=cit.mt_city_id
group by
    1,2
$lim">${attach}

echo "succuess,detail see ${attach}"
