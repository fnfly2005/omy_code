#!/bin/bash
#--------------------猫眼演出readme-------------------
#*************************api1.0*******************
# 优化输出方式,优化函数处理
path=""
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

sms=`fun dp_myshow__s_messagepush.sql`
srs=`fun dp_myshow__s_stockoutregisterstatistic.sql`
srr=`fun dp_myshow__s_stockoutregisterrecord.sql`
so=`fun detail_myshow_saleorder.sql u`

sms_performance_id="49797,50160" #开售提醒项目ID
dim="2" #自定义维度
performance_id="50160" #缺货登记及交易项目ID
sta="1,2,3"
sta_date="2018-07-11"
end_date="2018-07-25"

file="yhyy01"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    coalesce(sr_show_name,'all') sr_show_name,
    coalesce(sr_ticket_price,'all') sr_ticket_price,
    count(distinct sms.mobile) as sms_num
from (
    select distinct
        sm.mobile
    from (
        $sms
            and performanceid in ($sms_performance_id)
            and createtime>='$sta_date'
            and createtime<'$end_date'
        ) sm
        left join (
            select
                usermobileno as mobile
            $so
                and performance_id in ($performance_id)
            group by
                1
            ) so
            on so.mobile=sm.mobile
    where
        so.mobile is null
    ) sms
    left join (
        select
            mobile,
            case when 2 in ($dim) then show_name
            else 'all' end as sr_show_name,
            case when 2 in ($dim) then ticket_price
            else 'all' end as sr_ticket_price
        from (
            $srs
                and performanceid in ($performance_id)
                and createtime>='$sta_date'
                and createtime<'$end_date'
            ) srs
            left join (
                $srr
                and smssendstatus in ($sta)
                ) srr
            on srs.stockoutregisterstatisticid=srr.stockoutregisterstatisticid
        group by
            1,2,3
    ) as sr
    on sr.mobile=sms.mobile
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


