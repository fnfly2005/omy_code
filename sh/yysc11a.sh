#!/bin/bash
path="/Users/fannian/Documents/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
}

si=`fun detail_order_seat_info.sql` 
csd=`fun aggr_discount_card_seat_dwd.sql`
cin=`fun dim_cinema.sql`
cit=`fun dim_myshow_city.sql`

file="yysc11"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    csd.mobile_phone,
    cit.city_name,
    cit.province_name
from (
    $cit
    and province_name like '%\$name%'
    ) cit
    join (
    $cin
    ) cin
    on cin.city_id=cit.mt_city_id
    join (
    $csd
    ) csd
    on csd.cinema_id=cin.cinema_id
group by
    csd.mobile_phone,
    cit.city_name,
    cit.province_name
limit 400000
$lim">${attach}

echo "succuess,detail see ${attach}"
