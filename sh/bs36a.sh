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
sos=`fun detail_myshow_saleorder.sql`
per=`fun dim_myshow_performance.sql`
md=`fun myshow_dictionary.sql`
cus=`fun dim_myshow_customer.sql`

file="bs36"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    \$dim,
    \$dw,
    count(distinct so1.\$user) as usernum,
    count(distinct case when fdw>1 then so1.\$user end) as cross_usernum
from (
    select
        \$user,
        count(distinct order_id) fon,
        count(distinct \$dw) fdw,
        count(distinct dt) fdt
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
        left join (
            $per
            ) per
        on per.performance_id=so.performance_id
        left join (
            $md
            and key_name='sellchannel'
            ) md
        on md.key=so.sellchannel
        left join (
            $cus
            ) cus
        on cus.customer_id=so.customer_id
    group by
        1
    ) so1
    left join (
        $sos
            and sellchannel not in (9,10,11)
            and (
                (meituan_userid<>0
                and '\$user'='meituan_userid')
                or (usermobileno not in (13800138000,13000000000)
                    and usermobileno is not null
                    and '\$user'='mobile')
                )
        ) sos
    on so1.\$user=sos.\$user
    left join (
        $per
        ) per
    on per.performance_id=sos.performance_id
    left join (
        $md
        and key_name='sellchannel'
        ) md
    on md.key=sos.sellchannel
    left join (
        $cus
        ) cus
    on cus.customer_id=sos.customer_id
group by
    1,2
$lim">${attach}

echo "succuess!"
echo ${attach}
if [ ${1}r == pr ]
#加上任意字符，如r 避免空值报错
then
cat ${attach}
#命令行参数为p时，打印输出文件
fi
