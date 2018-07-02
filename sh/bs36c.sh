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

so=`fun detail_myshow_saleorder.sql`
sos=`fun detail_myshow_saleorder.sql d`

file="bs36"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    count(distinct so1.uid) as user_num,
    count(distinct sos1.uid) as ft_usern
from (
    select
        \$user as uid,
        max(\$ht) ht
    from (
        $so
            and sellchannel not in (9,10,11)
            and (
                (meituan_userid<>0
                and '\$user'='meituan_userid')
                or (usermobileno not in (13800138000,13000000000)
                    and usermobileno is not null
                    and '\$user'='mobile')
                )
        ) so
    group by
        1
    ) so1
    left join (
        select
            \$user as uid,
            max(\$ht) ht
        from (
            $sos
            where
                pay_time is not null
                and pay_time>='\$\$begindate'
                and pay_time<'\$\$enddate{6m}'
                and sellchannel not in (9,10,11)
                and (
                    (meituan_userid<>0
                    and '\$user'='meituan_userid')
                    or (usermobileno not in (13800138000,13000000000)
                        and usermobileno is not null
                        and '\$user'='mobile')
                    )
            ) as sos
        group by
            1
        ) sos1
    on so1.uid=sos1.uid
    and so1.ht<sos1.ht
$lim">${attach}

echo "succuess!"
echo ${attach}
if [ ${1}r == pr ]
#加上任意字符，如r 避免空值报错
then
cat ${attach}
#命令行参数为p时，打印输出文件
fi


