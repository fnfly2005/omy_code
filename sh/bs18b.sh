#!/bin/bash
path="/Users/fannian/Documents/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
}

spo=`fun detail_myshow_salepayorder.sql` 
per=`fun dim_myshow_performance.sql`
file="bs18"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    performance_name,
    totalprice
from (
    select
        performance_id,
        totalprice,
        row_number() over (order by totalprice desc) as rank
    from (
    select
        performance_id,
        sum(totalprice) as totalprice
    from (
        $spo
        ) spo
    group by
        1
        ) as s1
    ) as s2
    left join (
        $per
        ) as per
    on per.performance_id=s2.performance_id
where
    rank=1
$lim">${attach}

echo "succuess,detail see ${attach}"

