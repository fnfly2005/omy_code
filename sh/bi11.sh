#!/bin/bash
#etl/detail_myshow_saleorder.sql
source ./fuc.sh

ery=`fun sql/dp_myshow__s_orderdelivery.sql u`
ity=`fun sql/dim_myshow_city.sql`

file="bi11"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    ery.city_name
from (
    select distinct
        cityname as city_name
    $ery
        and cityname is not null
        and cityname not like '%区划'
    ) as ery
    left join (
    $ity
    ) ity
    on ity.city_name=ery.city_name
where
    ity.city_name is null
$lim">${attach}

echo "succuess!"
echo ${attach}
if [ ${1}r == pr ]
#加上任意字符，如r 避免空值报错
then
cat ${attach}
#命令行参数为p时，打印输出文件
fi
