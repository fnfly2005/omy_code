#!/bin/bash
#--------------------猫眼演出readme-------------------
#*************************api1.0*******************
# 优化输出方式,优化函数处理
path="/Users/fannian/Documents/my_code/"
clock="00"
fun() {
echo `cat ${path}sql/${1} | grep -iv "/\*"`
}
mes=`fun s_messagepush.sql` 
file="bd25"
lim="limit 100000;"
attach="${path}doc/${file}.sql"
echo "
select
    count(distinct mobile) num 
from (
    $mes
    and PerformanceID in ($2)
    ) mes
$lim">${attach}

echo "succuess!"
echo ${attach}
if [ ${1}r == pr ]
#加上任意字符，如r 避免空值报错
then
cat ${attach}
#命令行参数为p时，打印输出文件
fi
