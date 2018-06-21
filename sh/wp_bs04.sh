#!/bin/bash
#--------------------猫眼演出readme-------------------
#*************************api1.0*******************
# 优化输出方式,优化函数处理
path="/Users/fannian/Documents/my_code/"
fun() {
    if [ $2x == dx ];then
        echo `cat ${path}sql/${1} | grep -iv "/\*" | sed '/where/,$'d`
    elif [ $2x == ux ];then
        echo `cat ${path}sql/${1} | grep -iv "/\*" | sed '1,/from/'d | sed '1s/^/from/'`
    elif [ $2x == tx ];then
        echo `cat ${path}sql/${1} | grep -iv "/\*" | sed "s/begindate/today{-1d}/g;s/enddate/today{-0d}/g"`
    elif [ $2x == utx ];then
        echo `cat ${path}sql/${1} | grep -iv "/\*" | sed "s/begindate/today{-1d}/g;s/enddate/today{-0d}/g" | sed '1,/from/'d | sed '1s/^/from/'`
    else
        echo `cat ${path}sql/${1} | grep -iv "/\*"`
    fi
}

it=`fun item_type.sql`
ii=`fun item_info.sql`
ci=`fun city.sql`
ve=`fun venue.sql`
file="wp_bs04"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    item_name,
    city_name,
    venue_name,
    type_lv1_name,
    type_lv2_name,
    dt
from (
    $ii
    ) ii
    left join (
        $ve
        ) ve
    on ii.venue_id=ve.venue_id
    left join (
       $it
       ) it
       on it.type_id=ii.type_id
    left join (
        $ci
        ) ci
        on ci.city_id=ii.city_id
$lim">${attach}

echo "succuess!"
echo ${attach}
if [ ${1}r == pr ]
#加上任意字符，如r 避免空值报错
then
cat ${attach}
#命令行参数为p时，打印输出文件
fi


