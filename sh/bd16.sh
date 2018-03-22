#!/bin/bash
path="/Users/fannian/Documents/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
}

cin=`fun dim_cinema.sql`
cit=`fun dim_myshow_city.sql`

file="bd16"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select distinct
    cinema_id
from (
    select distinct
        mt_city_id
    from (
        $cit
        and province_name in ('\$name')
        union all
        $cit
        and city_name in ('\$name')
        ) c1
    ) cit
    left join (
    $cin
    where machine_type=1
    ) cin
    on cin.city_id=cit.mt_city_id
$lim">${attach}

echo "succuess,detail see ${attach}"
