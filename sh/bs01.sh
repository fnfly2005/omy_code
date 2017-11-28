#!/bin/bash
clock="00"
t1=${1:-`date -v -1d +"%Y-%m-%d ${clock}:00:00"`}
t2=${2:-`date -j -f %s $(expr $(date -j -f%Y-%m-%d ${t1% *} +%s) + 86400) +"%Y-%m-%d ${clock}:00:00"`}
t3=`date -j -f %s $(expr $(date -j -f%Y-%m-%d ${t1% *} +%s) - 86400) +"%Y-%m-%d ${clock}:00:00"`
path="/Users/fannian/Documents/my_code/"
fun() {
echo `cat ${path}sql/${1}.sql | sed "s/-time1/${2:-${t1% *}}/g;
s/-time2/${3:-${t2% *}}/g;s/-time3/${4:-${t3% *}}/g"`
}
so=`fun dp_myshow__s_order`
sos=`fun dp_myshow__s_ordersalesplansnapshot`
sod=`fun dp_myshow__s_orderdelivery`
bs=`fun dp_myshow__bs_activitymap`
sc=`fun dp_myshow__s_customer`
file="bs01"
attach="${path}doc/${file}.sql"


echo "select
from
    (
    $so
    ) so
    join 
    (
    $sos
    and PerformanceID=$3
    ) sos
    (
    $sod
    ) sod
    (
    $bs
    ) bs
    (
    $sc
    ) sc
    ">${attach}

