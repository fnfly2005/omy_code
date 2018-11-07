#!/bin/bash
#分平台流量销售
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

spo=`fun detail_myshow_salepayorder.sql u` 
md=`fun myshow_dictionary.sql`

file="xk03"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    sp1.dt,
    sp1.pt,
    uv,
    totalprice,
    order_num,
    ticket_num,
    grossprofit
from (
    select
        sp0.dt,
        md.value2 as pt,
        sum(sp0.order_num) as order_num,
        sum(sp0.totalprice) as totalprice,
        sum(ticket_num) as ticket_num,
        sum(grossprofit) as grossprofit
    from (
        select
            partition_date as dt,
            sellchannel,
            sum(totalprice) as totalprice,
            count(distinct order_id) as order_num,
            sum(salesplan_count*setnumber) as ticket_num,
            sum(grossprofit) as grossprofit
        $spo
        group by
            partition_date,
            sellchannel
        ) as sp0
        left join
        (
        $md
        and key_name='sellchannel'
        ) as md
        on sp0.sellchannel=md.key
    group by
        sp0.dt,
        md.value2
    ) as sp1
    left join (
    select
        fpw.dt,
        case when md.value2 is null then '其他'
        else md.value2 end as pt,
        sum(fpw.uv) as uv
    from (
        select
            partition_date as dt,
            app_name,
            count(distinct union_id) as uv
        from
            mart_flow.detail_flow_pv_wide_report
        where partition_date>='\$\$begindate'
            and partition_date<'\$\$enddate'
            and partition_log_channel='movie'
            and partition_app in (
            'movie',
            'dpsensitive_nova',
            'other_app',
            'dp_m',
            'group'
            )
            and page_identifier in (
            select value
            from upload_table.myshow_pv
            where key='page_identifier'
            and page_tag1>=0
            )
        group by
            partition_date,
            app_name
        ) as fpw
        left join (
            $md
            and key_name='app_name'
            ) md
        on fpw.app_name=md.key
    group by
        fpw.dt,
        case when md.value2 is null then '其他'
        else md.value2 end
    ) as fp1
    on sp1.dt=fp1.dt
    and sp1.pt=fp1.pt
$lim">${attach}

echo "succuess!"
echo ${attach}
if [ ${1}r == pr ]
#加上任意字符，如r 避免空值报错
then
cat ${attach}
#命令行参数为p时，打印输出文件
fi
