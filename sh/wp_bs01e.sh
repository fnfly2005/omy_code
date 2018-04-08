#!/bin/bash
path="/Users/fannian/Documents/my_code/"
clock="00"
t1=${1:-`date -v -1d +"%Y-%m-%d ${clock}:00:00"`}
t2=${2:-`date -j -f %s $(expr $(date -j -f%Y-%m-%d ${t1% *} +%s) + 86400) +"%Y-%m-%d ${clock}:00:00"`}
t3=`date -j -f %s $(expr $(date -j -f%Y-%m-%d ${t1% *} +%s) - 86400) +"%Y-%m-%d ${clock}:00:00"`
fut() {
echo `grep -iv "\-time" ${path}sql/${1} | grep -iv "/\*"`
}

file="wp_bs01"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    from_unixtime(create_time/1000,'%Y-%m-%d') dt,
    item_id,
    mobile
from
    sale_reminder sr
    left join item_match_distributor imd
    using(online_id)
group by
    1,2,3
$lim">${attach}
echo "succuess,detail see ${attach}"
