#!/bin/bash
path="/Users/fannian/Documents/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
}

so=`fun detail_myshow_saleorder.sql` 
file="bs18"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    count(distinct usermobileno)
from (
    $so
    ) as so
$lim">${attach}

echo "succuess,detail see ${attach}"

