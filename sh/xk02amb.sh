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

spo=`fun detail_myshow_salepayorder.sql` 
mdk=`fun topic_movie_deal_kpi_daily.sql`
mp=`fun myshow_pv.sql u`
md=`fun myshow_dictionary.sql`

file="xk02"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    sp3.dt,
    sp3.bu,
    fp2.uv,
    sp3.order_num,
    sp3.ticket_num,
    sp3.totalprice
from (
    select
        dt,
        '平台' as bu,
        sum(order_num) order_num,
        sum(ticket_num) ticket_num,
        sum(totalprice) totalprice
    from (
        select
            spo.dt,
            '演出' as bu,
            count(distinct spo.order_id) as order_num,
            sum(spo.salesplan_count*spo.setnumber) as ticket_num,
            sum(spo.totalprice) as totalprice
        from
            (
            $spo
            and sellchannel=8
            ) spo
        group by
            1,2
        union all
        select
            dt,
            '电影' as bu,
            mdk.order_num,
            mdk.ticket_num,
            mdk.gmv as totalprice
        from (
            $mdk
            ) as mdk
        ) spp
    group by
        1,2
    union all
    select
        spo.dt,
        '演出' as bu,
        count(distinct spo.order_id) as order_num,
        sum(spo.salesplan_count*spo.setnumber) as ticket_num,
        sum(spo.totalprice) as totalprice
    from
        (
        $spo
        and sellchannel=8
        ) spo
    group by
        1,2
    union all
    select
        dt,
        '电影' as bu,
        mdk.order_num,
        mdk.ticket_num,
        mdk.gmv as totalprice
    from (
        $mdk
        ) as mdk
    ) as sp3
    left join (
        select
            partition_date as dt,
            '电影' as bu,
            count(distinct union_id) as uv
        from
            mart_flow.detail_flow_pv_wide_report
        where partition_date>='\$\$begindate'
            and partition_date<'\$\$enddate'
            and partition_log_channel='movie'
            and partition_app='other_app'
            and app_name='gewara'
            and page_identifier in (
                select
                    value
                $mp
                and page='native'
                and page_tag1=-2
                )
        group by
            1,2
        union all
        select
            partition_date as dt,
            '演出' as bu,
            count(distinct union_id) as uv
        from
            mart_flow.detail_flow_pv_wide_report
        where partition_date>='\$\$begindate'
            and partition_date<'\$\$enddate'
            and partition_log_channel='movie'
            and partition_app='other_app'
            and app_name='gewara'
            and page_identifier in (
                select
                    value
                $mp
                and page='native'
                and page_tag1=0
                )
        group by
            1,2
        union all
        select
            partition_date as dt,
            '平台' as bu,
            count(distinct union_id) as uv
        from
            mart_flow.detail_flow_pv_wide_report
        where partition_date>='\$\$begindate'
            and partition_date<'\$\$enddate'
            and partition_log_channel='movie'
            and partition_app='other_app'
            and app_name='gewara'
            and page_identifier in (
                select
                    value
                $mp
                and page='native'
                )
        group by
            1,2
    ) as fp2
    on sp3.dt=fp2.dt
    and sp3.bu=fp2.bu
$lim">${attach}


echo "succuess!"
echo ${attach}
if [ ${1}r == pr ]
#加上任意字符，如r 避免空值报错
then
cat ${attach}
#命令行参数为p时，打印输出文件
fi
