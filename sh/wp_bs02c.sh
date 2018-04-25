#!/bin/bash
path="/Users/fannian/Documents/my_code/"
clock="00"
t1=${1:-`date -v -1d +"%Y-%m-%d ${clock}:00:00"`}
t2=${2:-`date -j -f %s $(expr $(date -j -f%Y-%m-%d ${t1% *} +%s) + 86400) +"%Y-%m-%d ${clock}:00:00"`}
t3=`date -j -f %s $(expr $(date -j -f%Y-%m-%d ${t1% *} +%s) - 86400) +"%Y-%m-%d ${clock}:00:00"`
fut() {
echo `grep -iv "\-time" ${path}sql/${1} | grep -iv "/\*"`
}

file="wp_bs02"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    mobile,
    max(substr(create_time,1,10)) as dt
from
    passport_user
where
    mobile is not null
    and length(mobile)=11
    and substr(mobile,1,2)>='13'
    and substr(create_time,1,10)>
group by
    1
$lim">${attach}
echo "succuess,detail see ${attach}"
