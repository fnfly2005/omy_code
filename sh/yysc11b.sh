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
    cit.province_name,
    cit.city_name,
    sum(phone_num) as num
from (
    $cit
    ) cit
    left join (
    select
        cin.city_id,
        approx_distinct(mobile_phone) as phone_num
    from (
        $cin
        ) cin
        left join (
        $csd
        ) csd
        on cin.cinema_id=csd.cinema_id
    group by
        1
    ) sc
    on sc.city_id=cit.mt_city_id
group by
    1,2
union all
select
    cit.province_name,
    '全部' city_name,
    sum(phone_num) as num
from (
    $cit
    ) cit
    left join (
    select
        cin.city_id,
        approx_distinct(mobile_phone) as phone_num
    from (
        $cin
        ) cin
        left join (
        $csd
        ) csd
        on cin.cinema_id=csd.cinema_id
    group by
        1
    ) sc
    on sc.city_id=cit.mt_city_id
group by
    1,2
$lim">${attach}

echo "succuess,detail see ${attach}"
