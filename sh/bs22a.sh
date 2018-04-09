#!/bin/bash
path="/Users/fannian/Documents/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
}

wso=`fun detail_wg_saleorder.sql`
wus=`fun dim_wg_user.sql`
file="bs22"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    count(distinct order_id),
    count(distinct wso.user_id) as so_num,
    count(distinct 
        case when order_mobile is not null 
            and length(order_mobile)=11 
            and substr(order_mobile,1,2)>='13' 
        then order_mobile end) as so_num1
from (
    $wso
    ) wso
$lim">${attach}

echo "succuess,detail see ${attach}"

