#!/bin/bash
path="/Users/fannian/Documents/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
}

spo=`fun detail_myshow_salepayorder.sql` 
file="bs18"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    dt
from (
    select
        dt,
        totalprice,
        row_number() over (order by totalprice desc) as rank
    from (
    select
        dt,
        sum(totalprice) as totalprice
    from (
        $spo
        ) spo
    group by
        1
        ) as s1
    ) as s2
where
    rank=1
$lim">${attach}

echo "succuess,detail see ${attach}"

