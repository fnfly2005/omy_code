#!/bin/bash
path="/Users/fannian/Documents/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
}

ci=`fun dim_myshow_city.sql` 
file="yysc11"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
from (
    select distinct
        city_id
    from (
        $ci
        and province_name in ('\$name')
        union all
        $ci
        and city_name in ('\$name')
        ) c1
    ) ci
    left join upload_table.mobile_info
    upload_table.wg_register_mobile
$lim">${attach}

echo "succuess,detail see ${attach}"

