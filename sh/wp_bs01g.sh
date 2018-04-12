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
   dt,
   item_id,
   user_id
from (
    select
        from_unixtime(create_time,'%Y-%m-%d') dt,
        item_id,
        user_id
    from
        item_attentions
    union all
    select
        from_unixtime(create_time,'%Y-%m-%d') dt,
        item_id,
        user_id
    from
        item_attention
    ) as iat
group by
    1,2,3
$lim">${attach}
echo "succuess,detail see ${attach}"