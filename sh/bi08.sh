#!/bin/bash
source ./fuc.sh

cin=`fun dim_cinema.sql u`
cit=`fun dim_myshow_city.sql`
file="bi08"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    cit.city_id as parentdpcity_id,
    cit.city_name as parentdpcity_name,
    secondary_city_id as mtcity_id
from (
    select distinct
        city_id,
        secondary_city_id
    $cin
        and secondary_city_id<>city_id
        and city_name<>'资阳'
    ) cin
    join (
        $cit
        ) cit
        on cit.mt_city_id=cin.city_id
$lim">${attach}

echo "succuess!"
echo ${attach}
if [ ${1}r == pr ]
#加上任意字符，如r 避免空值报错
then
cat ${attach}
#命令行参数为p时，打印输出文件
fi
