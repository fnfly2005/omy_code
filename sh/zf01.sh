#!/bin/bash
path="$private_home/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
}

so=`fun detail_myshow_saleorder.sql` 
file="zf01"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    * 
from
(select
    case when show_endtime is null 
        and show_starttime<='2018-01-06'
    then 1
        when length(show_endtime)<=0 
        and show_starttime<='2018-01-06'
    then 2
        when show_endtime<='2017-09-01' 
        and show_starttime<='2018-01-06'
    then 3
        when show_endtime<='2018-01-06'
        and show_endtime>'2017-09-01' 
    then 4
    else 0 end as flag,
    order_id,
    consumed_time,
    show_endtime,
    show_starttime,
    pay_time,
    order_create_time
from
    (
    $so
    and order_reserve_status=9
    and order_create_time>='2017-09-01'
    and order_refund_status=0
    and consumed_time is null
    ) as so) as s1
where
    s1.flag<>0
$lim">${attach}

echo "succuess,detail see ${attach}"
