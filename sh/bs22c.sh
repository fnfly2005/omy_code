#!/bin/bash
path="/Users/fannian/Documents/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
}

osr=`fun detail_wg_outstockrecord.sql`

file="bs22"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    count(1) as num,
    count(distinct 
        case when mobile is not null 
            and length(mobile)=11 
            and substr(cast(mobile as varchar),1,2)>='13' 
        then mobile end) as mob_num
from (
    $osr
    ) osr
$lim">${attach}

echo "succuess,detail see ${attach}"

