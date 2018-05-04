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

sod=`fun dp_myshow__s_orderdelivery.sql u`
so=`fun detail_myshow_saleorder.sql u`
md=`fun myshow_dictionary.sql`

file="bs30"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    dt,
    pt,
    ft,
    show_name,
    case when dif_min is null then '未取票'
        when dif_min='all' then 'all'
        when -cast(round(dif_min,0) as bigint)>=(\$hou*60) then '超时取票'
    else '正常取票' end as dif_tag,
    dif_hour,
    dif_min,
    order_num
from (
    select
        dt,
        pt,
        value2 as ft,
        show_name,
        case when 3=\$det then dif_min/60
        else dif_hour end dif_hour,
        case when 2=\$det then dif_hour*60
        else dif_min end dif_min,
        order_num
    from (
        select
            dt,
            value2 as pt,
            fetch_type,
            show_name,
            case when 2=\$det
                then date_diff('hour',pay_time,show_time)
            else 'all' end as dif_hour,
            case when 3=\$det
                then date_diff('minute',fetched_time,show_time)
            else 'all' end as dif_min,
            count(distinct so.order_id) as order_num
        from (
            select
                case when 1 in (\$dim) then substr(pay_time,1,10)
                else 'all' end as dt,
                case when 2 in (\$dim) then sellchannel
                else -99 end as sellchannel,
                fetch_type,
                case when 3 in (\$dim) then show_name
                else 'all' end as show_name,
                date_parse(pay_time,'%Y-%m-%d %H:%i:%s') as pay_time,
                date_parse(show_starttime,'%Y-%m-%d %H:%i:%s') as show_time,
                order_id
            $so
            and performance_id in (\$performance_id)
            and (fetch_type=4 or 1=\$det)
            ) so
            left join (
            select
                orderid as order_id,
                date_parse(fetchedtime,'%Y-%m-%d %H:%i:%s') as fetched_time
            $sod
            ) sod
            on sod.order_id=so.order_id
            left join (
            $md
            and key_name='sellchannel'
            ) md
            on md.key=so.sellchannel
        group by
            1,2,3,4,5,6
        ) sd
        left join (
        $md
        and key_name='fetch_type'
        ) md
        on md.key=sd.fetch_type
    ) as sen
$lim">${attach}

echo "succuess!"
echo ${attach}
if [ ${1}r == pr ]
#加上任意字符，如r 避免空值报错
then
cat ${attach}
#命令行参数为p时，打印输出文件
fi
