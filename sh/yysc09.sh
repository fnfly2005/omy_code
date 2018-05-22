#!/bin/bash
#--------------------猫眼演出readme-------------------
#*************************详情页-来源/日期/平台/项目维/UV/销售数据*******************
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
path="/Users/fannian/Documents/my_code/"

fpw=`fun detail_flow_pv_wide_report.sql` 
md=`fun myshow_dictionary.sql`
per=`fun dim_myshow_performance.sql`
spo=`fun detail_myshow_salepayorder.sql u`

file="yysc09"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    case when md1.value2 is not null then md1.value2
    when fp.fromTag=0 then '其他'
    when fp.fromTag is null then '其他'
    else fp.fromTag end fromTag,
    fp.dt,
    fp.pt,
    per.performance_id,
    per.performance_name,
    sum(uv) uv,
    sum(totalprice) as totalprice,
    sum(order_num) order_num,
    sum(ticket_num) as ticket_num,
    sum(grossprofit) as grossprofit
from (
    select
        fromTag,
        fp1.dt,
        md2.value2 as pt,
        performance_id,
        sum(uv) as uv
    from (
        select
            case when page_identifier='c_Q7wY4' 
                then custom['fromTag']
            else utm_source
            end as fromTag,
            partition_date as dt,
            app_name,
            case when page_identifier<>'pages/show/detail/index'
                    then custom['performance_id']
                else custom['id'] end as performance_id,
            count(distinct union_id) as uv
        from 
            mart_flow.detail_flow_pv_wide_report
        where partition_date>='\$\$begindate'
            and partition_date<'\$\$enddate'
            and partition_log_channel='movie'
            and partition_app in (
            'movie',
            'dianping_nova',
            'other_app',
            'dp_m',
            'group'
            )
            and page_identifier in (
            'c_Q7wY4',
            'pages/show/detail/index'
            )
        group by
            1,2,3,4
        ) as fp1
        left join (
        $md
        and key_name='app_name'
        ) md2
        on fp1.app_name=md2.key
        and performance_id in (\$id)
    where
        performance_id in (\$id)
    group by
        1,2,3,4
    ) fp
    left join (
        select
            fromTag,
            dt,
            value2 as pt,
            performance_id,
            sum(totalprice) as totalprice,
			sum(order_num) order_num,
            sum(ticket_num) as ticket_num,
            sum(grossprofit) as grossprofit
        from (
            select
                fromTag,
                dt,
                sellchannel,
                performance_id,
                sum(totalprice) as totalprice,
                count(distinct fp2.order_id) as order_num,
                sum(ticket_num) as ticket_num,
                sum(grossprofit) as grossprofit
            from (
                select distinct
                    case when event_id='b_WLx9n' then custom['fromTag']
                    else utm_source
                    end as fromTag,
                    order_id
                from
                    mart_flow.detail_flow_mv_wide_report
                where partition_date>='\$\$begindate'
                    and partition_date<'\$\$enddate'
                    and partition_log_channel='movie'
                    and partition_etl_source='2_5x'
                    and partition_app in (
                    'movie',
                    'dianping_nova',
                    'other_app',
                    'dp_m',
                    'group'
                    )
                    and event_id in ('b_WLx9n','b_w047f3uw')
                ) as fp2
                join (
                    select
                        partition_date as dt,
                        sellchannel,
                        performance_id,
                        order_id,
                        sum(totalprice) as totalprice,
                        sum(salesplan_count*setnumber) as ticket_num,
                        sum(grossprofit) as grossprofit
                    $spo
                        and sellchannel in (1,2,3,5,6,7,13)
                        and performance_id in (\$id)
                    group by
                        1,2,3,4
                    ) spo
                on fp2.order_id=spo.order_id
            group by
                1,2,3,4
            ) as sdo
            left join (
                $md
                and key_name='sellchannel'
                ) md3
            on md3.key=sdo.sellchannel 
        group by
            1,2,3,4
        ) as sp
    on sp.fromTag=fp.fromTag
    and sp.dt=fp.dt
    and sp.pt=fp.pt
    and sp.performance_id=fp.performance_id
    left join (
        $md
            and key_name='fromTag'
        ) md1
    on fp.fromTag=md1.key
    join (
        $per
        and performance_id in (\$id)
        ) per
    on fp.performance_id=per.performance_id
group by
    1,2,3,4,5
$lim">${attach}

echo "succuess!"
echo ${attach}
if [ ${1}r == pr ]
#加上任意字符，如r 避免空值报错
then
cat ${attach}
#命令行参数为p时，打印输出文件
fi
