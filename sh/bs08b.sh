#!/bin/bash
#TOP项目数据
path="/Users/fannian/Documents/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
}

spo=`fun detail_myshow_salepayorder.sql` 
per=`fun dim_myshow_performance.sql`
file="bs08"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    mt,
    performance_id,
    performance_name,
    totalprice,
    row_number() over(partition by mt order by totalprice desc) as rank
from (
    select
        substr(dt,1,7) as mt,
        spo.performance_id,
        performance_name,
        sum(totalprice) as totalprice
    from (
        $spo
        ) as spo
        left join (
        $per
        ) as per
        using(performance_id)
    group by
        1,2,3
    ) as s1
$lim">${attach}
echo "succuess,detail see ${attach}"
