#!/bin/bash
#--------------------mysensitiveycsensitivereadme-------------------
#*************************api1.0*******************
# 优化输出方式,优化函数处理
path="$private_home/my_code/"
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

so=`fun detail_myshow_saleorder.sql`

file="bs36"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    ht,
    count(distinct uid) 
from (
    select
        \$user as uid,
        min(\$date) ht
    from (
        $so    
            and sellchannel not in (9,10,11)
            and (
                (mtsensitive_userid<>0
                and '\$user'='mtsensitive_userid')
                or (usermobileno not in (13800138000,13000000000)
                    and usermobileno is not null
                    and '\$user'='mobile')
                )
        ) so
    group by
        1
    ) s1
group by
    1
order by
    1
$lim">${attach}

echo "succuess!"
echo ${attach}
if [ ${1}r == pr ]
#加上任意字符，如r 避免空值报错
then
cat ${attach}
#命令行参数为p时，打印输出文件
fi
