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

dea=`fun dp_myshow__s_deal.sql`
dsh=`fun dim_dp_shop.sql`

file="bs31"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    substr(dea.createtime,1,7) as mt,
    dp_city_name,
    dp_shop_name,
    count(distinct deal_id) as dea_num
from (
    $dea
    where
        createtime>='\$\$begindate'
        and createtime<'\$\$enddate'
    ) dea
    left join (
    $dsh
    ) dsh 
    on dsh.dp_shop_id=dea.shop_id
group by
    1,2,3
$lim">${attach}

echo "succuess!"
echo ${attach}
if [ ${1}r == pr ]
#加上任意字符，如r 避免空值报错
then
cat ${attach}
#命令行参数为p时，打印输出文件
fi


