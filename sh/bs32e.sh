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

soi=`fun dp_myshow__s_orderidentification.sql` 
per=`fun dim_myshow_performance.sql`

file="bs32"
lim="limit 1000;"
attach="${path}doc/${file}.sql"

echo "
select
    performance_name,
    city_name,
    shop_name,
    category_name,
	order_num,
	totalprice
from (
    select
        performance_id,
        count(distinct order_id) as order_num,
        sum(totalprice) as totalprice
    from 
        mart_movie.detail_myshow_saleorder
    where
        pay_time is not null
        and meituan_userid=1275075496
    group by
        1
    ) so
    join (
        $per
        ) per
    on per.performance_id=so.performance_id
$lim">${attach}

echo "succuess!"
echo ${attach}
if [ ${1}r == pr ]
#加上任意字符，如r 避免空值报错
then
cat ${attach}
#命令行参数为p时，打印输出文件
fi


