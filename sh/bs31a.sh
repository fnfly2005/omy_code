#!/bin/bash
#--------------------猫眼演出readme-------------------
#*************************api1.0*******************
# 优化输出方式,优化函数处理
#*************************bs31/wp_bs03_1.0*******************
#关于业务描述和重点风险证明材料收集准备需求-演出票务
#数据口径-项目最早上架时间
#维度-月、业务、城市、项目数
#统计城市、业务方计数
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

ss=`fun dim_myshow_salesplan.sql`
file="bs31"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    substr(salesplan_ontime,1,7) as mt,
    customer_type_name,
    customer_lvl1_name,
    customer_id,
    customer_name,
    city_name,
    count(distinct performance_id) as per_num
from (
    $ss
    where
        salesplan_ontime>='\$\$begindate'
        and salesplan_createtime<'\$\$enddate'
    ) ss
group by
    1,2,3,4,5,6
$lim">${attach}

echo "succuess!"
echo ${attach}
if [ ${1}r == pr ]
#加上任意字符，如r 避免空值报错
then
cat ${attach}
#命令行参数为p时，打印输出文件
fi


