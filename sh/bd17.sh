#!/bin/bash
path="/Users/fannian/Documents/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
}

mp=`fun dp_myshow__s_messagepush.sql` 
file="bd17"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    mobile
from (
    $mp
    and performanceid=\$id
    ) mp
$lim">${attach}

echo "succuess,detail see ${attach}"
