#!/bin/bash
path="/Users/fannian/Documents/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
}

pv=`fun detail_flow_pv_wide_report.sql` 
file="yysc07"
lim=";"
attach="${path}doc/${file}.sql"

echo "select
    
from
    (
    $pv
    ) as pv
$lim">${attach}

echo "succuess,detail see ${attach}"

