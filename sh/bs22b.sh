#!/bin/bash
path="/Users/fannian/Documents/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
}

wus=`fun dim_wg_user.sql`

file="bs22"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    count(distinct user_id) as num,
    count(distinct 
        case when mobile is not null 
            and length(mobile)=11 
            and substr(cast(mobile as varchar),1,2)>='13' 
        then mobile end) as mob_num
from (
    $wus
    ) wus
$lim">${attach}

echo "succuess,detail see ${attach}"

